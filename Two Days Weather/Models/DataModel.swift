import CouchbaseLiteSwift

final class DataModel {

	private let database: Database

	static let shared = DataModel(name: "two-days-weather")

	init(name: String) {
		do {
			database = try Database(name: name)
		} catch {
			fatalError("Error opening database")
		}
	}

}
