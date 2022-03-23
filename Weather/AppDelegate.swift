import UIKit



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

extension ViewController {
    
    func showAlert(title: String, messege: String, handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        let settingAction = UIAlertAction(title: "Settings", style: .default) { (_) in
            guard let profileUrl = URL(string:"App-Prefs:root=General&path=Network") else {
                return
            }

            if UIApplication.shared.canOpenURL(profileUrl) {
                UIApplication.shared.open(profileUrl, completionHandler: { (success) in
                    print(" Profile Settings opened: \(success)")
                })
            }
        }
        alertController.addAction(settingAction)
        alertController.addAction(okAction)
        
        self.present(alertController,animated: true, completion: nil)
    }
    
    
}


extension String {
    
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        
        return date
        
    }
}

extension Date {
    
    func toString(withFormat format: String = "EEEE ، d MMMM yyyy") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        
        return str
    }
}

extension UIView {
    
    func setShadowForWeatherView(height: Int, width: Int) {
        self.layer.shadowColor = UIColor.black.cgColor
        let shadowSize: CGFloat = 10
        let shadowDistance: CGFloat = 10
        let contactRect = CGRect(x: -shadowSize, y: CGFloat(height) - (shadowSize * 0.4) + shadowDistance, width: CGFloat(width) + shadowSize * 2, height: shadowSize)
        self.layer.shadowPath = UIBezierPath(ovalIn: contactRect).cgPath
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 1
        self.layer.cornerRadius = 7
    }
    
}
