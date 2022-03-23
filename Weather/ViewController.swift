import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Property
    let date = Date()
    let formatter = DateFormatter()
    
    var sortedGroupedDict = [Dictionary<String, [WeatherInformation]>.Element]()
    var lat: Double?
    var lon: Double?
    var arrayOfCitiesNames = [String]()
    var city: String? = "Minsk"
    
    let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("Wait a second", comment: "Pull to refresh")
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    private let locationManager = CLLocationManager()
    
    // MARK: - Outlets
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var mapConstrain: NSLayoutConstraint!
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        locationManager.delegate = self
        locationManager.requestLocation()
        recognizer()
        searchButton.setTitle(city, for: .normal)
        getWeather()
        tableView.refreshControl = myRefreshControl
        frameMapView()
    }
    
    // MARK: - Actions
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        if mapView.frame.origin.x == UIScreen.main.bounds.width {
            UIView.animate(withDuration: 0.4) {
                self.mapView.frame.origin.x = 0
            }
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        self.openJSON()
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController else { return }
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.arrayOfCitysName = arrayOfCitiesNames
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        tableView.reloadData()
        sender.endRefreshing()
    }
    
    func getWeather() {
        self.spinner.isHidden = false
        self.tableView.isHidden = false
        self.locationView.isHidden = true
        self.dataLabel.isHidden = true
        self.getRequest()
        self.cityNameLabel.text = city
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        getRequestByLoc()
        self.tableView.isHidden = true
        self.spinner.isHidden = false
        self.cityNameLabel.text = "Point"
    }
    
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        print("\(locationCoordinate.latitude) \(locationCoordinate.longitude)")
        self.lat = locationCoordinate.latitude
        self.lon = locationCoordinate.longitude
        
        let point = MKPointAnnotation()
        point.coordinate = locationCoordinate
        point.title = "Point"
        mapView.addAnnotation(point)
        getRequestByLoc()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.cityNameLabel.text = "Point"
            self.tableView.isHidden = true
            UIView.animate(withDuration: 0.4) {
                self.mapView.frame.origin.x = UIScreen.main.bounds.width
            }
            self.lon = 0
            self.lat = 0
        }
    }
    
    // MARK: - Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(location.latitude)\(location.longitude)")
        self.lon = location.longitude
        self.lat = location.latitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
   
    func frameMapView() {
        mapView.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    func recognizer() {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(recognizer)
    }
}

// MARK: - Extension
extension ViewController {
    
    func getRequestByLoc() {
        guard let latitude = self.lat else {return}
        guard let longitude = self.lon else {return}
        
        self.sendRequest(endpoint: "onecall?lat=\(latitude)&lon=\(longitude)&exclude=daily&appid=\(Constants.appID)") { (data) in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = json as? [String: Any] {
                    
                    let weatherByLoc = WeatherInformationTwo()
                    if let current = jsonResult["current"] as? [String: Any],
                        let weather = current["weather"] as? [[String: Any]] {
                        weatherByLoc.temp2 = current["temp"] as? Double
                        weatherByLoc.wind2 = current["wind_speed"] as? Double
                        weatherByLoc.humidity2 = current["humidity"] as? Double
                        for item in weather {
                            let main = item["main"] as? String
                            weatherByLoc.weather2 = main
                        }
                        
                        guard let temp = weatherByLoc.temp2 else {return}
                        guard let wind = weatherByLoc.wind2 else {return}
                        guard let humidity = weatherByLoc.humidity2 else {return}
                        guard let weather = weatherByLoc.weather2 else {return}
                        self.formatter.dateFormat = "HH:mm"
                        let result = self.formatter.string(from: self.date)
                        self.formatter.dateFormat = "MM-dd-yyyy"
                        let resultTwo = self.formatter.string(from: self.date)
                        
                        DispatchQueue.main.async {
                            self.spinner.isHidden = true
                            self.locationView.isHidden = false
                            self.dataLabel.isHidden = false
                            self.currentTempLabel.text = String(format: "%.0f°C", temp * 0.08)
                            self.tempLabel.text = String(format: "%.2f °C", temp * 0.08)
                            self.windLabel.text = "\(wind) m/s"
                            self.humidityLabel.text = "\(humidity) %"
                            self.timeLabel.text = result
                            self.dataLabel.text = resultTwo
                            self.imageView.image = UIImage(named: weather)
                            self.locationView.setShadowForWeatherView(height: 80, width: 355)
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", messege: "Location not found") { (_) in
                        self.spinner.isHidden = true
                    }
                }
            }
        }
    }
    
