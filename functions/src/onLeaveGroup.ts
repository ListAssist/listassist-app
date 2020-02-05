// Cloud function callable when user wants to leave group
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import FieldValue = admin.firestore.FieldValue;

const db = admin.firestore();

export const leaveGroup = functions.region("europe-west1").https.onCall((data, context) => {
    const groupid = data.groupid;
    const uid = context.auth.uid;

    if (!groupid) {
        throw new functions.https.HttpsError("invalid-argument", "GroupID is required");
    }

    return db.collection("groups_user")
        .doc(uid)
        .set({ groups: FieldValue.arrayRemove(groupid) }, { merge: true })
        .then(() => {
           return db.collection("groups")
                .doc(groupid)
                .get()
                .then(snap => {
                    if(snap.data()["members"].length === 1){
                        return Promise.all([
                            deleteCollection(snap.ref.path + "/lists", 5),
                            deleteCollection(snap.ref.path + "/shopping_data", 5),
                            db.collection("groups").doc(groupid).delete()
                        ]).then(() => { return { status: "Successful" }});
                    }

                    //@ts-ignore
                    const newMembers = snap.data()["members"].filter(m => m["uid"] !== uid);

                    let newCreator = snap.data()["creator"];

                    if(snap.data()["creator"]["uid"] === uid) newCreator = newMembers[0];

                    return db.collection("groups")
                        .doc(groupid)
                        .set({
                            creator: newCreator,
                            members: newMembers
                        }, { merge: true }).then(() => { return { status: "Successful" }});
                });
        });
});

//@ts-ignore
function deleteCollection(collectionPath, batchSize) {
    let collectionRef = db.collection(collectionPath);
    let query = collectionRef.orderBy('__name__').limit(batchSize);

    return new Promise((resolve, reject) => {
        deleteQueryBatch(query, batchSize, resolve, reject);
    });
}

//@ts-ignore
function deleteQueryBatch(query, batchSize, resolve, reject) {
    query.get()
    //@ts-ignore
        .then((snapshot) => {
            // When there are no documents left, we are done
            if (snapshot.size == 0) {
                return 0;
            }

            // Delete documents in a batch
            let batch = db.batch();
            //@ts-ignore
            snapshot.docs.forEach((doc) => {
                batch.delete(doc.ref);
            });

            return batch.commit().then(() => {
                return snapshot.size;
            });
            //@ts-ignore
        }).then((numDeleted) => {
        if (numDeleted === 0) {
            resolve();
            return;
        }

        // Recurse on the next process tick, to avoid
        // exploding the stack.
        process.nextTick(() => {
            deleteQueryBatch(query, batchSize, resolve, reject);
        });
    })
        .catch(reject);
}
