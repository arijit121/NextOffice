importScripts("https://www.gstatic.com/firebasejs/10.11.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.11.1/firebase-messaging-compat.js");


const firebaseConfig = {
  apiKey: "AIzaSyAEVtwidTOSSx5XjYEteDDSDKAHfwCz-WQ",
  authDomain: "nextoffice-4a398.firebaseapp.com",
  projectId: "nextoffice-4a398",
  storageBucket: "nextoffice-4a398.firebasestorage.app",
  messagingSenderId: "96573718732",
  appId: "1:96573718732:web:a32e6daf86bd8905028269",
  measurementId: "G-28XRZJZES4"
};
firebase.initializeApp(firebaseConfig);

let messaging;
try {
  messaging = firebase.messaging.isSupported() ? firebase.messaging() : null
} catch (err) {
  console.error('Failed to initialize Firebase Messaging', err);
}

if (messaging) {
  // To dispaly background notifications
  try {
    messaging.onBackgroundMessage((message) => {
      console.log('Received background message: ', message.data);
      var data = message.data;
      var title = data['title'];
      var body = data['body'];
      var bigText = data['message'];
      var image = data['image'];
      var actionURL = data['ActionURL'];
      var notificationOptions = {
        tag: body,
        body: bigText,
        icon: image,
        data: {
          url: actionURL,// This should contain the URL you want to open
        },
      }
      self.registration.showNotification(title, notificationOptions);
    });
  } catch (err) {
    console.log(err);
  }
}

// File: firebase-messaging-sw.js
// Handling Notification click
self.addEventListener('notificationclick', (event) => {
  event.notification.close(); // Closing the notification when clicked

  console.log('Notification click:', event.notification.data);

  const urlToOpen = event.notification.data?.url || '/';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      for (const client of windowClients) {
        if (client.url.includes(urlToOpen) && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(urlToOpen);
      }
    })
  );
});