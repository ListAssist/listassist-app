import * as admin from 'firebase-admin';
admin.initializeApp();

export { syncUser } from './syncUser';
export { acceptInvite } from './onAcceptInvite';
export { declineInvite } from './onDeclineInvite';
export { inviteUser } from './inviteUser';
