//
//  LoginController.swift
//  TheApp
//
//  Created by Abhijeet Malamkar on 2/18/17.
//  Copyright © 2017 abhijeetmalamkar. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController , UITextFieldDelegate{

    var messagesController:MessagesController?
    
    let inputsContainerView:UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
       return view
    }()
    
    let loginRegisterButton:UIButton = {
       let button = UIButton()
       button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
       button.setTitle("Register", for: .normal)
       button.titleLabel?.textColor = .white
       button.layer.cornerRadius = 5
       button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
       button.translatesAutoresizingMaskIntoConstraints = false
       button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
       return button
    }()
    
    func handleLogin(){
        guard let email = emailTextField.text, let password = passwordTextField.text else{
            print("Format is not valid")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, Error) in
            if Error != nil {
               print(Error as Any)
            }
            
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            print(email + "Logged In")
            //check for password
           
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func handleLoginRegister(){
       if loginRegisterSegmentedController.selectedSegmentIndex == 0 {
          handleLogin()
        } else {
          handleRegister()
       }
    }
        
    let nameTextField:UITextField = {
        let field = UITextField()
        field.placeholder = "Name"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let seperatorView:UIView = {
       let view = UIView()
       view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
       view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    
    let emailTextField:UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let emailSeperatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var passwordTextField:UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    lazy var profileImageView:UIImageView = {
      let view = UIImageView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.layer.cornerRadius = 75
      view.clipsToBounds = true
      view.contentMode = .scaleAspectFill
      view.image = UIImage(named: "default_profile_photo")
      view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfile)))
      view.isUserInteractionEnabled = true
      view.backgroundColor = .white
      return view
    }()
      
    let loginRegisterSegmentedController:UISegmentedControl = {
       let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 1
        sc.tintColor = .white
        sc.addTarget(self, action: #selector(handleLoginRegisterChanges), for: .valueChanged)
       return sc
    }()
    
    func handleLoginRegisterChanges(){
        let title = loginRegisterSegmentedController.titleForSegment(at: loginRegisterSegmentedController.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height of input controller
        inputContainerHeightConstraint?.constant = loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 100 : 150
        nameTextFieldHeightConstraint?.isActive = false
        nameTextFieldHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightConstraint?.isActive = true
        
        emailTextFieldHeightConstraint?.isActive = false
        emailTextFieldHeightConstraint = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightConstraint?.isActive = true
        
        passwordTextFieldHeightConstraint?.isActive = false
        passwordTextFieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedController.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightConstraint?.isActive = true
        
        
        nameTextField.isHidden = loginRegisterSegmentedController.selectedSegmentIndex == 0 ? true : false
        //seperatorView.isHidden = loginRegisterSegmentedController.selectedSegmentIndex == 0 ? true : false

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        view .addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedController)
        
        setupInputsContainer()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControll()
    }
    
    func setupLoginRegisterSegmentedControll(){
    
        loginRegisterSegmentedController.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedController.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedController.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedController.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
    }
    
    func setupProfileImageView(){
    
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedController.topAnchor, constant: -12).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    
    }
    
    var inputContainerHeightConstraint:NSLayoutConstraint?
    var nameTextFieldHeightConstraint:NSLayoutConstraint?
    var emailTextFieldHeightConstraint:NSLayoutConstraint?
    var passwordTextFieldHeightConstraint:NSLayoutConstraint?
    
    func setupInputsContainer(){
       
        //need contsraints for container view
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputContainerHeightConstraint = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerHeightConstraint?.isActive = true

        inputsContainerView.addSubview(nameTextField)
        
        //contraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightConstraint = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightConstraint?.isActive = true
        
        inputsContainerView.addSubview(seperatorView)
        
        //contraints
        seperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        seperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        seperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //contraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightConstraint = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightConstraint?.isActive = true
        
        //contraints
        emailSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //contraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightConstraint = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightConstraint?.isActive = true
        
    }
    
    func setupLoginRegisterButton(){
    
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
