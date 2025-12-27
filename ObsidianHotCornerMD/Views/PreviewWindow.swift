import Cocoa
import SwiftUI
import MarkdownUI

class PreviewWindow: NSWindow {
    private var contentHeight: CGFloat = 0
    private let viewModel = PreviewViewModel()
    private let settings: SettingsModel
    private let hosting: NSHostingView<PreviewContentView>
    
    
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    
    init(settings: SettingsModel) {
        self.settings = settings
        hosting = NSHostingView(
            rootView: PreviewContentView(viewModel: viewModel, settings: settings)
        )
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .floating
        
        contentView?.wantsLayer = true
        contentView?.layer?.cornerRadius = Constants.cornerRadius
        
        hosting.translatesAutoresizingMaskIntoConstraints = false
        contentView?.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.leadingAnchor.constraint(equalTo: contentView!.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: contentView!.trailingAnchor),
            hosting.topAnchor.constraint(equalTo: contentView!.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor),
        ])
    }
    
    /**
     Shows preview for given angle.
     - Parameters:
     - corner: Screen angle
     - content: Text (or placeholder message)
     - maxLines: Maximum number of lines
     - fileURL: URL of file to open. If nil - only text is shown without clickability.
     */
    func show(for corner: Corner, content: String, maxLines: Int, fileURL: URL? = nil) {
        // Update only when values change to avoid re-rendering during animations
        if viewModel.text != content { viewModel.text = content }
        if viewModel.fileURL != fileURL { viewModel.fileURL = fileURL }
        
        // Compute content height
        let lineHeight: CGFloat = 17
        let rawHeight = CGFloat(maxLines) * lineHeight + 2 * Constants.textPadding
        let currentScreen = NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) }
        let screenH = currentScreen?.visibleFrame.height ?? 800
        contentHeight = min(rawHeight + 2 * Constants.scrollPadding,
                            screenH - 2 * Constants.scrollPadding)
        
        // Position on the screen under the cursor; width comes from settings
        guard let screen = currentScreen else { return }
        let sf = screen.visibleFrame
        let padding = Constants.scrollPadding
        let width = CGFloat(settings.previewWidth)
        let x: CGFloat, y: CGFloat
        switch corner {
        case .topLeft:
            x = sf.minX + padding
            y = sf.maxY - padding
        case .topRight:
            // Align to the right edge accounting for width
            x = sf.maxX - width - padding
            y = sf.maxY - padding
        case .bottomLeft:
            x = sf.minX + padding
            y = sf.minY + contentHeight + padding
        case .bottomRight:
            x = sf.maxX - width - padding
            y = sf.minY + contentHeight + padding
        }
        
        let frame = NSRect(
            x: x,
            y: y - contentHeight,
            width: width,
            height: contentHeight
        )
        
        
        // If visible and frame unchanged, bail out
        if isVisible && frame == self.frame {
            return
        }
        
        // If visible and the frame changed, animate the move
        if isVisible {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = Constants.moveDuration
                self.animator().setFrame(frame, display: true)
            }
        }
        // If hidden, set frame and fade in
        else {
            setFrame(frame, display: false)
            alphaValue = 0
            orderFrontRegardless()
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = Constants.fadeDuration
                self.animator().alphaValue = 1
            }
        }
        
        
    }
    
    func hide() {
        guard isVisible && alphaValue > 0.5 else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = Constants.fadeDuration
            self.animator().alphaValue = 0
        }) {
            self.orderOut(nil)
        }
    }
}
