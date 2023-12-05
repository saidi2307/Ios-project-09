import FirebaseStorage
import UIKit

struct MusicViewModel {
  
    var title = ""
    var artist = ""
    var minute = "0"
    var second  = "0"
    var songId = ""
    var song: Song?
    
    init(song: Song) {
        self.song = song
        self.title = song.title
        self.artist = song.artist
        self.songId = song.songId
    }

   
    func getImageUrl()->String {
        
        return  "https://img.youtube.com/vi/\(songId)/0.jpg"
    }
    
    func downloadImage(completion: @escaping(_ image: UIImage?) -> ()) {
        guard let songId = self.song?.songId else {
            completion(nil)
            return
        }

        let path = "https://img.youtube.com/vi/\(songId)/0.jpg"

        guard let url = URL(string: path) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }

        task.resume()
    }

}
