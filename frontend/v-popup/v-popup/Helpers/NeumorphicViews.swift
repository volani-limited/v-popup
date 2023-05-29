//
//  NeumorphicViews.swift
//  hibernia-ios
//
//  Created by Oliver Bevan on 02/10/2022.
//

import SwiftUI

struct NeumorphicShape<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        if isHighlighted {
            shape
                .fill(
                    Color.background
                        .shadow(.inner(color: .backgroundEnd, radius: 3, x: 3, y: 3))
                        .shadow(.inner(color: .white, radius: 3, x: -3, y: -3))
                )
        } else {
            shape
                .fill(Color.background)
                .shadow(color: Color.backgroundEnd, radius: 10, x: 10, y: 10)
                .shadow(color: Color.white, radius: 10, x: -5, y: -5)
        }
    }
}

struct NeumorphicButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Group {
                    if configuration.isPressed {
                        Circle().fill(
                            Color.background
                                .shadow(.inner(color: .backgroundEnd, radius: 3, x: 3, y: 3))
                                .shadow(.inner(color: .white, radius: 3, x: -3, y: -3))
                        )
                    } else {
                        Circle()
                            .fill(Color.background)
                            .shadow(color: Color.backgroundEnd, radius: 10, x: 10, y: 10)
                            .shadow(color: Color.white, radius: 10, x: -5, y: -5)
                    }
                }
            )
        }
}

struct NeumorphicPreviews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.background.edgesIgnoringSafeArea(.all)
            VStack {
                NeumorphicShape(isHighlighted: true, shape: RoundedRectangle(cornerRadius: 25)).frame(width: 300, height: 60)
                NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)).frame(width: 300, height: 60)
    
                HStack {
                    VStack (alignment: .leading) {
                        Text("Item")
                    }
                    Button {
                        
                    } label: {
                        Image(systemName: "trash")
                            .bold()
                            .foregroundColor(Color.vRed)
                    }
                }
                .padding()
                .frame(width: 300)
                .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
            }
        }
    }
}
