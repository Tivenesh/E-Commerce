# E-commerce Flutter Project

A modern, full-featured e-commerce mobile application built with Flutter and backed by Firebase. It provides a clean user interface, real-time data synchronization, and a robust architecture for a seamless shopping experience.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Technologies & Packages Used](#technologies--packages-used)
- [Prerequisites](#prerequisites)
- [Firebase Setup](#firebase-setup)
- [Installation and Setup](#installation-and-setup)
- [Running the Project](#running-the-project)
- [Folder Structure](#folder-structure)
- [Contact](#contact)

---

## Overview

This project is a complete e-commerce application designed for both iOS and Android. It demonstrates how to build a scalable and maintainable mobile app using modern development practices.

-   **Flutter Frontend:** A single codebase delivers a beautiful, responsive, and native-feeling user interface on multiple platforms.
-   **Firebase Backend:** Leverages Firebase's powerful suite of tools for authentication, real-time database (Firestore), and file storage, providing a serverless and scalable backend.

---

## Architecture

The project is built using a clean, scalable architecture inspired by **MVVM (Model-View-ViewModel)**, with a distinct separation of concerns into three main layers:

1.  **Data Layer:**
    -   **Models:** Defines the data structures for the application (e.g., `User`, `Item`, `CartItem`, `OrderItem`).
    -   **Repositories/Services:** Manages all interactions with the backend (Firebase). It abstracts the data source from the rest of the application (e.g., `UserRepo`, `ItemRepo`, `FirebaseAuthService`).

2.  **Domain Layer:**
    -   **Use Cases:** Contains specific business logic for each feature. Use cases orchestrate the flow of data from repositories to the presentation layer, ensuring that business rules are applied consistently (e.g., `SignInUseCase`, `PlaceOrderUseCase`).

3.  **Presentation Layer:**
    -   **Views:** The UI of the application, composed of Flutter widgets. Views are responsible for displaying data and capturing user input (e.g., `ItemListPage`, `CartPage`).
    -   **ViewModels:** Manages the state for the Views. It interacts with the use cases to fetch and update data, and exposes the state to the UI for rendering. We use `ChangeNotifier` with the `Provider` package for state management.

---

## Features

-   **Firebase Authentication:** Secure user sign-up and sign-in with email and password.
-   **Product Catalog:** Browse a list of available products and services with real-time updates from Firestore.
-   **Search Functionality:** Filter items by name, description, or category.
-   **Shopping Cart:** Add, remove, and update the quantity of items in the cart.
-   **Order Management:** Place orders from the cart and view a history of past orders.
-   **User Profile:** View and update user profile information.

---

## Technologies & Packages Used

-   **Framework:** Flutter
-   **Backend:** Firebase
    -   **Authentication:** `firebase_auth`
    -   **Database:** `cloud_firestore`
    -   **Storage:** `firebase_storage`
-   **State Management:** `provider`
-   **Asynchronous Programming:** `rxdart` (for debouncing search queries)
-   **Utilities:**
    -   `uuid`: For generating unique IDs.
    -   `logger`: For structured and readable console logs.
    -   `image_picker`: For selecting images (not fully implemented but available).

---

## Prerequisites

-   **Flutter SDK:** Make sure you have the Flutter SDK installed.
-   **IDE:** An IDE with Flutter support like VS Code or Android Studio.
-   **Firebase Account:** A Google account to create and manage a Firebase project.
-   **FlutterFire CLI:** Install the FlutterFire CLI to configure Firebase for your project.
    ```bash
    dart pub global activate flutterfire_cli
    ```

---

## Firebase Setup

This project requires a Firebase project to function. Follow these steps carefully:

1.  **Create a Firebase Project:**
    -   Go to the [Firebase Console](https://console.firebase.google.com/).
    -   Click "Add project" and follow the on-screen instructions.

2.  **Configure for Flutter:**
    -   From your project's root directory, run the FlutterFire configuration command:
        ```bash
        flutterfire configure
        ```
    -   This command will prompt you to select your Firebase project and will automatically generate the necessary configuration files (`firebase_options.dart`) for both Android and iOS.

3.  **Enable Authentication:**
    -   In the Firebase Console, navigate to **Build > Authentication**.
    -   Click the "Get started" button.
    -   On the "Sign-in method" tab, select **Email/Password** and enable it.

4.  **Set up Firestore Database:**
    -   Navigate to **Build > Firestore Database**.
    -   Click "Create database" and start in **test mode** for easy initial setup. This allows open read/write access.
    -   **For production**, you should update your security rules to be more secure. Here is an example to allow only authenticated users to read and write data:
        ```
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            // Allow read/write access only for authenticated users
            match /{document=**} {
              allow read, write: if request.auth != null;
            }
          }
        }
        ```

5.  **Set up Firebase Storage:**
    -   Navigate to **Build > Storage**.
    -   Click "Get started" and follow the prompts to set up your storage bucket.
    -   Update the storage security rules as needed. An example for allowing authenticated users:
        ```
        rules_version = '2';
        service firebase.storage {
          match /b/{bucket}/o {
            match /{allPaths=**} {
              allow read, write: if request.auth != null;
            }
          }
        }
        ```

---

## Installation and Setup

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/yourusername/ecommerce.git](https://github.com/yourusername/ecommerce.git)
    cd ecommerce
    ```

2.  **Install Dependencies:**
    Run the following command to get all the required packages:
    ```bash
    flutter pub get
    ```

---

## Running the Project

Once the setup is complete, you can run the application on a connected device or an emulator:

```bash
flutter run





lib/
├── data/
│   ├── models/           # Data classes (User, Item, Cart, Order)
│   ├── services/         # Repositories for data operations (e.g., item_repo.dart, user_repo.dart)
│   └── usecases/         # Business logic for specific features (e.g., signin.dart, place_order_usecase.dart)
├── presentation/
│   ├── carts/            # View and ViewModel for the shopping cart
│   ├── items/            # View and ViewModel for the item list
│   ├── orders/           # View and ViewModel for the order history
│   ├── users/            # View and ViewModel for the user profile
│   └── authscreen.dart   # The main authentication view
├── routing/
│   └── routes.dart       # Route constants and generation logic
├── utils/
│   └── logger.dart       # Configuration for the logger
└── main.dart             # Main entry point of the application


