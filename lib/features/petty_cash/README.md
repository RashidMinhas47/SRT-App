# Petty Cash Feature

This feature implements a complete petty cash bill submission system following Clean Architecture principles.

## Folder Structure

```
lib/features/petty_cash/
├── domain/                    # Domain Layer (Business Logic)
│   ├── entities/             # Business Entities
│   │   └── petty_cash_bill.dart
│   ├── repositories/         # Repository Interfaces
│   │   └── petty_cash_repository.dart
│   ├── usecases/            # Use Cases (Business Operations)
│   │   ├── submit_petty_cash_bill.dart
│   │   ├── complete_advance_payment.dart
│   │   ├── get_user_bills.dart
│   │   ├── get_pending_advances.dart
│   │   ├── update_bill_status.dart
│   │   ├── export_to_excel.dart
│   │   ├── upload_photo.dart
│   │   └── get_filtered_bills.dart
│   └── domain.dart          # Barrel file for exports
├── data/                     # Data Layer (Implementation)
│   ├── models/              # Data Models
│   ├── datasources/         # Data Sources (API, Local)
│   └── repositories/        # Repository Implementations
└── presentation/            # Presentation Layer (UI)
    ├── bloc/               # Business Logic Components
    ├── pages/              # Screen Pages
    └── widgets/            # Reusable Widgets
```

## Domain Layer Components

### Entities

#### PettyCashBill
The main entity representing a petty cash bill with the following fields:
- `id`: Unique identifier
- `billType`: Type of bill (enum: materialPurchase, foodMeals, transportFuel, miscellaneous, advanceRequest)
- `billNumber`: Bill number from vendor
- `vendorName`: Name of the vendor
- `customerProjectName`: Customer or project name
- `location`: Location where expense occurred
- `amount`: Expense amount
- `expenseDate`: Date of the expense
- `comments`: Additional comments
- `photoUrl`: URL of the bill photo
- `status`: Current status (enum: pending, pendingBillSubmission, billPending, approved, rejected, needsClarification)
- `userId`: ID of the user who submitted
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp

**Special fields for advance payments:**
- `isAdvancePayment`: Whether this is an advance payment
- `advancePurpose`: Purpose of the advance
- `expectedAmount`: Expected final amount
- `parentAdvanceId`: Links final bill to advance request

### Repository Interface

The `PettyCashRepository` defines the contract for data operations:
- `submitBill()`: Submit a new bill
- `updateBill()`: Update existing bill
- `getUserBills()`: Get all bills for a user
- `getPendingAdvances()`: Get pending advance payments
- `uploadPhoto()`: Upload bill photo
- `linkBillToAdvance()`: Link final bill to advance
- `getFilteredBills()`: Get filtered bills
- `updateBillStatus()`: Update bill status (admin)
- `exportToExcel()`: Export to Excel format

### Use Cases

1. **SubmitPettyCashBill**: Handles new bill submission with validation
2. **CompleteAdvancePayment**: Links final bill to an advance request
3. **GetUserBills**: Retrieves all bills for current user
4. **GetPendingAdvances**: Gets advances awaiting bill attachment
5. **UpdateBillStatus**: For admin approval/rejection
6. **ExportToExcel**: Generates Excel report
7. **UploadPhoto**: Handles photo uploads
8. **GetFilteredBills**: Retrieves filtered bills based on criteria

## Data Layer Components

### Models

#### PettyCashBillModel
Extends the PettyCashBill entity with JSON serialization capabilities:
- `fromJson()`: Creates model from JSON data
- `toJson()`: Converts model to JSON format
- `toOdooJson()`: Converts to Odoo-specific JSON format with `x_` prefixed fields
- `fromEntity()`: Creates model from domain entity
- `toEntity()`: Converts model back to domain entity

### Remote Data Source

#### PettyCashRemoteDataSource
Abstract interface defining all remote data operations:
- Odoo API integration for bill operations
- Photo upload to Odoo attachments
- Network connectivity checking
- Proper error handling with Either types

### Repository Implementation

#### PettyCashRepositoryImpl
Concrete implementation that:
- Connects domain layer with data layer
- Handles network connectivity checks
- Converts between entities and models
- Provides proper error handling
- Implements all repository interface methods

## Presentation Layer Components

