import Foundation

class Constants {
    
    static let baseURL = "http://api.openweathermap.org/data/2.5/"
    static let appID = "4aa4ff5e9c5b22f32260cf876233c6d2"
    static let halfMonthPeriodWheather = "forecast?q=%@&units=metric&appid=\(Constants.appID)"
}
