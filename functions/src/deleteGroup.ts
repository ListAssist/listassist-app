// Cloud function callable when user wants to delete group
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import FieldValue = admin.firestore.FieldValue;

const db = admin.firestore();

export const deleteGroup = functions.region("europe-west1").https.onCall((data, context) => {
    const groupid = data.groupid;
    const uid = context.auth.uid;

    if (!groupid) {
        throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
    }

    return db.collection("groups")
        .doc(groupid)
        .get()
        .then(async (snap) => {
            if(snap.data()["creator"]["uid"] !== uid) {
                return { status: "Failed" };
            }
            return Promise.all([
                db.collection("groups")
                    .doc(groupid)
                    .delete(),
                // @ts-ignore
                snap.data()["members"].map((member) => {
                    return db.collection("groups_user")
                        .doc(member.uid)
                        .set({ groups: FieldValue.arrayRemove(groupid) }, { merge: true })
                }),
                db.collection("invites")
                    .where("groupid", "==", groupid)
                    .onSnapshot((value) => {
                        value.docs.forEach(doc => doc.ref.delete());
                    })
            ]).then(() => {
                return { status: "Successful" };
            })
            .catch(() => {
                return { status: "Failed exception" };
            });
        })
        .catch(() => {
            return { status: "Failed exception" };
        });
});
