import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const declineInvite = functions.region("europe-west1").https.onCall((data, context) => {
  const inviteid = data.inviteid;
  const uid = context.auth.uid;


  if (!inviteid) {
    throw new functions.https.HttpsError("invalid-argument", "InviteID is required");
  }

  return db.collection("invites")
        .doc(inviteid)
        .get()
        .then((snap) => {
          if(!snap.exists){
            return { status: "Failed" };
          }
          if(snap.data()["to"] === uid){
            return db.collection("invites")
              .doc(inviteid)
              .delete()
              .then(() => {
                return { status: "Successful" };
              });
          }
          return { status: "Failed" };
        });

});
