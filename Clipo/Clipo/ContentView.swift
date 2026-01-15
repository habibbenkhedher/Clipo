import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var searchText = ""
    @State private var selectedFilter: ClipboardItemType? = nil
    
    var filteredItems: [ClipboardItem] {
        var items = clipboardManager.items
        
        // Filter by type
        if let filter = selectedFilter {
            items = items.filter { $0.type == filter }
        }
        
        // Search
        if !searchText.isEmpty {
            items = items.filter { $0.preview.localizedCaseInsensitiveContains(searchText) }
        }
        
        return items
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Filter tabs
            filterTabsView
            
            Divider()
            
            // Items list
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                itemsListView
            }
        }
        .frame(width: 400, height: 600)
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundColor(.blue)
            
            TextField("Search clipboard...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button(action: { clipboardManager.clearAll() }) {
                Image(systemName: "trash")
            }
            .buttonStyle(PlainButtonStyle())
            .help("Clear all")
        }
        .padding()
    }
    
    private var filterTabsView: some View {
        HStack(spacing: 0) {
            FilterButton(title: "All", icon: "square.grid.2x2", isSelected: selectedFilter == nil) {
                selectedFilter = nil
            }
            
            FilterButton(title: "Text", icon: "doc.text", isSelected: selectedFilter == .text) {
                selectedFilter = .text
            }
            
            FilterButton(title: "Images", icon: "photo", isSelected: selectedFilter == .image) {
                selectedFilter = .image
            }
            
            FilterButton(title: "Links", icon: "link", isSelected: selectedFilter == .url) {
                selectedFilter = .url
            }
            
            FilterButton(title: "Files", icon: "folder", isSelected: selectedFilter == .file) {
                selectedFilter = .file
            }
        }
        .padding(.vertical, 8)
    }
    
    private var itemsListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(filteredItems) { item in
                    ClipboardItemRow(item: item)
                        .environmentObject(clipboardManager)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No clipboard items")
                .font(.headline)
            
            Text("Copy something to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 11))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
