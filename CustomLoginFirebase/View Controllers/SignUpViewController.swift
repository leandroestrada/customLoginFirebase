//
//  SignUpViewController.swift
//  CustomLoginFirebase
//
//  Created by leandro de araujo estrada on 20/02/20.
//  Copyright © 2020 Leandro Estrada. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        
        // Do any additional setup after loading the view.
    }
    
    
    func setUpElements(){
        errorLabel.alpha = 0
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    //Check the fields and validate that the data is corret. If everything is correct, this method returns nil. Otherwise, it returns the error message
    func validateFields() -> String? {
        //Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ==  "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please fill in all fields"
        }
        
        //Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false{
            //Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number"
        }
        
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        //Validate the fields
        let error = validateFields()
        
        //There's something wrong with the fields, show error message
        if error != nil {
            showError(error!)
        }
        else{
            //Created cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                //Check for erros
                if err != nil{
                    print(err?.localizedDescription)
                    //There was an error creating the user
                    self.showError("Error creating the user")
                }
                else{
                    //User was created sucessfully, now store the first and last name
                    
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["first_name":firstName, "last_name":lastName, "uid": result!.user.uid ]) { (error) in
                        if error != nil {
                            //Show error message
                            self.showError("Error saving user data")
                        }
                    }
                    //Transition to the home screen
                    self.transitionToHome()

                }
            }
        }
        
    }
    
    func showError(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome(){
        
       let homeViewController =  storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
}
