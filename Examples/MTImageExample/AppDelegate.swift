import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
	private var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let viewController = ViewController()
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = viewController
		window.makeKeyAndVisible()
		self.window = window
		return true
	}
}
