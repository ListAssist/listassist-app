import * as admin from 'firebase-admin';
admin.initializeApp();

export { syncUser } from './syncUser';
export { acceptInvite } from './onAcceptInvite';
export { declineInvite } from './onDeclineInvite';
export { inviteUsers } from './inviteUsers';
export { createGroup } from './createGroup';
export { leaveGroup } from './onLeaveGroup';
export { deleteGroup } from './deleteGroup';
export { updateGroup } from './updateGroup';
