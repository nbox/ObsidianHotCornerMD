import Foundation

class PreviewViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var fileURL: URL?
}
