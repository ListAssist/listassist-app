// Cloud function callable when user wants to leave group
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import FieldValue = admin.firestore.FieldValue;

const db = admin.firestore();

export const leaveGroup = functions.region("europe-west1").https.onCall((data, context) => {
    const groupid = data.groupid;
    const uid = context.auth.uid;

    if (!groupid) {
        throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
    }

    return db.collection("groups_user")
        .doc(uid)
        .set({ groups: FieldValue.arrayRemove(groupid) }, { merge: true })
        .then(() => {
            return db.collection("users")
                .doc(uid)
                .get()
                .then((snapUser) => {
                    if (!snapUser.exists) {
                        return null;
                    }
                    return db.collection("groups")
                        .doc(groupid)
                        .set({
                            members: FieldValue.arrayRemove({
                                uid: uid,
                                displayName: snapUser.data()["displayName"],
                                photoURL: snapUser.data()["photoURL"] || "",
                            })
                        }, { merge: true });
                });
        });
});
