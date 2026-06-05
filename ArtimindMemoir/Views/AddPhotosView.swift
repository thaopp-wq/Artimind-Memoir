import SwiftUI
import Photos
import UIKit

// MARK: - Models

struct AlbumItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let collection: PHAssetCollection?
    static func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool { lhs.id == rhs.id }
}

enum MediaTypeFilter: CaseIterable {
    case all, videos, photos, livePhotos
    var title: String {
        switch self {
        case .all: return "All"
        case .videos: return "Videos"
        case .photos: return "Photos"
        case .livePhotos: return "Live Photos"
        }
    }
}

// MARK: - Photo Library Manager

@MainActor
final class PhotoLibraryManager: ObservableObject {
    @Published var albums: [AlbumItem] = []
    @Published var assets: [PHAsset] = []
    @Published var isAuthorized = false

    func setup(filter: MediaTypeFilter) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized || status == .limited {
            isAuthorized = true
            loadAlbums()
            loadAssets(collection: nil, filter: filter)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] s in
                Task { @MainActor [weak self] in
                    self?.isAuthorized = (s == .authorized || s == .limited)
                    if self?.isAuthorized == true {
                        self?.loadAlbums()
                        self?.loadAssets(collection: nil, filter: filter)
                    }
                }
            }
        }
    }

    func loadAlbums() {
        var items: [AlbumItem] = [AlbumItem(name: "Recents", collection: nil)]
        let smartSpecs: [(String, PHAssetCollectionSubtype)] = [
            ("Favourites", .smartAlbumFavorites),
            ("Videos", .smartAlbumVideos),
            ("Live Photos", .smartAlbumLivePhotos),
            ("Selfies", .smartAlbumSelfPortraits),
            ("Screenshots", .smartAlbumScreenshots),
            ("Panoramas", .smartAlbumPanoramas),
        ]
        for (name, subtype) in smartSpecs {
            let fetch = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: nil)
            if let col = fetch.firstObject, PHAsset.fetchAssets(in: col, options: nil).count > 0 {
                items.append(AlbumItem(name: name, collection: col))
            }
        }
        let opts = PHFetchOptions()
        opts.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: true)]
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: opts)
        userAlbums.enumerateObjects { col, _, _ in
            items.append(AlbumItem(name: col.localizedTitle ?? "Album", collection: col))
        }
        albums = items
    }

    func loadAssets(collection: PHAssetCollection?, filter: MediaTypeFilter) {
        let opts = PHFetchOptions()
        opts.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        opts.fetchLimit = 300
        switch filter {
        case .photos:
            opts.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        case .videos:
            opts.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        case .livePhotos:
            opts.predicate = NSPredicate(format: "mediaType = %d AND (mediaSubtypes & %d) != 0",
                                         PHAssetMediaType.image.rawValue,
                                         PHAssetMediaSubtype.photoLive.rawValue)
        case .all:
            break
        }
        let result: PHFetchResult<PHAsset>
        if let col = collection {
            result = PHAsset.fetchAssets(in: col, options: opts)
        } else {
            result = PHAsset.fetchAssets(with: opts)
        }
        var list: [PHAsset] = []
        result.enumerateObjects { a, _, _ in list.append(a) }
        assets = list
    }
}

// MARK: - Photo Grid Cell

struct PhotoGridCell: View {
    let asset: PHAsset
    let isSelected: Bool
    let selectionOrder: Int?
    var failMarked: Bool = false
    var ineligible: Bool = false
    var onTap: () -> Void
    var onClearIneligible: (() -> Void)? = nil
    @State private var thumbnail: UIImage?

