import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Timestamp = admin.firestore.Timestamp;

const db = admin.firestore();

export const inviteUser = functions.region("europe-west1").https.onCall(async (data, context) => {
    const targetuid = data.targetuid;
    const groupid = data.groupid;
    const groupname = data.groupname;
    const from = data.from;
    const uid = context.auth.uid;

    if (!targetuid) {
        throw new functions.https.HttpsError("invalid-argument", "UID is required");
    }

    if (!groupid) {
        throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
    }

    if(targetuid === uid) {
        return { status: "Failed" };
    }

    return db.collection("groups_user")
        .doc(uid)
        .get()
        .then((snap) => {
            if(!snap.exists){
                return { status: "Failed no doc" };
            }
            if(!snap.data()["groups"].includes(groupid)) {
                return { status: "Failed not in group" };
            }
            return db.collection("invites")
                .add({
                    created: Timestamp.now(),
                    from: from,
                    groupid: groupid,
                    groupname: groupname,
                    to: targetuid,
                    type: "pending"
                })
                .then(() => {
                    return { status: "Successful" };
                })
                .catch(() => {
                    return { status: "Failed exception" };
                });
        })
        .catch((e) => {
            return { status: "Failed exception aussen ", e: e };
        });

});
