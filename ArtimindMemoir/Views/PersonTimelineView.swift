import SwiftUI

// MARK: - Timeline data models

struct TimelineYear: Identifiable {
    let id = UUID()
    let year: Int
    let months: [TimelineMonth]
}

struct TimelineMonth: Identifiable {
    let id = UUID()
    let name: String            // e.g. "May"
    let posts: [TimelinePost]

    var totalPhotos: Int {
        posts.reduce(0) { $0 + $1.images.count }
    }
}

struct TimelinePost: Identifiable {
    let id = UUID()
    let date: String            // e.g. "15 May"
    let images: [String]        // asset names
}

/// Build sample timeline grouped by year → month, newest first.
private func buildTimeline(for person: Person) -> [TimelineYear] {
    let allImages = ["hero-memory", "explore-living-album", "explore-restore",
                     "explore-loved-ones", "wedding-preview", "avatar-man", "avatar-woman", "icon-mascot"]

    let seed = abs(person.name.hashValue)

    func imgs(_ indices: [Int]) -> [String] {
        indices.map { allImages[$0 % allImages.count] }
    }

    return [
        TimelineYear(year: 2026, months: [
            TimelineMonth(name: "May", posts: [
                TimelinePost(date: "15 May", images: imgs([0, 1, 2, 3, 4, 5, 6])),
                TimelinePost(date: "12 May", images: imgs([2, 5])),
                TimelinePost(date: "8 May", images: imgs([7, 3, 1])),
                TimelinePost(date: "3 May", images: imgs([4, 6])),
                TimelinePost(date: "1 May", images: imgs([0, 2, 5, 7])),
            ]),
            TimelineMonth(name: "Apr", posts: [
                TimelinePost(date: "20 Apr", images: imgs([4, 0, 6, 2, 1])),  // +2
                TimelinePost(date: "8 Apr", images: imgs([3])),
            ]),
            TimelineMonth(name: "Feb", posts: [
                TimelinePost(date: "14 Feb", images: imgs([5, 7, 0, 3, 1, 6])),  // +3
            ]),
            TimelineMonth(name: "Jan", posts: [
                TimelinePost(date: "8 Jan", images: imgs([2, 4])),
                TimelinePost(date: "1 Jan", images: imgs([6, 0, 3])),
            ]),
        ]),
        TimelineYear(year: 2025, months: [
            TimelineMonth(name: "Dec", posts: [
                TimelinePost(date: "25 Dec", images: imgs([7, 1, 4, 0, 5, 2, 3, 6])),  // +5
                TimelinePost(date: "10 Dec", images: imgs([3, 5])),
            ]),
            TimelineMonth(name: "Nov", posts: [
                TimelinePost(date: "11 Nov", images: imgs([0, 2, 6])),
            ]),
            TimelineMonth(name: "Sep", posts: [
                TimelinePost(date: "7 Sep", images: imgs([4, 7, 1, 5])),  // +1
                TimelinePost(date: "1 Sep", images: imgs([6])),
            ]),
            TimelineMonth(name: "Aug", posts: [
                TimelinePost(date: "19 Aug", images: imgs([2, 0])),
            ]),
        ]),
        TimelineYear(year: 2024, months: [
            TimelineMonth(name: "Oct", posts: [
                TimelinePost(date: "30 Oct", images: imgs([1, 3, 5, 7, 0])),  // +2
            ]),
            TimelineMonth(name: "Jun", posts: [
                TimelinePost(date: "14 Jun", images: imgs([4, 6])),
                TimelinePost(date: "5 Jun", images: imgs([0, 2, 7])),
            ]),
            TimelineMonth(name: "Mar", posts: [
                TimelinePost(date: "1 Mar", images: imgs([5, 1, 3, 6, 4, 7])),  // +3
            ]),
        ]),
    ]
}

private struct SelectedPhoto: Identifiable {
    let id = UUID()
    let name: String
}

// MARK: - PersonTimelineView

struct PersonTimelineView: View {
    let person: Person
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: String?
    @State private var selectedPost: TimelinePost?
    @State private var editedName: String = ""
    @State private var isEditingName = false
    @FocusState private var nameFieldFocused: Bool
    @State private var currentSlide = 0

    private var timeline: [TimelineYear] {
        buildTimeline(for: person)
    }

