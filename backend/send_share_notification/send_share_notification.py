import firebase_admin
from firebase_admin import auth
from firebase_admin import firestore
from firebase_admin import messaging

def verify_auth_token(token):
    try:
        decoded_auth_token = auth.verify_id_token(token)

        if decoded_auth_token == None:
            return False
        else:
          return True
    except:
        return False

def main(request):
    if not firebase_admin._apps:
        firebase_admin.initialize_app()

    if not request.method == "GET":
        return "Bad request, not GET method", 403

    auth_token = request.args.get("token")
    destination_email = request.args.get("email")

    if not new_token or not old_token:
        return "Bad request, could not parse", 403

    if not verify_auth_token:
      return "Unauthorized", 401
    
    db = firestore.client()

    sender_query = db.collection("users").document(auth.verify_id_token(token)["uid"])

    sender_doc = sender_query.get()

    if not sender_doc:
      return "Unauthorized", 401

    if not sender_doc["email"]:
      return "Unauthorized", 401

    sender_email = sender_doc["email"]

    destination_query = db.collection("users").where("email", "==", email)
    destination_user_docs = query.stream()

    if not dodestination_user_docscs:
      return "Could not find user", 501

    if not destination_user_docs[0]["fcmRegistrations"]:
      return "User has no FCM registration", 501
    
    registrations = docs[0]["fcmRegistrations"]

    message = messaging.MulticastMessage(
      notification=messaging.Notification(
        title=(sender_email + " shared a list with you"),
        body="Tap to view",
    ),
    tokens=registrations,
    )
    
    messaging.send_multicast(message)
    
    return 200
