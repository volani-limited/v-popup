# PopUp!

PopUp is a shopping list app built with SwiftUI using Firebase Auth, Firestore, Cloud Functions, and Messaging.
Download on [Testflight](https://testflight.apple.com/join/bFJlL4bS).

## Features

Features include multiple shopping lists, the ability to sign in with Google to restore state across multiple application installations and a share function that allows other users to collaborate on shopping lists.

## Application structure
### Frontend
The frontend is a fairly typical SwiftUI Lifecycle iOS application making use of Combine to provide dependencies to all views and to allow data flow between the Views and the Model. I have also stuck to the async/await structure to keep the code clean and avoid nested closures. The MVVM model might be more closely followed I believe I have struck a balance to have good code that isn't overenginered.

### Backend
The backend makes use of Firebase Cloud Firestore to record and save objects created by users. I have made use of the new Swift SDKs to use Codable to automatically serialise model objects. The security rules are setup and provided to make sure data is only accessible by its owner. 

I have made use of two cloud functions, **merge_accounts** and **send_share_notification**. Merge accounts makes sure no shopping_lists are lost when the user signs into Google if their Google account is already linked to an earlier app installation. Share notification is called by the client when sharing a shopping list and it sends a notification to the share destination to notify the user that somebody has shared a list with them. It makes use of the Firebase Cloud Messaging service, with FCM registration tokens saved at application launch to the user's database entry to allow notifications to be sent to all logged in devices.

## What's good/what could be improved
I'm generally pretty happy with the overall architecture of the app. That being said, there is some room for improvment with the UI certainly and to a lesser extent for the error handling. 
Most of everything else is good though and I'm pleased with the use of Combine and async/await I have, although I would perhaps liked to have used Combine with the wrapper for Firestore to stream the document updates that way. 