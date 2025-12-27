import SwiftUI
import Foundation
import KeyboardShortcuts


struct SettingsView: View {
    @ObservedObject var model: SettingsModel
    @State private var showingImporter = false
    
    private func screenWidth() -> Double {
        Double(NSScreen.main?.visibleFrame.width ?? 800)
    }
    
    
    private let cornerColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
            
            GroupBox(label: Label(LocalizedStringKey("settings.markdownFile"), systemImage: "doc.text")) {
                HStack {
                    Text(model.fileURL?.pathRelativeToHome ?? NSLocalizedString("settings.none", comment: ""))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Button(LocalizedStringKey("settings.choose")) {
                        showingImporter = true
                    }
                    .fileImporter(isPresented: $showingImporter,
                                  allowedContentTypes: [.plainText],
                                  allowsMultipleSelection: false) { result in
                        if case .success(let urls) = result, let url = urls.first {
                            model.fileURL = url
                        }
                    }
                }
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            
            
            GroupBox(label: Label(LocalizedStringKey("settings.previewLines"), systemImage: "text.alignleft")) {
                HStack {
                    Slider(
                        value: Binding(
                            get: { Double(model.previewLines) },
                            set: { model.previewLines = Int($0) }
                        ),
                        in: 5...100,
                        step: 5
                    )
                    Text("\(model.previewLines)")
                        .frame(width: 30, alignment: .trailing)
                }
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            
            
            GroupBox(label: Label(LocalizedStringKey("settings.previewWidth"), systemImage: "arrow.left.and.right")) {
                HStack {
                    Slider(
                        value: Binding(
                            get: { Double(model.previewWidth) },
                            set: { model.previewWidth = Int($0) }
                        ),
                        in: 200...screenWidth(), // from 200px up to the screen width
                        step: 50
                    )
                    Text("\(model.previewWidth)")
                        .frame(width: 40, alignment: .trailing)
                }
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            
            
            GroupBox(label: Label(LocalizedStringKey("settings.hotCorners"), systemImage: "rectangle.portrait.inset.filled")) {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        Toggle(LocalizedStringKey("settings.topLeft"), isOn: $model.topLeft)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Toggle(LocalizedStringKey("settings.topRight"), isOn: $model.topRight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack(spacing: 10) {
                        Toggle(LocalizedStringKey("settings.bottomLeft"), isOn: $model.bottomLeft)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Toggle(LocalizedStringKey("settings.bottomRight"), isOn: $model.bottomRight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            
            
            GroupBox(label: Label(LocalizedStringKey("settings.behavior"), systemImage: "gearshape")) {
                VStack(alignment: .leading) {
                    Toggle(LocalizedStringKey("settings.openInObsidian"), isOn: $model.openOnClick)
                    Toggle(LocalizedStringKey("settings.openAtLogin"), isOn: $model.launchAtLogin)
                    Toggle(LocalizedStringKey("settings.enableShortcut"), isOn: $model.shortcutEnabled)
                    
                    if model.shortcutEnabled {
                        HStack {
                            Text(LocalizedStringKey("settings.shortcut"))
                            KeyboardShortcuts.Recorder(for: .togglePreview)
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        
                        Picker("", selection: $model.shortcutCorner) {
                            ForEach(Corner.allCases, id: \.rawValue) { corner in
                                Text(corner.rawValue.capitalized).tag(corner)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                        .padding(.vertical, 5)
                    }
                    
                    
                }
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            Button {
                if let url = URL(string: "https://github.com/nbox/ObsidianHotCornerMD") {
                    NSWorkspace.shared.open(url)
                }
            } label: {
                HStack {
                    Image(systemName: "link")
                    Text(LocalizedStringKey("settings.viewOnGitHub"))
                    Spacer()
                }
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            
            GroupBox {
                Button(role: .destructive) {
                    NSApp.terminate(nil)
                } label: {
                    HStack {
                        Label(LocalizedStringKey("settings.quit"), systemImage: "power")
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(minWidth: 350)
    }
}
