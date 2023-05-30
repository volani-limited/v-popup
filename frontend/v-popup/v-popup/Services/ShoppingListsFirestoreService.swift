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
    @Published var sharedShoppingLists: [ShoppingList]

    @Published var selectedShoppingList: ShoppingList { didSet {
            do {
                try saveSelectedShoppingList()
            } catch {
                print("There was an error saving the shopping list")
            }
        }
    }
    
    private var db: Firestore
    private var uid: String?

    private var shoppingListsListenerRegistration: ListenerRegistration?
    private var sharedShoppingListsListenerRegistration: ListenerRegistration?

    private var subscriptions: Set<AnyCancellable>
    
    init(authService: AuthService) {
        subscriptions = Set<AnyCancellable>()
        shoppingLists = [ShoppingList]()
        sharedShoppingLists = [ShoppingList]()

        selectedShoppingList = ShoppingList(created: Date.now, owner: "", sharedWith: "", title: "", items: [ShoppingListItem]())
        
        self.db = authService.db
    
        authService.$user.sink { [weak self] user in
            self?.uid = user?.uid
            self?.registerShoppingListsListener()

            if let email = user?.email {
                self?.registerSharedShoppingListsListener(for: email)
            } else {
                if let listener = self?.sharedShoppingListsListenerRegistration {
                    listener.remove()
                    self?.sharedShoppingListsListenerRegistration = nil
                }
            }
        }
        .store(in: &subscriptions)
    }
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
    
    private func registerShoppingListsListener() {
        if let listener = shoppingListsListenerRegistration {
            listener.remove()
            shoppingListsListenerRegistration = nil
        }
        
        let query = db.collection("shopping_lists").whereField("owner", isEqualTo: uid?.description)
        shoppingListsListenerRegistration = query.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents in shopping_lists collection")
                return
            }
            
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
    
    private func registerSharedShoppingListsListener(for email: String) {
        if let listener = sharedShoppingListsListenerRegistration {
            listener.remove()
            sharedShoppingListsListenerRegistration = nil
        }
        
        let query = db.collection("shopping_lists").whereField("sharedWith", isEqualTo: email)
        
        sharedShoppingListsListenerRegistration = query.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents in shopping_lists collection")
                return
            }
            
            self?.sharedShoppingLists = documents.compactMap { queryDocumentSnapshot in
                do {
                    return try queryDocumentSnapshot.data(as: ShoppingList.self)
                } catch {
                    print("There was an error decoding the document")
                    return nil
                }
            }
        }
    }
    
    func addShoppingList(withTitle title: String) throws {
        let newList = ShoppingList(owner: uid!, sharedWith: "", title: title, items: [ShoppingListItem]())
        let ref = db.collection("shopping_lists")
        
        try ref.addDocument(from: newList)
    }
    
    func deleteShoppingList(id: String) {
        let ref = db.collection("shopping_lists").document(id)
        
        ref.delete()
    }
    
    func saveSelectedShoppingList() throws {
        let ref = db.collection("shopping_lists").document(selectedShoppingList.id!)
        
        try ref.setData(from: selectedShoppingList)
    }
}
