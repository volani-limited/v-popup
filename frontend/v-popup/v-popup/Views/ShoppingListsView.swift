//
//  ShoppingListsView.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListsView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    @Binding var slideOverPosition: Int
    
    @State private var shouldDefocusNewField: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text("My\nLists")
                    .font(.title)
                    .padding()
                Spacer()
            }
            
            ScrollView() {
                VStack(spacing: 80) {
                    AddShoppingListFieldView(focusStateChange: $shouldDefocusNewField)
                    VStack(spacing: 75) {
                        ForEach(dataModel.shoppingLists, id: \.id) { shoppingList in
                            ShoppingListsItemView(item: shoppingList)
                                .onTapGesture {
                                    dataModel.selectedShoppingList = shoppingList
                                    withAnimation {
                                        slideOverPosition = 1
                                    }
                                }
                        }
                    }
                }
            }
            
            if false { //!dataModel.sharedShoppingLists.isEmpty {
                HStack {
                    Text("Shared with me").font(.title)
                        .padding()
                    Spacer()
                }
                ScrollView {
                    VStack {
                        ForEach(dataModel.shoppingLists, id: \.id) { shoppingList in
                            ShoppingListsItemView(item: shoppingList)
                                .onTapGesture {
                                    dataModel.selectedShoppingList = shoppingList
                                    withAnimation {
                                        slideOverPosition = 1
                                    }
                                }
                        }
                    }
                }
            }
        }
        .onTapGesture {
            shouldDefocusNewField.toggle()
        }
    }
}

struct ShoppingListsView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListsView(slideOverPosition: .constant(0))
    }
}
