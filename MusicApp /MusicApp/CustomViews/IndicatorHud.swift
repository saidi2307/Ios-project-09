import UIKit
class IndicatorHud: UIView {
    
    static private let view = IndicatorHud()
   
    private let loadingView = UIView()
    private let backgroundView = UIView()
    
    static var keyWindow: UIWindow? {
      let allScenes = UIApplication.shared.connectedScenes
      for scene in allScenes {
        guard let windowScene = scene as? UIWindowScene else { continue }
        for window in windowScene.windows where window.isKeyWindow {
           return window
         }
       }
        return nil
    }
    
    init() {
        
        super.init(frame: IndicatorHud.keyWindow!.frame)
        initBackgroundView()
        initLoadingView()
        initIndicatorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initBackgroundView() {
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.alpha = 0
        addSubview(backgroundView)
    }
    
    private func initIndicatorView() {
        
        let imageSide = loadingView.frame.size.width / 1.5
        let imageX = loadingView.frame.width/2 - (imageSide/2)
        let imageY = loadingView.frame.height/2 - (imageSide/2)
        
        let activityIndicator =  UIActivityIndicatorView(frame: CGRect(x: imageX, y: imageY, width: imageSide, height: imageSide))
        activityIndicator.style = .large
        activityIndicator.color = UIColor.appColor
        activityIndicator.tintColor = UIColor(displayP3Red: 0.0/255.0, green: 62.0/255.0, blue: 147.0/255.0, alpha: 1)
        activityIndicator.startAnimating()
        loadingView.addSubview(activityIndicator)
    }
    
    private func initLoadingView() {
        let side = frame.size.width / 4
        let x = frame.midX - (side/2)
        let y = frame.midY - (side/2)
        loadingView.frame = CGRect(x: x, y: y, width: side, height: side)
        loadingView.backgroundColor = .clear
        addSubview(loadingView)
    }
    
     
    static func show() {
        
        DispatchQueue.main.async {
            
            if IndicatorHud.view.superview == nil {
                keyWindow?.addSubview(IndicatorHud.view)
                //appWindow?.addSubview(IndicatorHud.view)
            }
        }
       
    }
    
 
    
    static func dismiss() {
        
        DispatchQueue.main.async {
            
            if IndicatorHud.view.superview != nil {
                IndicatorHud.view.removeFromSuperview()
            }
            
        }
        
    }
    
}

 
