import SwiftUI
import Carbon

@main
struct ClipoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var popover = NSPopover()
    private var statusItem: NSStatusItem?
    private var hotkeyManager = HotkeyManager()
    private var clipboardManager = ClipboardManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipo")
            button.action = #selector(togglePopover)
        }
        
        // Setup popover
        popover.contentSize = NSSize(width: 400, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView()
                .environmentObject(clipboardManager)
        )
        
        // Register hotkey (Cmd+Shift+V)
        hotkeyManager.registerHotkey(
            keyCode: 9, // V key
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.togglePopover()
        }
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}
