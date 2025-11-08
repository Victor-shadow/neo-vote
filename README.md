# neo_vote

A new Flutter project.

## Getting Started

# NeoVote Mobile App: Flutter Frontend Architecture

This document outlines the complete frontend architecture for the NeoVote mobile application, built with Flutter. It details the guiding design principles, a scalable folder structure, and how this structure meets the requirements laid out in the NeoVote business plan.

## 1. Guiding Principles for UI/UX

The design and development of the NeoVote mobile app will adhere to the following core principles:

1.  **Clarity and Simplicity:** The user journey—from login to casting a vote—must be intuitive and effortless. The UI will minimize cognitive load, ensuring voters can participate without confusion.
2.  **Security and Trust:** The interface must constantly reassure the user that their vote is secure, private, and correctly recorded. This will be achieved through visual cues like biometric prompts, success animations, loading states, and easily accessible, verifiable vote receipts.
3.  **Responsiveness:** The layout must adapt seamlessly to all Android device sizes and orientations, from small-screen budget phones to large-screen tablets. We will use responsive widgets and dynamic layouts to ensure a consistent, high-quality experience for every user.
4.  **Accessibility (a11y):** The app must be usable by people with disabilities. This includes ensuring proper color contrast, using scalable fonts for readability, and making the app fully compatible with screen readers like TalkBack.
5.  **Dynamic Branding:** While the core app will have a distinct NeoVote brand, the architecture will support custom branding (logos, color schemes) for institutional clients, as specified in the project requirements.

---

## 2. Optimized Folder Structure

To ensure scalability, testability, and a clear separation of concerns, the project will be organized by **feature**, with a shared **core** layer for common functionality.


---

## 3. Explanation of Key Directories and Files

#### `api/`
-   **Purpose:** To abstract all data fetching logic. Whether calling a REST API, a GraphQL endpoint, or interacting directly with the Solana blockchain via a library, it happens here. This isolates complex data source logic from the UI and business logic layers.
-   **Example (`vote_api.dart`):** Contains the `castVote(ballotData)` function, which will construct, sign, and submit a transaction to the Solana network.

#### `core/`
This is the heart of the application's shared logic, accessible by all features.
-   **`services/`:** For complex functionalities that are not tied to a specific feature.
    -   `secure_storage_service.dart`: Handles securely storing sensitive data like auth tokens or private keys using `flutter_secure_storage`.
    -   `connectivity_service.dart`: Monitors the user's network status to enable/disable offline mode features.
-   **`models/`:** Defines the structure of data (e.g., `BallotModel` with `fromMap` and `toMap` methods for JSON serialization).
-   **`l10n/` (Localization):** Flutter's official way to handle multi-language support. The `.arb` files store key-value pairs for each UI string in each language (English, Swahili, Kinyarwanda).

#### `features/`
This is where the application's screens and feature-specific logic are built. Each subfolder is a self-contained module. The numbered prefixes (`0_`, `1_`) indicate the typical user flow, making navigation easier.
-   **`controller/`:** The business logic for the feature, powered by Riverpod's `StateNotifier` or `FutureProvider`. The controller orchestrates calls to the API layer and manages the feature's state.
-   **`view/`:** The screens (UI) for the feature. They are deliberately kept "dumb," meaning they only display data from the controller and forward user events (e.g., button taps) back to the controller.
-   **`widgets/`:** Reusable UI components that are specific to this feature. For example, `election_card.dart` is only used on the dashboard, so it belongs here.

#### `presentation/`
This folder defines the app's global look and feel.
-   **`common_widgets/`:** Truly global, reusable widgets like `PrimaryButton` or `LoadingSpinner` that can be used on any screen.
    -   **`responsive_layout.dart`:** A crucial widget for supporting all devices. It can define different layouts for mobile and tablet, ensuring the UI looks great everywhere.
-   **`theme/`:** Defines colors, fonts, and component styles. `app_theme.dart` will be configured to allow for dynamic theming to support the "Custom branding for institutions" requirement.
-   **`assets/`:** Static files like brand logos, custom icons, and fonts.

#### `main.dart`
The entry point of the application. Its main job is to initialize Riverpod (`ProviderScope`), set the global theme, and use a provider (e.g., `authStateProvider`) to decide which initial screen to show: `LoginView` if logged out, or `DashboardView` if logged in.

---

## 4. How this Structure Meets Project Requirements

-   **Responsive & Dynamic UI:**
    -   The `responsive_layout.dart` widget and the general use of `LayoutBuilder` and `MediaQuery` ensure that the UI adapts gracefully to any screen size and orientation on all Android devices.

