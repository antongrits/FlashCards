//
//  CardView.swift
//  FlashCards
//
//  Created by Aнтон Гриц on 3.04.25.
//

import SwiftUI
import SwiftData

struct CardView: View {
    let card: CardModel
    
    @State private var isFlipped = false
    @State private var flipBackTask: Task<Void, Never>? = nil
    @Binding var selectionMode: Bool
    
    private func cardImage() -> some View {
        GeometryReader { geometry in
            Image(uiImage: UIImage(data: card.imageData)!)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(20)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.indigo.gradient)
            .frame(height: 260)
            .overlay {
                if !isFlipped {
                    cardImage()
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white.opacity(0.25))
                        .overlay {
                            Text(card.word)
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .lineLimit(8)
                                .truncationMode(.tail)
                                .padding(6)
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        }
                        .padding(20)
                }
            }
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .animation(.linear, value: isFlipped)
            .onTapGesture {
                if !selectionMode {
                    isFlipped.toggle()

                    if !isFlipped {
                        flipBackTask?.cancel()
                        flipBackTask = nil
                        return
                    }

                    flipBackTask = Task {
                        try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
                        if !Task.isCancelled {
                            isFlipped = false
                            flipBackTask = nil
                        }
                    }
                }
            }
            .onDisappear {
                flipBackTask?.cancel()
                flipBackTask = nil
            }
    }
}
