//
//  ContentView.swift
//  v-popup
//
//  Created by Oliver Bevan on 24/05/2023.
//

import SwiftUI
import Firebase

struct RootView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    
    @State var slideOverPosition: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ShoppingListsView(slideOverPosition: $slideOverPosition)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                ShoppingListView(slideOverPosition: $slideOverPosition)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(x: geometry.size.width)
            }
            .background{
                Color.background
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geometry.size.width * 2)
                    .offset(x: geometry.size.width / 2)
            }
            .offset(x: -geometry.size.width * CGFloat(slideOverPosition))
        }
    }
}
