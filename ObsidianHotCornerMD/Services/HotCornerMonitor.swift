import Cocoa

enum Corner: String, CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight
}


protocol HotCornerDelegate: AnyObject {
    func mouseMoved(to corner: Corner?)
}

/// Monitors global mouse-moved events to detect hot corners.
class HotCornerMonitor {
    private var monitor: Any?
    weak var delegate: HotCornerDelegate?
    
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] _ in
            guard let self = self else { return }
            let loc = NSEvent.mouseLocation
            guard let screen = NSScreen.screens.first(where: { $0.frame.contains(loc) }) else { return }
            let f = screen.frame

            // Remember whether we were using the expanded zone
            let wasInside = Constants.cornerZone == Constants.largeZone

            // Check whether the pointer is inside any corner on this screen
            let nowInside =
                (loc.x <= f.minX + Constants.cornerZone && loc.y >= f.maxY - Constants.cornerZone)
                || (loc.x >= f.maxX - Constants.cornerZone && loc.y >= f.maxY - Constants.cornerZone)
                || (loc.x <= f.minX + Constants.cornerZone && loc.y <= f.minY + Constants.cornerZone)
                || (loc.x >= f.maxX - Constants.cornerZone && loc.y <= f.minY + Constants.cornerZone)

            if !wasInside && nowInside {
                Constants.cornerZone = Constants.largeZone
            } else if wasInside && !nowInside {
                Constants.cornerZone = Constants.smallZone
            }

            var activeCorner: Corner? = nil
            if loc.x <= f.minX + Constants.cornerZone && loc.y >= f.maxY - Constants.cornerZone {
                activeCorner = .topLeft
            } else if loc.x >= f.maxX - Constants.cornerZone && loc.y >= f.maxY - Constants.cornerZone {
                activeCorner = .topRight
            } else if loc.x <= f.minX + Constants.cornerZone && loc.y <= f.minY + Constants.cornerZone {
                activeCorner = .bottomLeft
            } else if loc.x >= f.maxX - Constants.cornerZone && loc.y <= f.minY + Constants.cornerZone {
                activeCorner = .bottomRight
            }
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.mouseMoved(to: activeCorner)
            }
        }

    }
    
    func stop() {
        if let m = monitor { NSEvent.removeMonitor(m); monitor = nil }
    }
}
