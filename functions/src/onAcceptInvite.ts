import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import FieldValue = admin.firestore.FieldValue;

const db = admin.firestore();

export const acceptInvite = functions.https.onCall((data, context) => {
  const groupid = data.groupid;
  const inviteid = data.inviteid;
  const uid = context.auth.uid;

  if (!groupid) {
    throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
  }

  /*return db.ref('/messages').push({
    text: sanitizedMessage,
    author: { uid, name, picture, email },
  }).then(() => {
    console.log('New Message written');
    // Returning the sanitized message to the client.
    return { text: sanitizedMessage };
  })*/

  // return db.collection("groups_user")
  //     .doc(uid)
  //     .set({ groups: FieldValue.arrayUnion(groupid) }, {merge: true})
  //     .then(() => {
  //       return { status: "Successful" };
  //     });


    return db.collection("invites")
        .doc(inviteid)
        .get()
        .then((snap) => {
            if(!snap.exists){
                return { status: "Failed" };
            }
            if(snap.data()["to"] === uid){
                return db.collection("groups_user")
                    .doc(uid)
                    .set({ groups: FieldValue.arrayUnion(groupid) }, {merge: true})
                    .then(() => {
                        return db.collection("invites")
                            .doc(inviteid)
                            .set({ type: "accepted" }, { merge: true })
                            .then(() => {
                                return { status: "Successful" };
                            });
                    });
            }
            return { status: "Failed" };
        });

});
