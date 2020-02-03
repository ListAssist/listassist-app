import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {DocumentSnapshot} from "firebase-functions/lib/providers/firestore";

const db = admin.firestore();

export const syncUser = functions.region("europe-west1").firestore
    .document("users/{userId}")
    .onWrite(async (change: functions.Change<DocumentSnapshot>, context) => {
        if (change.after.exists) {
            const name = change.before.data()["displayName"];
            const newName = change.after.data()["displayName"];
            const pic = change.before.data()["photoURL"];
            const newPic = change.after.data()["photoURL"];
            const uid = change.before.ref.id;

            if(name === newName && pic === newPic){
                return;
            }

            try {
                const groupsDoc = await db.collection("groups_user").doc(uid).get();
                const groups: any[] = groupsDoc.data()["groups"];
                for(const group of groups) {
                    const grp = await db.collection("groups").doc(group).get();
                    const newGroup = grp.data();

                    delete newGroup["title"];
                    delete newGroup["created"];
                    if(newGroup["creator"]["uid"] === uid){
                        newGroup["creator"]["displayName"] = newName;
                        newGroup["creator"]["photoURL"] = newPic;
                    }else {
                        delete newGroup["creator"];
                    }

                    //@ts-ignore
                    newGroup["members"].forEach(e => {
                        if(e["uid"] === uid){
                            e["displayName"] = newName;
                            e["photoURL"] = newPic;
                        }
                    });
                    await db.collection("groups").doc(group).set(newGroup, { merge: true });
                }
            }catch (e) {
                console.error(e);
                return;
            }
        }
    });
