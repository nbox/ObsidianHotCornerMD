import AppKit

struct Constants {
    // Small and large corner zones
    static let smallZone: CGFloat = 20      // minimum zone
    static let largeZone: CGFloat = 80      // expanded zone
    static var cornerZone: CGFloat = smallZone
    
    static let previewWidth: CGFloat = 400
    static let cornerRadius: CGFloat = 10
    static let scrollPadding: CGFloat = 12    // padding around the scroll view
    static let textPadding: CGFloat = 6
    
    static let fadeDuration: TimeInterval = 0.2
    static let moveDuration: TimeInterval = 0.15
    static let hideDelay: TimeInterval = 0.10
    
}
