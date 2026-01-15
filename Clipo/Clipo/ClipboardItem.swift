import Foundation
import AppKit

enum ClipboardItemType: String, Codable {
    case text
    case image
    case file
    case url
}

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let type: ClipboardItemType
    let content: Data
    var preview: String
    var applicationName: String?
    
    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         type: ClipboardItemType,
         content: Data,
         preview: String,
         applicationName: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.content = content
        self.preview = preview
        self.applicationName = applicationName
    }
}
