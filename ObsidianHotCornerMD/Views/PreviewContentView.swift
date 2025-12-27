import SwiftUI
import MarkdownUI
import AppKit

struct PreviewContentView: View {
    @ObservedObject var viewModel: PreviewViewModel
    let settings: SettingsModel
    
    var body: some View {
        Group {
            // If a valid file is set
            if let url = viewModel.fileURL,
               FileManager.default.fileExists(atPath: url.path) {
                
                // Show Markdown
                ScrollView(.vertical) {
                    Markdown(viewModel.text)
                        .markdownTheme(.gitHub)
                        .padding(Constants.textPadding)
                }
                
            } else {
                // Placeholder when no file is selected
                Text(LocalizedStringKey("placeholder.pleaseSelectFile"))
                    .foregroundColor(.gray)
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: Constants.cornerRadius,
                            style: .continuous
                        )
                    )
            }
        }
        .padding(Constants.scrollPadding)
        .frame(
            minWidth: CGFloat(settings.previewWidth),
            maxWidth: CGFloat(settings.previewWidth),
            alignment: .leading
        )
        .background(Color(red: 24.0/255.0, green: 25.0/255.0, blue: 29.0/255.0, opacity: 1.0))
        .clipShape(
            RoundedRectangle(
                cornerRadius: Constants.cornerRadius,
                style: .continuous
            )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            guard settings.openOnClick,
                  let fileURL = viewModel.fileURL,
                  FileManager.default.fileExists(atPath: fileURL.path),
                  let obsidianURL = fileURL.obsidianOpenURL else {
                return
            }
            NSWorkspace.shared.open(obsidianURL)
        }
    }
}
