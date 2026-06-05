import SwiftUI

struct PeopleListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = PeopleStore.shared
    @State private var showAddSheet = false
    @State private var newName = ""
    @State private var nameForSelected = ""
    @State private var selectedToAdd: UUID?
    @State private var selectedPerson: Person?

    private var hiddenPeople: [Person] {
        // People in samplePeople but not yet in the store
        let shownIDs = Set(store.people.map(\.id))
        return samplePeople.filter { !shownIDs.contains($0.id) }
    }

    private var canAdd: Bool {
        selectedToAdd != nil || !newName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(
                title: "People",
                onBack: { dismiss() },
                trailingButton: AnyView(addButton)
            )
            .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    // Add new person card
                    addPersonCard

                    // Existing people
                    ForEach(store.people) { person in
                        PeopleGridCard(person: person)
                            .onTapGesture { selectedPerson = person }
                    }
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(item: $selectedPerson) { person in
            PersonTimelineView(person: person)
        }
        .sheet(isPresented: $showAddSheet, onDismiss: {
            newName = ""
            nameForSelected = ""
            selectedToAdd = nil
        }) {
            addPersonSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Add button (trailing nav)

    private var addButton: some View {
        Button { showAddSheet = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(ArtimindDS.ColorToken.blue)
        }
    }

    // MARK: - Add person card (first item in grid)

    private var addPersonCard: some View {
        Button { showAddSheet = true } label: {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(ArtimindDS.ColorToken.blue)

                Text("Add Person")
                    .font(AppFont.dmSans(.medium, size: 12))
                    .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                    .strokeBorder(
                        ArtimindDS.ColorToken.stroke,
                        style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add person sheet

    private var addPersonSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Add a Person")
                .font(AppFont.dmSans(.semibold, size: 18))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)

            // Select from hidden people
            if !hiddenPeople.isEmpty {
                Text("Select a person")
                    .font(AppFont.dmSans(.medium, size: 13))
                    .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                    .padding(.bottom, 10)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(hiddenPeople) { person in
                            let isSelected = selectedToAdd == person.id
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if isSelected {
                                        selectedToAdd = nil
                                        nameForSelected = ""
                                    } else {
                                        selectedToAdd = person.id
                                        nameForSelected = person.name
                                    }
                                }
                            } label: {
                                Image(person.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                isSelected ? ArtimindDS.ColorToken.blue : ArtimindDS.ColorToken.strokeSoft,
                                                lineWidth: isSelected ? 2.5 : 1
                                            )
                                    )
                                    .overlay(alignment: .bottomTrailing) {
                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(ArtimindDS.ColorToken.blue)
                                                .background(Circle().fill(ArtimindDS.ColorToken.appBackground).padding(2))
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 16)

                // Name field for selected person
                if selectedToAdd != nil {
                    Text("Name this person (optional)")
                        .font(AppFont.dmSans(.medium, size: 13))
                        .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                        .padding(.bottom, 8)

                    TextField("Name", text: $nameForSelected)
                        .font(AppFont.dmSans(.regular, size: 16))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous)
                                .fill(ArtimindDS.ColorToken.panelElevated)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous)
                                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                        )
                        .padding(.bottom, 16)
                }
            }

            // Divider
            if !hiddenPeople.isEmpty && selectedToAdd == nil {
                HStack(spacing: 12) {
                    Rectangle().fill(ArtimindDS.ColorToken.strokeSoft).frame(height: 1)
                    Text("or")
                        .font(AppFont.dmSans(.regular, size: 12))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                    Rectangle().fill(ArtimindDS.ColorToken.strokeSoft).frame(height: 1)
                }
                .padding(.bottom, 16)

                // New name field
                Text("Add a new person")
                    .font(AppFont.dmSans(.medium, size: 13))
                    .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                    .padding(.bottom, 8)

                TextField("Name", text: $newName)
                    .font(AppFont.dmSans(.regular, size: 16))
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous)
                            .fill(ArtimindDS.ColorToken.panelElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous)
                            .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                    )
                    .padding(.bottom, 16)
            }

            // Add button
            Button {
                if let id = selectedToAdd,
                   var person = hiddenPeople.first(where: { $0.id == id }) {
                    let trimmed = nameForSelected.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty { person.name = trimmed }
                    store.add(person)
                } else {
                    let trimmed = newName.trimmingCharacters(in: .whitespaces)
                    let images = ["avatar-man", "avatar-woman"]
                    store.add(Person(name: trimmed, imageName: images.randomElement()!))
                }

                newName = ""
                nameForSelected = ""
                selectedToAdd = nil
                showAddSheet = false
            } label: {
                Text("Add")
                    .font(AppFont.dmSans(.bold, size: 15))
                    .foregroundStyle(canAdd ? .black : AppColor.disabledButtonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Capsule().fill(canAdd ? Color.white : AppColor.disabledButton)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
        }
        .padding(24)
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
    }
}

// MARK: - Grid card

private struct PeopleGridCard: View {
    let person: Person

    var body: some View {
        VStack(spacing: 0) {
            Image(person.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 110)
                .clipped()

            Text(person.isUnnamed ? "Name" : person.name)
                .font(AppFont.dmSans(person.isUnnamed ? .regular : .medium, size: 13))
                .foregroundStyle(person.isUnnamed ? ArtimindDS.ColorToken.textTertiary : .white)
                .italic(person.isUnnamed)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(ArtimindDS.ColorToken.panel)
        }
        .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        PeopleListView()
    }
    .preferredColorScheme(.dark)
}
