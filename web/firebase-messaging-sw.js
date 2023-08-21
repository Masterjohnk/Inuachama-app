importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

//Using singleton breaks instantiating messaging()
// App firebase = FirebaseWeb.instance.app;


firebase.initializeApp({
      apiKey: "AIzaSyByG-xFf7UudQMF5kdz7QXiUjvswWzeG88",
      authDomain: "pushnotifications-cf0a6.firebaseapp.com",
      databaseURL: "https://pushnotifications-cf0a6.firebaseio.com",
      projectId: "pushnotifications-cf0a6",
      storageBucket: "pushnotifications-cf0a6.appspot.com",
      messagingSenderId: "201999290411",
      appId: "1:201999290411:web:869eb6db8c4b0049ba9a6e"
   });

const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            return registration.showNotification("New Message");
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});