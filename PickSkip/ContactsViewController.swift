//
//  ContactsViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/9/17.
//
//

import UIKit
import Contacts

class ContactsViewController: UITableViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Checking if phone number is available for the given contact.
        var contacts: [CNContact] = {
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
        for contact in contacts {
            if contact.phoneNumbers.count > 0 {
                print("\(contact.phoneNumbers[0].value.stringValue)")
            }
        }
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
