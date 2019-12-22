import UIKit

final class ForecastPageViewController: UIPageViewController {

	private let forecastViewControllers = [ForecastNavigationViewController(title: "Today"), ForecastNavigationViewController(title: "Tomorrow")]

	private let pageControl = UIPageControl()

	override func viewDidLoad() {
		super.viewDidLoad()
		dataSource = self
		delegate = self
		setViewControllers([forecastViewControllers[0]], direction: .forward, animated: false)

		pageControl.currentPageIndicatorTintColor = .label
		pageControl.pageIndicatorTintColor = .secondaryLabel
		pageControl.numberOfPages = forecastViewControllers.count
		pageControl.currentPage = 0
		view.addSubview(pageControl)

		pageControl.translatesAutoresizingMaskIntoConstraints = false
		pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
		let dotScale: CGFloat = 1.75
		pageControl.transform = CGAffineTransform(scaleX: dotScale, y: dotScale)
	}

	func update(forecasts: TodayAndTomorrowsForecast) {
		forecastViewControllers[0].forecastViewController.update(forecast: forecasts.today)
		forecastViewControllers[1].forecastViewController.update(forecast: forecasts.tomorrow)
	}

}

// MARK: - UIPageViewControllerDelegate

extension ForecastPageViewController: UIPageViewControllerDelegate {

	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if let viewController = viewControllers?.first, let index = getIndex(of: viewController) {
			pageControl.currentPage = index
		}
	}

}

// MARK: - UIPageViewControllerDataSource

extension ForecastPageViewController: UIPageViewControllerDataSource {

	private func getIndex(of viewController: UIViewController) -> Int? {
		guard let viewController = viewController as? ForecastNavigationViewController else {
			return nil
		}
		return forecastViewControllers.firstIndex(of: viewController)
	}

	private func getNextViewController(for viewController: UIViewController) -> UIViewController? {
		guard let index = getIndex(of: viewController) else {
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
