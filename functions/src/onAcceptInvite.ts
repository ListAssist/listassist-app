import * as functions from 'firebase-functions';
//import * as admin from 'firebase-admin';

//const db = admin.firestore();

export const acceptInvite = functions.region("europe-west1").https.onCall((data, context) => {
  const groupid = data.groupid;

  if (!groupid) {
    throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
  }

  return {status: "Done", uid: context.auth.uid};
});