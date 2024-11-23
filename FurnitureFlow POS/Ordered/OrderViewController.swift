//
//  OrderViewController.swift
//  POS
//
//  Created by Maaz on 09/10/2024.
//

import UIKit

class OrderViewController: UIViewController, UITextFieldDelegate , UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var UserTF: DropDown!
    @IBOutlet weak var ProductTF: DropDown!
    @IBOutlet weak var PaymentTF: DropDown!
    @IBOutlet weak var DateofOrder: UITextField!
    @IBOutlet weak var DiscountTF: UITextField!
    @IBOutlet weak var AmountTF: UITextField!
    @IBOutlet weak var AdvancePayTF: UITextField!
    @IBOutlet weak var CashView: UIView!
    @IBOutlet weak var InstallmentView: UIView!
    @IBOutlet weak var FirstInstallmentTF: UITextField!
    @IBOutlet weak var NowAmountTF: UITextField!
    
  //  var isFirstTimeTapped = true // Flag to track the first tap

    var pickedImage = UIImage()
    var Users_Detail: [User] = [] // Array of User model objects
    var products_Detail: [Products] = []
    
    var selectedOrderDetail: Products?
    private var numberPicker = UIPickerView()
    private let numbers = Array(1...1000) // Array of numbers from 1 to 100
    private var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userOrder = selectedOrderDetail {
            ProductTF.text = userOrder.name
            AmountTF.text = userOrder.price

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium // Adjust date style as needed
            dateFormatter.timeStyle = .none
            
            if let dateOfBirth = userOrder.DateOfAdd as? Date {
                DateofOrder.text = dateFormatter.string(from: dateOfBirth)
            } else if let dateOfBirthString = userOrder.DateOfAdd as? String {
                // If dateofbirth is already a String, just assign it
                DateofOrder.text = dateOfBirthString
            }
           
        }
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture2.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture2)
        
        setupDatePicker(for: DateofOrder, target: self, doneAction: #selector(donePressedDate))
        setupNumberPicker(for: DiscountTF)

        // Set circular style for image
//        makeImageViewCircular(imageView: Image)
        
        // PaymentTF Dropdown
        PaymentTF.optionArray = ["Cash", "Installments"]
        PaymentTF.didSelect { (selectedText, index, id) in
            self.PaymentTF.text = selectedText
            
            // Show or hide views based on selection
            if index == 0 { // Cash selected
                self.CashView.isHidden = false
                self.InstallmentView.isHidden = true
            } else if index == 1 { // Installments selected
                self.CashView.isHidden = true
                self.InstallmentView.isHidden = false
            }
        }
        PaymentTF.delegate = self

        // Handle UserTF delegate if needed
        UserTF.delegate = self
        ProductTF.delegate = self
        
        // Set delegates
          DiscountTF.delegate = self
          AmountTF.delegate = self
        
     //  NowAmountTF.delegate = self
//        DiscountTF.addTarget(self, action: #selector(discountTextFieldChanged), for: .editingChanged)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load data from UserDefaults for Users_Detail
        if let savedData = UserDefaults.standard.array(forKey: "UserDetails") as? [Data] {
            let decoder = JSONDecoder()
            Users_Detail = savedData.compactMap { data in
                do {
                    let user = try decoder.decode(User.self, from: data)
                    return user
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        
        // Set up the dropdown options for UserTF
        setUpUserDropdown()
        
        // Load data from UserDefaults for Users_Detail
        if let savedData = UserDefaults.standard.array(forKey: "ProductDetails") as? [Data] {
            let decoder = JSONDecoder()
            products_Detail = savedData.compactMap { data in
                do {
                    let user = try decoder.decode(Products.self, from: data)
                    return user
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                    return nil
                }
            }
        }
        // Set up the dropdown options for UserTF
        setUpProductsDropdown()
        
     // NowAmountTF.delegate = self
    }
//    @objc func discountTextFieldChanged() {
//        guard let amountText = AmountTF.text,
//              let discountText = DiscountTF.text,
//              let amount = Double(amountText),
//              let discount = Double(discountText) else {
//            return
//        }
//        
//        // Calculate the discounted amount
//        let discountAmount = amount * (discount / 100)
//        let finalAmount = amount - discountAmount
//        
//        // Update the AmountTF with the new discounted value
//        AmountTF.text = String(format: "%.2f", finalAmount)
//    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    @objc func donePressedDate() {
        // Get the date from the picker and set it to the text field
        if let datePicker = DateofOrder.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            DateofOrder.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        DateofOrder.resignFirstResponder()
    }
  
    func applyDiscount() {
          guard let amountText = AmountTF.text,
                let originalAmount = Double(amountText),
                let discountText = DiscountTF.text,
                let discountValue = Double(discountText) else {
              // Handle invalid input
              showAlert(title: "Invalid Input", message: "Please enter valid numbers in Amount and Discount fields.")
              return
          }

          // Calculate the discounted amount
          let discount = (originalAmount * discountValue) / 100
          let discountedAmount = originalAmount - discount

          // Update the AmountTF with discounted value
          AmountTF.text = String(format: "%.2f", discountedAmount)

          // Optional: Visual feedback for successful discount application
          DiscountTF.backgroundColor = .systemGreen.withAlphaComponent(0.2)
          AmountTF.backgroundColor = .systemGreen.withAlphaComponent(0.2)

          // Reset background colors after a delay
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
           
          }
      }

      // Optional: Reset discounted amount when DiscountTF is cleared
      func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          if textField == DiscountTF, string.isEmpty {
              // Reset to original amount when discount field is cleared
              if let originalAmount = Double(AmountTF.text ?? "0") {
                  AmountTF.text = String(format: "%.2f", originalAmount)
              }
          }
          return true
      }
    func setupNumberPicker(for textField: UITextField) {
        // Set up the UIPickerView
        numberPicker.delegate = self
        numberPicker.dataSource = self
        
        // Assign the picker to the text field's input view
        textField.inputView = numberPicker
        
        // Add toolbar with "Done" button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolbar
        
        // Set text field delegate and track the active text field
        textField.delegate = self
    }
    @objc func donePressed() {
        // Get the selected number from the picker and set it to the active text field
        if let textField = activeTextField {
            let selectedRow = numberPicker.selectedRow(inComponent: 0)
            textField.text = "\(numbers[selectedRow])"
            textField.resignFirstResponder()
        }
    }
    
    // UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        // Custom logic for specific fields
        if textField == NowAmountTF {
            showAlert(title: "Notice", message: "Please Add Amount after implementing the installments charges")
            textField.resignFirstResponder() // Prevents editing
        }
    }
    // Reset background color for AmountTF and DiscountTF when DiscountTF is cleared
    func textField2(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == DiscountTF, string.isEmpty {
            // Reset AmountTF when DiscountTF is cleared
            if let originalAmount = Double(AmountTF.text ?? "0") {
                AmountTF.text = String(format: "%.2f", originalAmount)
            }
        }
        return true
    }
    // MARK: - UITextField Delegate
    
  
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
        
        if textField == DiscountTF {
            applyDiscount()
        }
    }
    
    // MARK: - UIPickerView Data Source and Delegate Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numbers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(numbers[row])"
    }

    func makeImageViewCircular(imageView: UIImageView) {
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
    }

    func clearTextFields() {
        UserTF.text = ""
        ProductTF.text = ""
        PaymentTF.text = ""
        DateofOrder.text = ""
        AmountTF.text = ""
        AdvancePayTF.text = ""
        FirstInstallmentTF.text = ""
        NowAmountTF.text = ""
        DiscountTF.text = ""

    }

    // Set up User dropdown options from Users_Detail array
    func setUpUserDropdown() {
        // Check if Users_Detail array is empty
        if Users_Detail.isEmpty {
            // If no users are available, set the text field to "No user available"
            UserTF.text = "No user available please first add the user"
            UserTF.isUserInteractionEnabled = false // Disable interaction if no users are available
        } else {
            // Extract names from the Users_Detail array
            let userNames = Users_Detail.map { $0.name }
            
            // Assign names to the dropdown
            UserTF.optionArray = userNames
            
            // Enable interaction if users are available
            UserTF.isUserInteractionEnabled = true
            
            // Handle selection from dropdown
            UserTF.didSelect { (selectedText, index, id) in
                self.UserTF.text = selectedText
                print("Selected user: \(self.Users_Detail[index])") // Optional: Handle selected user
            }
        }
    }
    // Set up User dropdown options from Users_Detail array
    func setUpProductsDropdown() {
        // Check if Users_Detail array is empty
        if products_Detail.isEmpty {
            // If no users are available, set the text field to "No user available"
            ProductTF.text = "No product available please first add the product"
            ProductTF.isUserInteractionEnabled = false // Disable interaction if no users are available
        } else {
            // Extract names from the Users_Detail array
            let userNames = products_Detail.map { $0.name }
            
            // Assign names to the dropdown
            ProductTF.optionArray = userNames
            
            // Enable interaction if users are available
            ProductTF.isUserInteractionEnabled = true
            
            // Handle selection from dropdown
            ProductTF.didSelect { (selectedText, index, id) in
                self.ProductTF.text = selectedText
                print("Selected user: \(self.products_Detail[index])") // Optional: Handle selected user
            }
        }
    }




    func saveOrderData(_ sender: Any) {
        // Check if all mandatory fields are filled
        guard let user = UserTF.text, !user.isEmpty,
              let product = ProductTF.text, !product.isEmpty,
              let DateOr = DateofOrder.text, !DateOr.isEmpty,
              let payment = PaymentTF.text, !payment.isEmpty
        else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }

        // Declare variables to hold payment details
        var amounts: String? = nil
        var advancePayments: String? = nil
        var firstInstallments: String? = nil
        var nowAmounts: String? = nil
        var discounts: String? = nil


        // Handle payment type
        if payment == "Cash" {
            // Check if AmountTF is filled
            if let cashAmount = AmountTF.text, !cashAmount.isEmpty {
                amounts = cashAmount
            }
            if let discountsOnCash = DiscountTF.text {
                discounts = discountsOnCash
            }else {
                showAlert(title: "Error", message: "Please fill in the Amount field.")
                return
            }
        } else if payment == "Installments" {
            // Check if installment fields are filled
            if let advance = AdvancePayTF.text, !advance.isEmpty,
               let nowAmount = NowAmountTF.text, !nowAmount.isEmpty,
               let firstInstallment = FirstInstallmentTF.text {
                advancePayments = advance
                nowAmounts = nowAmount
                firstInstallments = firstInstallment /*?? "N/A"*/
            } else {
                showAlert(title: "Error", message: "Please enter all payment details.")
                return
            }
        }

        // Generate random character for order number
        let randomCharacter = generateOrderNumber()
        let CustomerId = generateCustomerId()

        // Create new order detail safely
        let newOrderDetail = Ordered(
            orderNo: "\(randomCharacter)", customerId: "\(CustomerId)",
            user: user,
            product: product,
            DateOfOrder: convertStringToDate(DateOr) ?? Date(),
            Discount: discounts ?? "Nil",
            paymentType: payment,
            amount: amounts ?? "N/A", // Use a default value if nil
            advancePaymemt: advancePayments ?? "N/A",
            firstInstallment: firstInstallments ?? "N/A",
            nowAmount: nowAmounts ?? "N/A"
        )
        
        // Save the order detail
        saveOrderDetail(newOrderDetail)
    }


    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Corrected year format
        return dateFormatter.date(from: dateString)
    }
    
    func saveOrderDetail(_ order: Ordered) {
        var orders = UserDefaults.standard.object(forKey: "OrderDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(order)
            orders.append(data)
            UserDefaults.standard.set(orders, forKey: "OrderDetails")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Done", message: "Order Detail has been Saved successfully.")
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        saveOrderData(sender)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
