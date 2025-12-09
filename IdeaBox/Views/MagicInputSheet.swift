//
//  MagicInputSheet.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/4/25.
//

import SwiftUI

struct MagicInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var briefIdeas = ""
    @State private var isGenerating = false
    @State private var generatedIdeas: [Idea] = []
    @State private var showingGeneratedIdeas = false
    @State private var errorMessage: String?
    
    let onSave: ([Idea]) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $briefIdeas)
                    .font(.body)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .padding()
                
                Button {
                    processWithAI()
                } label: {
                    if isGenerating {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 5)
                            Text("Processing...")
                        }
                    } else {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Generate Ideas")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(briefIdeas.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Magic Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingGeneratedIdeas) {
                GeneratedIdeasView(ideas: generatedIdeas) { selectedIdeas in
                    let newIdeas = selectedIdeas.map { Idea(title: $0.title, description: $0.description) }
                    onSave(newIdeas)
                    dismiss()
                }
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }
    
    private func processWithAI() {
        guard !briefIdeas.isEmpty else { return }
        isGenerating = true
        
        Task {
            do {
                // TODO: 生成點子
                showingGeneratedIdeas = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isGenerating = false
        }
    }
}

#Preview {
    MagicInputSheet { newIdeas in
        print("New Ideas: \(newIdeas)")
    }
}