    var body: some View {
        Button(action: onTap) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Group {
                        if let img = thumbnail {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Color(hex: "#1C1C1E")
                        }
                    }
                )
                .overlay(Color.black.opacity(ineligible ? 0.55 : (isSelected ? 0.06 : 0.18)))
                .overlay(alignment: .bottomTrailing) {
                    if asset.mediaType == .video && !ineligible {
                        Text(formatDuration(asset.duration))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2)
                            .padding(.trailing, 5)
                            .padding(.bottom, 5)
                    }
                }
                .overlay(alignment: .topLeading) {
                    if let order = selectionOrder, !ineligible {
                        Text("\(order)")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.black)
                            .frame(width: 22, height: 22)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 1.5))
                            .padding(6)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if ineligible {
                        Button {
                            onClearIneligible?()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Color.black.opacity(0.55)))
                                .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .padding(6)
                    } else if failMarked {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .background(Color(hex: "#F26B8C"))
                            .clipShape(Circle())
                            .padding(6)
                    }
                }
                .overlay {
                    if ineligible {
                        VStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color(hex: "#F26B8C"))
                            Text("Photo Not Eligible")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.6)
                                .padding(.horizontal, 4)
                        }
                        .allowsHitTesting(false)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(borderColor, lineWidth: 2.5)
                )
        }
        .buttonStyle(.plain)
        .disabled(ineligible)
        .onAppear {
            guard thumbnail == nil else { return }
            let opts = PHImageRequestOptions()
            opts.deliveryMode = .opportunistic
            opts.isNetworkAccessAllowed = true
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 400, height: 400),
                                                  contentMode: .aspectFill, options: opts) { img, _ in
                if let img = img { DispatchQueue.main.async { thumbnail = img } }
            }
        }
    }

    private var borderColor: Color {
        if ineligible { return Color(hex: "#F26B8C") }
        if failMarked { return Color(hex: "#F26B8C") }
        if isSelected { return .white }
        return .clear
    }

    private func formatDuration(_ t: TimeInterval) -> String {
        let s = Int(t)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}

// MARK: - Slot Thumbnail

struct SlotThumbnail: View {
    let asset: PHAsset
    @State private var img: UIImage?

    var body: some View {
        Group {
            if let img = img {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                Color(hex: "#1C1C1E")
            }
        }
        .onAppear {
            guard img == nil else { return }
            let opts = PHImageRequestOptions()
            opts.deliveryMode = .opportunistic
            opts.isNetworkAccessAllowed = true
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 120, height: 120),
                                                  contentMode: .aspectFill, options: opts) { result, _ in
                if let result = result { DispatchQueue.main.async { img = result } }
            }
        }
    }
}

// MARK: - Main View

