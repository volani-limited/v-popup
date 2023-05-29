//
//  ShoppingListItemView.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListItemView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService

    var item: ShoppingListItem

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text(item.title)
                    .bold()
                    .foregroundColor(.titleText)
                    .padding()
                    .frame(width: geometry.size.width - 100)
                    .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
                    .offset(x: 50)
                Button {
                    dataModel.selectedShoppingList.items = dataModel.selectedShoppingList.items.filter { $0.id != item.id}
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.vRed)
                }
            }
        }
    }
}

struct ShoppingListItemView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListItemView(item: ShoppingListItem(title: "title"))
    }
}