-   **Secure Login (Biometric + Passwordless):**
    -   The logic is encapsulated in `features/0_auth/controller/auth_controller.dart`.
    -   The UI prompt is a reusable widget: `features/0_auth/widgets/biometric_prompt_button.dart`.
    -   Sensitive tokens are handled by the `core/services/secure_storage_service.dart`.

-   **Ballot Display (Multiple Types):**
    -   The `features/2_voting/view/ballot_view.dart` will use conditional logic based on the ballot type (`single_choice`, `ranked_choice`) to render the appropriate interactive widget from `features/2_voting/widgets/ballot_options/`. This design is highly scalable for future election types.

-   **Offline-Ready:**
    -   `core/services/connectivity_service.dart` will notify controllers when the app is offline.
    -   The `VotingController` will detect offline status and queue the vote transaction locally. When connectivity is restored, a background service will sync the queued votes.

-   **Multi-language Support:**
    -   The `core/l10n/` directory, combined with Flutter's internationalization packages, provides a robust and standard way to manage translations. A user can change their language in the profile settings, and the entire UI will update instantly.

-   **CI/CD and Testing:**
    -   This feature-first structure is ideal for testing. Unit tests can be written for controllers and API classes, while widget tests can target individual feature screens in isolation, leading to a more stable and reliable application.

- Folder structure
- md
  neo_vote_app/
  └── lib/
  ├── api/
  │   ├── auth_api.dart
  │   ├── election_api.dart
  │   └── vote_api.dart
  │
  ├── core/
  │   ├── providers/
  │   │   └── api_providers.dart
  │   │
  │   ├── services/
  │   │   ├── connectivity_service.dart
  │   │   ├── notification_service.dart
  │   │   └── secure_storage_service.dart
  │   │
  │   ├── models/
  │   │   ├── ballot_model.dart
  │   │   ├── candidate_model.dart
  │   │   └── user_model.dart
  │   │
  │   ├── utils/
  │   │   ├── constants.dart
  │   │   ├── failure.dart
  │   │   └── typedefs.dart
  │   │
  │   └── l10n/
  │       ├── app_en.arb
  │       ├── app_sw.arb
  │       └── app_rw.arb
  │
  ├── features/
  │   ├── 0_auth/
  │   │   ├── controller/
  │   │   │   └── auth_controller.dart
  │   │   ├── view/
  │   │   │   ├── login_view.dart
  │   │   │   └── otp_view.dart
  │   │   └── widgets/
  │   │       └── biometric_prompt_button.dart
  │   │
  │   ├── 1_dashboard/
  │   │   ├── controller/
  │   │   │   └── dashboard_controller.dart
  │   │   ├── view/
  │   │   │   └── dashboard_view.dart
  │   │   └── widgets/
  │   │       ├── election_card.dart
  │   │       └── no_elections_widget.dart
  │   │
  │   ├── 2_voting/
  │   │   ├── controller/
  │   │   │   └── voting_controller.dart
  │   │   ├── view/
  │   │   │   ├── ballot_view.dart
  │   │   │   └── vote_confirmation_view.dart
  │   │   └── widgets/
  │   │       ├── ballot_options/
  │   │       │   ├── single_choice_option.dart
  │   │       │   └── ranked_choice_option.dart
  │   │       └── vote_timer_widget.dart
  │   │
  │   ├── 3_receipts/
  │   │   ├── controller/
  │   │   │   └── receipts_controller.dart
  │   │   ├── view/
  │   │   │   ├── receipt_list_view.dart
  │   │   │   └── receipt_detail_view.dart
  │   │   └── widgets/
  │   │       └── receipt_list_item.dart
  │   │
  │   └── 4_profile/
  │       ├── controller/
  │       │   └── profile_controller.dart
  │       ├── view/
  │       │   ├── profile_view.dart
  │       │   └── language_selection_view.dart
  │       └── widgets/
  │           └── theme_switcher_widget.dart
  │
  ├── presentation/
  │   ├── common_widgets/
  │   │   ├── responsive_layout.dart
  │   │   ├── primary_button.dart
  │   │   ├── loading_spinner.dart
  │   │   └── error_display_widget.dart
  │   │
  │   ├── theme/
  │   │   ├── app_theme.dart
  │   │   └── palettes.dart
  │   │
  │   └── assets/
  │       ├── fonts/
  │       ├── icons/
  │       └── images/
  │
  └── main.dart
