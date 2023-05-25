//
//  ShoppingListsItem.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListsItemView: View {
    var item: ShoppingList
    var body: some View {
        Text("List created " + (item.created?.formatted(date: .numeric, time: .omitted) ?? ""))
            .padding(.init(top: 30, leading: 10, bottom: 30, trailing: 10))
            .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 10)))
    }
}
