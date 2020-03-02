import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import FieldValue = admin.firestore.FieldValue;

const db = admin.firestore();

export const updateGroup = functions.region("europe-west1").https.onCall((data, context) => {
    const group = data.group;
    const uid = context.auth.uid;

    if (!group) {
        throw new functions.https.HttpsError("invalid-argument", "Group is required");
    }

    return db.collection("groups")
        .doc(group["id"])
        .get()
        .then((snap) => {
            if(snap.data()["creator"]["uid"] !== uid) return { status: "Failed" };
            //@ts-ignore
            const newMembers = snap.data()["members"].filter(m => group["members"].includes(m["uid"]));
            //@ts-ignore
            const removedMembers = snap.data()["members"].filter(m => !group["members"].includes(m["uid"]));
            console.log(newMembers);
            return Promise.all([
                //@ts-ignore
                removedMembers.map((member) => {
                    return db.collection("groups_user")
                        .doc(member.uid)
                        .set({ groups: FieldValue.arrayRemove(group.id) }, { merge: true })
                }),
                db.collection("groups")
                .doc(group["id"])
                .set({
                    title: group["title"],
                    members: newMembers,
                    settings: group["settings"]
                }, { merge: true })
            ]).catch(e => {
                return { status: "Failed"};
            }).then(v => {
                return { status: "Successful" };
            });
        });
});

