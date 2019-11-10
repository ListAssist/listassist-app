import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import FieldValue = admin.firestore.FieldValue;
import Timestamp = admin.firestore.Timestamp;

const db = admin.firestore();

export const createGroup = functions.https.onCall(async (data, context) => {
    const title = data.title;
    const uid = context.auth.uid;

    if (!title) {
        throw new functions.https.HttpsError("invalid-argument", "Title is required");
    }

    let username: string;

    return db.collection("users")
        .doc(uid)
        .get()
        .then((snap) => {
            if(!snap.exists){
                return { status: "Failed no doc" };
            }
            username = snap.data()["displayName"];
            return db.collection("groups")
                .add({
                    title: title,
                    created: Timestamp.now(),
                    creator: {
                        uid: uid,
                        displayName: snap.data()["displayName"],
                        photoURL: snap.data()["photoURL"] || "",
                    }
                })
                .then((doc) => {
                    return db.collection("groups_user")
                        .doc(uid)
                        .set({ groups: FieldValue.arrayUnion(doc.id) }, { merge: true })
                        .then(() => { return { status: "Successful", groupid: doc.id, groupname: title, creator: username }});
                })
                .catch(() => {
                    return { status: "Failed exception" };
                });
        })
        .catch((e) => {
            return { status: "Failed exception aussen ", e: e };
        });

});
