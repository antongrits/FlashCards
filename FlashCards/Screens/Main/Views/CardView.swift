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
    @Binding var selectionMode: Bool
    
    private func cardImage() -> some View {
        Image(uiImage: card.imageData != nil ? UIImage(data: card.imageData!)! : UIImage(systemName: "photo")!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(20)
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
                    
                    if !isFlipped { return }

                    Task {
                        try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
                        if isFlipped {
                            isFlipped = false
                        }
                    }
                }
            }
    }
}
