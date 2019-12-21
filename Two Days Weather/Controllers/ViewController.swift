import CoreLocation
import UIKit

final class ViewController: UIViewController {

	private let locationManager = CLLocationManager()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		locationManager.delegate = self
	}

	override func viewDidAppear(_ animated: Bool) {
		checkLocationAccess(authorization: CLLocationManager.authorizationStatus())
	}

}

//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {

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
