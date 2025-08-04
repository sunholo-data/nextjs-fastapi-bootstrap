// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics, type Analytics } from "firebase/analytics";
import { getFirestore } from "firebase/firestore";

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCRUJFqI3kZIcvZ0n5l1rvvczAV37YBbLs",
  authDomain: "multivac-internal-dev.firebaseapp.com",
  projectId: "multivac-internal-dev",
  storageBucket: "multivac-internal-dev.firebasestorage.app",
  messagingSenderId: "374404277595",
  appId: "1:374404277595:web:0c10884d6a5a3e5146e67e",
  measurementId: "G-PQEXZQP0MG"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Analytics (only in browser environment)
let analytics: Analytics | null = null;
if (typeof window !== 'undefined') {
  analytics = getAnalytics(app);
}

// Initialize Firestore with the tagassistant database
const db = getFirestore(app, 'tagassistant');

export { app, analytics, db };