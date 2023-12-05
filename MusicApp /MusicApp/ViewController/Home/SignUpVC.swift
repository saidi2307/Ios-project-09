//
//  SignUpVC.swift
//  MusicApp
//
 

import UIKit

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        if validate(){
            FireStoreManager.shared.signUp(email: self.email.text ?? "", name: self.username.text ?? "", password: self.password.text ?? "")
        }
        
    }

    @IBAction func onLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func validate() ->Bool {
        
        if(self.username.text!.isEmpty) {
            showAlerOnTop(message: "Please enter name.")
            return false
        }
        
        
        if(self.email.text!.isEmpty) {
            showAlerOnTop(message: "Please enter email.")
            return false
        }
        
        if !email.text!.emailIsCorrect() {
            showAlerOnTop(message: "Please enter valid email id")
            return false
        }
        
        if(self.password.text!.isEmpty) {
            showAlerOnTop(message: "Please enter password.")
            return false
        }
        
        return true
    }
}
