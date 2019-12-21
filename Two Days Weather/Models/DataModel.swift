import CouchbaseLiteSwift
import CoreLocation

private let secondsInDay: TimeInterval = 24 * 60 * 60

func isTomorrow(timestamp: TimeInterval, currentTimestamp: TimeInterval) -> Bool {
	return currentTimestamp + secondsInDay <= timestamp
}

final class DataModel {

	private let database: Database

	static let shared = DataModel(name: "two-days-weather")

	private let lastLocationID = "last-location"
	private let latitudeKey = "latitude"
	private let longitudeKey = "longitude"

	private let minimumLocationDistance: Double = 500

	init(name: String) {
		do {
			database = try Database(name: name)
		} catch {
			fatalError("Error opening database")
		}
	}

	private func isCached(at newLocation: CLLocation) -> Bool {
		guard let oldLocationDocument = database.document(withID: lastLocationID) else {
			return false
		}
		let oldLatitude = oldLocationDocument.double(forKey: latitudeKey)
		let oldLongitude = oldLocationDocument.double(forKey: longitudeKey)
		guard oldLatitude != 0 && oldLongitude != 0 else {
			return false
		}
		let oldLocation = CLLocation(latitude: oldLatitude, longitude: oldLongitude)
		return newLocation.distance(from: oldLocation) <= minimumLocationDistance
	}

	func getCachedForecast(at location: CLLocation) -> TodayAndTomorrowsForecast? {
		guard isCached(at: location) else {
			return nil
		}
		let currentTimestamp = Date().timeIntervalSince1970
		let query = QueryBuilder
			.select([
				SelectResult.property("time"),
				SelectResult.property("cityName"),
				SelectResult.property("temperature"),
			])
			.from(DataSource.database(database))
			.where(Expression.property("time").greaterThanOrEqualTo(Expression.double(currentTimestamp)))
			.orderBy(Ordering.property("time").ascending())
			.limit(Expression.int(100))
		do {
			let results = try query.execute()
			guard let todayResults = results.next(), let tomorrowResults = results.first(where: { isTomorrow(timestamp: $0.double(forKey: "time"), currentTimestamp: currentTimestamp) }) else {
				print("Could not find valid today/tomorrow in", results)
				return nil
			}
			return TodayAndTomorrowsForecast(today: OpenWeatherForecast(queryResult: todayResults), tomorrow: OpenWeatherForecast(queryResult: tomorrowResults))
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}

	func save(location: CLLocation, forecast: OpenWeatherForecastData) {
		let document = MutableDocument(id: lastLocationID, data: [
			latitudeKey: location.coordinate.latitude,
			longitudeKey: location.coordinate.longitude,
		])
		do {
			try database.saveDocument(document)
			try database.setDocumentExpiration(withID: lastLocationID, expiration: Calendar.current.date(byAdding: .day, value: 5, to: Date()))
		} catch {
			print(error.localizedDescription, location)
		}
		do {
			try database.inBatch {
				for entry in forecast.entries {
					let timestamp = entry.time
					let entryID = Int(timestamp).description
					let document = MutableDocument(id: entryID, data: [
						"time": timestamp,
						"cityName": forecast.cityName,
						"temperature": entry.temperature,
					])
					try database.saveDocument(document)
					try database.setDocumentExpiration(withID: entryID, expiration: Date(timeIntervalSince1970: timestamp + 5 * secondsInDay))
				}
			}
		} catch {
			print(error.localizedDescription)
		}
	}

}
