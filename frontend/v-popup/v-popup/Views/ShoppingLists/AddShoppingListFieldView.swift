//
//  CreateShoppingListView.swift
//  v-popup
//
//  Created by Oliver Bevan on 29/05/2023.
//

import SwiftUI

struct AddShoppingListFieldView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    @Binding var focusStateChange: Bool
    
    @State private var newTitle: String = ""
    @FocusState private var fieldFocusState: Bool
    
    @State private var showAddError: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            TextField("Add shopping list...", text: $newTitle)
                .focused($fieldFocusState)
                .foregroundColor(.text)
                .onChange(of: focusStateChange) { isFocused in
                    if !isFocused {
                        fieldFocusState = false
                        newTitle = ""
                    }
                }
                .onSubmit {
                    do {
                        try dataModel.addShoppingList(withTitle: newTitle)
                        newTitle = ""
                    } catch {
                        showAddError = true
                    }
                }
                .alert("There was an error adding the shopping list", isPresented: $showAddError) {
                            Button("Ok", role: .cancel) { }
                        }
             .padding()
             .frame(width: geometry.size.width - 100)
             .background(NeumorphicShape(isHighlighted: true, shape: RoundedRectangle(cornerRadius: 25)))
             .offset(x: 50)
         }
    }
}

struct CreateShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        AddShoppingListFieldView(focusStateChange: .constant(false))
    }
}
