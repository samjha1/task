QR Code Subscription App (Flutter + Firebase)
This is a Flutter application that manages user subscriptions and generates QR codes using Firebase Firestore and Firebase Authentication. Users can scan the QR code to verify their subscription status.

📌 Features
✅ User Authentication – Sign in using Firebase Authentication
✅ Subscription Management – Store user plans and expiry dates in Firestore
✅ QR Code Generation – Generate and display a unique QR code for each user
✅ Real-time Updates – Fetch subscription details dynamically
✅ Responsive UI – Mobile-friendly interface with smooth animations

🚀 Tech Stack
Flutter (Dart)
Firebase Authentication
Firebase Firestore
qr_flutter (QR Code Generator)
GetX / Provider (for state management) (if used)
📂 Firestore Structure
📁 users (Collection)
    📄 user_id (Document)
      🔹 name: "sam"
      🔹 email: "sam@gmail.com"
      🔹 qr_code_data: "subscription"
      🔹 plan_expiry_date: "2025-12-31"

