import CouchbaseLiteSwift
import CoreLocation
import Foundation

typealias TodayAndTomorrowsForecast = (today: OpenWeatherForecast, tomorrow: OpenWeatherForecast)

struct OpenWeatherForecast {
	let cityName: String
	let temperature: Double
	let time: TimeInterval

	init(cityName: String, temperature: Double, time: TimeInterval) {
		self.cityName = cityName
		self.temperature = temperature
		self.time = time
	}

	init(queryResult: ResultSet.Element) {
		self.cityName = queryResult.string(forKey: "cityName") ?? "??"
		self.temperature = queryResult.double(forKey: "temperature")
		self.time = queryResult.double(forKey: "time")
	}
}

struct OpenWeatherForecastDataEntry {
	let time: TimeInterval
	let temperature: Double

	init?(json: [String: Any]) {
		guard let time = json["dt"] as? TimeInterval, let mainObject = json["main"] as? [String: Any] else {
			print("json missing fields", json)
			return nil
		}
		guard let temperature = mainObject["temp"] as? Double else {
			print("mainObject missing fields", mainObject)
			return nil
		}
		self.time = time
		self.temperature = temperature
	}
}

struct OpenWeatherForecastData {
	let cityID: Int
	let cityName: String
	let entries: [OpenWeatherForecastDataEntry]

	init?(json: [String: Any]) {
		guard let cityObject = json["city"] as? [String: Any], let forecastEntries = json["list"] as? [[String: Any]] else {
			print("json missing fields", json)
			return nil
		}
		guard let cityID = cityObject["id"] as? Int, let cityName = cityObject["name"] as? String else {
			print("cityObject missing fields", cityObject)
			return nil
		}
		self.cityID = cityID
		self.cityName = cityName
		self.entries = forecastEntries.compactMap { OpenWeatherForecastDataEntry(json: $0) }
	}
}

final class OpenWeather {

	private static let baseURL = "https://api.openweathermap.org/data/2.5/forecast?APPID=\(openWeatherMapAPIKey)"

	static func forecast(at location: CLLocation, callback: @escaping (OpenWeatherForecastData) -> Void) {
		let urlString = "\(baseURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
		guard let url = URL(string: urlString) else {
			return print("Invalid url", urlString)
		}
		let session = URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				return print(error.localizedDescription)
			}
			guard let data = data else {
				return print("Invalid data", url, response ?? "nil")
			}
			do {
				if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let weatherData = OpenWeatherForecastData(json: json) {
					callback(weatherData)
				}
			} catch {
				print(error.localizedDescription)
			}
		}
		session.resume()
	}

}
