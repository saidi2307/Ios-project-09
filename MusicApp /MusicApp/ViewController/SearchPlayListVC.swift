 
import UIKit
class SearchPlayListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var playlist: [Playlist] = []
    var originalPlaylist: [Playlist] = [] // Store the original playlist for resetting

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerCells([CommonCell.self])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMyPlayList()
    }
    
    func getMyPlayList() {
        ViewModel.shared.getMyPlayList { playList in
            self.playlist = playList
            self.originalPlaylist = playList
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onSearch(_ sender: Any) {
        guard let searchText = searchTF.text?.lowercased(), !searchText.isEmpty else {
            // If the search text is empty, reset the playlist to the original list
            self.playlist = self.originalPlaylist
            self.tableView.reloadData()
            return
        }
        
        // Filter the playlist based on the search text
        let filteredPlaylist = originalPlaylist.filter { $0.name.lowercased().contains(searchText) || $0.description.lowercased().contains(searchText) }
        
        // Update the playlist with the filtered results
        self.playlist = filteredPlaylist
        
        // Reload the table view to reflect the changes
        self.tableView.reloadData()
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
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SongsDetailsVC") as! SongsDetailsVC
        vc.playlist = self.playlist[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
