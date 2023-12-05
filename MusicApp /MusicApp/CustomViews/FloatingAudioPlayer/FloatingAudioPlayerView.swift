 

import UIKit
import AVFoundation

public protocol FloatingAudioPlayerViewDelegate: AnyObject {
    func floatingAudioPlayerViewDidTapPlay()
    func floatingAudioPlayerViewDidTapPause()
    func floatingAudioPlayerViewDidTapNext()
    func floatingAudioPlayerViewDidChangeProgress(progress: Float)
}

@IBDesignable
class FloatingAudioPlayerView: UIView {
    
    @IBOutlet var ytPlayer: YouTubePlayerView!
    private var timer: Timer?
    @IBOutlet weak var songImageBG: UIImageView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var audioNameLabel: UILabel!
    @IBOutlet weak var audioAuthorLabel: UILabel!
    @IBOutlet weak var playOrPauseBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    weak var delegate: FloatingAudioPlayerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        nibSetup()
    }
    
    func setViewsEnable(value:Bool) {
        self.playOrPauseBtn.isEnabled = value
        self.slider.isUserInteractionEnabled = value
    }
    private func nibSetup() {
        backgroundColor = .clear
    
        contentView = loadViewFromNib()
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true

        addSubview(contentView)
        
        playOrPauseBtn.setImage(UIImage(named: "pause", in: Bundle(for: Self.self), compatibleWith: nil), for: .selected)
        slider.tintColor = .white
        slider.setThumbImage(UIImage(named: "thumb", in: Bundle(for: Self.self), compatibleWith: nil), for: .normal)
        slider.setThumbImage(UIImage(named: "thumb", in: Bundle(for: Self.self), compatibleWith: nil), for: .highlighted)
        slider.addTarget(self, action: #selector(sliderChangedValue(_:)), for: .valueChanged)
        setViewsEnable(value: false)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpInside)
        self.ytPlayer.delegate = self
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @IBAction func playOrPauseBtnTapHandler(_ sender: UIButton) {
        if sender.isSelected {
            delegate?.floatingAudioPlayerViewDidTapPause()
            self.ytPlayer.pause()
            timer?.invalidate()
        }else{
            delegate?.floatingAudioPlayerViewDidTapPlay()
            self.ytPlayer.play()
            self.startTimer()
            
        }
        sender.isSelected = !sender.isSelected
        
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        removeView()
    }
    
    func removeView() {
        timer?.invalidate()
        timer = nil
        self.removeFromSuperview()
    }
    
    @IBAction func nextButtonTapHandler(_ sender: UIButton) {
        delegate?.floatingAudioPlayerViewDidTapNext()
    }
    
    public func play(audioModel: FloatingAudioModel, delegate: FloatingAudioPlayerViewDelegate) {
       
        print(audioModel.songId)
        ytPlayer.loadVideoID(audioModel.songId)
        ytPlayer.baseURL = "https://www.youtube.com"
        ytPlayer.playerVars = [
                   "playsinline": "1",
                   "controls": "0",
                   "showinfo": "0",
                   "origin": "http://www.youtube.com",
                   ] as YouTubePlayerView.YouTubePlayerParameters
        
        self.delegate = delegate
        setAudio(progress: audioModel.audioProgress)
        audioImageView.load(urlString: audioModel.imageURL, placeholder: UIImage(named: "note", in: Bundle(for: Self.self), compatibleWith: nil))
        self.songImageBG.load(urlString: audioModel.imageURL, placeholder: UIImage(named: "note", in: Bundle(for: Self.self), compatibleWith: nil))
        audioNameLabel.text = audioModel.name
        audioAuthorLabel.text = audioModel.artist
        playOrPauseBtn.isSelected = true
      
       
    }
    
    private func startTimer() {
        // Set up a timer to update the slider value every second
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            self.ytPlayer.getCurrentTime(completion: { (time) in
                DispatchQueue.main.async {
                    let currentTime = Float(time ?? 0)
                    self.slider.value = currentTime
                    if currentTime > self.slider.maximumValue {
                        // Stop the timer when the duration exceeds the maximum value
                        timer.invalidate()
                        self.delegate?.floatingAudioPlayerViewDidChangeProgress(progress: self.slider.maximumValue)
                    } else {
                        self.delegate?.floatingAudioPlayerViewDidChangeProgress(progress: currentTime)
                    }
                }
            })
        }
    }
    
    public func pause() {
        playOrPauseBtn.isSelected = false
        ytPlayer.pause()
    }
    
    public func setAudio(progress: Float) {
        if !slider.isHighlighted {
            slider.setValue(progress, animated: false)
        }
    }
    
    @objc private func sliderChangedValue(_ slider: UISlider) {
        delegate?.floatingAudioPlayerViewDidChangeProgress(progress: slider.value)
    }
    
    @objc private func sliderTouchUp() {
        // Handle slider touch up (user stopped dragging)
        let seekTime = Double(slider.value)
        ytPlayer.seekTo(Float(seekTime), seekAhead: true)
    }
    
}

