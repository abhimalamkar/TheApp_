//
//  LoginController+Handlers.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/18/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit
import Firebase


extension LoginController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func handleSelectProfile(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        //picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel Picker")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func handleRegister(){
        //print(123)
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else{
            print("Format is not valid")
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (FIRUser, error) in
            if error != nil{
                print(error as Any)
                return
            }
            
            let imageName = NSUUID().uuidString
            guard let uid = FIRUser?.uid else { return }
            
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
            //if let uploadData = UIImagePNGRepresentation((self.profileImageView.imageView?.image!)!) {
               storageRef.put(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil {
                  print(error as Any)
                    return
                }
                
                if let profileImageUrl = metaData?.downloadURL()?.absoluteString {
                    print("uploading")
                    let values = ["name":name,"email": email,"profile_image_url" : profileImageUrl]
                    self.regissterUserIntoDatabaseWithUid(uid: uid, values: values as [String : AnyObject])
                }
                
              })
            }
        })
    }
    
    private func regissterUserIntoDatabaseWithUid(uid:String,values:[String:AnyObject]){
        //successfully authenticated
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err as Any)
            }
            //self.messagesController?.fetchUserAndSetupNavBarTitle()
            let user = User()
            user.setValuesForKeys(values)
            self.messagesController?.setupNavBarWithUser(user: user)
            self.dismiss(animated: true, completion: nil)
            print("Updated user in Database!")
        })
    }

    //
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       
        var selectedImageFromPicker:UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] {
            selectedImageFromPicker = editedImage as? UIImage
        }
        else if let orignalImage = info[UIImagePickerControllerOriginalImage] {
            selectedImageFromPicker = orignalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
           profileImageView.image = selectedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
