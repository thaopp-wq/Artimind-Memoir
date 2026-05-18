import SwiftUI

struct WeddingEditScriptView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var manager = WeddingTributeManager.shared
    @State private var navigateToProcessing = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case brideName, groomName, script
    }

    @State private var isEditingScript = false

    private var template: WeddingTemplate? { manager.selectedTemplate }

    private var speakerName: String {
        guard let t = manager.selectedTemplate else { return "Dad" }
        return t.speakerRole == .father ? "Dad" : "Mom"
    }

    private let maxWords = 50

    private var wordCount: Int {
        manager.scriptText
            .split(separator: " ")
            .filter { !$0.isEmpty }
            .count
    }

    private var isOverLimit: Bool { wordCount > maxWords }

    private var wordCountLabel: AttributedString {
        var str = AttributedString("\(wordCount)/\(maxWords) words")
        str.foregroundColor = isOverLimit ? UIColor(Color(hex: "#F26B8C")) : UIColor(AppColor.labelTertiary)
        str.font = UIFont(name: "DMSans-Regular", size: 12)
        return str
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Writing Message", onBack: { dismiss() })
                .padding(.top, 8)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection
                    sectionDivider
                    namesSection
                    sectionDivider
                    scriptSection
                    sectionDivider
                    footerNote
                }
                .padding(.bottom, 100)
            }

            ctaButton
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .navigationDestination(isPresented: $navigateToProcessing) {
            WeddingProcessingView()
        }
        .onTapGesture { focusedField = nil; isEditingScript = false }
        .onChange(of: manager.brideName) { oldValue, newValue in
            if newValue.isEmpty && !oldValue.isEmpty {
                manager.scriptText = manager.scriptText.replacingOccurrences(of: oldValue, with: "{bride_name}")
            } else if !newValue.isEmpty {
                let search = oldValue.isEmpty ? "{bride_name}" : oldValue
                if !search.isEmpty, manager.scriptText.contains(search) {
                    manager.scriptText = manager.scriptText.replacingOccurrences(of: search, with: newValue)
                }
            }
        }
        .onChange(of: manager.groomName) { oldValue, newValue in
            if newValue.isEmpty && !oldValue.isEmpty {
                manager.scriptText = manager.scriptText.replacingOccurrences(of: oldValue, with: "{groom_name}")
            } else if !newValue.isEmpty {
                let search = oldValue.isEmpty ? "{groom_name}" : oldValue
                if !search.isEmpty, manager.scriptText.contains(search) {
                    manager.scriptText = manager.scriptText.replacingOccurrences(of: search, with: newValue)
                }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("A message for wedding day")
                .font(AppFont.dmSans(.bold, size: 24))
                .foregroundColor(.white)

            Text("Create a loving message in their voice, for the moment they couldn't be there.")
                .font(AppFont.dmSans(.regular, size: 14))
                .foregroundColor(AppColor.labelSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, 8)
    }

    // MARK: - Names

    private var namesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Who is getting married?")
                .font(AppFont.dmSans(.semibold, size: 17))
                .foregroundColor(.white)

            if template?.requiresNames == true {
                HStack(spacing: 12) {
                    nameField(label: "Bride's name", text: $manager.brideName, placeholder: "Emma", field: .brideName)

                    if (template?.nameFields.count ?? 0) > 1 {
                        nameField(label: "Groom's name", text: $manager.groomName, placeholder: "Daniel", field: .groomName)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    private func nameField(label: String, text: Binding<String>, placeholder: String, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFont.dmSans(.medium, size: 12))
                .foregroundColor(AppColor.labelSecondary)

            TextField(placeholder, text: text)
                .font(AppFont.dmSans(.regular, size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1C1C1E"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .focused($focusedField, equals: field)
                .autocorrectionDisabled()
        }
    }

    // MARK: - Script

    private var scriptSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("A message from \(speakerName)")
                .font(AppFont.dmSans(.semibold, size: 17))
                .foregroundColor(.white)

            // Script editor / display
            VStack(alignment: .leading, spacing: 0) {
                if isEditingScript {
                    TextEditor(text: $manager.scriptText)
                        .font(AppFont.dmSans(.regular, size: 15))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .frame(minHeight: 150)
                        .focused($focusedField, equals: .script)
                } else {
                    // Display mode: overflow words highlighted
                    highlightedScriptText
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isEditingScript = true
                            focusedField = .script
                        }
                }

                // Footer row
                HStack {
                    Text(wordCountLabel)

                    Spacer()

                    Button {
                        if let tmpl = template {
                            var text = tmpl.scriptTemplate
                            if !manager.brideName.isEmpty {
                                text = text.replacingOccurrences(of: "{bride_name}", with: manager.brideName)
                            }
                            if !manager.groomName.isEmpty {
                                text = text.replacingOccurrences(of: "{groom_name}", with: manager.groomName)
                            }
                            manager.scriptText = text
                        }
                    } label: {
                        Text("Restore original wording")
                            .font(AppFont.dmSans(.medium, size: 12))
                            .foregroundColor(AppColor.tabActive)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .padding(.top, 6)
            }
            .background(
                RoundedRectangle(cornerRadius: 16).fill(Color(hex: "#1C1C1E"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Highlighted Script Text

    /// Displays the script with words beyond maxWords highlighted in pink.
    private var highlightedScriptText: some View {
        let words = manager.scriptText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

        var attributed = AttributedString()
        for (i, word) in words.enumerated() {
            if i > 0 { attributed.append(AttributedString(" ")) }
            var part = AttributedString(word)
            if i >= maxWords {
                part.foregroundColor = Color(hex: "#E8C840")
                part.backgroundColor = Color(hex: "#E8C840").opacity(0.15)
            } else {
                part.foregroundColor = .white
            }
            part.font = AppFont.dmSans(.regular, size: 15)
            attributed.append(part)
        }

        return Text(attributed)
            .lineSpacing(4)
    }

    // MARK: - Footer Note

    private var footerNote: some View {
        Text(isOverLimit
             ? "Your message is too long. Please keep it under \(maxWords) words for best results."
             : "Shorter messages usually sound more natural and emotional.")
            .font(AppFont.dmSans(.regular, size: 13))
            .foregroundColor(isOverLimit ? Color(hex: "#F26B8C") : AppColor.labelTertiary)
            .padding(.horizontal, AppSpacing.screenPadding)
    }

    // MARK: - Section Divider

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(height: 1)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, 20)
    }

    // MARK: - CTA

    private var ctaButton: some View {
        let ok = !manager.scriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return Button {
            focusedField = nil
            navigateToProcessing = true
        } label: {
            Text("Create video")
                .font(AppFont.dmSans(.bold, size: 17))
                .foregroundColor(ok ? .white : Color(hex: "#6B6B6E"))
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(
                    Capsule().fill(ok ? Color(hex: "#8E0612") : Color(hex: "#2A2A2C"))
                )
        }
        .disabled(!ok).buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.top, 10).padding(.bottom, 14)
    }
}

#Preview {
    NavigationStack {
        WeddingEditScriptView()
            .onAppear {
                let m = WeddingTributeManager.shared
                m.selectTemplate(WeddingTemplate.samples[0])
                m.brideName = "Emma"
                m.groomName = "Daniel"
            }
    }
    .preferredColorScheme(.dark)
}
