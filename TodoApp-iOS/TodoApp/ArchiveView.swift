import SwiftUI

// MARK: - ArchiveView

struct ArchiveView: View {
    @EnvironmentObject var store: TodoStore

    // Completed tasks grouped by the calendar day they were completed, newest first
    var groups: [(date: Date, items: [TodoItem])] {
        let completed = store.items.filter { $0.isCompleted }
        let cal = Calendar.current
        let grouped = Dictionary(grouping: completed) { item in
            cal.startOfDay(for: item.completedAt ?? item.createdAt)
        }
        return grouped
            .map { (date: $0.key, items: $0.value.sorted { ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt) }) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        Group {
            if groups.isEmpty {
                ArchiveEmptyStateView()
            } else {
                List {
                    ForEach(groups, id: \.date) { group in
                        Section(header: Text(sectionTitle(for: group.date))) {
                            ForEach(group.items) { item in
                                ArchiveRow(item: item)
                            }
                            .onDelete { offsets in
                                let ids = Set(offsets.map { group.items[$0].id })
                                withAnimation { store.delete(ids: ids) }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .animation(.default, value: store.items)
            }
        }
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !groups.isEmpty {
                    Button("Clear All", role: .destructive) {
                        withAnimation { store.clearCompleted() }
                    }
                    .font(.subheadline)
                }
            }
        }
    }

    // MARK: - Date formatting

    private func sectionTitle(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date)     { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }

        let daysAgo = cal.dateComponents([.day], from: date, to: cal.startOfDay(for: Date())).day ?? 0
        let formatter = DateFormatter()

        if daysAgo < 7 {
            formatter.dateFormat = "EEEE"                       // Monday
        } else if cal.component(.year, from: date) == cal.component(.year, from: Date()) {
            formatter.setLocalizedDateFormatFromTemplate("MMMMd") // January 15
        } else {
            formatter.dateStyle = .long                          // January 15, 2024
        }
        return formatter.string(from: date)
    }
}

// MARK: - ArchiveRow

struct ArchiveRow: View {
    @EnvironmentObject var store: TodoStore
    let item: TodoItem

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .strikethrough(true, color: .secondary)

                if let completedAt = item.completedAt {
                    Text(completedAt, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Button {
                withAnimation { store.restore(item) }
            } label: {
                Image(systemName: "arrow.uturn.backward.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - ArchiveEmptyStateView

struct ArchiveEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "archivebox")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Archive is Empty")
                .font(.title3.bold())
                .foregroundStyle(.secondary)
            Text("Completed tasks will appear here,\ngrouped by the day you finished them.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ArchiveView()
            .environmentObject(TodoStore())
    }
}
