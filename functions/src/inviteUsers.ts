import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Timestamp = admin.firestore.Timestamp;

const db = admin.firestore();

export const inviteUsers = functions.https.onCall(async (data, context) => {
    const targetuids = data.targetuids;
    const groupid = data.groupid;
    const groupname = data.groupname;
    const from = data.from;
    const uid = context.auth.uid;

    if (!targetuids) {
        throw new functions.https.HttpsError("invalid-argument", "UID is required");
    }

    if (!groupid) {
        throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
    }

    if(targetuids.includes(uid)) {
        return { status: "Failed" };
    }

    console.log(targetuids);

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
            return Promise.all(
                    targetuids.map((target: string) => db.collection("users")
                        .where("email", "==", target)
                        .get()
                        .then((sn) => {
                            console.log(sn);
                            console.log(sn.docs[0]);
                            if(!sn.docs && !sn.docs[0]) return null;
                            return db.collection("invites")
                                .add({
                                    created: Timestamp.now(),
                                    from: from,
                                    groupid: groupid,
                                    groupname: groupname,
                                    to: sn.docs[0].data()["uid"],
                                    type: "pending"
                                })
                        }))
                )
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
