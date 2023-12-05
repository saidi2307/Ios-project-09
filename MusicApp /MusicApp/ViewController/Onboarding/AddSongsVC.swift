//
//  AddSongsVC.swift
//  MusicApp
//
 

import UIKit

class AddSongsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnDone.layer.cornerRadius = 4
        btnDone.layer.borderColor =  UIColor.black.cgColor
        btnDone.layer.borderWidth = 1
        btnDone.clipsToBounds = true
        
        btnCancel.layer.cornerRadius = 4
        btnCancel.layer.borderColor =  UIColor.black.cgColor
        btnCancel.layer.borderWidth = 1
        btnCancel.clipsToBounds = true
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "SongsDetailsVC" ) as! SongsDetailsVC
                
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