### BLoC Pattern Implementation

#### PettyCashBloc
Main business logic controller that:
- Handles all user interactions and form events
- Manages state transitions
- Calls appropriate use cases for data operations
- Provides reactive UI updates

#### Events
- **SubmitBillEvent**: Submits a new petty cash bill
- **SelectBillTypeEvent**: Handles bill type selection
- **UploadPhotoEvent**: Manages photo uploads
- **LoadUserBillsEvent**: Loads user's bill history
- **LoadPendingAdvancesEvent**: Loads pending advance requests
- **CompleteAdvanceEvent**: Links bills to advance requests
- **UpdateBillStatusEvent**: Updates bill approval status
- **ExportToExcelEvent**: Exports data to Excel
- **ClearPhotoEvent**: Removes uploaded photo
- **ResetFormEvent**: Resets form to initial state

#### States
- **PettyCashInitial**: Initial state
- **PettyCashLoading**: Loading state during operations
- **BillTypeSelected**: When bill type is selected
- **PhotoUploaded**: When photo is successfully uploaded
- **BillSubmittedSuccess**: When bill submission succeeds
- **PettyCashError**: Error state with message
- **UserBillsLoaded**: When user bills are loaded
- **PendingAdvancesLoaded**: When pending advances are loaded
- **AdvanceCompleted**: When advance is completed
- **BillStatusUpdated**: When bill status is updated
- **ExcelExported**: When Excel export is complete
- **FormReset**: When form is reset

### UI Components

#### PettyCashFormPage
Complete form implementation with:
- **Responsive design** using Sizer package
- **Form validation** for all required fields
- **Conditional fields** based on bill type selection
- **Photo upload** with camera and gallery options
- **Image compression** (70% quality)
- **Real-time validation** and error messages
- **Loading states** and progress indicators
- **Success/error feedback** via SnackBars

#### Form Features
- **Bill Type Dropdown**: 5 options with conditional behavior
- **Dynamic Fields**: Different fields for advance vs regular bills
- **Date Picker**: Expense date selection (max date = today)
- **Photo Upload**: Camera/gallery with preview and delete
- **Validation**: Comprehensive field validation
- **Submit Button**: Dynamic text based on bill type

## Usage

To use the complete feature, import the barrel files:

```dart
// Domain layer
import 'package:your_app/features/petty_cash/domain/domain.dart';

// Data layer
import 'package:your_app/features/petty_cash/data/data.dart';

// Presentation layer
import 'package:your_app/features/petty_cash/presentation/presentation.dart';
```

## Error Handling

All layers use `Either<Exception, T>` for error handling, providing type-safe error management.

## Validation

The domain layer includes comprehensive validation:
- Required field validation
- Amount validation (must be > 0)
- Date validation (cannot be in future)
- Advance payment specific validation
- Status transition validation

## Network Handling

The data layer includes:
- Network connectivity checking before API calls
- Proper error handling for network failures
- Retry mechanisms for failed operations

## Form Validation Rules

### Required Fields
- **Bill Type**: Must be selected
- **Location**: Cannot be empty
- **Comments/Purpose**: Cannot be empty
- **Expense Date**: Must be selected (max date = today)
- **Photo**: Required for non-advance bills

### Conditional Requirements
- **Advance Requests**: Must include purpose and expected amount
- **Regular Bills**: Must include amount and photo
- **Amount Fields**: Must be valid positive numbers

### Photo Requirements
- **Format**: JPEG/PNG with 70% compression
- **Source**: Camera or gallery selection
- **Preview**: Available with delete option
- **Validation**: Required for non-advance bills

## Integration Points

### Dependencies
- **flutter_bloc**: State management
- **image_picker**: Photo selection
- **sizer**: Responsive design
- **dartz**: Functional programming utilities
- **equatable**: Value equality

### Existing Codebase Integration
- **ColorManager**: Consistent theming
- **ConstanceManager**: User session management
- **Odoo API**: Backend integration patterns
- **Navigation**: Standard Flutter navigation

## Next Steps

1. **Dependency Injection**: Set up GetIt for service locator
2. **Odoo Integration**: Replace remote data source stubs
3. **Testing**: Unit and widget tests
4. **Navigation**: Integrate with app navigation
5. **Offline Support**: Add local storage capabilities
