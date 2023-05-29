//
//  AuthService.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import Foundation
import Firebase
import GoogleSignIn

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
                print("Anonymous sign in failed")
                completionHandler(error)
                return
            }
            
            print("User anonymously signed in with uid: " + String(authResult!.user.uid))
            
            self?.localUser = LocalUser(id: authResult!.user.uid)
            self?.setUserFile()
            
            completionHandler(nil)
        }
    }
    
    func signInWithGoogle() {
        let clientID = FirebaseApp.app()!.options.clientID
        
        let config = GIDConfiguration(clientID: clientID!)
        GIDSignIn.sharedInstance.configuration = config
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene!.windows.first?.rootViewController
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController!) { [weak self] result, error in
            guard error == nil, let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("There was an error signing in with Google")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            self?.user?.link(with: credential) { result, error in
                if let error = error {
                    
                } else {
                    self?.localUser = LocalUser(id: self?.user?.uid, created: self?.localUser?.created, email: self?.user?.email)
                    self?.setUserFile()
                }
            }
        }
    }
    
    private func setUserFile() { //TODO: make async?
        do {
            try db.collection("users").document(self.user!.uid).setData(from: self.localUser)
        }
        catch {
            print("There was an error: " + error.localizedDescription)
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
                self?.signInAnonymously(completionHandler: nil)
                
            }
        }
    }
}