extension FloatingAudioPlayerView : YouTubePlayerDelegate{
    
    
    func playerReady(_ videoPlayer: YouTubePlayerView) {
         
        self.ytPlayer.play()
        
        self.ytPlayer.getDuration { (duration) in
                   
            self.slider.maximumValue = Float(duration ?? 0)
            self.slider.minimumValue = 0
            
            if(duration ?? 0 > 2) {
                self.setViewsEnable(value: true)
            }
        }
         
        self.startTimer()
        
    }
    
    
    
}
extension UIImageView {
    /// Loads image from web asynchronosly and caches it, in case you have to load url
    /// again, it will be loaded from cache if available
    func load(url: URL, placeholder: UIImage?, cache: URLCache? = nil) {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            self.image = image
        } else {
            self.image = placeholder
            DispatchQueue.global(qos: .userInitiated).async {
                URLSession.shared.dataTask(with: request, completionHandler: {[weak self] (data, response, error) in
                    
                    if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300 {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        
                        DispatchQueue.main.async {
                            if let image = UIImage(data: data)  {
                                self?.image = image
                            }
                        }
                    }
                }).resume()
            }
        }
    }
    
    func load(urlString: String?, placeholder: UIImage?, cache: URLCache? = nil) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }
        load(url: url, placeholder: placeholder, cache: cache)
    }
}



class PlayerController: NSObject {
    
    static let shared = PlayerController()
    
    
       private func removePlayerView() {
            if let window = UIApplication.shared.keyWindow,
               let existingPlayerView = window.viewWithTag(1001) as? FloatingAudioPlayerView {
                existingPlayerView.removeFromSuperview()
            }
        }
    
    func addPlayer(song:Song) {
        
        self.removePlayerView()
    
        if let window = UIApplication.shared.keyWindow {
  
            print(song.songId)
     
            let musicViewModel = MusicViewModel(song: Song(songId:song.songId, title: song.title, artist: song.artist))
            
            let floatingAudioModel = FloatingAudioModel(name: musicViewModel.title, artist: musicViewModel.artist, imageURL: musicViewModel.getImageUrl(), audioProgress: 0, songId: musicViewModel.songId)
            
            let floatingAudioPlayerView = FloatingAudioPlayerView()
            floatingAudioPlayerView.frame = CGRect(x: 0, y: window.height - 140, width: window.width, height: 100)
            floatingAudioPlayerView.tag = 1001
            floatingAudioPlayerView.isUserInteractionEnabled = true
            window.addSubview(floatingAudioPlayerView)
            floatingAudioPlayerView.play(audioModel: floatingAudioModel, delegate: self)
        }
    }
}

extension PlayerController: FloatingAudioPlayerViewDelegate {
    func floatingAudioPlayerViewDidTapPlay() {
       
    }
    
    func floatingAudioPlayerViewDidTapPause() {
        
    }
    
    func floatingAudioPlayerViewDidTapNext() {
        // Handle next tap
    }
    
    func floatingAudioPlayerViewDidChangeProgress(progress: Float) {
       
    }
}
