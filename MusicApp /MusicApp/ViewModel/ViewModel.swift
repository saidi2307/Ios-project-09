
import UIKit

class ViewModel {

   static let shared = ViewModel()

   func getMyPlayList(completion: @escaping ([Playlist])->()) {

       FireStoreManager.shared.getPlaylists(forEmail: getEmail()) { playList in
            
           completion(playList)
       }
   }
    
    func getSharedPlayList(completion: @escaping ([Playlist])->()) {

        FireStoreManager.shared.getSharedPlaylists(forEmail: getEmail()) { playList in
             
            completion(playList)
        }
    }
    
    
    func getSongs(documentID:String,completion: @escaping ([Song])->()) {

        FireStoreManager.shared.getSongList(documentID:documentID) { songs in
            completion(songs)
        }
   }
    
    func deletePlayList(playList: Playlist, completion: @escaping (Bool) -> Void) {
            FireStoreManager.shared.deletePlaylist(documentID: playList.getDocumentId()) { success in
                if success {
                    print("Playlist deleted successfully")
                } else {
                    // Handle deletion failure, if needed
                    print("Error deleting playlist")
                }
                completion(success)
            }
        }
     
    
    
    func addPlayList(name:String,description:String,completion: @escaping ()->()) {
 
        FireStoreManager.shared.addPlaylist(name: name, description: description, email:  getEmail()) {
             
            completion()
        }
        
    }
    
    func editPlayList(name:String,description:String,documentId:String,completion: @escaping ()->()) {
 
        FireStoreManager.shared.editPlaylist(name: name, description: description, email:  getEmail(), documentId: documentId) {
             
            completion()
        }
        
    }
 
}
