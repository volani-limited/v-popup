//
//  AddShoppingListItemFieldView.swift
//  v-popup
//
//  Created by Oliver Bevan on 29/05/2023.
//

import SwiftUI

struct AddShoppingListItemFieldView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    @Binding var focusStateChange: Bool
    
    @State private var newItemTitle: String = ""
    @FocusState private var fieldFocusState: Bool
    
    var body: some View {
        GeometryReader { geometry in
            TextField("Add item...", text: $newItemTitle)
                .focused($fieldFocusState)
                .onChange(of: focusStateChange) { isFocused in
                    if !isFocused {
                        fieldFocusState = false
                        newItemTitle = ""
                    }
                }
                .onSubmit {
                    dataModel.selectedShoppingList.items.append(ShoppingListItem(title: newItemTitle))
                    newItemTitle = ""
                }
             .padding()
             .frame(width: geometry.size.width - 100)
             .background(NeumorphicShape(isHighlighted: true, shape: RoundedRectangle(cornerRadius: 25)))
             .offset(x: 50)
         }
    }
}

struct AddShoppingListItemFieldView_Previews: PreviewProvider {
    static var previews: some View {
        AddShoppingListItemFieldView(focusStateChange: .constant(false))
    }
}

