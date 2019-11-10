// Cloud function callable when user wants to leave group
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import FieldValue = admin.firestore.FieldValue;

const db = admin.firestore();

export const leaveGroup = functions.https.onCall((data, context) => {
    const groupid = data.groupid;
    const uid = context.auth.uid;

    if (!groupid) {
        throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
    }

    return db.collection("groups_user")
        .doc(uid)
        .set({ groups: FieldValue.arrayRemove(groupid) }, { merge: true });
});
