import SwiftUI

struct PhotoRestorePreviewView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToProcessing = false

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Preview", onBack: { dismiss() })
                .padding(.top, 8)

            Spacer()

            // Photo preview
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .clipShape(RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: ArtimindDS.Radius.md, style: .continuous)
                        .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                        .padding(.horizontal, 24)
                )

            // Info
            Text("This photo will be analyzed and restored by AI")
                .font(AppFont.dmSans(.regular, size: 13))
                .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                .padding(.top, 16)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                Button { navigateToProcessing = true } label: {
                    Text("Restore Now")
                        .font(AppFont.dmSans(.bold, size: 16))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Capsule().fill(.white))
                }
                .buttonStyle(.plain)

                Button { dismiss() } label: {
                    Text("Choose Different Photo")
                        .font(AppFont.dmSans(.medium, size: 14))
                        .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, ArtimindDS.Size.sidePadding)
            .padding(.bottom, 36)
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToProcessing) {
            PhotoRestoreProcessingView(image: image)
        }
    }
}

#Preview {
    NavigationStack {
        PhotoRestorePreviewView(image: UIImage(named: "hero-memory")!)
    }
    .preferredColorScheme(.dark)
}
