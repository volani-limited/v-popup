import re
import firebase_admin
from firebase_admin import auth
from firebase_admin import firestore
import time

def verify_old_token(token):
    try:
        decoded_auth_token = auth.verify_id_token(token)

        if decoded_auth_token == None:
            return False

        if decoded_auth_token.firebase.sign_in_provider == "anonymous":
            return True
        else:
            return False
    except:
        return False

def verify_new_token(token):
    try: 
        decoded_auth_token = auth.verify_id_token(token)

        if decoded_auth_token == None:
            return False

        if decoded_auth_token.firebase.sign_in_provider == "anonymous":
            return False

        auth_time = decoded_auth_token.auth_time * 1000
        sign_in_time = int(time.time() * 1000) - auth_time
        
        if sign_in_time > 300000:
            return False
    except:
        return False

def perform_migration(old_token, new_token):
    old_id = old_token.uid
    new_id = new_token.uid

    db = firestore.client()

    migration_transaction = db.transaction()
    old_items_ref = db.collection("shopping_lists").where("owner", "==", old_id)

    @firestore.transactional
    def update_in_transaction(transaction, old_items_ref):
        snapshot = old_items_ref.get(transaction=transaction)
        transaction.update(old_items_ref, {
                "owner": new_id
            })

    update_in_transaction(migration_transaction, old_items_ref)

def main(request):
    if not firebase_admin._apps:
        firebase_admin.initialize_app()

    if not request.method == "GET":
        return "Bad request, not GET method", 403

    new_token = request.args.get("new")
    old_token = request.args.get("old")


    if not new_token or not old_token:
        return "Bad request, could not parse", 403


    if not verify_old_token(old_token):
        return "Unauthorized: could not verify old token", 401
    
    if not verify_new_token(new_token):
        return "Unauthorized: Could not verify new account token", 401

    perform_migration(old_token, new_token)

    return "Success", 200