    func openJSON() {
        if let path = Bundle.main.path(forResource: "city.list", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String: Any]] {
                    for key in jsonResult {
                        guard let name = key["name"] as? String else { return }
                        self.arrayOfCitiesNames.append(name)
                    }
                }
            } catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func getRequest() {
        guard let cityName = city?.replacingOccurrences(of: " ", with: "%20") else { return }
        
        var weatherInform = [WeatherInformation]()
        let query = String(format: Constants.halfMonthPeriodWheather, cityName)
        
        self.sendRequest(endpoint: query) { (data) in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = json as? [String: Any] {
                    
                    if let list =  jsonResult["list"] as? [[String: Any]] {
                        
                        for object in list {
                            
                            let wheatherObject = WeatherInformation()
                            
                            if let main = object["main"] as? [String: Any] {
                                wheatherObject.temp = main["temp"] as? Double
                                wheatherObject.humidity = main["humidity"] as? Double
                            }
                            
                            if let wind = object["wind"] as? [String: Any] {
                                wheatherObject.wind = wind["speed"] as? Double
                            }
                            
                            if let dateStr = object["dt_txt"] as? String,
                                let date = dateStr.toDate(withFormat: "yyyy-MM-dd HH:mm:ss") {
                                wheatherObject.date = date
                            }
                            
                            if let weatherArray = object["weather"] as? [[String: Any]] {
                                guard let weatherr = weatherArray.first else { return }
                                wheatherObject.weather = weatherr["main"] as? String
                            }
                            
                            
                            weatherInform.append(wheatherObject)
                            print()
                        }
                        let groupedDict = Dictionary(grouping: weatherInform) { element -> String in
                            let dateStr = element.date?.toString(withFormat: "MM-dd-yyyy")
                            return dateStr ?? ""
                        }
                        
                        self.sortedGroupedDict = groupedDict.sorted { (element1, element2) -> Bool in
                            return element2.key > element1.key
                        }
                        guard let currentTemp = self.sortedGroupedDict[0].value[0].temp else { return }
                        
                        DispatchQueue.main.async {
                            self.currentTempLabel.text = String(format: "%.0f°C", currentTemp)
                            self.spinner.isHidden = true
                            self.tableView.reloadData()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(title: jsonResult["cod"] as? String ?? "", messege: jsonResult["message"] as? String ?? "") { _ in
                                self.spinner.isHidden = true
                            }
                        }
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Incorrect City", messege: error.localizedDescription) { _ in
                        self.spinner.isHidden = true
                    }
                }
            }
        }
    }
    
    private func sendRequest(endpoint: String, completion: @escaping (Data) -> ()) {
        guard let url = URL(string: "\(Constants.baseURL)\(endpoint)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil, let data = data {
                completion(data)
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "No Internet Connection", messege: "You need to have Mobile Data or Wi-Fi") { (_) in
                        self.spinner.isHidden = true
                    }
                }
            }
        }
        task.resume()
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedGroupedDict.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedGroupedDict[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as? WeatherCell {
            
            let item = sortedGroupedDict[indexPath.section].value[indexPath.row]
            cell.tempLabel.text = "\(item.temp ?? 0.0) °C"
            cell.speedLabel.text = "\(item.wind ?? 0.0) m/s"
            cell.warmLabel.text = "\(item.humidity ?? 0.0) %"
            cell.dateLabel.text = item.date?.toString(withFormat: "HH:mm") ?? ""
            cell.weatherImageView.image = UIImage(named: item.weather ?? "")
            
            cell.alphaView.layer.cornerRadius = 7
            cell.alphaView.setShadowForWeatherView(height: 80, width: 355)
            
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherHeaderCell") as? WeatherHeaderCell {
            cell.dateLabel.text = sortedGroupedDict[section].key
            return cell
        }
        return nil
    }
}

// MARK: - MKMapView
private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
