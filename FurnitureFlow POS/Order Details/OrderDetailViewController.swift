//
//  OrderDetailViewController.swift
//  POS
//
//  Created by Maaz on 11/10/2024.
//

import UIKit
import PDFKit

class OrderDetailViewController: UIViewController {

    @IBOutlet weak var discountLabel: UILabel!

    @IBOutlet weak var updateAmountLabel: UILabel!
    @IBOutlet weak var firstInstallmentLbl: UILabel!
    @IBOutlet weak var advancePayLabel: UILabel!
    @IBOutlet weak var inCashLabel: UILabel!
    @IBOutlet weak var paymentTypeLbl: UILabel!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var dateOfOrderLbl: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var pdfView: UIView!
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var Paid_InstLabel: UILabel!
    @IBOutlet weak var AddInst_Btn: UIButton!
    
    @IBOutlet weak var installmentNoTF: UITextField!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var dateOfPayTf: UITextField!
    
    var selectedOrderDetail: Ordered?
    
  

    // Array to store installment details
    var installments: [(installmentNo: String, amount: String, date: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"
        

        if let orderDetail = selectedOrderDetail {
            // Assigning values as per your existing logic
            orderNoLabel.text = orderDetail.orderNo
            userNameLabel.text = orderDetail.user
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: orderDetail.DateOfOrder)
            dateOfOrderLbl.text = dateString
            
            productNameLbl.text = orderDetail.product
            paymentTypeLbl.text = orderDetail.paymentType
            inCashLabel.text =  "\(currency) \(orderDetail.amount)"
            advancePayLabel.text = "\(currency) \(orderDetail.advancePaymemt)" 
            firstInstallmentLbl.text = "\(currency) \(orderDetail.firstInstallment)"
            updateAmountLabel.text = "\(currency) \( orderDetail.nowAmount)"
            discountLabel.text = "\( orderDetail.Discount)%"
            
            // Check the payment type and hide/show the labels and button
            if orderDetail.paymentType.lowercased() == "cash" {
                Paid_InstLabel.isHidden = true
                AddInst_Btn.isHidden = true
            } else {
                Paid_InstLabel.isHidden = false
                AddInst_Btn.isHidden = false
                
                // Automatically add first installment if available and not empty
                if !orderDetail.firstInstallment.isEmpty {
                    let firstInstallmentData = (installmentNo: "1st Installment", amount: orderDetail.firstInstallment, date: dateString) // assuming dateString is the order date
                    installments.append(firstInstallmentData)
                }
            }
            
          
        }
        
        // Setup date picker
        setupDatePicker(for: dateOfPayTf, target: self, doneAction: #selector(donePressed))
        
        // Set up table view delegate and data source
        TableView.delegate = self
        TableView.dataSource = self
        
        // Load saved installments
        loadInstallmentsFromUserDefaults()
        
        // Reload table view to reflect any initial data
        TableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"

    }
    @objc func donePressed() {
           // Get the date from the picker and set it to the text field
           if let datePicker = dateOfPayTf.inputView as? UIDatePicker {
               let dateFormatter = DateFormatter()
               dateFormatter.dateStyle = .medium
               dateFormatter.timeStyle = .none
               dateOfPayTf.text = dateFormatter.string(from: datePicker.date)
           }
           // Dismiss the keyboard
        dateOfPayTf.resignFirstResponder()
       }
    func showPopViewWithAnimation() {
        popView.isHidden = false // Ensure the view is visible
        
        // Initial state before animation
        popView.alpha = 0.0 // Start fully transparent
        popView.transform = CGAffineTransform(translationX: 0, y: 100) // Start slightly below its final position
        
        // Animation to fade in and slide up
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.popView.alpha = 1.0 // Fade in
            self.popView.transform = CGAffineTransform.identity // Slide up to its original position
        }, completion: nil)
    }
    
    func hidePopViewWithAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.popView.alpha = 0.0 // Fade out
            self.popView.transform = CGAffineTransform(translationX: 0, y: 100) // Slide down
        }, completion: { _ in
            self.popView.isHidden = true // Hide after animation completes
        })
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func CancelButton(_ sender: Any) {
        popView.isHidden = true
        hidePopViewWithAnimation()
    }
    @IBAction func AddInnstallmentButton(_ sender: Any) {
        popView.isHidden = false
        showPopViewWithAnimation()
    }
    @IBAction func DoneButton(_ sender: Any) {
        // Validate that all text fields are filled
          guard let installmentNo = installmentNoTF.text, !installmentNo.isEmpty,
                let amount = amountTF.text, !amount.isEmpty,
                let date = dateOfPayTf.text, !date.isEmpty else {
              // Show alert if fields are empty
              showAlert("Please fill all the fields")
              return
          }

          // Add the new installment data to the array
          let newInstallment = (installmentNo: installmentNo, amount: amount, date: date)
          installments.append(newInstallment)

          // Reload the table view to display the new entry
          TableView.reloadData()

          // Clear the text fields after adding data
          installmentNoTF.text = ""
          amountTF.text = ""
          dateOfPayTf.text = ""

          // Hide the pop-up view
          popView.isHidden = true

          // Save installments to UserDefaults
          saveInstallmentsToUserDefaults()
    }
    
    
    @IBAction func PdfGenerateButton(_ sender: Any) {
        let pdfData = createPDF(from: pdfView)
        savePdf(data: pdfData)
    }
    
    // Function to save installments to UserDefaults
    func saveInstallmentsToUserDefaults() {
        guard let orderId = selectedOrderDetail?.orderNo else { return }

        // Convert the installments array of tuples to an array of dictionaries
        let installmentDicts = installments.map { installment in
            return ["installmentNo": installment.installmentNo, "amount": installment.amount, "date": installment.date]
        }

        // Save the array of dictionaries in UserDefaults using the orderId as the key
        UserDefaults.standard.set(installmentDicts, forKey: orderId)
    }

    // Function to load installments from UserDefaults
    func loadInstallmentsFromUserDefaults() {
        guard let orderId = selectedOrderDetail?.orderNo else { return }

        // Retrieve the array of dictionaries from UserDefaults
        if let savedInstallments = UserDefaults.standard.array(forKey: orderId) as? [[String: String]] {
            // Convert dictionaries back to tuples and assign them to the installments array
            installments = savedInstallments.map { dict in
                return (installmentNo: dict["installmentNo"] ?? "", amount: dict["amount"] ?? "", date: dict["date"] ?? "")
            }
        }
    }
    // Function to show an alert
       func showAlert(_ message: String) {
           let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
    // Function to create PDF from the view
    func createPDF(from view: UIView) -> Data {
        let pdfPageFrame = view.bounds
        let pdfData = NSMutableData()
        
        // Create the PDF context
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        
        // Render the view into the PDF context
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return Data() }
        view.layer.render(in: pdfContext)
        
        // Close the PDF context
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
    // Function to save the PDF data to the device
    func savePdf(data: Data) {
        // Specify the file path and name
        let fileName = "OrderDetail.pdf"
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            // Write the PDF data to the file
            do {
                try data.write(to: fileURL)
                print("PDF saved at: \(fileURL)")
                
                // Present sharing options for the saved PDF
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
                
            } catch {
                print("Could not save PDF file: \(error.localizedDescription)")
            }
        }
    }
}
extension OrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // Number of rows is based on the number of installments
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return installments.count
    }
    
    // Configure each cell with the corresponding installment data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "installmentCell", for: indexPath) as! installmentTableViewCell
        
        // Get the corresponding installment
        let installment = installments[indexPath.row]
        
        // Assign values to the cell's labels
        cell.installmentNo.text = installment.installmentNo
        cell.payAmount.text =  "\(currency) \(installment.amount)" 
        cell.dateLabel.text = installment.date
        
        return cell
    }
    
    // Set the row height (optional, for better UI control)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the installment from the array
            installments.remove(at: indexPath.row)
            
            // Save the updated array to UserDefaults
            saveInstallmentsToUserDefaults()
            
            // Delete the row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

