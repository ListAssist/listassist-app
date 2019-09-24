import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {DocumentSnapshot} from "firebase-functions/lib/providers/firestore";

const db = admin.firestore();

export const syncUser = functions.firestore
    .document("users/{userId}")
    .onWrite(async (change: functions.Change<DocumentSnapshot>, context) => {
        if (change.after.exists) {
            let data = change.after.data();
            let pubData: any = {
                displayName: data.displayName,
                email: data.email,
                uid: data.uid
            };
            if (data.photoURL) {
                pubData.photoURL = data.photoURL;
            }

            await db.collection("pub_users").doc(context.params.userId).set(pubData, {merge: true});
        } else {
            await db.collection("pub_users").doc(context.params.userId).delete();
        }
    });