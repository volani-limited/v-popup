//
//  ShoppingListsView.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListsView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    var body: some View {
        ZStack {
            LinearGradient(Color.backgroundStart, Color.backgroundEnd)
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    ForEach(dataModel.shoppingLists, id: \.id) { shoppingList in
                        ShoppingListsItemView(item: shoppingList)
                    }
                    // add entry field
                }
            }
            
        }
    }
}

struct ShoppingListsView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListsView()
    }
}
