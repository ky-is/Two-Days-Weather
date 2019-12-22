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
	let temperatureContextLabel = UILabel()
	let dateLabel = UILabel()

	private var forecast: OpenWeatherForecast?

	private let temperatureFontSize: CGFloat = 64

	let measurementFormatter: MeasurementFormatter = {
		let measurementFormatter = MeasurementFormatter()
		measurementFormatter.numberFormatter.maximumFractionDigits = 1
		return measurementFormatter
	}()

	let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	let timeFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .none
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
		titleLabel.textColor = .secondaryLabel
		temperatureLabel.font = UIFont.monospacedDigitSystemFont(ofSize: temperatureFontSize, weight: .bold)
		temperatureLabel.textColor = .label
		temperatureContextLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		temperatureContextLabel.textColor = .secondaryLabel
		dateLabel.font = UIFont.preferredFont(forTextStyle: .body)
		dateLabel.textColor = .tertiaryLabel
		view.addSubview(titleLabel)
		view.addSubview(temperatureLabel)
		view.addSubview(temperatureContextLabel)
		view.addSubview(dateLabel)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		titleLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -temperatureFontSize * 2/3).isActive = true
		temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
		temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		temperatureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
		temperatureContextLabel.translatesAutoresizingMaskIntoConstraints = false
		temperatureContextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		temperatureContextLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: temperatureFontSize * 2/3).isActive = true
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		dateLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: temperatureFontSize + 8).isActive = true

		update(forecast: forecast)
	}

	func update(forecast: OpenWeatherForecast?) {
		self.forecast = forecast
		titleLabel.text = forecast?.cityName
		temperatureLabel.text = forecast != nil ? convert(temperature: forecast!.temperature) : "…"
		let date = forecast != nil ? Date(timeIntervalSince1970: forecast!.time) : nil
		temperatureContextLabel.text = date != nil ? (abs(date!.timeIntervalSinceNow) > 2 * .hour ? "at \(timeFormatter.string(from: date!))" : "currently") : ""
		dateLabel.text = format(date: date)
	}

	private func convert(temperature: Double) -> String {
		let input = Measurement(value: temperature, unit: UnitTemperature.kelvin)
		return measurementFormatter.string(from: input)
	}

	private func format(date: Date?) -> String {
		guard let date = date else {
			return ""
		}
		return dateFormatter.string(from: date)
	}

}
