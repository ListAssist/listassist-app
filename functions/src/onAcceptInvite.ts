import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import FieldValue = admin.firestore.FieldValue;

const db = admin.firestore();

export const acceptInvite = functions.https.onCall((data, context) => {
  const inviteid = data.inviteid;
  const uid = context.auth.uid;

  if (!inviteid) {
    throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
  }

    return db.collection("invites")
        .doc(inviteid)
        .get()
        .then((snap) => {
            if(!snap.exists){
                return { status: "Failed" };
            }
            if(snap.data()["to"] === uid) {
                return Promise.all([
                    db.collection("groups_user")
                        .doc(uid)
                        .set({ groups: FieldValue.arrayUnion(snap.data()["groupid"]) }, { merge: true }),
                    db.collection("invites")
                        .doc(inviteid)
                        .set({ type: "accepted" }, { merge: true })
                ]).then(() => {
                    return { status: "Successful" }
                });
            }
            return { status: "Failed" };
        });

});
