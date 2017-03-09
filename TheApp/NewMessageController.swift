//
//  NewMessageController.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/18/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewMessageController: UITableViewController {

    let cellId = "cellId"
    var users = [User]()
    var messagesController:MessagesController?
    var matchedUsers:[String:Int]? {
        didSet{
            print(filteredUsers)
        }
    }
    var filteredUsers = [[String:Int](),[String:Int](),[String:Int]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(matchedUsers)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser(){
        if let users = matchedUsers {
            for usr in users {
                FIRDatabase.database().reference().child("users").child(usr.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String:AnyObject] {
                        let user = User()
                        user.id = snapshot.key
                        user.setValuesForKeys(dictionary)
                        self.users.append(user)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }

        //Old code
//        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
//            
//            if let dictionary = snapshot.value as? [String:AnyObject] {
//                let user = User()
//                user.id = snapshot.key
//                user.setValuesForKeys(dictionary)
//                self.users.append(user)
//                
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            }
//            
//        }, withCancel: nil)
    }

    
    
    func handleCancel(){
       self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? UserCell
        let user = users[indexPath.item]
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        
        if let userProfileImageurl = user.profile_image_url {
           cell?.profileImageView.loadImageUsingCacheUrlString(urlString: userProfileImageurl)
        }
        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.item]
            self.messagesController?.showChatController(user:user)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Rejected Users"
        default:
            return "Error"
        }
    }

}

