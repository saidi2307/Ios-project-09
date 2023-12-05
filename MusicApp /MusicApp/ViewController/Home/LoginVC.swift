//
//  LoginVC.swift
//  MusicApp
//
 

import UIKit

class LoginVC: UIViewController {

 
    
    
    @IBOutlet var txtEmail: UITextField!
    @IBOutlet var txtPassword: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
 
      
        if(txtEmail.text!.isEmpty) {
            showAlerOnTop(message: "Please enter your username.")
            return
        }

        if(self.txtPassword.text!.isEmpty) {
            showAlerOnTop(message: "Please enter your password.")
            return
        }
        else{
            FireStoreManager.shared.login(email: txtEmail.text?.lowercased() ?? "", password: txtPassword.text ?? "") { success in
                if success{
                        SceneDelegate.shared?.loginCheckOrRestart()
                }

            }
        }
        
    }
    

    @IBAction func btnRegisterTapped(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "SignUpVC" ) as! SignUpVC
                
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnForgotTapped(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "ForgotPassword" ) as! ForgotPassword
                
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
