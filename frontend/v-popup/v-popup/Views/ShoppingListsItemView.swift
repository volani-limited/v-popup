//
//  ShoppingListsItem.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListsItemView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService

    var item: ShoppingList
    var body: some View {
       GeometryReader { geometry in
           HStack {
               VStack (alignment: .leading) {
                   Text(item.title).bold() + Text(" | " + "Created " + (item.created?.formatted(date: .numeric, time: .omitted) ?? ""))
                   Text(item.items.count.description + " items")
               }
               Button {
                   dataModel.deleteShoppingList(id: item.id!)
               } label: {
                   Image(systemName: "trash")
               }
           }
            .padding()
            .frame(width: geometry.size.width - 100)
            .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
            .offset(x: 50)
        }
    }
}
