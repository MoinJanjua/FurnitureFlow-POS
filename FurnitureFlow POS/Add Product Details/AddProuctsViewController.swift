//
//  AddProuctsViewController.swift
//  POS
//
//  Created by Maaz on 10/10/2024.
//

import UIKit

class AddProuctsViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var UpdateButton: UIButton!
    @IBOutlet weak var CurrenyDateTF: UITextField!
    @IBOutlet weak var productPriceTF: UITextField!
    @IBOutlet weak var productQuantityTF: UITextField!
    @IBOutlet weak var productNameTF: UITextField!
    @IBOutlet weak var Image: UIImageView!
    
    private var datePicker: UIDatePicker?
    var pickedImage = UIImage()
    var productName = String()
    
    private var numberPicker = UIPickerView()
    private let numbers = Array(1...1000) // Array of numbers from 1 to 100
    private var activeTextField: UITextField?
    
    var selectedCustomerDetail: Products?
    var selectedIndex: Int?

       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userDetail = selectedCustomerDetail {
            Image.image = userDetail.pic
            productNameTF.text = userDetail.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium // Adjust date style as needed
            dateFormatter.timeStyle = .none
            
            if let dateOfBirth = userDetail.DateOfAdd as? Date {
                CurrenyDateTF.text = dateFormatter.string(from: dateOfBirth)
            } else if let dateOfBirthString = userDetail.DateOfAdd as? String {
                // If dateofbirth is already a String, just assign it
                CurrenyDateTF.text = dateOfBirthString
            }
           productQuantityTF.text = userDetail.quantities
            productPriceTF.text = userDetail.price
            
           
        }
        if let index = selectedIndex {
            UpdateButton.setTitle("Update", for: .normal)
        }
        //    imagePiker Works
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        Image.isUserInteractionEnabled = true
        Image.addGestureRecognizer(tapGesture)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture2.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture2)
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"
        
        setupNumberPicker(for: productQuantityTF)
        setupDatePicker(for: CurrenyDateTF, target: self, doneAction: #selector(donePressedoddatepick))

    }
    @objc func hideKeyboard()
      {
          view.endEditing(true)
      }
    @objc func donePressedoddatepick() {
        // Get the date from the picker and set it to the text field
        if let datePicker = CurrenyDateTF.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Same format as in convertStringToDate
            CurrenyDateTF.text = dateFormatter.string(from: datePicker.date)
        }
        // Dismiss the keyboard
        CurrenyDateTF.resignFirstResponder()
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
    
    // MARK: - UITextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
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
    func clearTextFields() {
        productPriceTF.text = ""
        productQuantityTF.text = ""
        productNameTF.text = ""
        CurrenyDateTF.text = ""

        Image.image = nil  // Clear the image
    }

    //ImagePicker Works
    @objc func imageViewTapped() {
        openGallery()
    }
    func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func yourFunctionToTriggerImagePicker() {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let pickedImage = info[.originalImage] as? UIImage {
               picker.dismiss(animated: true) {
                   self.pickedImage = pickedImage
                   self.Image.image = pickedImage
               }
           }
       }
    
    func saveProductsData(_ sender: Any) {
        // Check if any of the text fields are empty
        guard let productName = productNameTF.text, !productName.isEmpty,
              let productQuantity = productQuantityTF.text, !productQuantity.isEmpty,
              let productPrice = productPriceTF.text, !productPrice.isEmpty
        else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        // Check if an image is selected
        guard let pics = Image.image else {
            showAlert(title: "Error", message: "Please add a product picture.")
            return
        }
        
        guard let imageData = pics.jpegData(compressionQuality: 1.0) else {
            showAlert(title: "Error", message: "Error processing the image.")
            return
        }
        
        // Check and set the current date if the text field is empty
        if CurrenyDateTF.text?.isEmpty ?? true {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy" // Ensure the format matches your requirement
            CurrenyDateTF.text = dateFormatter.string(from: Date()) // Set current date
        }
        
        let CurrentDate = CurrenyDateTF.text ?? ""
        
        let randomCharacter = generateProductNumber()
        let newDetail = Products(
            id: "\(randomCharacter)",
            picData: imageData,
            name: productName,
            price: productPrice,
            quantities: productQuantity,
            DateOfAdd: convertStringToDate(CurrentDate) ?? Date()
        )
        // Check if editing or creating new entry
        if let index = selectedIndex {
            updateSavedData(newDetail, at: index) // Update existing entry
        } else {
            saveProductDetail(newDetail) // Save new entry
        }
       // saveProductDetail(newDetail)
    }

    // Function to update existing data
    func updateSavedData(_ updatedTranslation: Products, at index: Int) {
        if var savedData = UserDefaults.standard.array(forKey: "ProductDetails") as? [Data] {
            let encoder = JSONEncoder()
            do {
                let updatedData = try encoder.encode(updatedTranslation)
                savedData[index] = updatedData // Update the specific index
                UserDefaults.standard.set(savedData, forKey: "ProductDetails")
            } catch {
                print("Error encoding data: \(error.localizedDescription)")
            }
        }
        showAlert(title: "Updated", message: "Your Event Has Been Updated Successfully.")
    }
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy" // Corrected year format
        return dateFormatter.date(from: dateString)
    }
    
    func saveProductDetail(_ product: Products) {
        var products = UserDefaults.standard.object(forKey: "ProductDetails") as? [Data] ?? []
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(product)
            products.append(data)
            UserDefaults.standard.set(products, forKey: "ProductDetails")
            clearTextFields()
           
        } catch {
            print("Error encoding medication: \(error.localizedDescription)")
        }
        showAlert(title: "Done", message: "Product Detail has been Saved successfully.")
    }
    
    @IBAction func CurrencyBtn(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "CurrencyViewController") as! CurrencyViewController
        newViewController.modalPresentationStyle = .fullScreen
        newViewController.modalTransitionStyle = .crossDissolve
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        saveProductsData(sender)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }

}
