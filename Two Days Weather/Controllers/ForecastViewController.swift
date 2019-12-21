import UIKit

final class ForecastNavigationViewController: UINavigationController {
	let forecastViewController = ForecastViewController()

	init(title: String) {
		forecastViewController.title = title
		super.init(rootViewController: forecastViewController)
		navigationBar.prefersLargeTitles = true
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

final class ForecastViewController: UIViewController {

	let titleLabel = UILabel()
	let temperatureLabel = UILabel()

	private var forecast: OpenWeatherForecast?

	private let temperatureFontSize: CGFloat = 64

	let measurementFormatter: MeasurementFormatter = {
		let measurementFormatter = MeasurementFormatter()
		measurementFormatter.numberFormatter.maximumFractionDigits = 1
		return measurementFormatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
		titleLabel.textColor = .secondaryLabel
		temperatureLabel.font = UIFont.monospacedDigitSystemFont(ofSize: temperatureFontSize, weight: .bold)
		temperatureLabel.textColor = .label
		view.addSubview(titleLabel)
		view.addSubview(temperatureLabel)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -temperatureFontSize).isActive = true
		temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
		temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		temperatureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true

		update(forecast: forecast)
	}

	func update(forecast: OpenWeatherForecast?) {
		self.forecast = forecast
		titleLabel.text = forecast?.cityName
		temperatureLabel.text = forecast != nil ? convert(temperature: forecast!.temperature) : "…"
	}

	private func convert(temperature: Double) -> String {
		let input = Measurement(value: temperature, unit: UnitTemperature.kelvin)
		return measurementFormatter.string(from: input)
	}

}
