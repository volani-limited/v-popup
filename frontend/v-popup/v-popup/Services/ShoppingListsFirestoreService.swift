//
//  ShoppingListsRepositoryService.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import Foundation
import Combine

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class ShoppingListsFirestoreService: ObservableObject {
    @Published var shoppingLists: [ShoppingList]
    
    private var db: Firestore
    private var uid: String?

    private var documentsListenerRegistration: ListenerRegistration?
    
    private var subscriptions: Set<AnyCancellable>
    
    init(authService: AuthService) {
        subscriptions = Set<AnyCancellable>()
        shoppingLists = [ShoppingList]()
        
        self.db = authService.db
        
        authService.$user.compactMap { user in
            user?.uid
        }
        .assign(to: \.uid, on: self)
        .store(in: &subscriptions)
    }
    
    func registerDocumentsListener() {
        if let listener = documentsListenerRegistration {
            listener.remove()
            documentsListenerRegistration = nil
        }
        
        let query = db.collection("shopping_lists").whereField("owner", isEqualTo: uid?.description)
        documentsListenerRegistration = query.addSnapshotListener { [weak self] (querySnapshot, error) in

            guard let documents = querySnapshot?.documents else {
                print("No documents in shopping_lists collection")
                return
            }
            
            print(documents)
            
            self?.shoppingLists = documents.compactMap { queryDocumentSnapshot in
                do {
                    return try queryDocumentSnapshot.data(as: ShoppingList.self)
                } catch {
                    print("There was an error decoding the document")
                    return nil
                }
            }
        }
    }
}
