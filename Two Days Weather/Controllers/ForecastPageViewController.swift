import UIKit

final class ForecastPageViewController: UIPageViewController {

	private let forecastViewControllers = [ForecastViewController(), ForecastViewController()]

	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		setViewControllers([forecastViewControllers[0]], direction: .forward, animated: false)
	}

	func update(forecasts: TodayAndTomorrowsForecast) {
		forecastViewControllers[0].update(forecast: forecasts.today)
		forecastViewControllers[1].update(forecast: forecasts.tomorrow)
	}

}

// MARK: - UIPageViewControllerDataSource

extension ForecastPageViewController: UIPageViewControllerDataSource {

	private func getNextViewController(for viewController: UIViewController) -> UIViewController? {
		guard let viewController = viewController as? ForecastViewController else {
			return nil
		}
		guard let index = forecastViewControllers.firstIndex(of: viewController) else {
			return nil
		}
		return forecastViewControllers[index == 0 ? 1 : 0]
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		return getNextViewController(for: viewController)
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		return getNextViewController(for: viewController)
	}

}
