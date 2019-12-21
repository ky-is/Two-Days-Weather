import UIKit

final class ForecastViewController: UIViewController {

	let titleLabel = UILabel()
	let temperatureLabel = UILabel()

	private var forecast: OpenWeatherForecast?

	override func viewDidLoad() {
		super.viewDidLoad()
		titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
		temperatureLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
		view.addSubview(titleLabel)
		view.addSubview(temperatureLabel)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -64).isActive = true
		temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
		temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		temperatureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true

		update(forecast: forecast)
	}

	func update(forecast: OpenWeatherForecast?) {
		self.forecast = forecast
		titleLabel.text = forecast?.cityName
		temperatureLabel.text = "\(forecast?.temperature.description ?? "?")°" // ℃℉
	}

}
