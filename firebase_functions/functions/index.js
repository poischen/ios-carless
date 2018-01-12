// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database. 
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Take the text parameter passed to this HTTP endpoint and insert it into the
// Realtime Database under the path /messages/:pushId/original
exports.filteredOfferings = functions.https.onRequest((req, res) => {
  // Grab the text parameter.
  const minSeats = req.query.minSeats;
  /* admin.database().ref('/messages').push({original: original}).then(snapshot => {
    // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
    res.writeHead(200, { 'Content-Type': 'application/json' })
  }); */
  admin.database().ref('/inserat').once('value').then(function(snapshot) {
  	const snapshotData = snapshot.val()
  	const filteredData = snapshotData.filter((elem) => {
  		if (elem !== null && elem !== undefined){
  			return elem.seats >= minSeats;
  		}
  	});
  	res.json({
  		filteredOfferings: filteredData
  	});
  });
 
});
