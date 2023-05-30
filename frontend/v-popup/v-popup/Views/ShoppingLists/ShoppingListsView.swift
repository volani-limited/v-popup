//
//  ShoppingListsView.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import SwiftUI

struct ShoppingListsView: View {
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService
    @EnvironmentObject var authService: AuthService

    @Binding var slideOverPosition: Int
    
    @State private var shouldDefocusNewField: Bool = false
    @State private var showAuthAlert: Bool = false
    @State private var showAuthErrorAlert: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("My\nLists")
                    .bold()
                    .font(.largeTitle)
                    .foregroundColor(.titleText)
                    .padding()
                Spacer()
                Button {
                    showAuthAlert = true
                } label: {
                    Image(systemName: "person.circle").foregroundColor(.text)
                }
                .buttonStyle(NeumorphicButtonStyle())
                .padding()
                .alert("Log in status", isPresented: $showAuthAlert) {
                    if (authService.user?.email != nil) {
                        Button(role: .destructive) {
                            do {
                                try authService.signOut()
                            } catch {
                                showAuthErrorAlert = true
                            }
                        } label: {
                            Text("Sign out")
                        }
                        
                        Button("Ok", role: .cancel) { }

                    } else {
                        Button {
                            Task {
                                do {
                                    try await authService.signInWithGoogle()
                                } catch {
                                    showAuthAlert = false
                                    showAuthErrorAlert = true
                                }
                            }
                        } label: {
                            Text("Sign in with Google")
                        }
                        
                        Button("Ok", role: .cancel) {
                            
                        }
                    }
                } message: {
                    if (authService.user?.email != nil) {
                        Text("Currently signed in with Google")
                    } else {
                        Text("Currently signed in anonymously")
                    }
                }
                .alert("There was an error siging in/out with Google", isPresented: $showAuthErrorAlert) {
                            Button("Ok", role: .cancel) { }
                }
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
            
            if !dataModel.sharedShoppingLists.isEmpty {
                HStack {
                    Text("Shared\nwith me")
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(.titleText)
                        .padding()
                    Spacer()
                }
                ScrollView {
                    VStack(spacing: 80) {
                        ForEach(dataModel.sharedShoppingLists, id: \.id) { shoppingList in
                            ShoppingListsItemView(item: shoppingList)
                                .onTapGesture {
                                    dataModel.selectedShoppingList = shoppingList
                                    withAnimation {
                                        slideOverPosition = 1
                                    }
                                }
                        }
                    }
                    .padding(.top, 40)
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
