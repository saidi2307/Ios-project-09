//
//  HomeVC.swift
//  MusicApp
//

import UIKit

var homeVC : HomeVC!

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    
    var playlist:[Playlist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.isHidden = true
        self.tableView.registerCells([CommonCell.self])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeVC = self
        self.getMyPlayList()
    }
    
    func getMyPlayList() {
        
        ViewModel.shared.getMyPlayList { playList in
            
            if(playList.isEmpty){
                self.stackView.isHidden = false
            }else {
                self.stackView.isHidden = true
            }
            self.playlist = playList
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func btnCreatePlaylistTapped(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "CreatePlaylistVC" ) as! CreatePlaylistVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = self.playlist[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath) as! CommonCell
        cell.setData(name: list.name.capitalized, desc: list.description.capitalized)
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
             
            let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
                guard let self = self else { return }
                
                ViewModel.shared.deletePlayList(playList: self.playlist[indexPath.row]) { value in
                    self.getMyPlayList()
                }
                
                completionHandler(true)
            }
            delete.backgroundColor = .red
            let swipeConfiguration = UISwipeActionsConfiguration(actions: [delete])
            return swipeConfiguration
            
        }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier:  "CreatePlaylistVC" ) as! CreatePlaylistVC
            vc.moveFrom = "Edit"
            vc.playlist = self.playlist[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            
            completionHandler(true)
        }
        editAction.backgroundColor = .blue

        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "SongsDetailsVC" ) as! SongsDetailsVC
        vc.playlist = self.playlist[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
