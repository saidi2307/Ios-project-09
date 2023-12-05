//
//  EditProfileVC.swift
//  MusicApp
//
 
import UIKit

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var textFiledName: UITextField!
    @IBOutlet weak var username: UITextField!

    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var dob: UITextField!
    @IBOutlet weak var male: UIButton!
    @IBOutlet weak var female: UIButton!

    let datePicker = UIDatePicker()
    var gender = ""
    var password = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getProfileData()
        previewImage.layer.cornerRadius = previewImage.frame.height/2
        previewImage.clipsToBounds = true
        
        datePicker.maximumDate = Date()
        self.dob.inputView =  datePicker
        self.showDatePicker()
        
        male.setImage(UIImage(named: "circle"), for: .normal)
        male.setImage(UIImage(named: "fillCircle"), for: .selected)
        
        female.setImage(UIImage(named: "circle"), for: .normal)
        female.setImage(UIImage(named: "fillCircle"), for: .selected)

    }
    
    @IBAction func onMaleFemaleClick(_ sender: UIButton){
        
        if sender == male{
            male.isSelected = true
            female.isSelected = false
            gender = "male"
        }else{
            male.isSelected = false
            female.isSelected = true
            gender = "female"
        }
        
    }
    
    func validate() ->Bool {
        
        if(self.textFiledName.text!.isEmpty) {
             showAlerOnTop(message: "Please enter name.")
            return false
        }
       
        if(self.gender == "") {
            showAlerOnTop(message: "Please select gender")
           return false
       }
        
        if(self.dob.text!.isEmpty) {
            showAlerOnTop(message: "Please enter dob.")
           return false
       }
        
        return true
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        
        
        showConfirmationAlert(message: "Are you sure want to logout?") { _ in
            
            FireStoreManager.shared.removeAllListeners()
            
            if let window = UIApplication.shared.keyWindow,
               let existingPlayerView = window.viewWithTag(1001) as? FloatingAudioPlayerView {
                existingPlayerView.removeFromSuperview()
            }
            
            
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach{key in   defaults.removeObject(forKey: key)}
            
            SceneDelegate.shared?.loginCheckOrRestart()
        }
        
    }
    
    
    @IBAction func onUpdate(_ sender: Any) {
    
        if validate(){
            let userdata = ["email": getEmail(), "name": self.textFiledName.text ?? "", "gender": self.gender, "password": self.password, "dob": self.dob.text ?? ""]
            
            FireStoreManager.shared.updateProfile(documentid: getDocumentId(), userData: userdata) { success in
                if success {
                    showAlerOnTop(message: "Profile Updated Successfully")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    func getProfileData(){
        FireStoreManager.shared.getProfile(email: UserDefaultsManager.shared.getEmail()) { querySnapshot in
            
            print(querySnapshot.documents)
            for (_,document) in querySnapshot.documents.enumerated() {
                do {
                    
                    let item = try document.data(as: UserDataModel.self)

                    self.textFiledName.text = item.name
                    self.username.text = item.email
                    self.dob.text = item.dob

                    self.gender = item.gender ?? ""
                    self.password = item.password ?? ""
                    
                    if item.gender == "male" {
                        self.male.isSelected = true
                    } else {
                        self.female.isSelected = true
                    }
                    
                }catch let error {
                    print(error)
                }
            }
        
        }
    }
}

extension EditProfileVC {
        func showDatePicker() {
            //Formate Date
            datePicker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                datePicker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            //ToolBar
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
            
            //done button & cancel button
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneHolydatePicker))
            doneButton.tintColor = .black
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelDatePicker))
            cancelButton.tintColor = .black
            toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
            
            // add toolbar to textField
            dob.inputAccessoryView = toolbar
            // add datepicker to textField
            dob.inputView = datePicker
            
        }
        
        @objc func doneHolydatePicker() {
            //For date formate
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            dob.text = formatter.string(from: datePicker.date)
            //dismiss date picker dialog
            self.view.endEditing(true)
        }
        
        @objc func cancelDatePicker() {
            self.view.endEditing(true)
        }

}
