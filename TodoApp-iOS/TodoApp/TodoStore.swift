import Foundation

class TodoStore: ObservableObject {
    @Published var items: [TodoItem] = []

    private let saveKey = "SavedTodos"

    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            items = decoded
        }
    }

    func add(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.insert(TodoItem(title: trimmed), at: 0)
        save()
    }

    func toggle(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isCompleted.toggle()
        save()
    }

    func delete(ids: Set<UUID>) {
        items.removeAll { ids.contains($0.id) }
        save()
    }

    func clearCompleted() {
        items.removeAll { $0.isCompleted }
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
