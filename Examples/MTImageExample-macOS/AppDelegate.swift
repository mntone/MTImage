import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
	private var window: NSWindow!
	
	func applicationWillFinishLaunching(_ notification: Notification) {
		let viewController = ViewController()
		let window = NSWindow(contentViewController: viewController)
		window.minSize = NSMakeSize(64, 64)
		window.title = "MTImageExample"
		window.center()
		self.window = window
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		self.window.makeKeyAndOrderFront(nil)
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
}
