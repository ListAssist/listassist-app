import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const acceptInvite = functions.https.onCall((data, context) => {
  const groupid = data.groupid;
  const uid = context.auth.uid;
  //const name = context.auth.token.name || null;

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

  return db.collection("groups_user")
      .doc(uid)
      .set({ groups: [groupid] }, {merge: true})
      .then(() => {
        return { status: "Successful" };
      });

  //return {
  //    status: "Done",
  //    groupid: groupid,
  //    uid: uid
  //};
});