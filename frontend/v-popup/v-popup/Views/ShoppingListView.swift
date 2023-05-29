//
//  ShoppingListView.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    
    @Binding var slideOverPosition: Int
    
    @State private var shouldDefocusNewField: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        slideOverPosition = 0
                    }
                } label: {
                    ZStack {
                        NeumorphicShape(isHighlighted: false, shape: Circle()).frame(width: 40, height: 40)
                        Image(systemName: "arrow.backward").scaledToFit()
                    }
                }
                Spacer()
            }
            
            HStack {
                VStack (alignment: .leading) {
                    Text(dataModel.selectedShoppingList.title).font(.title)
                    Text("" + (dataModel.selectedShoppingList.created?.formatted(date: .numeric, time: .omitted) ?? ""))
                    Text("Items: " + dataModel.selectedShoppingList.items.count.description)
                }
                .padding()
                Spacer()
            }
            
            ScrollView {
                VStack(spacing: 80) {
                    AddShoppingListItemFieldView(focusStateChange: $shouldDefocusNewField)
                    VStack(spacing: 75) {
                        ForEach(dataModel.selectedShoppingList.items, id: \.id) { item in
                            ShoppingListItemView(item: item)
                        }
                    }
                }
            }
            
            Spacer()
            Spacer()

        }
        .onTapGesture {
            shouldDefocusNewField.toggle()
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView(slideOverPosition: .constant(1))
    }
}
