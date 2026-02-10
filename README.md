# Koku - Smart Queue Manager

Koku is a Flutter-based application designed to streamline queue management for businesses. It allows business owners to create digital queues, manage waiting lists in real-time, and process clients efficiently.

## 📱 Current Workflow

### 1. Create a Queue
*   Navigate to the **Create Queue** screen.
*   **Input Details**: Enter the Queue Name, Address, Process Time (per client), and Description.
*   **Category**: Select a business category (e.g., Salon, Clinic) or specify a custom one.
*   **Result**: Upon creation, you are redirected to the *Queue Details* page.

### 2. Queue Details & Sharing
*   **Overview**: Displays the Queue Name and ID.
*   **QR Code**: Generates a unique QR code for the queue.
    *   *Save to Gallery*: Save the QR code image locally for printing or distribution.
*   **Share**: Share the queue link directly via system share sheet (WhatsApp, Messages, etc.).
*   **Edit**: Update queue details (Name, Address, etc.) via the *Edit* option in the top-right menu.
*   **Start Session**: Enter the initial number of people (or 0) to launch the *Live Queue* dashboard.

### 3. Live Queue Management
The central dashboard for managing the active flow of customers.

*   **Status Header**: dynamic display showing if a "Client is in Progress" or "No Client in Progress".
*   **Current Client Card**:
    *   Shows the currently active client's ID and Type (General, VIP, etc.).
    *   **Complete Client**: Field to mark the current session as finished and remove the client from active status.
*   **Waiting Queue List**:
    *   Displays a scrollable list of waiting participants.
    *   **Start Processing**: "Play" button (available only on the first item) to move them to "Current Client".
    *   **Remove**: "Trash Can" icon to remove a specific participant from the queue without processing them.
*   **Add Participant**:
    *   "Add Participant" button (Float Action Button) opens a form to add walk-ins manually.
    *   Supports Name (optional) and Queue Type (General, Priority, VIP, Consultation).

## 🛠 Features Implemented
*   **State Management**: Uses `ChangeNotifier` (QueueController) for real-time UI updates.
*   **Mock Data**: Generates sample queue items for testing flows.
*   **Edit Mode**: Reusable screens for creating and editing queue configurations.
*   **Navigation**: Seamless flow between Details -> Live Dashboard -> Edit Forms.

## 🚀 Getting Started

1.  **Prerequisites**: Flutter SDK installed.
2.  **Installation**:
    ```bash
    flutter pub get
    ```
3.  **Run**:
    ```bash
    flutter run
    ```
