//
//  LogCravingView.swift
//  CravePhone
//
//  RESPONSIBILITY: Displays the Log Craving screen with sections for:
//   - Description
//   - Speech Toggle
//   - Sliders (Intensity, Resistance)
//   - Emotions
//   - Submit Button
//
import SwiftUI

public struct LogCravingView: View {
    @ObservedObject var viewModel: LogCravingViewModel
    @State private var isSubmitting = false
    @FocusState private var isDescriptionFocused: Bool

    public init(viewModel: LogCravingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            CraveTheme.Colors.primaryGradient
                .ignoresSafeArea(.all)
                .onTapGesture {
                    // Dismiss the keyboard on background tap
                    isDescriptionFocused = false
                }

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    CravingDescriptionSectionView(text: $viewModel.cravingDescription)
                        .focused($isDescriptionFocused)

                    CraveSpeechToggleButton(
                        isRecording: viewModel.isRecordingSpeech,
                        onToggle: {
                            viewModel.toggleSpeechRecognition()
                            CraveHaptics.shared.mediumImpact()
                        }
                    )

                    CravingSlidersSectionView(
                        cravingStrength: $viewModel.cravingStrength,
                        resistance: $viewModel.confidenceToResist
                    )

                    CravingEmotionChipsView(
                        selectedEmotions: viewModel.selectedEmotions,
                        onToggleEmotion: { e in
                            viewModel.toggleEmotion(e)
                            CraveHaptics.shared.selectionChanged()
                        }
                    )

                    submitButton
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isDescriptionFocused = false
                }
            }
        }
        .alert(item: $viewModel.alertInfo) { info in
            Alert(
                title: Text(info.title),
                message: Text(info.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var submitButton: some View {
        Button {
            submitCraving()
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 6)
                }
                Text(isSubmitting ? "Saving..." : "Log Craving")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.cornerRadius(8))
            .foregroundColor(.white)
        }
        .disabled(isSubmitting)
    }

    private func submitCraving() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task {
            await viewModel.logCraving()
            isSubmitting = false
            isDescriptionFocused = false
        }
    }
}