    /// All unique images from timeline for the slideshow
    private var slideshowImages: [String] {
        let all = timeline.flatMap { $0.months.flatMap { $0.posts.flatMap { $0.images } } }
        var seen = Set<String>()
        return all.filter { seen.insert($0).inserted }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroBanner

                // Timeline
                ForEach(timeline) { yearGroup in
                    yearSection(yearGroup)
                }
            }
            .padding(.bottom, 120)
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topLeading) {
            // Solid dark control on photo bg (§6.6)
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.black.opacity(0.62)))
                    .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
            }
            .padding(.leading, ArtimindDS.Size.sidePadding)
            .padding(.top, ArtimindDS.Spacing.sm)
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .fullScreenCover(item: Binding(
            get: { selectedImage.map { SelectedPhoto(name: $0) } },
            set: { selectedImage = $0?.name }
        )) { photo in
            PhotoDetailView(imageName: photo.name)
        }
        .sheet(item: $selectedPost) { post in
            PhotoGridView(post: post) { imageName in
                selectedPost = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    selectedImage = imageName
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Person header

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            // Full-bleed slideshow
            TabView(selection: $currentSlide) {
                ForEach(Array(slideshowImages.enumerated()), id: \.offset) { index, img in
                    Image(img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Bottom gradient
            LinearGradient(
                colors: [
                    .clear,
                    .clear,
                    ArtimindDS.ColorToken.appBackground.opacity(0.4),
                    ArtimindDS.ColorToken.appBackground.opacity(0.85),
                    ArtimindDS.ColorToken.appBackground,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 160)

            // Name + count overlay
            VStack(alignment: .leading, spacing: 4) {
                if isEditingName {
                    // Inline text field + confirm button
                    HStack(spacing: 10) {
                        TextField("Enter name", text: $editedName)
                            .font(AppFont.cormorant(.bold, size: 34))
                            .foregroundStyle(.white)
                            .focused($nameFieldFocused)
                            .onSubmit { saveName() }

                        if !editedName.trimmingCharacters(in: .whitespaces).isEmpty {
                            Button { saveName() } label: {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(ArtimindDS.ColorToken.yellow)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onChange(of: nameFieldFocused) {
                        if !nameFieldFocused {
                            // Tap outside → cancel if empty, save if has text
                            if editedName.trimmingCharacters(in: .whitespaces).isEmpty {
                                editedName = ""
                                isEditingName = false
                            } else {
                                saveName()
                            }
                        }
                    }
                } else if person.isUnnamed && editedName.isEmpty {
                    // Tap to name
                    Button {
                        isEditingName = true
                        nameFieldFocused = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Name this person")
                                .font(AppFont.cormorant(.bold, size: 28))
                                .foregroundStyle(.white.opacity(0.5))
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    // Display name + edit icon
                    let displayName = editedName.isEmpty ? person.name : editedName
                    Button {
                        editedName = displayName
                        isEditingName = true
                        nameFieldFocused = true
                    } label: {
                        HStack(spacing: 8) {
                            Text(displayName)
                                .font(AppFont.cormorant(.bold, size: 34))
                                .foregroundStyle(.white)
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .buttonStyle(.plain)
                }

                let total = timeline.reduce(0) { $0 + $1.months.reduce(0) { $0 + $1.posts.count } }
                HStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 12))
                    Text("\(total) memories")
                        .font(AppFont.dmSans(.regular, size: 13))
                }
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
            }
            .padding(.horizontal, ArtimindDS.Size.sidePadding)
            .padding(.bottom, 20)
        }
        .frame(height: 340)
        .clipped()
        .onAppear { startAutoSlide() }
    }

    private func saveName() {
        let trimmed = editedName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            PeopleStore.shared.rename(id: person.id, to: trimmed)
        }
        isEditingName = false
        nameFieldFocused = false
    }

    private func startAutoSlide() {
        guard slideshowImages.count > 1 else { return }
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                currentSlide = (currentSlide + 1) % slideshowImages.count
            }
        }
    }

    // MARK: - Year section

    private func yearSection(_ yearGroup: TimelineYear) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Year marker
            HStack(spacing: 12) {
                Circle()
                    .fill(ArtimindDS.ColorToken.yellow)
                    .frame(width: 14, height: 14)

                Text(String(yearGroup.year))
                    .font(AppFont.cormorant(.bold, size: 26))
                    .foregroundStyle(ArtimindDS.ColorToken.yellow)
            }
            .padding(.leading, ArtimindDS.Size.sidePadding + 5)
            .padding(.bottom, 4)

            // Months with posts (max 3 days per month)
            ForEach(yearGroup.months) { month in
                // Month label + photo count
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(ArtimindDS.ColorToken.stroke.opacity(0.5))
                        .frame(width: 2, height: 14)
                    Text(month.name)
                        .font(AppFont.dmSans(.semibold, size: 14))
                        .foregroundStyle(ArtimindDS.ColorToken.textSecondary)

                    Text("\(month.totalPhotos) photos")
                        .font(AppFont.dmSans(.regular, size: 11))
                        .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                }
                .padding(.leading, ArtimindDS.Size.sidePadding + 11)
                .padding(.bottom, 2)

                // Show max 3 days
                ForEach(month.posts.prefix(3)) { post in
                    timelineRow(post: post)
                }

                // "View all X photos" if more than 3 days
                if month.posts.count > 3 {
                    Button {
                        // Create a combined post with all images for the sheet
                        let allImages = month.posts.flatMap { $0.images }
                        selectedPost = TimelinePost(date: "\(month.name) \(yearGroup.year)", images: allImages)
                    } label: {
                        HStack(spacing: 6) {
                            Text("View all \(month.totalPhotos) photos")
                                .font(AppFont.dmSans(.medium, size: 13))
                                .foregroundStyle(ArtimindDS.ColorToken.blue)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(ArtimindDS.ColorToken.blue)
                        }
                        .padding(.leading, ArtimindDS.Size.sidePadding + 30)
                        .padding(.bottom, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Single timeline row (line + dot + card)

    private func timelineRow(post: TimelinePost) -> some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline rail: line + dot
            VStack(spacing: 0) {
                Rectangle()
                    .fill(ArtimindDS.ColorToken.stroke.opacity(0.5))
                    .frame(width: 2, height: 12)

                Circle()
                    .fill(ArtimindDS.ColorToken.textSecondary)
                    .frame(width: 8, height: 8)

                Rectangle()
                    .fill(ArtimindDS.ColorToken.stroke.opacity(0.5))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 14)
            .padding(.leading, ArtimindDS.Size.sidePadding + 5)

            // Card
            postCard(post: post)
                .padding(.trailing, ArtimindDS.Size.sidePadding)
                .padding(.bottom, 12)
        }
    }

    // MARK: - Post card

    private func postCard(post: TimelinePost) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.date)
                .font(AppFont.dmSans(.medium, size: 12))
                .foregroundStyle(ArtimindDS.ColorToken.textTertiary)

            photoGrid(images: post.images, post: post)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                .fill(ArtimindDS.ColorToken.panel)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
        )
    }

    // MARK: - Photo grid (1-3 images)

    private func tappableImage(_ name: String, height: CGFloat) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture { selectedImage = name }
    }

    @ViewBuilder
    private func photoGrid(images: [String], post: TimelinePost) -> some View {
        let extra = images.count - 3

        switch images.count {
        case 1:
            tappableImage(images[0], height: 180)
                .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous))

        case 2:
            HStack(spacing: 3) {
                ForEach(images, id: \.self) { img in
                    tappableImage(img, height: 140)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous))

        default:
            HStack(spacing: 3) {
                tappableImage(images[0], height: 160)

                VStack(spacing: 3) {
                    tappableImage(images[1], height: 78.5)

                    // Third image or "+N" badge
                    Button {
                        if extra > 0 {
                            selectedPost = post
                        } else {
                            selectedImage = images[2]
                        }
                    } label: {
                        ZStack {
                            Image(images[2])
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 78.5)
                                .clipped()

                            if extra > 0 {
                                Color.black.opacity(0.55)

                                Text("+\(extra)")
                                    .font(AppFont.dmSans(.bold, size: 22))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(height: 78.5)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
            }
            .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.xs, style: .continuous))
        }
    }
}

// MARK: - Photo Grid View (all photos in a post)

struct PhotoGridView: View {
    let post: TimelinePost
    var onImageSelected: ((String) -> Void)?
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
    ]

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: post.date, onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 3) {
                    ForEach(post.images, id: \.self) { img in
                        Image(img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 130)
                            .clipped()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let callback = onImageSelected {
                                    callback(img)
                                }
                            }
                    }
                }
                .padding(.top, 8)
            }
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        PersonTimelineView(person: Person(name: "Grandpa", imageName: "avatar-man"))
    }
    .preferredColorScheme(.dark)
}
