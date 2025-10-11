# Budget Tracker iOS App

A minimalist, dark-themed iOS budget tracking application built with SwiftUI and SwiftData.

## Features

- **Dark Theme**: Elegant dark gray background with deep maroon and dark orange accents
- **Date Navigation**: Horizontal date picker with left/right navigation
- **Budget Overview**: Daily budget display with total expenses tracking
- **Expense Management**: Add new expenses with name and amount
- **Interactive Expense Blocks**: Wave animation, contextual menu, edit and delete functionality
- **Persistent Storage**: Uses SwiftData for local data persistence
- **Modern UI**: Clean, card-based design with subtle shadows and borders

## Interactive Features

### Expense Block Interactions
- **Instant Contextual Menu**: Single tap immediately shows Edit and Delete options
- **Edit Functionality**: Modify expense name and amount through a bottom sheet modal
- **Delete Confirmation**: Confirmation alert before removing expenses
- **Input Validation**: Real-time validation for expense amounts with error messages
- **Clean Design**: Simple, focused interaction without animation distractions

### Input Validation Features
- **Amount Validation**: Only allows digits, single period, and single comma
- **Real-time Feedback**: Error messages appear immediately for invalid input
- **Error Messages**: Clear Polish text: "Tylko cyfry, kropka lub przecinek są dozwolone."
- **Button State Management**: Save buttons are disabled when input is invalid
- **Consistent Experience**: Same validation logic in both Add and Edit expense sheets

### Gesture Support
- **Hover Detection**: `onHover` modifier for desktop and iPad experiences
- **Tap Interaction**: `onTapGesture` for iOS touch interactions with instant response
- **Simplified UX**: Direct access to actions without delays or animations

## Technical Details

- **Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **iOS Target**: iOS 17.0+
- **Architecture**: MVVM with SwiftUI
- **Interaction**: Clean, instant contextual menu system

## Components

### Main Views
- `ContentView`: Main application view
- `DatePickerView`: Horizontal date navigation
- `BudgetSectionView`: Budget and expenses overview
- `ExpenseBlockView`: Interactive expense display with animations
- `AddExpenseSheet`: Modal for adding new expenses
- `EditExpenseSheet`: Modal for editing existing expenses
- // TODO: placeholder for removed "Expenses to Pay" module

### Data Model
- `Expense`: SwiftData model with id, name, amount, and date
// TODO: placeholder for removed "Expenses to Pay" module

### Custom Colors
- `darkBackground`: Main app background
- `cardBackground`: Card and section backgrounds
- `deepMaroon`: Primary accent color
- `darkOrange`: Secondary accent color
- `textPrimary`: Main text color
- `textSecondary`: Secondary text color

## Usage

1. **View Budget**: See your daily budget and current expenses
2. **Navigate Dates**: Use left/right arrows to change dates
3. **Add Expenses**: Tap the orange "+" button to add new expenses
4. **Edit Expenses**: Tap on an expense block and select "Edit"
5. **Delete Expenses**: Tap on an expense block and select "Delete" (with confirmation)
6. **Interactive Feedback**: Experience wave animations and visual feedback on interactions
7. **Track Spending**: Monitor your daily spending against your budget
// TODO: placeholder for removed "Expenses to Pay" module

## Installation

1. Open the project in Xcode
2. Select your target device or simulator
3. Build and run the application

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Core Features
- **Date-Aware Expense Tracking**: View and manage expenses for specific dates
- **Daily Budget Management**: Set and track daily spending limits
- **Monthly Budget System**: Configure and manage monthly budget amounts
- **Expense Categories**: Organize expenses with custom names and amounts
- **Real-time Calculations**: Automatic daily expense totals and remaining budget
- **Data Persistence**: SwiftData integration for local storage
- **Clean Start**: Application begins with an empty state, ready for user's first expense

### Budget Management
- **Monthly Budget Panel**: Side panel (75% screen width from right) for budget management
- **Dynamic Daily Budget**: Calculated as monthly budget divided by days in current month
- **Smart Calculations**: Uses Calendar APIs for accurate day counting
- **Input Validation**: Ensures budget amount is >= 30 zł with real-time feedback

// TODO: placeholder for removed "Expenses to Pay" module

### Custom Transaction System
- **Circular Dollar Button**: Perfectly round green button with `dollarsign.circle.fill` icon for adding custom transactions
- **Modal View**: Dedicated `CustomTransactionView` for entering transaction details (title removed for cleaner interface)
- **Full-Screen Overlay**: Semi-transparent gray background covers entire screen with `.frame(maxWidth: .infinity, maxHeight: .infinity)`
- **Direct SwiftData Integration**: Transactions saved directly to SwiftData model
- **Immediate Persistence**: Data persists immediately upon save button tap
- **Count Badge**: Red circular badge on list.bullet icon showing transaction count
- **Transaction Display**: List of custom transactions visible in MonthlyBudgetView
- **Empty State**: "Brak transakcji" message when no transactions exist

### Date Management
- **Interactive Date Picker**: Navigate between dates with previous/next buttons
- **Date-Specific Views**: Each date shows only its associated expenses
- **Dynamic Content**: Expenses list and totals update automatically when changing dates
- **Empty State Handling**: Clear message when no expenses exist for a selected date

### User Interface Enhancements
- **Side Panel Overlay**: Semi-transparent dark overlay (40% opacity) blocks underlying UI when side panels are open
- **Background Dismissal**: Tap outside side panels to dismiss them with intuitive gesture support
- **Visual Separation**: Clear distinction between active panels and background content
- **Enhanced Focus**: Overlay ensures user attention remains on the active side panel
