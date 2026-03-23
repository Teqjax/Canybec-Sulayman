import SwiftUI

// MARK: - Filter

enum Filter: String, CaseIterable {
    case all    = "All"
    case active = "Active"
    case done   = "Done"
}

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var store: TodoStore
    @State private var filter: Filter = .all
    @State private var showingAddTask = false

    var filteredItems: [TodoItem] {
        switch filter {
        case .all:    return store.items
        case .active: return store.items.filter { !$0.isCompleted }
        case .done:   return store.items.filter { $0.isCompleted }
        }
    }

    var remainingCount: Int {
        store.items.filter { !$0.isCompleted }.count
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter picker
                Picker("Filter", selection: $filter) {
                    ForEach(Filter.allCases, id: \.self) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 12)

                // List or empty state
                if filteredItems.isEmpty {
                    EmptyStateView(filter: filter)
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            TodoRow(item: item) {
                                withAnimation { store.toggle(item) }
                            }
                        }
                        .onDelete { offsets in
                            let ids = Set(offsets.map { filteredItems[$0].id })
                            withAnimation { store.delete(ids: ids) }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .animation(.default, value: store.items)
                }

                // Bottom bar with remaining count and add button
                BottomBar(remainingCount: remainingCount) {
                    showingAddTask = true
                }
            }
            .navigationTitle("My Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if store.items.contains(where: { $0.isCompleted }) {
                        Button("Clear Done", role: .destructive) {
                            withAnimation { store.clearCompleted() }
                        }
                        .font(.subheadline)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet(isPresented: $showingAddTask)
                    .environmentObject(store)
                    .presentationDetents([.height(210)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - TodoRow

struct TodoRow: View {
    let item: TodoItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(item.isCompleted ? Color.green : Color.secondary)
                    .animation(.spring(duration: 0.3), value: item.isCompleted)

                Text(item.title)
                    .font(.body)
                    .foregroundStyle(item.isCompleted ? Color.secondary : Color.primary)
                    .strikethrough(item.isCompleted, color: .secondary)
                    .animation(.easeInOut(duration: 0.2), value: item.isCompleted)

                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - EmptyStateView

struct EmptyStateView: View {
    let filter: Filter

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: iconName)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.secondary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var iconName: String {
        switch filter {
        case .all:    return "checklist"
        case .active: return "checkmark.circle.fill"
        case .done:   return "star.circle.fill"
        }
    }

    private var title: String {
        switch filter {
        case .all:    return "No Tasks Yet"
        case .active: return "All Done!"
        case .done:   return "Nothing Completed"
        }
    }

    private var subtitle: String {
        switch filter {
        case .all:    return "Tap + to add your first task"
        case .active: return "You have no active tasks"
        case .done:   return "Complete a task to see it here"
        }
    }
}

// MARK: - BottomBar

struct BottomBar: View {
    let remainingCount: Int
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Text(remainingCount == 0 ? "All done!" : "\(remainingCount) remaining")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }
}

// MARK: - AddTaskSheet

struct AddTaskSheet: View {
    @EnvironmentObject var store: TodoStore
    @Binding var isPresented: Bool
    @State private var title = ""
    @FocusState private var focused: Bool

    private var isDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("New Task")
                .font(.headline)
                .padding(.top, 12)

            TextField("What needs to be done?", text: $title)
                .textFieldStyle(.roundedBorder)
                .font(.body)
                .focused($focused)
                .submitLabel(.done)
                .onSubmit(addTask)
                .padding(.horizontal)

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemGray5))
                .foregroundStyle(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Add Task") {
                    addTask()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isDisabled ? Color.blue.opacity(0.3) : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(isDisabled)
            }
            .padding(.horizontal)
        }
        .onAppear { focused = true }
    }

    private func addTask() {
        store.add(title)
        isPresented = false
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(TodoStore())
}
