# Elura
## Personalized Skincare App (Flutter + Firebase)

A smart and user-centric mobile application that helps users build and maintain effective skincare routines. The app provides personalized skincare recommendations based on skin quizzes, routine tracking, reminders, and weather-based skincare tips — all powered by **Flutter** on the frontend and **Firebase** on the backend.

## Features

### 1. User Authentication

* Secure sign up and login using Firebase Authentication
* Email & password authentication
* Persistent user sessions

### 2. Skin Quiz & Profile

* Interactive skin-type quiz (oily, dry, combination, sensitive, etc.)
* Lifestyle and concern-based questions (acne, pigmentation, aging, hydration)
* Personalized skincare routine stored in firebase realtime database.

### 3. Personalized Routine Builder

* Morning & night skincare routines
* Step-by-step routine (cleanser, toner, serum, moisturizer, sunscreen, etc.)
* Ability to add or remove routines

### 4. Product Recommendations

* Personalized product suggestions based on skin type and concerns
* Recommended products and routine stored in firebase real-time database

### 5. Routine Tracking

* Daily routine completion tracking
* Visual progress indicators on a calender
* Skipped / completed routine history
* Reaction to a routine/product option

### 6. Symptoms tracking

* Retake quiz in case of reaction with some product
* Questions are further specific to skin concerns and type of reaction. 
* New suggested products and routine based on reaction of users to products and results stored in firebase realtime database.

### 7. Reminders 

* Routine reminders
* Custom reminder time settings

### 8. Weather-Based Skincare Tips

* Skincare tips adjusted based on weather conditions (hot, cold, humid, dry)
* Suggestions like increased hydration, sunscreen usage, or barrier repair


## 🛠️ Tech Stack

### Frontend

* Flutter (Dart)

### Backend & Services

* Firebase Authentication
* Firebase Realtime Database

## Installation & Setup

### Prerequisites

* Flutter SDK installed
* Android Studio / VS Code
* Firebase account
* Android emulator or physical device

### Steps

1. **Clone the repository**

```bash
git clone https://github.com/your-username/skincare-app.git
cd skincare-app
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Firebase Configuration**

* Create a project in the **Firebase Console**
* Enable **Authentication (Email/Password)**
* Create a **Firebase Realtime Database**
* Set database rules according to application requirements
* Add the following apps in Firebase Console:

  * **Android app**
  * **Web app**
* Download and configure the required files:

  * `google-services.json` for Android
  * Firebase Web configuration keys (API key, auth domain, database URL, etc.) for Web
* Integrate Firebase using Flutter Firebase packages (`firebase_core`, `firebase_auth`, `firebase_database`)

4. **Run the app**

```bash
flutter run
```
