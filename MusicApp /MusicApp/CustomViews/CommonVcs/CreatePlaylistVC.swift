//
//  CreatePlaylistVC.swift
//  MusicApp
//
 

import UIKit
class CreatePlaylistVC: UIViewController {
   
   @IBOutlet var txtName: UITextField!
   @IBOutlet var txtDescp: UITextView!
   var playlist:Playlist!
   var moveFrom = ""
   
   @IBOutlet weak var editButton: ButtonWithShadow!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      if(moveFrom == "Edit") {
         self.txtName.text = playlist.name
         self.txtDescp.text = playlist.description
         self.editButton.setTitle("Update", for: .normal)
      }
   }
   
   
   
   @IBAction func backBurron(_ sender: UIButton) {
      self.navigationController?.popViewController(animated: true)
   }
   
   
   
   
   @IBAction func btnCreatePlaylistTapped(_ sender: UIButton) {
     
      if(txtName.text!.isEmpty) {
         showAlerOnTop(message: "Please add playlist name")
         return
      }
      
      if(txtDescp.text!.isEmpty) {
         showAlerOnTop(message: "Please add description")
         return
      }
      
      
      if(moveFrom == "Edit") {
         ViewModel.shared.editPlayList(name: self.txtName.text!, description: self.txtDescp.text!, documentId: self.playlist.getDocumentId()) {
            self.navigationController?.popViewController(animated: true)
         }
         
      }else {
         
         ViewModel.shared.addPlayList(name: self.txtName.text!, description: self.txtDescp.text!) {
             
            self.navigationController?.popViewController(animated: true)
         }

      }
      
    
      
   }
   
}

    
  

 
