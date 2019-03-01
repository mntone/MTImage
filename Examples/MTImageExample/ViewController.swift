import MTImage
import MTImageSwift

#if os(macOS)
import AppKit

public typealias ViewControllerBase = NSViewController
#else
import UIKit

public typealias ViewControllerBase = UIViewController
#endif

public final class ViewController: ViewControllerBase {
	private static let targetURLString = "http://littlesvr.ca/apng/images/world-cup-2014-42.gif"
	
	private weak var imageView: MTAnimatedImageView!
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
#if os(macOS)
		let imageView = MTAnimatedImageView(frame: NSRect(x: 0, y: 0, width: 640, height: 360))
		imageView.imageScaling = .scaleProportionallyUpOrDown
#else
		let imageView = MTAnimatedImageView(frame: .zero)
		imageView.backgroundColor = .black
		imageView.contentMode = .scaleAspectFit
#endif
		self.imageView = imageView
		
		view = imageView
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		if let targetURL = URL(string: ViewController.targetURLString) {
			let task = URLSession.shared.dataTask(with: targetURL) { data, response, error in
				guard error == nil,
					  let response = response as? HTTPURLResponse,
					  response.statusCode == 200,
					  let data = data
					  else { return }
				
				if let image = MTAnimatedImage(data: data) {
					DispatchQueue.main.async {
						self.imageView.image = image
					}
				}
			}
			task.resume()
		}
	}
}
