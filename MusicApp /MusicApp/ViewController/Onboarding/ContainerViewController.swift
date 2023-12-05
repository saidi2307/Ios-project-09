//
//  ContainerViewController.swift
//  MusicApp
//
 

import UIKit

var containerViewController : ContainerViewController?

class ContainerViewController: UIViewController {

 
    @IBOutlet weak var homeContainerView: UIView!
    @IBOutlet weak var songsListContainerView: UIView!
    @IBOutlet weak var btnHome: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var homeBell: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    
    lazy var firstViewController: HomeVC = {
        return storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
    }()
    
    lazy var secondViewController: SearchPlayListVC = {
        return storyboard?.instantiateViewController(withIdentifier: "SearchPlayListVC") as! SearchPlayListVC
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerViewController = self
        // Do any additional setup after loading the view.
       // lblUserName.text = "dweewrwerewrwer"
        homeContainerView.isHidden = false
        songsListContainerView.isHidden = true
        addChild(childController: firstViewController, to: homeContainerView)
        removeContentViewController(secondViewController)
        self.lblUserName.text = "Welcome \(getName())"
        FireStoreManager.shared.setupNotificationListener(forUserEmail: getEmail()) { msg in
             
            if(msg.count > 0) {
                self.setImage(color: .red)
            }else {
                self.setImage(color: .appColor)
            }
        }
        self.setImage(color: .appColor)
    }
    
    
    private func addContentViewController(color1: UIColor, color2: UIColor) {
        btnHome.backgroundColor =  color1
        btnSearch.backgroundColor =  color2
        homeBell.backgroundColor =  color2
        btnProfile.backgroundColor =  color2
    }
    @IBAction func onShareButton(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "SharedPlayListVc" ) as! SharedPlayListVc
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
//    private func addContentViewController(_ viewController: UIViewController) {
//        addChild(childController: homeListVC, to: viewController)
//    }
//
    
//    private func setupChildViewControllers() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//        let homeListVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
//        addChild(childController: homeListVC, to: homeContainerView)
////        self.filterListVC = filterListVC
////        self.filterListVC.delegate = self
//
////        let songListVC = storyboard.instantiateViewController(withIdentifier: "SongsListVC") as! SongsListVC
////        //movieListVC.movies = movies
////        addChild(childController: songListVC, to: songsListContainerView)
//       // self.movieListVC = movieListVC
//    }
    

    @IBAction func btnCreatePlaylistTapped(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "CreatePlaylistVC" ) as! CreatePlaylistVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnAllTapped(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            homeContainerView.isHidden = false
            songsListContainerView.isHidden = true
            addChild(childController: firstViewController, to: homeContainerView)
            removeContentViewController(secondViewController)
        case 2:
            homeContainerView.isHidden = true
            songsListContainerView.isHidden = false
            addChild(childController: secondViewController, to: songsListContainerView)
            removeContentViewController(firstViewController)
        case 3:
            homeContainerView.isHidden = false
            songsListContainerView.isHidden = true
            addChild(childController: firstViewController, to: homeContainerView)
            removeContentViewController(secondViewController)
        case 4:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC" ) as! NotificationVC
            self.navigationController?.pushViewController(vc, animated: true)
            setImage(color: .appColor)
        default:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC" ) as! EditProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func setImage(color:UIColor) {
        
        if let image = UIImage(systemName: "bell.badge") {
            // Apply the tint color to the entire button
            homeBell.tintColor = color
            // Set the rendering mode to template to apply the tint color only to the image
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            // Set the tinted image to the button's image
            homeBell.setImage(tintedImage, for: .normal)
        }
    }

    
    private func removeContentViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    
    func changeButtonOrImageColor<T>(uiColor:UIColor,imageName:String,type:T) -> T {
      let image:UIImage? = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
      if let btn = type as? UIButton {
        btn.setImage(image, for: .normal)
        btn.tintColor = uiColor
        return btn as! T
      } else {
        let imageView = type as? UIImageView
          let tintableImage = imageView?.image?.withRenderingMode(.alwaysTemplate)
        imageView?.image = tintableImage
        imageView?.tintColor = uiColor
        return imageView as! T
      }
    }

}



extension UIViewController {
    
    func addChild(childController: UIViewController, to view: UIView) {
        self.addChild(childController)
        childController.view.frame = view.bounds
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
}
