# FlashCards

FlashCards is a SwiftUI-based iOS application that allows users to create and manage visual flashcards consisting of an image and a word. The app supports both local storage with SwiftData and cloud synchronization using Firebase services. Authentication is optional and includes support for Email/Password and Google Sign-In. The app is built using the MVVM architecture and follows modern iOS development best practices.

## Features

- Display flashcards in a responsive grid layout: 2 columns in portrait, 3 in landscape.
- Add new flashcards by selecting an image from the photo library and entering a word.
- Store flashcards locally using SwiftData.
- Optional sign-in to sync flashcards with Firebase Firestore and Firebase Storage.
- Authentication using Firebase Authentication (Email/Password and Google Sign-In).
- Clear separation of local and cloud data logic.
- Centralized synchronization logic handled by `FirebaseSyncService`.
- Network error handling and deferred sync when offline.
- Clean and adaptive UI with animations and responsive text.

## Technologies Used

- SwiftUI
- SwiftData
- Firebase Authentication
- Firebase Firestore
- Firebase Storage
- Google Sign-In SDK
- MVVM pattern
- Swift Concurrency (async/await)

## System Requirements

- iOS 17.0 or later

## Setup Instructions

1. Clone the repository.
2. Open the project in Xcode.
3. Create a Firebase project and configure Authentication, Firestore, and Storage.
4. Enable Email/Password and Google Sign-In methods in Firebase Console.
5. Download the `GoogleService-Info.plist` file and add it to the project.
6. Add Firebase SDKs using Swift Package Manager:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - GoogleSignIn
7. Build and run the project on a real device or simulator.



<img width="166" alt="image" src="https://github.com/user-attachments/assets/febd2c87-bdb0-4c85-80fb-912a94409072" />
<img width="166" alt="image" src="https://github.com/user-attachments/assets/b3b2eabf-3cde-4320-adc3-5427b564f012" />
<img width="166" alt="image" src="https://github.com/user-attachments/assets/3245b2cc-c77e-4086-8852-0f9043842675" />
<img width="166" alt="image" src="https://github.com/user-attachments/assets/beb8e1ce-9ddd-41f3-9b3e-58521449022e" />
<img width="166" alt="image" src="https://github.com/user-attachments/assets/89758aa7-a6c3-4307-83d8-8b74fe8132e1" />
<img width="166" alt="image" src="https://github.com/user-attachments/assets/db046bfd-3334-4159-b686-9a78fb373c17" />
<img width="166" alt="image" src="https://github.com/user-attachments/assets/48116993-aa66-427d-8b23-e1b0d241a1d9" />
