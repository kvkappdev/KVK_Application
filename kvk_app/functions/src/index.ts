import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const fcm = admin.messaging();

export const sendToAnnouncement= functions.firestore
  .document('Announcements/{announcementId}')
  .onCreate(async snapshot => {

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'KVK App',
        body: 'A new announcement has just been created',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    return fcm.sendToTopic('announcements', payload);
  });