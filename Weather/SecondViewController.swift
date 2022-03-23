import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    
    let date = Date()
    let formatter = DateFormatter()
    var arrayOfCitysName = [String]()
    var searchedCities = [String]()
    var searching = false
    var city: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

        
    }
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedCities.count
        } else {
            return arrayOfCitysName.count
        }
    }
    
    
}

extension SecondViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedCities = arrayOfCitysName.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
               controller.modalPresentationStyle = .fullScreen
               controller.modalTransitionStyle = .crossDissolve
               self.present(controller, animated: true, completion: nil)
           }
}


extension SecondViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as? SearchCell {
            if searching {
                cell.cityNameLabel.text = searchedCities[indexPath.row]
            } else {
                cell.cityNameLabel.text = arrayOfCitysName[indexPath.row]
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searching {
            city = searchedCities[indexPath.row]
        } else {
            city = arrayOfCitysName[indexPath.row]
        }
        
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.city = city
        self.present(controller, animated: true, completion: nil)
    }
    
}

