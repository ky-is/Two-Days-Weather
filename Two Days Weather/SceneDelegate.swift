import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else {
			return
		}
		let window = UIWindow(windowScene: windowScene)
		window.rootViewController = ViewController()
		window.makeKeyAndVisible()
		self.window = window
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
		if let viewController = window?.rootViewController as? ViewController {
			viewController.checkLocation()
		}
	}

}
