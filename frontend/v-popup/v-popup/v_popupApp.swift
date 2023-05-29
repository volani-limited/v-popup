//
//  v_popupApp.swift
//  v-popup
//
//  Created by Oliver Bevan on 24/05/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

@main
struct v_popupApp: App {
    private var authService: AuthService
    private var dataService: ShoppingListsFirestoreService
    
    init() {
        FirebaseApp.configure()
        authService = AuthService()
        dataService = ShoppingListsFirestoreService(authService: authService)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(authService).environmentObject(dataService)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
