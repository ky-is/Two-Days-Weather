import CoreLocation
import UIKit

final class ViewController: UIViewController {

	private let locationManager = CLLocationManager()

	private let pageViewController = ForecastPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		locationManager.delegate = self
		locationManager.startMonitoringSignificantLocationChanges()
		addChild(pageViewController)
		pageViewController.didMove(toParent: self)
		view.addSubview(pageViewController.view)
	}

	override func viewDidAppear(_ animated: Bool) {
		checkLocationAccess(authorization: CLLocationManager.authorizationStatus())
	}

}

//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let latestLocation = locations.last else {
			return
		}
		if let forecasts = DataModel.shared.getCachedForecast(at: latestLocation) {
			pageViewController.update(forecasts: forecasts)
			return
		}
		OpenWeather.forecast(at: latestLocation) { forecast in
			let currentTimestamp = Date().timeIntervalSince1970
			guard let todayEntry = forecast.entries.first, let tomorrowEntry = forecast.entries.first(where: { isTomorrow(timestamp: $0.time, currentTimestamp: currentTimestamp) }) else {
				return print("Could not find valid today/tomorrow in", forecast.entries)
			}
			let today = OpenWeatherForecast(cityName: forecast.cityName, temperature: todayEntry.temperature, time: todayEntry.time)
			let tomorrow = OpenWeatherForecast(cityName: forecast.cityName, temperature: tomorrowEntry.temperature, time: tomorrowEntry.time)
			DispatchQueue.main.async {
				self.pageViewController.update(forecasts: TodayAndTomorrowsForecast(today: today, tomorrow: tomorrow))
			}
			DataModel.shared.save(location: latestLocation, forecast: forecast)
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("locationManager didFailWithError", error.localizedDescription)
	}

	//MARK: Authorization

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		checkLocationAccess(authorization: status)
	}

	private func checkLocationAccess(authorization: CLAuthorizationStatus) {
		switch authorization {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		case .denied, .restricted:
			let alert = UIAlertController(title: "Location Services are disabled", message: "Two Days Weather needs to access your location while using the app, so it knows what forecast to show you. Please enable Location Services in the Settings app.", preferredStyle: .alert)
			let actionOK = UIAlertAction(title: "OK", style: .default) { _ in
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
					return print("openSettingsURLString invalid", UIApplication.openSettingsURLString)
				}
				guard UIApplication.shared.canOpenURL(settingsUrl) else {
					return print("openSettingsURLString unavailable", UIApplication.openSettingsURLString)
				}
				UIApplication.shared.open(settingsUrl)
			}
			alert.addAction(actionOK)
			present(alert, animated: true, completion: nil)
		case .authorizedAlways, .authorizedWhenInUse:
			break
		@unknown default:
			break
		}
	}

}
