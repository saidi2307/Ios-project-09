 
import UIKit

class CommonCell: UITableViewCell {
 
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    func setData(name:String,desc:String) {
        self.name.text = name
        self.desc.text = desc
    }
    
}
