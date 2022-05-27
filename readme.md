# Push Notifications Interview Question
This repo is set up as a test question. The push notifications are not working as intended. Can you figure out why and correct the issue?

## Notes
- Push notifications are handled through OneSignal integration ([documentation](https://documentation.onesignal.com/reference/create-notification)). The main file for this setup is `/lib/push/notify.rb`.
- The frontend for this application is a react native mobile application. This is configured correctly.
- There are two types of notifications in this app: event-driven notifications that are sent to individual users, and time-based notifications that go to all users. The time-based notifications are working as expected, but the others are not being received.


