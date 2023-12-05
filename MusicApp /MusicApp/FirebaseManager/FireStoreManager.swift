
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Firebase
import FirebaseFirestoreSwift


class FireStoreManager {
    
    public static let shared = FireStoreManager()
    var hospital = [String]()
    var notificationListeners: [ListenerRegistration] = []

    var db: Firestore!
    var dbRef : CollectionReference!
    var lastMessages : CollectionReference!
    var playListRef : CollectionReference!
    var notificationCollection : CollectionReference!
    var messageArray: [String] = [] {
           didSet {
               // Call a callback function here
               notificationVC?.reloadData()
           }
       }

    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        dbRef = db.collection("Users")
        playListRef = db.collection("PlayList")
        notificationCollection = db.collection("Notifications")
    }
    
    
    func getPlaylists(forEmail email: String, completion: @escaping ([Playlist]) -> Void) {
            IndicatorHud.show()

            playListRef.whereField("createdBy", isEqualTo: email.lowercased())
                .getDocuments { (snapshot, error) in
                    IndicatorHud.dismiss()

                    if let error = error {
                        showAlerOnTop(message: "Error getting playlists: \(error.localizedDescription)")
                        completion([])
                    } else if let snapshot = snapshot {
                        // Parse the playlist data from the snapshot
                        let playlists = snapshot.documents.compactMap { document -> Playlist? in
                            do {
                                var playlist = try document.data(as: Playlist.self)
                                playlist.setDocumentId(documetId: document.documentID)
                                return playlist
                            } catch {
                                print("Error decoding playlist: \(error.localizedDescription)")
                                return nil
                            }
                        }

                        completion(playlists)
                    } else {
                        showAlerOnTop(message: "Unknown error getting playlists.")
                        completion([])
                    }
            }
      }
    
    func deletePlaylist(documentID: String, completion: @escaping (Bool) -> Void) {
            IndicatorHud.show()

            playListRef.document(documentID).delete { error in
                IndicatorHud.dismiss()

                if let error = error {
                    showAlerOnTop(message: "Error deleting playlist: \(error.localizedDescription)")
                    completion(false)
                } else {
                    showAlerOnTop(message: "Playlist deleted successfully")
                    completion(true)
                }
            }
        }
    func clearNotifications() {
            // Clear notifications locally
           
        let notificationCollectionPath = notificationCollection.document(getEmail().lowercased()).collection("Notification")

        // Delete all documents in the "Notification" collection for the user
               notificationCollectionPath.getDocuments { (querySnapshot, error) in
                   if let error = error {
                       print("Error getting documents: \(error.localizedDescription)")
                       // Handle the error appropriately
                       return
                   }

                   for document in querySnapshot?.documents ?? [] {
                       // Delete each document
                       notificationCollectionPath.document(document.documentID).delete()
                   }
               }
        
        FireStoreManager.shared.messageArray.removeAll()
    }
    
    func getSongList(documentID: String, completion: @escaping ([Song]) -> Void) {
        IndicatorHud.show()

       
       let playListListner = playListRef.document(documentID).addSnapshotListener { [self] (snapshot, error) in
            IndicatorHud.dismiss()

            print(documentID)
            print(playListRef.description)
            
            if let error = error {
                showAlerOnTop(message: "Error listening for playlist changes: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                showAlerOnTop(message: "Playlist does not exist.")
                completion([])
                return
            }

      
                // Parse the playlist data
                guard let playlistData = snapshot.data(),
                      let songsData = playlistData["songs"] as? [[String: Any]] else {
                   // showAlerOnTop(message: "Song List Not Found")
                    completion([])
                    return
                }
                
                var songs: [Song] = []
                
                for item in songsData {
                                if let songId = item["songId"] as? String,
                                   let title = item["title"] as? String,
                                   let artist = item["artist"] as? String {
                                    let song = Song(songId: songId, title: title, artist: artist)
                                    songs.append(song)
                                }
               }
                
               completion(songs)
             
        }
        
        
        notificationListeners.append(playListListner)
    }

    
    func editPlaylist(name: String, description: String, email: String,documentId:String,completion: @escaping () -> Void) {
        
        let playlistData: [String: Any] = [
            "name": name.lowercased(),
            "description": description,
        ]
        
     
        playListRef.document(documentId).updateData(playlistData) { error in
               if let error = error {
                   print("Error updating document: \(error.localizedDescription)")
               } else {
                   print("Document successfully updated")
                   // Call the completion handler to indicate the update is complete
                   completion()
               }
           }
    }
    
    func addPlaylist(name: String, description: String, email: String,completion: @escaping () -> Void) {
        
        IndicatorHud.show()
        
        // Check if the playlist with the same name already exists for the user
        playListRef.whereField("name", isEqualTo: name.lowercased())
            .whereField("createdBy", isEqualTo: email.lowercased())
                   .getDocuments { (snapshot, error) in
        
          IndicatorHud.dismiss()
            if let error = error {
                 showAlerOnTop(message:"Error checking playlist existence: \(error.localizedDescription)")
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                // Playlist with the same name already exists for the user
                 showAlerOnTop(message:"Playlist with the same name already exists for the user.")
                // You can show an alert here
            } else {
                // Playlist does not exist, add a new one
                let playlistData: [String: Any] = [
                    "name": name.lowercased(),
                    "description": description,
                    "timestamp": FieldValue.serverTimestamp(),
                    "createdBy": email.lowercased(),
                    "sharedWith": [email.lowercased()]
                ]
                IndicatorHud.show()
                
                self.playListRef.addDocument(data: playlistData) { error in
                    IndicatorHud.dismiss()
                    if let error = error {
                         showAlerOnTop(message:"Error adding playlist: \(error.localizedDescription)")
                    } else {
                         showAlerOnTop(message:"Playlist added successfully")
                         completion()
                    }
                }
            }
        }
    }
    
    func addSongToPlaylist(playListName:String,documentId: String, songId: String, songTitle: String, artist: String,completion: @escaping () -> Void) {
        let songData: [String: Any] = [
            "songId": songId,
            "title": songTitle,
            "artist": artist
        ]

        IndicatorHud.show()
        
        // Update the "songs" array field in the playlist document
        playListRef.document(documentId).updateData([
            "songs": FieldValue.arrayUnion([songData])
        ]) { error in
            
            IndicatorHud.dismiss()
            
            if let error = error {
                 showAlerOnTop(message:"Error adding song to playlist: \(error.localizedDescription)")
            } else {
                showAlerOnTop(message: "Song added to playlist successfully")
                completion()
                
                // Notify users about the playlist update
                self.getPlaylistSubscribers(documentId: documentId) { subscribers in
                                for subscriber in subscribers {
                                    
                                    self.notifyUser(userEmail: subscriber, message: "Playlist \(playListName) updated: \(songTitle) by \(artist)")
                                }
                       }
            }
        }
    }
    
    
    func notifyUser(userEmail: String, message: String) {
        let notificationData: [String: Any] = [
            "userEmail": userEmail.lowercased(),
            "message": message,
            "timestamp": FieldValue.serverTimestamp()
        ]

        notificationCollection.document(userEmail.lowercased()).collection("Notification").addDocument(data: notificationData) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification added successfully")
            }
        }
    }
    
    func setupNotificationListener(forUserEmail userEmail: String, messageCallback: @escaping (String) -> Void) {
        let notificationCollectionPath = notificationCollection.document(userEmail.lowercased()).collection("Notification")

        let listener =  notificationCollectionPath.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                if let error = error {
                    print("Error listening for notifications: \(error.localizedDescription)")
                }
                return
            }

            for documentChange in snapshot.documentChanges {
                switch documentChange.type {
                case .added:
                    // Handle added notification
                  
                    let message = documentChange.document["message"] as? String ?? ""
                        print("Added Notification: \(message)")
                        self.messageArray.append(message)
                        messageCallback(message)
                 
                // You can also handle modified and removed notifications if needed
                case .modified:
                    print("Modified Notification")
                case .removed:
                    print("Removed Notification")
                }
            }
        }
        
        notificationListeners.append(listener)
    }

    func getPlaylistSubscribers(documentId: String, completion: @escaping ([String]) -> Void) {
        playListRef.document(documentId).getDocument { snapshot, error in
            if let error = error {
                print("Error getting playlist subscribers: \(error.localizedDescription)")
                completion([])
            } else if let snapshot = snapshot, let data = snapshot.data(), let subscribers = data["sharedWith"] as? [String] {
                completion(subscribers)
            } else {
                completion([])
            }
        }
    }
    
    
    
    
 
    func sharePlaylist(playListId: String, shareToEmail: String) {
        playListRef.document(playListId).updateData([
            "sharedWith": FieldValue.arrayUnion([shareToEmail.lowercased()])
        ]) { error in
            if let error = error {
                showAlerOnTop(message: "Error sharing playlist: \(error.localizedDescription)")
            } else {
                showAlerOnTop(message: "Playlist shared successfully")
            }
        }
    }
 
 

    
    func getSharedPlaylists(forEmail email: String, completion: @escaping ([Playlist]) -> Void) {
        IndicatorHud.show()

        // Query playlists where the sharedWith array contains the user's email
        playListRef.whereField("sharedWith", arrayContains: email.lowercased())
            .getDocuments { (snapshot, error) in
                IndicatorHud.dismiss()

                if let error = error {
                    showAlerOnTop(message: "Error getting shared playlists: \(error.localizedDescription)")
                    completion([])
                } else if let snapshot = snapshot {
                    // Parse the playlist data from the snapshot
                    let playlists = snapshot.documents.compactMap { document -> Playlist? in
                        
                        do {
                            var playlist = try document.data(as: Playlist.self)
                            playlist.setDocumentId(documetId: document.documentID)
                            return playlist
                        } catch {
                            print("Error decoding playlist: \(error.localizedDescription)")
                            return nil
                        }
                    }

                    completion(playlists)
                } else {
                    showAlerOnTop(message: "Unknown error getting shared playlists.")
                    completion([])
                }
        }
    }

    
    

        
    func getPlaylistDetails(forPlaylistId playlistId: String, completion: @escaping (Playlist?) -> Void) {
        // Query playListRef to get detailed data for the playlist
        playListRef.document(playlistId).getDocument { (document, error) in
            if let error = error {
                 showAlerOnTop(message:"Error getting playlist details: \(error.localizedDescription)")
                completion(nil)
            } else if let document = document, document.exists {
                // Convert Firestore document to a Playlist object (you need to define your Playlist model)
                do {
                    let playlist = try document.data(as: Playlist.self)
                    completion(playlist)
                } catch {
                     showAlerOnTop(message:"Error decoding playlist details: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                 showAlerOnTop(message:"Playlist document does not exist")
                completion(nil)
            }
        }
    }

    
    
    func signUp(email:String,name:String,password:String) {
        
        self.checkAlreadyExistAndSignup(name:name,email:email,password:password)
    }

    
    func login(email:String,password:String,completion: @escaping (Bool)->()) {
        let  query = db.collection("Users").whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, err) in
         
            if(querySnapshot?.count == 0) {
                showAlerOnTop(message: "Email not found!!")
            }else {

                for document in querySnapshot!.documents {
                    print("doclogin = \(document.documentID)")
                    UserDefaults.standard.setValue("\(document.documentID)", forKey: "documentId")

                    if let pwd = document.data()["password"] as? String{

                        if(pwd == password) {

                            let name = document.data()["name"] as? String ?? ""
                            let email = document.data()["email"] as? String ?? ""
                            let password = document.data()["password"] as? String ?? ""
                            
                            UserDefaultsManager.shared.saveData(name: name, email: email, password: password)
                            completion(true)

                        }else {
                            showAlerOnTop(message: "Password doesn't match")
                        }


                    }else {
                        showAlerOnTop(message: "Something went wrong!!")
                    }
                }
            }
        }
   }
    
    func getPassword(email:String,password:String,completion: @escaping (String)->()) {
        let  query = db.collection("Users").whereField("email", isEqualTo: email.lowercased())
        
        query.getDocuments { (querySnapshot, err) in
            
            if(querySnapshot?.count == 0) {
                showAlerOnTop(message: "Email id not found!!")
            }else {
                
                for document in querySnapshot!.documents {
                     showAlerOnTop(message:"doclogin = \(document.documentID)")
                    UserDefaults.standard.setValue("\(document.documentID)", forKey: "documentId")
                    if let pwd = document.data()["password"] as? String{
                        completion(pwd)
                    }else {
                        showAlerOnTop(message: "Something went wrong!!")
                    }
                }
            }
        }
    }
    
    func checkAlreadyExistAndSignup(name:String,email:String,password:String) {
        
        getQueryFromFirestore(field: "email", compareValue: email) { querySnapshot in
             
            print(querySnapshot.count)
            
            if(querySnapshot.count > 0) {
                showAlerOnTop(message: "This Email is Already Registerd!!")
            }else {
                
                // Signup
                
                let data = ["name":name,"email":email,"password":password] as [String : Any]
                
                self.addDataToFireStore(data: data) { _ in
                    
                  
                    showOkAlertAnyWhereWithCallBack(message: "Registration Success!!") {
                         
                        DispatchQueue.main.async {
                            SceneDelegate.shared?.loginCheckOrRestart()
                        }
                       
                    }
                    
                }
               
            }
        }
    }
    
    func getQueryFromFirestore(field:String,compareValue:String,completionHandler:@escaping (QuerySnapshot) -> Void){
        
        dbRef.whereField(field, isEqualTo: compareValue).getDocuments { querySnapshot, err in
            
            if let err = err {
                
                showAlerOnTop(message: "Error getting documents: \(err)")
                return
            }else {
                
                if let querySnapshot = querySnapshot {
                    return completionHandler(querySnapshot)
                }else {
                    showAlerOnTop(message: "Something went wrong!!")
                }
                
            }
        }
        
    }
    
    func addDataToFireStore(data:[String:Any] ,completionHandler:@escaping (Any) -> Void){
        let dbr = db.collection("Users")
        dbr.addDocument(data: data) { err in
            if let err = err {
                showAlerOnTop(message: "Error adding document: \(err)")
            } else {
                completionHandler("success")
            }
        }
    }
    
    func getProfile(email:String,completionHandler:@escaping (QuerySnapshot) -> Void) {
        let  query = db.collection("Users").whereField("email", isEqualTo: email)
        
        query.getDocuments { snap, error in
            
            if let _ = error {
                
            }else {
                
                if let querySnapshot = snap {
                    
                    return completionHandler(querySnapshot)
                }else {
                    showAlerOnTop(message: "Something went wrong!!")
                }
               
            }
           
        }
   }
    
    
    func updateProfile(documentid:String, userData: [String:String] ,completion: @escaping (Bool)->()) {
        let  query = db.collection("Users").document(documentid)
        
        query.updateData(userData) { error in
            if let error = error {
                print("Error updating Firestore data: \(error.localizedDescription)")
                // Handle the error
            } else {
                print("Profile data updated successfully")
                completion(true)
                // Handle the success
            }
        }
    }
    
    
    
    func removeAllListeners() {
           for listener in notificationListeners {
               listener.remove()
           }
           notificationListeners.removeAll()
       }
    
    
}

