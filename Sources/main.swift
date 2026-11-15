import AppKit
import Foundation
import ServiceManagement

@main
final class VPNMenuBarApp: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static func main() {
        let app = NSApplication.shared
        let delegate = VPNMenuBarApp()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }

    private var item: NSStatusItem!
    private var timer: Timer?
    private var status: VPNStatus = .unknown
    private let menu = NSMenu()
    private var settingsWindow: NSWindow?
    private var wells: [NSColorWell] = []
    private var loginCheckbox: NSButton?
    private var loginMessage: NSTextField?
    private let defaults = UserDefaults.standard

    func applicationDidFinishLaunching(_ notification: Notification) {
        item = NSStatusBar.system.statusItem(withLength: 28)
        item.button?.imagePosition = .imageOnly
        item.button?.title = ""
        item.menu = menu
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in self?.refresh() }
    }

    private func refresh() {
        let (output, ok) = run("/usr/sbin/scutil", ["--nc", "list"])
        // Tunnelblick starts its own OpenVPN executable, which is not necessarily
        // registered as a macOS VPN service visible to scutil.
        let (processes, processCheckOK) = run("/bin/ps", ["-axo", "command="])
        let tunnelblick = processCheckOK && processes.components(separatedBy: .newlines).contains { line in
            let command = line.trimmingCharacters(in: .whitespaces)
            return command.hasPrefix("/Applications/Tunnelblick.app/Contents/Resources/openvpn/") &&
                   command.contains("/openvpn")
        }
        if !ok && !tunnelblick { status = .unknown }
        else {
            let active = ok ? output.components(separatedBy: .newlines).filter {
                $0.range(of: #"\(Connected\)"#, options: .regularExpression) != nil
            } : []
            let joined = active.joined(separator: "\n").lowercased()
            let surf = joined.contains("com.surfshark.vpnclient.macos")
            let wg = joined.contains("com.wireguard.macos")
            let unknownService = active.contains { line in
                let lower = line.lowercased()
                return !lower.contains("com.surfshark.vpnclient.macos") &&
                       !lower.contains("com.wireguard.macos")
            }
            let detectedConnections = [surf, wg, tunnelblick, unknownService]
            let count = detectedConnections.filter { $0 }.count
            if count > 1 || unknownService || !ok { status = .unknown }
            else if tunnelblick { status = .tunnelblick }
            else if surf { status = .surfshark }
            else if wg { status = .wireguard }
            else { status = .none }
        }
        updateDot()
        updateMenu()
    }

    private func updateDot() {
        let image = NSImage(size: NSSize(width: 24, height: 24), flipped: false) { [weak self] _ in
            guard let self = self else { return false }
            self.color(for: self.status).setFill()
            NSBezierPath(ovalIn: NSRect(x: 3, y: 3, width: 18, height: 18)).fill()
            return true
        }
        image.isTemplate = false
        item.button?.image = image
        item.button?.toolTip = status.title
    }

    private func color(for status: VPNStatus) -> NSColor {
        if let data = defaults.data(forKey: status.key),
           let stored = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            return stored
        }
        return status.defaultColor
    }

    private func updateMenu() {
        menu.removeAllItems()
        let info = NSMenuItem(title: status.title, action: nil, keyEquivalent: "")
        info.isEnabled = false
        menu.addItem(info)
        menu.addItem(.separator())
        let settings = NSMenuItem(title: "Einstellungen …", action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)
        let refreshItem = NSMenuItem(title: "Jetzt prüfen", action: #selector(refreshClicked), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)
        let quit = NSMenuItem(title: "Beenden", action: #selector(quitClicked), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    @objc private func refreshClicked() { refresh() }
    @objc private func quitClicked() { NSApplication.shared.terminate(nil) }

    @objc private func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 440, height: 398),
                              styleMask: [.titled, .closable, .miniaturizable],
                              backing: .buffered, defer: false)
        window.title = "VPN Menu Bar – Einstellungen"
        window.center()
        window.isReleasedWhenClosed = false
        window.delegate = self
        let content = NSView(frame: NSRect(x: 0, y: 0, width: 440, height: 398))
        window.contentView = content

        let heading = label("Farben der Menüleistenanzeige", frame: NSRect(x: 24, y: 348, width: 370, height: 26), size: 17, bold: true)
        content.addSubview(heading)
        let statuses: [VPNStatus] = [.wireguard, .surfshark, .tunnelblick, .none, .unknown]
        wells = []
        for (index, vpn) in statuses.enumerated() {
            let y = 301 - CGFloat(index) * 43
            content.addSubview(label(vpn.settingsName, frame: NSRect(x: 28, y: y, width: 260, height: 25), size: 14))
            let well = NSColorWell(frame: NSRect(x: 330, y: y - 2, width: 78, height: 30))
            well.color = color(for: vpn)
            well.tag = index
            well.target = self
            well.action = #selector(colorChanged(_:))
            content.addSubview(well)
            wells.append(well)
        }
        let reset = NSButton(title: "Standardfarben wiederherstellen", target: self, action: #selector(resetColors))
        reset.frame = NSRect(x: 24, y: 83, width: 250, height: 25)
        content.addSubview(reset)

        let checkbox = NSButton(checkboxWithTitle: "Automatisch bei Anmeldung starten", target: self, action: #selector(toggleLogin(_:)))
        checkbox.frame = NSRect(x: 24, y: 52, width: 370, height: 24)
        checkbox.state = SMAppService.mainApp.status == .enabled ? .on : .off
        content.addSubview(checkbox)
        loginCheckbox = checkbox
        let note = label("Start bei Anmeldung erfordert eine App im Programme-Ordner.", frame: NSRect(x: 27, y: 20, width: 390, height: 25), size: 11)
        note.textColor = .secondaryLabelColor
        content.addSubview(note)
        loginMessage = note
        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func label(_ text: String, frame: NSRect, size: CGFloat, bold: Bool = false) -> NSTextField {
        let field = NSTextField(labelWithString: text)
        field.frame = frame
        field.font = bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
        return field
    }

    @objc private func colorChanged(_ sender: NSColorWell) {
        let statuses: [VPNStatus] = [.wireguard, .surfshark, .tunnelblick, .none, .unknown]
        guard statuses.indices.contains(sender.tag) else { return }
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: sender.color, requiringSecureCoding: true) {
            defaults.set(data, forKey: statuses[sender.tag].key)
        }
        updateDot()
    }

    @objc private func resetColors() {
        let statuses: [VPNStatus] = [.wireguard, .surfshark, .tunnelblick, .none, .unknown]
        for (index, vpn) in statuses.enumerated() {
            defaults.removeObject(forKey: vpn.key)
            wells[index].color = vpn.defaultColor
        }
        updateDot()
    }

    @objc private func toggleLogin(_ sender: NSButton) {
        do {
            if sender.state == .on { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
            loginMessage?.stringValue = sender.state == .on ? "Autostart aktiviert." : "Autostart deaktiviert."
        } catch {
            sender.state = SMAppService.mainApp.status == .enabled ? .on : .off
            loginMessage?.stringValue = "Autostart konnte nicht geändert werden: \(error.localizedDescription)"
        }
    }

    private func run(_ executable: String, _ args: [String]) -> (String, Bool) {
        let process = Process()
        let output = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = args
        process.standardOutput = output
        process.standardError = Pipe()
        do {
            try process.run()
            let data = output.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            return (String(data: data, encoding: .utf8) ?? "", process.terminationStatus == 0)
        } catch { return ("", false) }
    }
}

enum VPNStatus {
    case wireguard, surfshark, tunnelblick, none, unknown
    var key: String {
        switch self {
        case .wireguard: return "color.wireguard"
        case .surfshark: return "color.surfshark"
        case .tunnelblick: return "color.tunnelblick"
        case .none: return "color.none"
        case .unknown: return "color.unknown"
        }
    }
    var title: String {
        switch self {
        case .wireguard: return "WireGuard aktiv"
        case .surfshark: return "Surfshark aktiv"
        case .tunnelblick: return "Tunnelblick (OpenVPN) aktiv"
        case .none: return "Kein VPN verbunden (laut scutil)"
        case .unknown: return "VPN-Status unklar"
        }
    }
    var settingsName: String {
        switch self {
        case .wireguard: return "WireGuard"
        case .surfshark: return "Surfshark"
        case .tunnelblick: return "Tunnelblick (OpenVPN)"
        case .none: return "Kein VPN"
        case .unknown: return "Unbekannt / mehrere VPNs"
        }
    }
    var defaultColor: NSColor {
        switch self {
        case .wireguard: return NSColor(calibratedRed: 0.86, green: 0.12, blue: 0.12, alpha: 1)
        case .surfshark: return NSColor(calibratedRed: 0.08, green: 0.48, blue: 0.91, alpha: 1)
        case .tunnelblick: return NSColor(calibratedRed: 0.57, green: 0.31, blue: 0.85, alpha: 1)
        case .none: return NSColor(calibratedRed: 0.08, green: 0.65, blue: 0.29, alpha: 1)
        case .unknown: return NSColor(calibratedRed: 0.95, green: 0.58, blue: 0.08, alpha: 1)
        }
    }
}
