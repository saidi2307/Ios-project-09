//
//  SongsDetailsVC.swift
//  MusicApp
//
 

import UIKit

class SongsDetailsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    var playlist: Playlist?
    var songs : [Song] = []
    @IBOutlet weak var numberOfSongs: UILabel!
    @IBOutlet weak var playListTitle: UILabel!
    var moveFrom = ""
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        stackView.isHidden = true
        self.tableView.registerCells([CommonCell.self])
       
        if let playlist = playlist {
            
            self.playListTitle.text = playlist.name.capitalized
            
            if (!playlist.getDocumentId().isEmpty) {
                
                self.getSongs()
            }
        }
        
        if(self.moveFrom == "Shared"){
           // self.addBtn.isHidden = true
          //  self.shareBtn.isHidden = true
        }
    }
     
    @IBAction func onShare(_ sender: Any) {
        
        // Create an alert controller
              let alertController = UIAlertController(title: "Enter Email", message: "Please enter user email address", preferredStyle: .alert)

              // Add a text field to the alert controller
              alertController.addTextField { (textField) in
                  textField.placeholder = "Email"
              }

              // Create an action for the "OK" button
             let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                  // Get the entered email from the text field
                  if let email = alertController.textFields?.first?.text {
                      // Print the entered email
                      print("Email entered: \(email)")
 
                      if(!email.isEmpty)  {
                          
                      FireStoreManager.shared.sharePlaylist(playListId: playlist?.getDocumentId() ?? "", shareToEmail: email.lowercased())
                           
                      }
                  }
              }

              // Create an action for the "Cancel" button
              let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

              // Add the actions to the alert controller
              alertController.addAction(okAction)
              alertController.addAction(cancelAction)

              // Present the alert controller
              present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func onAddMusic(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "AddSongVC" ) as! AddSongVC
        vc.playListDocumentId = self.playlist?.getDocumentId() ?? ""
        vc.playListName =  self.playlist?.name ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func getSongs() {
        
        ViewModel.shared.getSongs(documentID: self.playlist?.getDocumentId() ?? "") { songs in
            
            if(songs.isEmpty){
                self.stackView.isHidden = false
            }else {
                self.stackView.isHidden = true
            }
            self.songs = songs
            self.numberOfSongs.text = "\(self.songs.count ) Songs"
            self.tableView.reloadData()
            
        }
       
    }
    
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = self.songs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath) as! CommonCell
        cell.setData(name: list.title.capitalized, desc: list.artist.capitalized)
        cell.playButton.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let song = self.songs[indexPath.row]
        
        PlayerController.shared.addPlayer(song: song)
       
    }
}


 
