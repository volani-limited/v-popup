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
        try! Auth.auth().signOut()
    }
    
    @MainActor
    func signInAnonymously() async throws {
        let authResult = try await Auth.auth().signInAnonymously()
        
        print("User anonymously signed in with uid: " + String(authResult.user.uid))
        
        localUser = LocalUser(id: authResult.user.uid)
        try setUserFile()
    }
    
    @MainActor
    func signInWithGoogle() async throws {
        let clientID = FirebaseApp.app()!.options.clientID
        
        let config = GIDConfiguration(clientID: clientID!)
        GIDSignIn.sharedInstance.configuration = config
        
        let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = await windowScene!.windows.first?.rootViewController
        
        let authResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController!)
        
        let credential = GoogleAuthProvider.credential(withIDToken: authResult.user.idToken!.tokenString, accessToken: authResult.user.accessToken.tokenString)
        
        let oldIDToken = try await self.user?.getIDToken()
        
        do {
            try await self.user?.link(with: credential)
        } catch {
            guard (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue else {
                throw AuthError.signInWithGoogleError
                return
            }
            try await Auth.auth().signIn(with: credential)
            try await mergeUserData(with: oldIDToken!)
        }
        
        localUser?.email = self.user?.email
        try setUserFile()
    }
    
    private func mergeUserData(with oldIDToken: String) async throws {
        let newIDToken = try await self.user?.getIDToken()
        
        let url = URL(string: "https://europe-west2-v-popup.cloudfunctions.net/merge_accounts?new=\(newIDToken!)&old=\(oldIDToken)")
        let request = URLRequest(url: url!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.signInWithGoogleError
        }
    }
    
    private func setUserFile() throws { //TODO: make async?
        try db.collection("users").document(self.user!.uid).setData(from: self.localUser)
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
    
    
    private func registerAuthStateDidChangeListener() {
        if let handle = userStateHandle {
            Auth.auth().removeStateDidChangeListener(handle) // Remove handle if it exists already
        }
        
        self.userStateHandle = Auth.auth().addStateDidChangeListener { (auth, user) in // Add handle and handle cases
            
                self.user = user
                if let user = user {
                    print("User state changed, uid: " + user.uid)
                } else {
                    Task {
                        do {
                            try await self.signInAnonymously()
                        } catch {
                            fatalError("The user could not be signed in.")
                    }
                }
            }
        }
    }
}

enum AuthError: Error {
    case signInWithGoogleError
}
