//
//  ContentView.swift
//  v-popup
//
//  Created by Oliver Bevan on 24/05/2023.
//

import SwiftUI
import Firebase

struct RootView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var dataModel: ShoppingListsFirestoreService

    var body: some View {
        ShoppingListsView()
        .onAppear {
            if authService.user == nil {
                authService.signInAnonymously { error in
                    if error == nil {
                        dataModel.registerDocumentsListener()
                    }
                }
            }
        }
    }
}
