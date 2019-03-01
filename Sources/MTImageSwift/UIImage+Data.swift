import MTImage

extension UIImage {
	@available(iOS 11.0, tvOS 11.0, *)
	public func heicData(compressionQuality: CGFloat) -> Data? {
		return UIImageHEICRepresentation(self, compressionQuality)
	}
	
	public func webPData(compressionQuality: CGFloat) -> Data? {
		return UIImageWebPRepresentation(self, compressionQuality)
	}
}
