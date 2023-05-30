//
//  ShoppingListsItem.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListsItemView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    @EnvironmentObject var authService: AuthService
    
    var item: ShoppingList

    var body: some View {
       GeometryReader { geometry in
           HStack {
               VStack (alignment: .leading) {
                   Text(item.title).bold().foregroundColor(.titleText) + Text(" | " + "Created " + (item.created?.formatted(date: .numeric, time: .omitted) ?? "")).foregroundColor(.text)
                   Text(item.items.count.description + (item.items.count == 1 ? " item" : " items"))
                       .foregroundColor(.text)
               }
               
               Spacer()

               if item.sharedWith != authService.user?.email {
                   Button {
                       dataModel.deleteShoppingList(id: item.id!)
                   } label: {
                       Image(systemName: "trash").bold().foregroundColor(.vRed)
                   }
               } else {
                   Button {
                       var unsharedItem = item
                       unsharedItem.sharedWith = ""
                       
                       dataModel.selectedShoppingList = unsharedItem
                   } label: {
                       Image(systemName: "x.circle").bold().foregroundColor(.vRed)
                   }
               }
           }
            .padding()
            .frame(width: geometry.size.width - 100)
            .background(NeumorphicShape(isHighlighted: false, shape: RoundedRectangle(cornerRadius: 25)))
            .offset(x: 50)
        }
    }
}
