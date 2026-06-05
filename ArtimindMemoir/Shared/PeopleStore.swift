import SwiftUI

@MainActor
class PeopleStore: ObservableObject {
    static let shared = PeopleStore()

    @Published var people: [Person] = samplePeople

    func rename(id: UUID, to newName: String) {
        if let index = people.firstIndex(where: { $0.id == id }) {
            people[index].name = newName
        }
    }

    func add(_ person: Person) {
        people.append(person)
    }
}
