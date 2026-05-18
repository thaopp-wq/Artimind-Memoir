import SwiftUI

struct UploadPhotosPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let maxSelection: Int
    let onComplete: ([Int]) -> Void

    @State private var selectedItems: [Int] = []
    @State private var showFilters = false

    private let totalAssets = 18
    private let gridSpacing: CGFloat = 4

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    mediaGrid
                        .padding(.top, 18)
                        .padding(.bottom, 140)
                }
            }

            bottomActionBar
        }
        .navigationBarHidden(true)
    }

    // MARK: Header — Library title + subtitle + glass actions

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Library")
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(AppColor.labelPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(subtitleText)
                    .font(AppFont.dmSans(.semibold, size: 14))
                    .foregroundColor(AppColor.labelSecondary)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    showFilters.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColor.labelPrimary)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.06)))
                        .overlay(Circle().stroke(Color.white.opacity(0.16), lineWidth: 1))
                        .glassBackground(shape: .circle, interactive: true)
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(AppFont.dmSans(.semibold, size: 15))
                        .foregroundColor(AppColor.labelPrimary)
                        .padding(.horizontal, 18)
                        .frame(height: 44)
                        .background(Capsule().fill(Color.white.opacity(0.06)))
                        .overlay(Capsule().stroke(Color.white.opacity(0.16), lineWidth: 1))
                        .glassBackground(shape: .capsule, interactive: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 8)
    }

    private var subtitleText: String {
        if selectedItems.isEmpty {
            return "Select up to \(maxSelection) photos"
        }
        return "\(selectedItems.count) of \(maxSelection) selected"
    }

    // MARK: Grid

    private var mediaGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: gridSpacing),
                GridItem(.flexible(), spacing: gridSpacing),
                GridItem(.flexible(), spacing: gridSpacing)
            ],
            spacing: gridSpacing
        ) {
            ForEach(0..<totalAssets, id: \.self) { index in
                mediaCell(index)
            }
        }
        .padding(.horizontal, 16)
    }

    private func mediaCell(_ index: Int) -> some View {
        let order = selectedItems.firstIndex(of: index)
        let isSelected = order != nil
        let borderColor: Color = isSelected ? Color(hex: "#00AFC4") : Color.clear

        return Button {
            toggleSelection(index)
        } label: {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: gradientFor(index),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Color.black.opacity(isSelected ? 0.20 : 0.0)

                selectionBadge(order: order)
                    .padding(8)
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 3)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func selectionBadge(order: Int?) -> some View {
        if let order = order {
            ZStack {
                Circle().fill(Color(hex: "#00AFC4"))
                Circle().stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                Text("\(order + 1)")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(.white)
            }
            .frame(width: 26, height: 26)
        } else {
            ZStack {
                Circle().fill(Color.black.opacity(0.25))
                Circle().stroke(Color.white.opacity(0.85), lineWidth: 1.5)
            }
            .frame(width: 26, height: 26)
        }
    }

    // MARK: Bottom floating action bar (glass)

    private var bottomActionBar: some View {
        HStack(spacing: 14) {
            Text(bottomLabel)
                .font(AppFont.dmSans(.semibold, size: 14))
                .foregroundColor(AppColor.labelSecondary)
                .padding(.leading, 18)

            Spacer()

            continueButton
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Capsule().fill(Color.black.opacity(0.45)))
        .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
        .glassBackground(shape: .capsule)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var continueButton: some View {
        Button {
            onComplete(selectedItems)
            dismiss()
        } label: {
            HStack(spacing: 6) {
                Text("Continue")
                    .font(AppFont.dmSans(.bold, size: 15))
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .heavy))
            }
            .foregroundColor(isReady ? .white : AppColor.labelTertiary)
            .padding(.horizontal, 22)
            .frame(height: 48)
            .background(continueButtonBackground)
            .overlay(Capsule().stroke(Color.white.opacity(isReady ? 0.25 : 0.12), lineWidth: 1))
            .glassBackground(shape: .capsule, interactive: true)
        }
        .buttonStyle(.plain)
        .disabled(!isReady)
    }

    @ViewBuilder
    private var continueButtonBackground: some View {
        if isReady {
            Capsule().fill(
                LinearGradient(
                    colors: [Color(hex: "#C90F1C"), Color(hex: "#8E0612")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            Capsule().fill(Color.white.opacity(0.08))
        }
    }

    private var bottomLabel: String {
        if selectedItems.isEmpty {
            return "No photos selected"
        }
        return "\(selectedItems.count)/\(maxSelection) photos"
    }

    private var isReady: Bool {
        selectedItems.count == maxSelection
    }

    // MARK: Helpers

    private func toggleSelection(_ index: Int) {
        if let existing = selectedItems.firstIndex(of: index) {
            selectedItems.remove(at: existing)
        } else if selectedItems.count < maxSelection {
            selectedItems.append(index)
        }
    }

    private func gradientFor(_ index: Int) -> [Color] {
        let palettes: [[Color]] = [
            [Color(hex: "#F1DCA9"), Color(hex: "#C3A066"), Color(hex: "#3E2B16")],
            [Color(hex: "#B9C7B2"), Color(hex: "#75654E"), Color(hex: "#17130F")],
            [Color(hex: "#AD9A74"), Color(hex: "#604C3D"), Color(hex: "#17110E")],
            [Color(hex: "#806E48"), Color(hex: "#473928"), Color(hex: "#14110D")],
            [Color(hex: "#7E6B48"), Color(hex: "#473827"), Color(hex: "#17110E")],
            [Color(hex: "#8B6E4C"), Color(hex: "#45301F"), Color(hex: "#120E0B")],
            [Color(hex: "#77604A"), Color(hex: "#35271E"), Color(hex: "#100D0B")],
            [Color(hex: "#4B4E46"), Color(hex: "#272A29"), Color(hex: "#111214")],
            [Color(hex: "#F3C57C"), Color(hex: "#9A6530"), Color(hex: "#2C1C12")]
        ]
        return palettes[index % palettes.count]
    }
}

#Preview {
    UploadPhotosPickerView(maxSelection: 6, onComplete: { _ in })
        .preferredColorScheme(.dark)
}
