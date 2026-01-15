import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            itemIcon
                .frame(width: 32, height: 32)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.preview)
                    .lineLimit(3)
                    .font(.system(size: 13))
                
                HStack {
                    if let appName = item.applicationName {
                        Text(appName)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(timeAgo(from: item.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Actions
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: { pasteItem() }) {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Copy to clipboard")
                    
                    Button(action: { deleteItem() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete")
                }
            }
        }
        .padding(12)
        .background(isHovered ? Color.gray.opacity(0.1) : Color.clear)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            pasteItem()
        }
    }
    
    private var itemIcon: some View {
        Group {
            switch item.type {
            case .text:
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.blue)
            case .image:
                if let image = NSImage(data: item.content) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.green)
                }
            case .url:
                Image(systemName: "link.circle.fill")
                    .foregroundColor(.purple)
            case .file:
                Image(systemName: "folder.fill")
                    .foregroundColor(.orange)
            }
        }
        .font(.system(size: 20))
    }
    
    private func pasteItem() {
        clipboardManager.copyToPasteboard(item)
        
        // Simulate paste (Cmd+V)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let source = CGEventSource(stateID: .hidSystemState)
            
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
            keyDown?.flags = .maskCommand
            
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
            keyUp?.flags = .maskCommand
            
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }
    
    private func deleteItem() {
        clipboardManager.deleteItem(item)
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        
        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(seconds / 86400)
            return "\(days)d ago"
        }
    }
}
