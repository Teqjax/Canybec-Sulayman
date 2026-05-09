import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject var store: TodoStore
    @State private var showingAddTask = false

    var activeItems: [TodoItem] {
        store.items.filter { !$0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if activeItems.isEmpty {
                    ActiveEmptyStateView()
                } else {
                    List {
                        ForEach(activeItems) { item in
                            TodoRow(item: item) {
                                withAnimation { store.toggle(item) }
                            }
                        }
                        .onDelete { offsets in
                            let ids = Set(offsets.map { activeItems[$0].id })
                            withAnimation { store.delete(ids: ids) }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .animation(.default, value: store.items)
                }

                BottomBar(count: activeItems.count) {
                    showingAddTask = true
                }
            }
            .navigationTitle("My Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ArchiveView()
                            .environmentObject(store)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "archivebox")
                            if store.completedCount > 0 {
                                Text("\(store.completedCount)")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
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

struct ActiveEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No Active Tasks")
                .font(.title3.bold())
                .foregroundStyle(.secondary)
            Text("Tap + to add a task")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

// MARK: - BottomBar

struct BottomBar: View {
    let count: Int
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Text(count == 0 ? "All done!" : "\(count) remaining")
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
