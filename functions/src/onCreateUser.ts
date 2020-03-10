import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const onCreateUser = functions.region("europe-west1").firestore
    .document("users/{userId}")
    .onCreate((created, context) => {
        return db.doc(`users/${created.id}`).set({
            settings: {
                ai_enabled: true,
                ai_interval: 5,
                msg_autolist: false,
                msg_general: false,
                msg_invite: false,
                msg_offer: false,
                scanner_manual: true,
            }
        }, { merge: true }).then(res => {
            return res;
        })
    });
