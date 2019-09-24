import * as admin from 'firebase-admin';
type Timestamp = admin.firestore.Timestamp;

export interface User {
    uid: string;
    displayName: string;
    email: string;
    lastLogin: Timestamp;
    photoURL?: string;
}