# Journey

**Journey** is an advanced, AI-powered **Digital ID application** designed to unify Malaysian government services into a single digital identity platform. It simplifies interactions with agencies like **JPN**, **JPJ**, **Immigration**, and **LHDN** by integrating a secure digital wallet, a seamless payment gateway, and an intelligent chatbot assistant.

## Core Highlights

1.  **Unified Dashboard**: Manage Digital MyKad, Driving Licenses, and check Touch 'n Go NFC balances.
2.  **Smart AI Assistant**: Powered by **Gemini Pro** to provide context-aware help and deep-linking to services.
3.  **Advanced Security**: Features **AES-256 encryption**, a "Kill Switch" for remote revocation, and **Blockchain-style logging**.
4.  **Cross-Platform Integration**: Demonstrates secure **autocomplete** and data transfer (**Scan-to-Fill**) between the mobile app and web portals.

---

## 🛠️ Tech Stack

### Frontend (Mobile App)
-   **Framework**: [Flutter](https://flutter.dev/) (Dart)
-   **State Management**: `Provider` / `ChangeNotifier`
-   **UI Components**: Material 3 Design
-   **Navigation**: GoRouter

### Backend (API & Logic)
-   **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python)
-   **AI Engine**: Gemini Pro (via Google Generative AI)
-   **Database**: JSON-based mock database

---

## 🏗️ Getting Started

### Prerequisites
-   **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install/windows)
-   **Python 3.10+**: [Install Python](https://www.python.org/downloads/)

### 1. Backend Setup

1.  Navigate to the backend directory:
    ```bash
    cd backend
    ```
2.  Create a virtual environment:
    ```bash
    python -m venv venv
    venv\Scripts\activate
    ```
3.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
4.  Run the server:
    ```bash
    uvicorn main:app --reload
    ```
    The backend will start at `http://127.0.0.1:8000`.

### 2. Frontend Setup

1.  Navigate to the frontend directory:
    ```bash
    cd frontend
    ```
2.  Get Flutter packages:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

### 3. Running the Auto-fill Demo

1.  Navigate to the `mock_website` directory.
2.  Open `index.html` in your web browser.
3.  Click **"Fill with Journey"**.
4.  In the modal, click **"Simulate Mobile Scan"** to see the auto-fill magic in action.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.