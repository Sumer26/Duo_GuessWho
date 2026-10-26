import SwiftUI
import FaceOffCore

struct QuestionPickerView: View {
    @ObservedObject var store: GameStore
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            Section {
                Text("Choose one question. The answer is calculated from your opponent’s secret. You’ll flip cards yourself.")
                    .foregroundStyle(.secondary)
            }
            ForEach(["Accessories", "Hats", "Facial hair", "Hair"], id: \.self) { category in
                Section(category) {
                    ForEach(Question.allCases.filter { $0.category == category }) { question in
                        let previous = store.game.currentBoard?.history.first { $0.question == question }
                        Button {
                            store.perform { _ = try $0.ask(question) }
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text(question.text).foregroundStyle(previous == nil ? .primary : .secondary)
                                Spacer()
                                if let previous {
                                    Text(previous.answer ? "Yes" : "No").font(.caption.bold()).foregroundStyle(.secondary)
                                } else {
                                    Image(systemName: "arrow.up.right").foregroundStyle(Theme.accent)
                                }
                            }.padding(.vertical, 8)
                        }
                        .disabled(previous != nil || !store.game.canAsk)
                        .accessibilityLabel(question.text)
                        .accessibilityValue(previous.map { "Previously answered \($0.answer ? "yes" : "no")" } ?? "Not asked")
                    }
                }
            }
        }
        .navigationTitle("Ask a question").navigationBarTitleDisplayMode(.inline)
    }
}
