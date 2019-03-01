import ImageIO

open class MTImageCreateOption {
	var options: [CFString: Any] = [:]
	
	public var shouldCache: Bool {
		get {
			let flag = options[kCGImageSourceShouldCache] as? Bool
			if let flag = flag {
				return flag
			}
#if arch(arm64) || arch(x86_64)
			return true
#else
			return false
#endif
		}
		set(value) {
			options[kCGImageSourceShouldCache] = value;
		}
	}
	
	@available(OSX 10.9, *)
	public var shouldCacheImmediately: Bool {
		get {
			let flag = options[kCGImageSourceShouldCacheImmediately] as? Bool
			if let flag = flag {
				return flag
			}
			return false
		}
		set(value) {
			options[kCGImageSourceShouldCacheImmediately] = value;
		}
	}
	
	public var shouldAllowFloat: Bool {
		get {
			let flag = options[kCGImageSourceShouldAllowFloat] as? Bool
			if let flag = flag {
				return flag
			}
			return false
		}
		set(value) {
			options[kCGImageSourceShouldAllowFloat] = value;
		}
	}
	
	func get() -> CFDictionary {
		return options as CFDictionary
	}
}
