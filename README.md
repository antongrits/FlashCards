# FlashCards

FlashCards is a SwiftUI-based iOS application that allows users to create and manage visual flashcards consisting of an image and a word. The app supports both local storage with SwiftData and cloud synchronization using Firebase services. Authentication is optional and includes support for Email/Password and Google Sign-In. The app is built using the MVVM architecture and follows modern iOS development best practices.

## Features

- Display flashcards in a grid layout: 2 columns in portrait, 3 in landscape.
- Add new flashcards by selecting an image from the photo library and providing a word.
- Store flashcards locally using SwiftData.
- Optional login to sync flashcards with Firebase Firestore and Firebase Storage.
- Authentication using Firebase Authentication (Email/Password and Google Sign-In).
- Offline support with fallback to local data when not connected.
- Two-way synchronization with Firebase when the user logs in.
- Clean and simple UI with layout adaptation, animations, and responsive text.

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

![EEE3DBB4-8EC5-40AC-A3C3-9952BD3A3FCA_1_101_o](https://github.com/user-attachments/assets/febd2c87-bdb0-4c85-80fb-912a94409072)
![CC7798CD-7F17-43AB-9BE8-6BBBAD7A2D07_1_101_o](https://github.com/user-attachments/assets/b3b2eabf-3cde-4320-adc3-5427b564f012)
![8820CF37-C8D3-4FA6-8759-851B3AD4E836_1_101_o](https://github.com/user-attachments/assets/3245b2cc-c77e-4086-8852-0f9043842675)
![BEDB4DAB-684B-494D-8962-3F4841470953_1_101_o](https://github.com/user-attachments/assets/beb8e1ce-9ddd-41f3-9b3e-58521449022e)
![EC41B071-C1C1-45CC-B980-DCA36A696C45_1_101_o](https://github.com/user-attachments/assets/89758aa7-a6c3-4307-83d8-8b74fe8132e1)
![FC9A2B03-F291-4F82-A00E-94BA10A0B778_1_101_o](https://github.com/user-attachments/assets/db046bfd-3334-4159-b686-9a78fb373c17)
![0425765E-1E43-4E9B-8F5C-C760DED549A2_1_101_o](https://github.com/user-attachments/assets/48116993-aa66-427d-8b23-e1b0d241a1d9)









