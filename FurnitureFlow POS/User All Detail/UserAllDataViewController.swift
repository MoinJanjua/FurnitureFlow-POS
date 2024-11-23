//
//  UserAllDataViewController.swift
//  AssetAssign
//
//  Created by Moin Janjua on 20/08/2024.
//

import UIKit

class UserAllDataViewController: UIViewController {
    
    @IBOutlet weak var cunstomerdataView: UIView!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var userContact: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var MianView: UIView!
    
    @IBOutlet weak var CallButton: UIButton! // Connect this button outlet
    
 
   // var selectedEmpAssignedThings: AssignItems?
//    var tasks = [String]()
    
    //var userID = [String]()
    
    var Users_Detail: [User] = []
    var selectedCustomerDetail: User?
  
    var currency = String()

    var selectedOrderDetail: Ordered?
    var order_Detail: [Ordered] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDropShadow(to: cunstomerdataView)
        
        TableView.delegate = self
        TableView.dataSource = self
   
        if let userDetail = selectedCustomerDetail {
            userPicture.image = userDetail.pic
            userName.text = userDetail.name
            userAddress.text = userDetail.Address
            userEmail.text = userDetail.email
            userContact.text = userDetail.contact
            genderLbl.text = userDetail.gender
           
        }
        makeImageViewCircular(imageView: userPicture)
        
        // Disable the Call button if the device can't make calls
//         if !UIApplication.shared.canOpenURL(URL(string: "tel://")!) {
//             CallButton.isEnabled = false
//         }
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currency = UserDefaults.standard.value(forKey: "currencyISoCode") as? String ?? "$"

        if let savedData = UserDefaults.standard.array(forKey: "OrderDetails") as? [Data] {
            let decoder = JSONDecoder()
            order_Detail = savedData.compactMap { data in
                do {
                    let order = try decoder.decode(Ordered.self, from: data)
                    return order
                } catch {
                    print("Error decoding medication: \(error.localizedDescription)")
                    return nil
                }
            }
          //   Now filter orders based on the current selected customer
    if let selectedCustomer = selectedCustomerDetail {
        let filteredOrders = order_Detail.filter { $0.user == selectedCustomer.name }
        order_Detail = filteredOrders // Update the order_Detail array with filtered results
                }
        }
     TableView.reloadData()
    }
     



    func makeImageViewCircular(imageView: UIImageView) {
           // Ensure the UIImageView is square
           imageView.layer.cornerRadius = imageView.frame.size.width / 2
           imageView.clipsToBounds = true
       }
    
    // Copy Works
    @objc func copyTextOfEmail() {
        if let text = userEmail.text {
            UIPasteboard.general.string = text
            self.showToast(message: "Copied", font: .systemFont(ofSize: 17.0))
        }
    }
    @objc func copyTextOfPhoneNumber() {
        if let text = userContact.text {
            UIPasteboard.general.string = text
            self.showToast(message: "Copied", font: .systemFont(ofSize: 17.0))
        }
    }
    
    func convertDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Adjust to the desired format
        return dateFormatter.string(from: date)
    }
   

    
    // Action for CallButton
      @IBAction func callUserContact(_ sender: UIButton) {
          guard let phoneNumber = userContact.text, !phoneNumber.isEmpty else {
              showAlert("Invalid Number", "No phone number available.")
              return
          }
          
          let formattedPhoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
          
          if let phoneURL = URL(string: "tel://\(formattedPhoneNumber)") {
              if UIApplication.shared.canOpenURL(phoneURL) {
                  UIApplication.shared.open(phoneURL)
              } else {
                  showAlert("Error", "This device cannot make phone calls.")
              }
          } else {
              showAlert("Error", "Invalid phone number format.")
          }
      }
    // Show an alert if needed
       func showAlert(_ title: String, _ message: String) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
    @IBAction func CopyEmailButton(_ sender: Any) {
        copyTextOfEmail()
    }
    
    @IBAction func CopyNumberButton(_ sender: Any) {
        copyTextOfPhoneNumber()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
extension UserAllDataViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order_Detail.count
    }
    
    // Configure the cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCell", for: indexPath) as! TableViewCell
        
        // recentProductCell
        
        let order = order_Detail[indexPath.row]
        
        // Set the product information to the cell labels
        cell.PaymentTypeLabel.text = order.paymentType
        cell.amountLabel.text = "\(currency)\(order.amount)"
        cell.productLabel.text = "Product: \(order.product)"  // Customize as per your 'Ordered' model
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: order.DateOfOrder)
        cell.dateLabe.text = dateString
        
    // cell.dateLabe.text = "Ordered On: \(order.orderDate)"
        
        return cell
    }
    
    // Optionally, set the height for each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90  // Adjust as per your design
    }
    
}

