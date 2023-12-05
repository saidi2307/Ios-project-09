
import Foundation

func getEmail()->String {
   return  UserDefaultsManager.shared.getEmail().lowercased()
}

func getName()->String {
   return  UserDefaultsManager.shared.getName().capitalized
}

func getDocumentId()->String {
    return  UserDefaultsManager.shared.getDocumentId()
}

class UserDefaultsManager  {
   
   static  let shared =  UserDefaultsManager()
   
   func clearUserDefaults() {
       
       let defaults = UserDefaults.standard
       let dictionary = defaults.dictionaryRepresentation()

           dictionary.keys.forEach
           {
               key in   defaults.removeObject(forKey: key)
           }
   }
       
   
   func isLoggedIn() -> Bool{
       
       let email = getEmail()
       
       if(email.isEmpty) {
           return false
       }else {
          return true
       }
     
   }
    
   func getEmail()-> String {
       
       let email = UserDefaults.standard.string(forKey: "email") ?? ""
       
       print(email)
      return email
   }
   
   func getName()-> String {
      return UserDefaults.standard.string(forKey: "name") ?? ""
   }
   
   func getUserName()-> String {
      return UserDefaults.standard.string(forKey: "username") ?? ""
   }
   
   func getPhone()-> String {
      return UserDefaults.standard.string(forKey: "phone") ?? ""
   }
   
   func getPassword()-> String {
      return UserDefaults.standard.string(forKey: "password") ?? ""
   }
   
   func getDocumentId()-> String {
      return UserDefaults.standard.string(forKey: "documentId") ?? ""
   }
   
   func saveData(name:String, email:String, password: String) {
       UserDefaults.standard.setValue(name, forKey: "name")
       UserDefaults.standard.setValue(email, forKey: "email")
       UserDefaults.standard.setValue(password, forKey: "password")
   }
 
   func clearData(){
       UserDefaults.standard.removeObject(forKey: "email")
       UserDefaults.standard.removeObject(forKey: "name")
       UserDefaults.standard.removeObject(forKey: "password")
       UserDefaults.standard.removeObject(forKey: "documentId")
   }
    
    func saveFavourite(title: String) {
      
        UserDefaults.standard.set(true, forKey: getEmail().lowercased() + title.lowercased())
    }
    
    // Function to get favorites
    func getFavorites(title: String) -> Bool {
        
        return UserDefaults.standard.bool(forKey:  getEmail().lowercased() + title.lowercased())
    }
    
    func removeFavorite(title: String) {
           UserDefaults.standard.removeObject(forKey: getEmail().lowercased() + title.lowercased())
    }
}
