import Foundation

class WeatherInformation {
    var temp: Double?
    var humidity: Double?
    var wind: Double?
    var date: Date?
    var weather: String?
    
    init() {
        self.temp = 0.0
        self.humidity = 0.0
        self.wind = 0.0
        self.date = Date()
        self.weather = ""
    }
    
    init(temp: Double, humidity: Double, wind: Double, date: Date, weather: String) {
        self.temp = temp
        self.humidity = humidity
        self.wind = wind
        self.date = date
        self.weather = weather
    }
    
}

class WeatherInformationTwo {
    var temp2: Double?
    var humidity2: Double?
    var wind2: Double?
    var weather2: String?
    
    init() {
        self.temp2 = 0.0
        self.humidity2 = 0.0
        self.wind2 = 0.0
        self.weather2 = ""
    }
    
    init(temp2: Double, humidity2: Double, wind2: Double, weather2: String) {
        self.temp2 = temp2
        self.humidity2 = humidity2
        self.wind2 = wind2
        self.weather2 = weather2
    }
}


