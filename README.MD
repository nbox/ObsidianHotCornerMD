# Obsidian Hot Corner Preview

A lightweight macOS menu bar app that brings your Obsidian notes to your fingertips-just like “Quick Notes” with active screen corners. Select any `.md` file in the settings, then hover your cursor over one of the screen’s corners. A floating preview window renders your Markdown document on top of all other windows, and a single click opens the note in Obsidian.

## Demo

<div style="text-align: center;">
  <img src="./assets/demo.gif" alt="App Demo" style="max-width:600px; height:auto;" />
  <p><em>Hover into the corner → preview appears → click to open in Obsidian.</em></p>
  <img src="./assets/settings.png" alt="Settings Menu" style="max-width:100px; height:auto;" />
  <p><em>The pencil icon in the menu bar opens the settings panel.</em></p>
</div>

<details> <summary><strong>⚙️ Settings</strong></summary>

- **Markdown File**: Choose your `.md` file via the standard file picker.
- **Preview Lines / Width**: Adjust how many lines are shown and the width of the preview window.
- **Hot Corners**: Enable one or more corners (top-left, top-right, bottom-left, bottom-right).
- **Click to Open**: Open the note in Obsidian using the `obsidian://` URL scheme.
- **Keyboard Shortcut**: Assign a custom shortcut to toggle the preview on and off.
- **Launch at Login**: Enable “Open at Login,” implemented via a Launch Agent (`~/Library/LaunchAgents`). The app will appear in System Settings → General → Login Items (you can disable it there).

</details>

## Installation

DMG install checklist:

1. Download the latest `.dmg` from the [Releases](https://github.com/nbox/ObsidianHotCornerMD/releases) page.
2. Open the `.dmg` to mount it. You will see `ObsidianHotCornerMD.app` and an `Applications` shortcut.
3. Drag `ObsidianHotCornerMD.app` onto the `Applications` shortcut.
4. Eject the mounted DMG.
5. Launch the app from Applications — the menu bar icon will appear. Open Settings, choose your Markdown file, enable desired corners, adjust width/lines, assign a hotkey, and (optionally) enable launch at login.

Note: On first launch, macOS may request **Input Monitoring** permission to observe mouse movement for hot corners. Grant it at: System Settings → Privacy & Security → Input Monitoring.

## License

This project is licensed under the MIT License.

## Build from source

- Xcode: 16.1 or newer
- Swift: 5.x (as provided by Xcode)
- macOS target: 12.4+ (configurable in the project settings)

Steps:

- Open `ObsidianHotCornerMD.xcodeproj` in Xcode.
- Select the `ObsidianHotCornerMD` scheme and a “My Mac” destination.
- Build and run.

Release (archive):

- In Xcode, Product → Archive (Release configuration).
- Alternatively, push a tag `vX.Y.Z` to let GitHub Actions build and attach a `.dmg` to the corresponding Release.
