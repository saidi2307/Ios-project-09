
import FirebaseFirestore

struct Playlist: Codable {
    var name: String
    var description: String
    var createdBy: String
    var timestamp: Timestamp
    var songs: [Song]?
    var sharedWith: [String]?
    var documentId:String?
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case createdBy
        case timestamp
        case songs
    }
    
    mutating func setDocumentId(documetId:String) {
        self.documentId = documetId
    }
    
    func getDocumentId() -> String {
        return self.documentId ?? ""
    }
}

struct Song: Codable {
    var songId: String
    var title: String
    var artist: String
}
