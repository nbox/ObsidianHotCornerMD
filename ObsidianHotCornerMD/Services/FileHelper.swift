import Foundation

extension URL {
    private static let invalidObsidianPathCharacters =
        CharacterSet.controlCharacters.union(.newlines)

    /// obsidian://open?path=… URL
    var obsidianOpenURL: URL? {
        let rawPath = path
        guard !rawPath.isEmpty else {
            return nil
        }
        if rawPath.rangeOfCharacter(from: Self.invalidObsidianPathCharacters) != nil {
            return nil
        }
        var components = URLComponents()
        components.scheme = "obsidian"
        components.host = "open"
        components.queryItems = [URLQueryItem(name: "path", value: rawPath)]
        return components.url
    }

    /// Convert "/Users/<name>/…/Projects/Vault/file.md" to "Projects/Vault/file.md"
    var pathRelativeToHome: String {
        let homePrefix = FileManager.default.homeDirectoryForCurrentUser.path + "/"
        if path.hasPrefix(homePrefix) {
            return String(path.dropFirst(homePrefix.count))
        } else {
            return path
        }
    }
}