struct AddPhotosView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var library = PhotoLibraryManager()
    @ObservedObject private var generator = GenerationManager.shared
    @Binding var selectedTab: Int

    @State private var selectedFilter: MediaTypeFilter = .all
    @State private var selectedAlbum: AlbumItem? = nil
    @State private var showAlbumSheet = false
    @State private var showQuickMenu = false
    @State private var selectedAssets: [PHAsset] = []
    @State private var navigateToDetecting = false
    /// QA-only flag: when true the next photo cell tapped is "marked as fail" — picking it
    /// and pressing Continue routes the user straight to DetectionFailedView. Long-press the
    /// Continue button to toggle this mode.
    @State private var markFailMode = false
    @State private var failMarkedAssetID: String? = nil

    private let maxSelection = 13
    private let gridColumns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                filterTabs
                if library.isAuthorized {
                    photosGrid
                } else {
                    permissionView
                }
            }

            bottomBar

            quickMenuOverlay
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToDetecting) {
            DetectingFacesView(selectedTab: $selectedTab, selectedAssets: selectedAssets)
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnToAddPhotos)) { _ in
            navigateToDetecting = false
            // Drop the assets that just failed detection — they shouldn't stay in the slot strip.
            selectedAssets.removeAll { generator.ineligibleAssetIDs.contains($0.localIdentifier) }
        }
        .onAppear { library.setup(filter: selectedFilter) }
        .onChange(of: selectedFilter) { _, f in
            library.loadAssets(collection: selectedAlbum?.collection, filter: f)
        }
        .sheet(isPresented: $showAlbumSheet) { albumSheet }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    showQuickMenu.toggle()
                }
            } label: {
                HStack(spacing: 5) {
                    Text(currentCategoryTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .rotationEffect(.degrees(showQuickMenu ? 180 : 0))
                }
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    // MARK: Quick category dropdown (liquid glass)

    @ViewBuilder
    private var quickMenuOverlay: some View {
        if showQuickMenu {
            ZStack(alignment: .topLeading) {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) { showQuickMenu = false }
                    }

                quickMenu
                    .frame(width: 260)
                    .padding(.leading, 18)
                    .padding(.top, 60)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var quickMenu: some View {
        VStack(spacing: 0) {
            quickMenuRow(icon: "rectangle.stack.badge.play", title: "Recents") {
                applyQuick(.recents)
            }
            quickMenuDivider
            quickMenuRow(icon: "play.circle", title: "Videos") {
                applyQuick(.videos)
            }
            quickMenuDivider
            quickMenuRow(icon: "heart", title: "Favorites") {
                applyQuick(.favorites)
            }
            quickMenuDivider
            quickMenuRow(icon: "square.grid.2x2", title: "All albums") {
                withAnimation(.easeInOut(duration: 0.15)) { showQuickMenu = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    showAlbumSheet = true
                }
            }
        }
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        )
        .glassBackground(shape: .rounded(24), interactive: true)
        .shadow(color: .black.opacity(0.45), radius: 22, x: 0, y: 12)
    }

    private var quickMenuDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
            .padding(.leading, 70)
    }

    private func quickMenuRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 18) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)

                Text(title)
                    .font(.system(size: 19, weight: .regular))
                    .foregroundColor(.white)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private enum QuickCategory { case recents, videos, favorites }

    private var currentCategoryTitle: String {
        if let album = selectedAlbum { return album.name }
        switch selectedFilter {
        case .videos: return "Videos"
        case .photos: return "Photos"
        case .livePhotos: return "Live Photos"
        case .all: return "Recents"
        }
    }

    private func applyQuick(_ category: QuickCategory) {
        withAnimation(.easeInOut(duration: 0.15)) { showQuickMenu = false }
        switch category {
        case .recents:
            selectedAlbum = nil
            selectedFilter = .all
            library.loadAssets(collection: nil, filter: .all)
        case .videos:
            selectedAlbum = nil
            selectedFilter = .videos
            library.loadAssets(collection: nil, filter: .videos)
        case .favorites:
            if let fav = library.albums.first(where: { $0.name == "Favourites" || $0.name == "Favorites" }) {
                selectedAlbum = fav
                library.loadAssets(collection: fav.collection, filter: selectedFilter)
            }
        }
    }

    // MARK: Album chips

    private var albumChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(library.albums) { album in
                    Button {
                        selectedAlbum = album.name == "Recents" ? nil : album
                        library.loadAssets(collection: selectedAlbum?.collection, filter: selectedFilter)
                    } label: {
                        Text(album.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isAlbumSelected(album) ? .black : .white.opacity(0.8))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(isAlbumSelected(album) ? Color.white : Color.white.opacity(0.09))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private func isAlbumSelected(_ album: AlbumItem) -> Bool {
        album.name == "Recents" ? selectedAlbum == nil : selectedAlbum == album
    }

    // MARK: Filter tabs

    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(MediaTypeFilter.allCases, id: \.self) { filter in
                Button { selectedFilter = filter } label: {
                    VStack(spacing: 7) {
                        Text(filter.title)
                            .font(.system(size: 14, weight: filter == selectedFilter ? .semibold : .regular))
                            .foregroundColor(filter == selectedFilter ? .white : .white.opacity(0.38))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Rectangle()
                            .fill(filter == selectedFilter ? Color.white : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 2)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
        }
    }

    // MARK: Photo grid

    private var photosGrid: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: gridColumns, spacing: 2) {
                ForEach(library.assets, id: \.localIdentifier) { asset in
                    let idx = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier })
                    let isIneligible = generator.ineligibleAssetIDs.contains(asset.localIdentifier)
                    PhotoGridCell(
                        asset: asset,
                        isSelected: idx != nil,
                        selectionOrder: idx.map { $0 + 1 },
                        failMarked: asset.localIdentifier == failMarkedAssetID,
                        ineligible: isIneligible,
                        onTap: { handleCellTap(asset) },
                        onClearIneligible: { clearIneligible(asset) }
                    )
                }
            }
            .padding(.bottom, 185)
        }
    }

    private func handleCellTap(_ asset: PHAsset) {
        if markFailMode {
            failMarkedAssetID = (failMarkedAssetID == asset.localIdentifier) ? nil : asset.localIdentifier
            markFailMode = false
            return
        }
        toggleSelection(asset)
    }

    private func clearIneligible(_ asset: PHAsset) {
        generator.ineligibleAssetIDs.remove(asset.localIdentifier)
        if let idx = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            selectedAssets.remove(at: idx)
        }
    }

    // MARK: Permission view

    private var permissionView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.28))
            Text("Allow Photo Access")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            Text("Allow access to select photos for your AI album")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Open Settings")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 28).padding(.vertical, 13)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 40)
    }

    // MARK: Bottom bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<maxSelection, id: \.self) { i in slotView(index: i) }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1)
            HStack {
                Text(bottomCaptionText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(markFailMode ? 0.85 : 0.4))
                Spacer()
                Button {
                    guard !selectedAssets.isEmpty else { return }
                    if let failID = failMarkedAssetID,
                       selectedAssets.contains(where: { $0.localIdentifier == failID }) {
                        GenerationManager.shared.forceDetectionFailure = true
                    }
                    navigateToDetecting = true
                } label: {
                    Text("Continue")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(selectedAssets.isEmpty ? .white.opacity(0.22) : .black)
                        .padding(.horizontal, 28).padding(.vertical, 12)
                        .background(selectedAssets.isEmpty ? Color.white.opacity(0.07) : Color.white)
                        .clipShape(Capsule())
                }
                .disabled(selectedAssets.isEmpty)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.6).onEnded { _ in
                        markFailMode.toggle()
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .padding(.bottom, 8)
        }
        .background(Color(hex: "#0F0F0F"))
    }

    private var bottomCaptionText: String {
        if markFailMode {
            return "Tap a photo to mark it as fail-test"
        }
        if let id = failMarkedAssetID, !id.isEmpty {
            return selectedAssets.isEmpty
                ? "Fail-test photo marked · pick photos to continue"
                : "\(selectedAssets.count) of \(maxSelection) selected · fail-test active"
        }
        return selectedAssets.isEmpty
            ? "Select up to \(maxSelection) photos"
            : "\(selectedAssets.count) of \(maxSelection) selected"
    }

    private func slotView(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
                .frame(width: 58, height: 58)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(
                            index == selectedAssets.count ? Color.white.opacity(0.55) : Color.white.opacity(index < selectedAssets.count ? 0 : 0.1),
                            lineWidth: 1.5
                        )
                )
            if index < selectedAssets.count {
                SlotThumbnail(asset: selectedAssets[index])
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack {
                    HStack {
                        Text("\(index + 1)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 17, height: 17)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                            .padding(3)
                        Spacer()
                    }
                    Spacer()
                }
                .frame(width: 58, height: 58)
            } else {
                Text("\(index + 1)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(index == selectedAssets.count ? 0.4 : 0.18))
            }
        }
    }

    // MARK: Album sheet

    private var albumSheet: some View {
        NavigationView {
            List(library.albums) { album in
                Button {
                    selectedAlbum = album.name == "Recents" ? nil : album
                    library.loadAssets(collection: selectedAlbum?.collection, filter: selectedFilter)
                    showAlbumSheet = false
                } label: {
                    HStack {
                        Text(album.name).foregroundColor(.white)
                        Spacer()
                        if isAlbumSelected(album) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 13, weight: .semibold))
                        }
                    }
                }
                .listRowBackground(Color(hex: "#1C1C1E"))
            }
            .listStyle(.plain)
            .background(Color.black)
            .scrollContentBackground(.hidden)
            .navigationTitle("Albums")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { showAlbumSheet = false }.foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func toggleSelection(_ asset: PHAsset) {
        if let idx = selectedAssets.firstIndex(where: { $0.localIdentifier == asset.localIdentifier }) {
            selectedAssets.remove(at: idx)
        } else if selectedAssets.count < maxSelection {
            selectedAssets.append(asset)
        }
    }
}

#Preview {
    NavigationStack { AddPhotosView(selectedTab: .constant(0)) }.preferredColorScheme(.dark)
}
