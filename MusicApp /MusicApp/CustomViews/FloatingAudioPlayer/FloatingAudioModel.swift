 

import Foundation

public struct FloatingAudioModel {
    public let name: String
    public let artist: String?
    public let imageURL: String?
    public let audioProgress: Float
    public let songId: String
    
    public init(name: String, artist: String?, imageURL: String?, audioProgress: Float,songId:String) {
        self.name = name
        self.artist = artist
        self.imageURL = imageURL
        self.audioProgress = audioProgress
        self.songId = songId
    }
}
