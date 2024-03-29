//
//  ShoppingListView.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    @EnvironmentObject var authService: AuthService
    
    @Binding var slideOverPosition: Int
    
    @State private var shouldDefocusNewField: Bool = false
    @State private var showShareAlert: Bool = false
    @State private var showNotPermanantAccountError: Bool = false
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
                    if authService.user?.email != nil {
                        showShareAlert = true
                    } else {
                        showNotPermanantAccountError = true
                    }
                } label: {
                    ZStack {
                        NeumorphicShape(isHighlighted: false, shape: Circle()).frame(width: 40, height: 40)
                        Image(systemName: "square.and.arrow.up.circle")
                            .foregroundColor(.text)
                    }
                }
                .padding(20)
            }
            .alert("Enter the email address to share to (leave empty to not share)", isPresented: $showShareAlert) {
                TextField("Email...", text: $shareEmail)
                    .autocapitalization(.none)
                Button("Ok", role: .cancel) {
                    guard shareEmail != authService.user?.email else {
                        return
                    }

                    dataModel.selectedShoppingList.sharedWith = shareEmail.lowercased()
                    authService.sendShareNotification(to: shareEmail.lowercased())
                }
            }
            .alert("You need to sign in with Google to share lists", isPresented: $showNotPermanantAccountError) {
                Button("Ok", role: .cancel) { } //TODO: Add button for Sign in with Google?
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
        .onAppear {
            shareEmail = dataModel.selectedShoppingList.sharedWith
        }
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView(slideOverPosition: .constant(1))
    }
}
