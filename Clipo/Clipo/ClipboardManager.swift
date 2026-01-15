
import Cocoa
import Combine

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    
    private var pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = 0
    private var timer: Timer?
    private let maxItems = 1000
    
    init() {
        loadItems()
        startMonitoring()
    }
    
    // MARK: - Monitoring
    
    func startMonitoring() {
        lastChangeCount = pasteboard.changeCount
        
        // Poll clipboard every 0.5 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        
        captureCurrentClipboard()
    }
    
    // MARK: - Capture
    
    private func captureCurrentClipboard() {
        // Try to get text first
        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            addTextItem(string)
            return
        }
        
        // Try to get image
        if let image = NSImage(pasteboard: pasteboard) {
            addImageItem(image)
            return
        }
        
        // Try to get file URLs
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL], !urls.isEmpty {
            addFileItem(urls)
            return
        }
    }
    
    private func addTextItem(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        
        // Check for URL
        let itemType: ClipboardItemType = isValidURL(text) ? .url : .text
        
        let item = ClipboardItem(
            type: itemType,
            content: data,
            preview: String(text.prefix(200)),
            applicationName: getCurrentApplicationName()
        )
        
        addItem(item)
    }
    
    private func addImageItem(_ image: NSImage) {
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return
        }
        
        let item = ClipboardItem(
            type: .image,
            content: pngData,
            preview: "Image \(Int(image.size.width))x\(Int(image.size.height))",
            applicationName: getCurrentApplicationName()
        )
        
        addItem(item)
    }
    
    private func addFileItem(_ urls: [URL]) {
        let filePaths = urls.map { $0.path }
        guard let data = try? JSONEncoder().encode(filePaths) else { return }
        
        let preview = urls.map { $0.lastPathComponent }.joined(separator: ", ")
        
        let item = ClipboardItem(
            type: .file,
            content: data,
            preview: preview,
            applicationName: getCurrentApplicationName()
        )
        
        addItem(item)
    }
    
    private func addItem(_ item: ClipboardItem) {
        // Avoid duplicates
        if let first = items.first, first.preview == item.preview {
            return
        }
        
        items.insert(item, at: 0)
        
        // Limit history
        if items.count > maxItems {
            items.removeLast()
        }
        
        saveItems()
    }
    
    // MARK: - Paste
    
    func copyToPasteboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        
        switch item.type {
        case .text, .url:
            if let string = String(data: item.content, encoding: .utf8) {
                pasteboard.setString(string, forType: .string)
            }
        case .image:
            if let image = NSImage(data: item.content) {
                pasteboard.writeObjects([image])
            }
        case .file:
            if let filePaths = try? JSONDecoder().decode([String].self, from: item.content) {
                let urls = filePaths.compactMap { URL(fileURLWithPath: $0) }
                pasteboard.writeObjects(urls as [NSPasteboardWriting])
            }
        }
        
        // Update change count to prevent re-capturing
        lastChangeCount = pasteboard.changeCount
    }
    
    // MARK: - Storage
    
    private func saveItems() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(items) {
            UserDefaults.standard.set(encoded, forKey: "clipboardItems")
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "clipboardItems"),
           let decoded = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            items = decoded
        }
    }
    
    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    func clearAll() {
        items.removeAll()
        saveItems()
    }
    
    // MARK: - Helpers
    
    private func getCurrentApplicationName() -> String? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        return frontmostApp.localizedName
    }
    
    private func isValidURL(_ string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = .link
        guard let detector = try? NSDataDetector(types: types.rawValue) else {
            return false
        }
        let matches = detector.matches(in: string, range: NSRange(string.startIndex..., in: string))
        return matches.first?.url != nil && !string.contains(" ")
    }
}
