//
//  NotificationVC.swift
//  MusicApp
//
 

import UIKit

var notificationVC:NotificationVC?

class NotificationVC: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var messageArray: [String] = []
    
    func reloadData() {
        messageArray = FireStoreManager.shared.messageArray
        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        notificationVC = nil
    }

    @IBAction func onClear(_ sender: Any) {
        
        FireStoreManager.shared.clearNotifications()
        
        showAlerOnTop(message: "Notification List cleared")
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationVC = self
        self.tableView.registerCells([CommonCell.self])
        reloadData()
    }
    

    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath) as! CommonCell
        cell.setData(name: "New Song Added", desc: self.messageArray[indexPath.row])
        return cell
    }
}
