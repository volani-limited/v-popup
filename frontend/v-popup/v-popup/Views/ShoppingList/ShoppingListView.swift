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
    @State private var showShareAlert: Bool = false
    @State private var shareEmail: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation {
                        slideOverPosition = 0
                    }
                } label: {
                    ZStack {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.text)
                    }
                }.buttonStyle(NeumorphicButtonStyle())
                .padding(20)
                Spacer()
                Button {
                    showShareAlert = true
                } label: {
                    ZStack {
                        NeumorphicShape(isHighlighted: false, shape: Circle()).frame(width: 40, height: 40)
                        Image(systemName: "square.and.arrow.up.circle")
                            .foregroundColor(.text)
                    }
                }
                .padding(20)
            }
            .alert("Enter the email address to share to (leave empty to not share)" $showShareAlert) {
                TextField("Email...", $shareEmail)
                Button("Ok", role: .cancel) {
                    dataModel.selectedShoppingList.sharedWith = shareEmail
                    authService.sendShareNotification(to: shareEmail)
                }
            }
            
            HStack {
                VStack (alignment: .leading) {
                    Text(dataModel.selectedShoppingList.title).font(.title)
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(.titleText)
                    Text("Created: " + (dataModel.selectedShoppingList.created?.formatted(date: .numeric, time: .omitted) ?? ""))
                        .foregroundColor(.text)
                        .bold()
                    Text(dataModel.selectedShoppingList.items.count.description + (dataModel.selectedShoppingList.items.count == 1 ? " item" : " items"))
                        .foregroundColor(.text)
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
