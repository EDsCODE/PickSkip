//
//  ComposeMessageViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/11/17.
//
//

import UIKit
import Contacts

class ComposeMessageViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var selectedContactsTextField: UITextField!
    
    @IBOutlet weak var yearButton: UIButton!
    
    
    
    
    let contacts: [CNContact] = {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        
        var allContainers : [CNContainer] = []
        do {
            allContainers = try store.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results : [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    var selectedContacts : [String] = []
    
    let months : [String] = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ]
    
    var monthCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedContactsTextField.delegate = self
        
        for contact in contacts {
            selectedContacts.append(contact.givenName + " " + contact.familyName)
        }
        
        
        
        yearButton.frame.size = CGSize(width: 152, height: 54)
        yearButton.layer.borderWidth = 1.5
        yearButton.layer.borderColor = UIColor(colorLiteralRed: 0, green: 117.0/255.0, blue: 231.0/255.0, alpha: 1).cgColor
        yearButton.layer.cornerRadius = 10
        let attributedTitle = NSMutableAttributedString(string: months[monthCount], attributes: [NSForegroundColorAttributeName : UIColor(colorLiteralRed: 0, green: 117.0/255.0, blue: 231.0/255.0, alpha: 1)])
        attributedTitle.addAttribute(NSKernAttributeName, value: 1.15, range: NSRange(location: 0, length: attributedTitle.length - 1))
        yearButton.setAttributedTitle(attributedTitle, for: .normal)
        yearButton.addTarget(self, action: #selector(pressed(sender:)), for: .touchUpInside)
        yearButton.titleLabel?.font = UIFont(name: "SFProText-Light", size: 25)
        // Do any additional setup after loading the view.
    }
    
    func setupButton(nameOfButton: String) {
        
    }
    
    func pressed(sender: UIButton) {
        if monthCount < 11 {
            monthCount += 1
            let attributedTitle = NSMutableAttributedString(string: months[monthCount], attributes: [NSForegroundColorAttributeName : UIColor(colorLiteralRed: 0, green: 117.0/255.0, blue: 231.0/255.0, alpha: 1)])
            yearButton.setAttributedTitle(attributedTitle, for: .normal)
        }
        else {
            monthCount = 0
            let attributedTitle = NSMutableAttributedString(string: months[monthCount], attributes: [NSForegroundColorAttributeName : UIColor(colorLiteralRed: 0, green: 117.0/255.0, blue: 231.0/255.0, alpha: 1)])
            yearButton.setAttributedTitle(attributedTitle, for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectedContactsTextField.resignFirstResponder()
        
        return true
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
