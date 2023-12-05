 
import UIKit

class AddSongVC: UIViewController {
  
    @IBOutlet weak var songID: UITextField!
    @IBOutlet weak var songTitle: UITextField!
    @IBOutlet weak var songArtist: UITextView!
    
    var playListDocumentId = ""
    var playListName = ""
    
    
    @IBAction func onAdd(_ sender: Any) {
        
        if(self.songTitle.text!.isEmpty) {
            showAlerOnTop(message: "Song Title Require")
            return
        }
        
        if(self.songID.text!.isEmpty) {
            showAlerOnTop(message: "Song ID Require")
            return
        }
        
        if(self.songID.text!.contains("-")) {
            showAlerOnTop(message: "Song ID Not Supported, plz try another song")
            return
        }
        
        var artist = self.songArtist.text!

        if(self.songArtist.text!.isEmpty) {
            artist = "Unknown"
        }
        
        FireStoreManager.shared.addSongToPlaylist(playListName:playListName,documentId: playListDocumentId, songId: songID.text!, songTitle: songTitle.text!, artist: artist){
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
}
 
