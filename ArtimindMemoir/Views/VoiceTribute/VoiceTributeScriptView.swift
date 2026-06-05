import SwiftUI

struct VoiceTributeScriptView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var session = VoiceTributeSession.shared
    @State private var navigateToProcessing = false
    @State private var speakerName = ""
    @State private var listenerName = ""
    @State private var showPrompts = false
    @FocusState private var focusedField: Field?

    private let maxWords = 50
    private let defaultScript = "My bae, I want you to know how proud I am of the person you\u{2019}ve become. Every day, I see the kindness in your heart and it fills me with joy. I am always with you."

    private let scriptPrompts: [(String, String)] = [
        ("Memorial", "I may not be there in person, but I\u{2019}m always with you. I\u{2019}m so proud of who you\u{2019}ve become."),
        ("Birthday", "Happy birthday! I wish I could be there to celebrate with you. You bring so much joy to everyone around you."),
        ("Wedding", "Today you begin a beautiful new chapter. Even though I can\u{2019}t be there, my love is with you always."),
        ("Thank You", "Thank you for everything you\u{2019}ve done for me. Your kindness has meant more than words can say."),
        ("Encouragement", "I believe in you more than you know. Keep going, keep shining. I\u{2019}m cheering for you every step of the way."),
        ("Comfort", "When the world feels heavy, remember you are never alone. Close your eyes and feel me right beside you."),
        ("Celebration", "Look at how far you\u{2019}ve come! I am so incredibly proud. This moment is yours and you deserve every bit of it."),
    ]

    private enum Field {
        case speaker, listener, script
    }

    private var assembledScript: String {
        var text = session.scriptText
        if !speakerName.isEmpty {
            text = text.replacingOccurrences(of: "{speaker}", with: speakerName)
        }
        if !listenerName.isEmpty {
            text = text.replacingOccurrences(of: "{listener}", with: listenerName)
        }
        return text
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Write Script", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero text
                    VStack(alignment: .leading, spacing: 8) {
                        (
                            Text("What would they\n")
                                .font(AppFont.cormorant(.bold, size: 28))
                                .foregroundColor(.white)
                            +
                            Text("say to you?")
                                .font(AppFont.cormorant(.regular, size: 28).italic())
                                .foregroundColor(ArtimindDS.ColorToken.textSecondary)
                        )

                        Text("Write the words you wish you could hear them say one more time.")
                            .font(AppFont.dmSans(.regular, size: 13))
                            .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                            .lineSpacing(2)
                    }

                    // Who is speaking
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Who is speaking?")
                            .font(AppFont.dmSans(.semibold, size: 14))
                            .foregroundStyle(.white)

                        TextField("", text: $speakerName, prompt: Text("Dad, Mom, Grandpa...")
                            .foregroundStyle(ArtimindDS.ColorToken.textTertiary))
                            .font(AppFont.dmSans(.regular, size: 15))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(ArtimindDS.ColorToken.panelElevated)
                            )
                            .focused($focusedField, equals: .speaker)
                    }


                    // Their message
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(speakerName.isEmpty ? "Their message" : "A message from \(speakerName)")
                                .font(AppFont.dmSans(.semibold, size: 14))
                                .foregroundStyle(.white)
                            Spacer()
                        }

                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $session.scriptText)
                                .font(AppFont.dmSans(.regular, size: 15))
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 180)
                                .focused($focusedField, equals: .script)

                            if session.scriptText.isEmpty {
                                Text("Write their message here...")
                                    .font(AppFont.dmSans(.regular, size: 15))
                                    .foregroundStyle(ArtimindDS.ColorToken.textTertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(14)
                        .overlay(alignment: .bottomTrailing) {
                            Button { showPrompts.toggle() } label: {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle().fill(ArtimindDS.ColorToken.blue)
                                    )
                            }
                            .padding(10)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(ArtimindDS.ColorToken.panelElevated)
                        )

                        // Word count + restore
                        HStack {
                            Text("\(session.wordCount)/\(maxWords) words")
                                .font(AppFont.dmSans(.medium, size: 12))
                                .foregroundStyle(
                                    session.wordCount > maxWords
                                    ? Color(hex: "#F2333F")
                                    : ArtimindDS.ColorToken.textTertiary
                                )

                            Spacer()

                            if !session.scriptText.isEmpty {
                                Button {
                                    session.scriptText = defaultScript
                                } label: {
                                    Text("Restore original wording")
                                        .font(AppFont.dmSans(.medium, size: 12))
                                        .foregroundStyle(ArtimindDS.ColorToken.blue)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Warning
                    if session.wordCount > maxWords {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "#F2333F"))
                            Text("Your message is too long. Please keep it under \(maxWords) words for best results.")
                                .font(AppFont.dmSans(.regular, size: 12))
                                .foregroundStyle(Color(hex: "#F2333F").opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, ArtimindDS.Size.sidePadding)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }
            .onTapGesture { focusedField = nil }

            // Continue button
            Button { navigateToProcessing = true } label: {
                Text("Continue")
                    .font(AppFont.dmSans(.bold, size: 16))
                    .foregroundStyle(session.hasScript ? .black : AppColor.disabledButtonText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Capsule().fill(session.hasScript ? Color.white : AppColor.disabledButton)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!session.hasScript)
            .padding(.horizontal, ArtimindDS.Size.sidePadding)
            .padding(.bottom, 32)
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showPrompts) {
            promptPickerSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .navigationDestination(isPresented: $navigateToProcessing) {
            VoiceTributeProcessingView()
        }
        .onAppear {
            if session.scriptText.isEmpty {
                session.scriptText = defaultScript
            }
        }
    }

    // MARK: - Prompt Picker Sheet

    private var promptPickerSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Choose a prompt")
                .font(AppFont.dmSans(.bold, size: 18))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(scriptPrompts, id: \.0) { prompt in
                        Button {
                            session.scriptText = prompt.1
                            showPrompts = false
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(prompt.0)
                                    .font(AppFont.dmSans(.semibold, size: 14))
                                    .foregroundStyle(.white)

                                Text(prompt.1)
                                    .font(AppFont.dmSans(.regular, size: 12))
                                    .foregroundStyle(ArtimindDS.ColorToken.textSecondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                                    .fill(ArtimindDS.ColorToken.panel)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: ArtimindDS.Radius.sm, style: .continuous)
                                    .stroke(ArtimindDS.ColorToken.strokeSoft, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(ArtimindDS.ColorToken.appBackground.ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        VoiceTributeScriptView()
    }
    .preferredColorScheme(.dark)
}
