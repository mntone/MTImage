#if os(iOS) || os(tvOS)
import MobileCoreServices
#else
import CoreServices
#endif
import ImageIO

public enum CGImageSourceTypeIdentifier {
	case jpeg
	case jpeg2000
	case tiff
	case gif
	case png
	case bmp
	case raw(String)
	
	fileprivate init(hint: String) {
		if UTTypeEqual(hint as CFString, kUTTypeJPEG) {
			self = .jpeg
		} else if UTTypeEqual(hint as CFString, kUTTypeJPEG2000) {
			self = .jpeg2000
		} else if UTTypeEqual(hint as CFString, kUTTypeTIFF) {
			self = .tiff
		} else if UTTypeEqual(hint as CFString, kUTTypeGIF) {
			self = .gif
		} else if UTTypeEqual(hint as CFString, kUTTypePNG) {
			self = .png
		} else if UTTypeEqual(hint as CFString, kUTTypeBMP) {
			self = .bmp
		} else {
			self = .raw(hint)
		}
	}
	
	fileprivate var string: CFString {
		switch self {
		case .jpeg:     return kUTTypeJPEG
		case .jpeg2000: return kUTTypeJPEG2000
		case .tiff:     return kUTTypeTIFF
		case .gif:      return kUTTypeGIF
		case .png:      return kUTTypePNG
		case .bmp:      return kUTTypeBMP
			
		case let .raw(type):
			return type as CFString
		}
	}
}

open class MTImageSourceCreateOption {
	var options: [CFString: Any] = [:]
	
	public var typeIdentifierHint: CGImageSourceTypeIdentifier? {
		get {
			let hint = options[kCGImageSourceTypeIdentifierHint] as? String
			if let hint = hint {
				return CGImageSourceTypeIdentifier(hint: hint)
			}
			return nil
		}
		set(value) {
			if let hint = value {
				options[kCGImageSourceTypeIdentifierHint] = hint.string;
			}
		}
	}
	
	func get() -> CFDictionary {
		return options as CFDictionary
	}
}
