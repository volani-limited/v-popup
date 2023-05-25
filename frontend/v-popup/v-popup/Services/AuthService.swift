//
//  AuthService.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import Foundation
import Firebase

class AuthService: ObservableObject {
    @Published var user: User?
    @Published var localUser: LocalUser?
    
    private(set) var db: Firestore
    
    private var userStateHandle: AuthStateDidChangeListenerHandle?
    private var userFileListener: ListenerRegistration?
    
    init() {
        db = Firestore.firestore()
        registerAuthStateDidChangeListener()
        registerUserFileListener()
    }
    
    func signInAnonymously(completionHandler: @escaping (Error?) -> Void) { // Wrap Firebase built in function, with completionHandler
        Auth.auth().signInAnonymously() { [weak self] authResult, error in //TODO: improve error handling?
            if let error = error {
                print("Anonymous sign in failed.")
                completionHandler(error)
                return
            }
            
            print("User anonymously signed in with uid: " + String(authResult!.user.uid))
            
            self?.setUserFile(user: LocalUser(id: authResult!.user.uid))
            
            completionHandler(nil)
        }
    }
    
    private func setUserFile(user: LocalUser) { //TODO: make async?
        do {
            let _ = try db.collection("users").document(user.id!).setData(from: user)
         }
         catch {
           print(error)
         }
    }
    
    private func registerUserFileListener(for uid: String) {
        if let userFileListener = userFileListener {
            userFileListener.remove() // Remove listener if it exists already
        }
        
        let ref = db.collection("users").document(uid) // If user exists, take UID and build DB reference
            
        userFileListener = ref.addSnapshotListener { documentSnapshot, error in
            if let document = documentSnapshot, document.exists { // Add the listener and set the localUser from the document when it updates
                self.localUser = try! document.data(as: LocalUser.self)
            }
        }
    }
    
    private func registerUserFileListener() {
        if let userFileListener = userFileListener {
            userFileListener.remove() // Remove listener if it exists already
        }
        
        if let user = user {
            let ref = db.collection("users").document(user.uid) // If user exists, take UID and build DB reference
            
            userFileListener = ref.addSnapshotListener { documentSnapshot, error in
                if let document = documentSnapshot, document.exists { // Add the listener and set the localUser from the document when it updates
                    self.localUser = try! document.data(as: LocalUser.self)
                }
            }
        }
    }
    
    private func registerAuthStateDidChangeListener () {
        if let handle = userStateHandle {
            Auth.auth().removeStateDidChangeListener(handle) // Remove handle if it exists already
        }
        
        self.userStateHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in // Add handle and handle cases
            self?.user = user
            if let user = user {
                print("User state changed, uid: " + user.uid)
            } else {
                print("User state changed, user signed out.")
            }
            self?.registerUserFileListener() // Register listener for userFile
        }
    }
}
