import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {DocumentSnapshot} from "firebase-functions/lib/providers/firestore";

const db = admin.firestore();

export const syncUser = functions.region("europe-west1").firestore
    .document("users/{userId}")
    .onWrite(async (change: functions.Change<DocumentSnapshot>, context) => {
        if (change.after.exists) {
            if (!change.after.isEqual(change.before)) {
                const data = change.after.data();
                
                const pubData: any = {
                    displayName: data.displayName,
                    uid: data.uid
                };
                if (data.photoURL) {
                    pubData.photoURL = data.photoURL;
                }
    
                await db.collection("pub_users").doc(context.params.userId).set(pubData, {merge: true});
            }
        } else {
            await db.collection("pub_users").doc(context.params.userId).delete();
        }
    });