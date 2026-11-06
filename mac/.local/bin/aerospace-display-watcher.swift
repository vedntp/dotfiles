// aerospace-display-watcher: ask Solo or Duo when an external screen is connected.
//
// Sleeps until macOS reports a display change (no polling). When a new external
// display appears while the laptop screen is also on, it shows a small dialog:
// Solo (Return, also picked automatically after the timeout) or Duo (D). The
// choice runs `aerospace-profile solo|duo`.
//
// Not asked: at launch, when a screen is unplugged, in the first seconds after
// wake (macOS re-adds displays then), or with the lid closed (only one screen,
// so the profile makes no difference).
//
// Test the dialog without plugging anything in:
//   aerospace-display-watcher --prompt-dry-run   (shows it, logs the choice, changes nothing)
//
// Runs from ~/Library/LaunchAgents/com.vp.aerospace-display-watcher.plist.
// Log: ~/Library/Logs/aerospace-display-watcher.log

import AppKit
import CoreGraphics
import Foundation

private let settleDelay: TimeInterval = 2.5      // HDMI often flickers while connecting
private let wakeGrace: TimeInterval = 20         // ignore display churn right after wake
private let promptTimeout: Int = 5              // seconds before Solo is picked
private let profileScript = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".local/bin/aerospace-profile").path
private let logURL = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Logs/aerospace-display-watcher.log")

private func log(_ message: String) {
    let line = "\(ISO8601DateFormatter().string(from: Date())) \(message)\n"
    guard let data = line.data(using: .utf8) else { return }
    if let handle = try? FileHandle(forWritingTo: logURL) {
        handle.seekToEndOfFile()
        handle.write(data)
        try? handle.close()
    } else {
        try? data.write(to: logURL)
    }
}

private func activeDisplays() -> (externals: Set<CGDirectDisplayID>, builtInOn: Bool) {
    var count: UInt32 = 0
    CGGetActiveDisplayList(0, nil, &count)
    var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
    CGGetActiveDisplayList(count, &ids, &count)
    var externals = Set<CGDirectDisplayID>()
    var builtInOn = false
    for id in ids.prefix(Int(count)) {
        if CGDisplayIsBuiltin(id) != 0 { builtInOn = true } else { externals.insert(id) }
    }
    return (externals, builtInOn)
}

private final class Watcher {
    private var knownExternals = activeDisplays().externals
    private var settleTimer: Timer?
    private var lastWake = Date.distantPast
    private var prompting = false

    init() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.lastWake = Date()
            log("wake")
        }
        log("started, externals=\(knownExternals.count)")
    }

    func displaysChanged() {
        settleTimer?.invalidate()
        settleTimer = Timer.scheduledTimer(withTimeInterval: settleDelay, repeats: false) { [weak self] _ in
            self?.settled()
        }
    }

    private func settled() {
        let (externals, builtInOn) = activeDisplays()
        let added = externals.subtracting(knownExternals)
        knownExternals = externals
        guard !added.isEmpty else { return }

        let sinceWake = Date().timeIntervalSince(lastWake)
        if sinceWake < wakeGrace { log("external added \(sinceWake.rounded())s after wake, not asking"); return }
        if !builtInOn { log("external added with lid closed, not asking"); return }
        if prompting { return }

        log("external added (\(added.count)), asking")
        let choice = ask()
        apply(choice)
    }

    func ask() -> String {
        prompting = true
        defer { prompting = false }

        let alert = NSAlert()
        alert.messageText = "Screen connected"
        alert.informativeText = "Solo: laptop is home, side-screen workspaces on the external screen.\n"
            + "Duo: the full two-screen split.\n\nPicking Solo in \(promptTimeout)s."
        let solo = alert.addButton(withTitle: "Solo")
        solo.keyEquivalent = "\r"
        let duo = alert.addButton(withTitle: "Duo")
        duo.keyEquivalent = "d"
        alert.window.level = .floating

        var remaining = promptTimeout
        let timer = Timer(timeInterval: 1, repeats: true) { t in
            remaining -= 1
            if remaining <= 0 {
                t.invalidate()
                NSApp.stopModal(withCode: .alertFirstButtonReturn)
            } else {
                alert.informativeText = alert.informativeText.replacingOccurrences(
                    of: #"in \d+s\."#, with: "in \(remaining)s.", options: .regularExpression)
            }
        }
        RunLoop.main.add(timer, forMode: .modalPanel)

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        timer.invalidate()
        let choice = response == .alertSecondButtonReturn ? "duo" : "solo"
        log("chose \(choice)\(remaining <= 0 ? " (timeout)" : "")")
        return choice
    }

    private func apply(_ profile: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [profileScript, profile]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            log("aerospace-profile \(profile): exit \(process.terminationStatus) \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
        } catch {
            log("aerospace-profile \(profile) failed to start: \(error)")
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)   // no Dock icon, no menu bar

if CommandLine.arguments.contains("--prompt-dry-run") {
    let watcher = Watcher()
    print(watcher.ask())
    exit(0)
}

private let watcher = Watcher()

CGDisplayRegisterReconfigurationCallback({ _, flags, _ in
    if flags.contains(.beginConfigurationFlag) { return }
    DispatchQueue.main.async { watcher.displaysChanged() }
}, nil)

app.run()
