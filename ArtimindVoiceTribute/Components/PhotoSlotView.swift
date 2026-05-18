import SwiftUI
import UIKit

struct PhotoSlotView: View {
    let label: String
    let isRequired: Bool
    let image: UIImage?
    var isDetecting: Bool = false
    var isValid: Bool = false
    let onTap: () -> Void
    var onRemove: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 155)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius))

                    Button {
                        onRemove?()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.65))
                                .frame(width: 26, height: 26)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(8)
                    .buttonStyle(.plain)
                } else {
                    RoundedRectangle(cornerRadius: AppSpacing.cardRadius)
                        .fill(AppColor.backgroundSecondary)
                        .frame(height: 155)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.cardRadius)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                                )
                                .foregroundColor(Color.white.opacity(0.12))
                        )
                        .overlay(
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.08))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        )
                        .onTapGesture(perform: onTap)
                }
            }
            .frame(height: 155)
            .contentShape(Rectangle())
            .onTapGesture {
                if image != nil { } else { onTap() }
            }

            HStack(spacing: 4) {
                Text(label)
                    .font(AppFont.dmSans(.medium, size: 12))
                    .foregroundColor(AppColor.labelPrimary)
                    .lineLimit(1)
                Spacer()
                if isValid {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColor.success)
                } else if isRequired && image == nil {
                    Text("Required")
                        .font(AppFont.dmSans(.regular, size: 11))
                        .foregroundColor(AppColor.requiredLabel)
                }
            }
        }
        .overlay {
            if isDetecting {
                RoundedRectangle(cornerRadius: AppSpacing.cardRadius)
                    .fill(Color.black.opacity(0.28))
                    .frame(height: 155)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

#Preview {
    ZStack {
        AppColor.background.ignoresSafeArea()
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            PhotoSlotView(
                label: "Image of Dad",
                isRequired: true,
                image: nil,
                onTap: {}
            )
            PhotoSlotView(
                label: "Image of Mom",
                isRequired: true,
                image: nil,
                onTap: {}
            )
        }
        .padding(16)
    }
}
