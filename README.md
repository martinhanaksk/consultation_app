# Consultation App

Author: Martin Hanák xhanakm00@stud.fit.vut.cz
Supervisor: prof. Ing. Adam Herout, Ph.D.

A Flutter mobile application that enables students to book consultation slots and allows teachers to manage consultation rooms, blocks and slots. The application follows the MVVM pattern.

---

## Project Structure

```
consultation_app/
└── lib/
    ├── main.dart                        # Application entry point
    ├── setup.dart                       # App initialization and dependency setup
    │
    ├── models/                          # Data models
    │   ├── block_model.dart
    │   ├── room_model.dart
    │   ├── slot_model.dart
    │   └── user_model.dart
    │
    ├── services/                        # App services
    │   ├── api_service.dart
    │   ├── app_router.dart
    │   ├── navigation_service.dart
    │   ├── session_manager.dart
    │   └── user_preferences.dart
    │
    ├── utils/                           # Utility functions and constants
    │   ├── app_svg.dart
    │   ├── constants.dart
    │   ├── helper_functions.dart
    │   ├── notify_user_utils.dart
    │   ├── theme_selector.dart
    │   ├── time_utils.dart
    │   ├── time_validation_utils.dart
    │   └── validator.dart
    │
    ├── viewmodels/                      # ViewModels (MVVM pattern)
    │   ├── add_slot_viewmodel.dart
    │   ├── base_consultations_viewmodel.dart
    │   ├── base_room_viewmodel.dart
    │   ├── change_settings_viewmodel.dart
    │   ├── create_block_viewmodel.dart
    │   ├── create_room_viewmodel.dart
    │   ├── display_slot_history_viewmodel.dart
    │   ├── display_users_in_room_viewmodel.dart
    │   ├── edit_block_viewmodel.dart
    │   ├── edit_room_viewmodel.dart
    │   ├── email_input_viewmodel.dart
    │   ├── join_room_viewmodel.dart
    │   ├── my_reservations_viewmodel.dart
    │   ├── owner_consultations_viewmodel.dart
    │   ├── register_viewmodel.dart
    │   ├── slider_menu_viewmodel.dart
    │   └── verify_otp_viewmodel.dart
    │
    └── views/                           # UI layer
        ├── add_slot_page.dart
        ├── create_block_page.dart
        ├── create_room_page.dart
        ├── display_list_of_emails_page.dart
        ├── display_notify_hours_page.dart
        ├── display_slot_history_page.dart
        ├── display_users_in_room_page.dart
        ├── edit_block_page.dart
        ├── edit_room_page.dart
        ├── email_input_page.dart
        ├── join_room_page.dart
        ├── my_reservations_page.dart
        ├── owner_consultations_page.dart
        ├── registration_page.dart
        ├── verify_otp_page.dart
        │
        ├── base_consultations/          # Base consultation view components
        │   ├── base_consultations_page.dart
        │   ├── block_consultation_card.dart
        │   ├── content_consultations.dart
        │   ├── no_rooms_found.dart
        │   └── room_selector_button.dart
        │
        ├── custom_widgets/              # Reusable UI widgets
        │   ├── animated_toggle_widget.dart
        │   ├── app_bar_menu_widget.dart
        │   ├── custom_checkbox_widget.dart
        │   ├── custom_date_range_picker_dialog.dart
        │   ├── custom_text_field_widget.dart
        │   ├── custom_time_duration_picker.dart
        │   ├── room_form_body_widget.dart
        │   └── slider_menu_widget.dart
        │
        ├── settings/                    # Settings screen
        │   ├── change_settings_page.dart
        │   ├── settings_dialogs.dart
        │   └── settings_tiles.dart
        │
        └── slots/                       # Slot-related UI components
            ├── another_users_slot.dart
            ├── current_user_slot.dart
            ├── free_slot.dart
            ├── keyboard_padding.dart
            ├── slot_time.dart
            ├── slot_widget.dart
            ├── take_slot_bottom_sheet.dart
            ├── type_bottom_sheet.dart
            └── type_toggle.dart
```


## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (bundled with Flutter)

### Installation

```bash
flutter pub get
flutter run
```

---
