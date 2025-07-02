# Jivhala Motors - Vehicle Management System

## Overview

Jivhala Motors is a comprehensive vehicle dealer management mobile application designed for small to mid-sized car dealerships. It tracks the entire vehicle lifecycle—from intake (Vehicle In) to sale (Vehicle Out)—and includes buyer management, PDF generation, notifications, data export, and full user profile capabilities.

**Designed and Developed by 5techG**

## 📱 Tech Stack

### Frontend (Mobile)
- **Framework**: Flutter
- **Language**: Dart
- **Architecture**: MVVM with Provider
- **UI/UX**: Cupertino + Material hybrid, Dark/Light Mode

### Backend
- **Framework**: Node.js + Express.js
- **Database**: MongoDB (Atlas)
- **Authentication**: JWT with email OTP
- **File Upload**: Multer
- **PDF Generation**: PDFKit
- **Security**: Password hashing with bcrypt, rate limiting, token expiration

## 🚀 Getting Started

### Prerequisites

- Node.js (v14 or higher)
- MongoDB (local or Atlas)
- Flutter SDK (latest stable)
- Android Studio / VS Code with Flutter extensions

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` file with your configurations:
   ```env
   MONGODB_URI=mongodb+srv://your-username:your-password@cluster.mongodb.net/jivhala_motors
   JWT_SECRET=your-super-secret-jwt-key
   JWT_EXPIRES_IN=7d
   NODE_ENV=development
   PORT=3000
   
   # Email configuration for OTP
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-app-password
   ```

4. **Start the server:**
   ```bash
   # Development mode
   npm run dev
   
   # Production mode
   npm start
   ```

5. **The server will run on:** `http://localhost:3000`

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API URL in constants:**
   
   Edit `lib/config/constants.dart`:
   ```dart
   // For Android emulator
   static const String baseUrl = 'http://10.0.2.2:3000/api';
   
   // For iOS simulator
   static const String baseUrl = 'http://localhost:3000/api';
   
   // For production
   static const String baseUrl = 'https://your-production-url.com/api';
   ```

4. **Run the app:**
   ```bash
   # Check connected devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device-id>
   
   # Run in debug mode
   flutter run --debug
   
   # Run in release mode
   flutter run --release
   ```

## 📁 Project Structure

### Backend Structure
```
backend/
├── server.js                 # Entry point
├── package.json              # Dependencies
├── .env                      # Environment variables
├── .env.example              # Environment template
├── middleware/
│   └── auth.js               # Authentication middleware
├── models/
│   ├── User.js               # User model
│   └── Vehicle.js            # Vehicle model
├── routes/
│   ├── auth.js               # Authentication routes
│   ├── vehicles.js           # Vehicle management routes
│   └── export.js             # Data export routes
└── uploads/                  # File storage directory
    └── vehicles/
```

### Frontend Structure
```
frontend/
├── lib/
│   ├── main.dart                     # App entry point
│   ├── routes.dart                   # App routing
│   ├── config/
│   │   ├── theme.dart                # App themes
│   │   └── constants.dart            # App constants
│   ├── models/
│   │   ├── user.dart                 # User model
│   │   ├── vehicle.dart              # Vehicle model
│   │   └── dashboard_stats.dart      # Dashboard statistics
│   ├── providers/
│   │   ├── auth_provider.dart        # Authentication state
│   │   ├── vehicle_provider.dart     # Vehicle state
│   │   └── theme_provider.dart       # Theme state
│   ├── services/
│   │   ├── api_service.dart          # API communication
│   │   └── notification_service.dart # Local notifications
│   ├── screens/
│   │   ├── splash/                   # Splash screen
│   │   ├── auth/                     # Authentication screens
│   │   ├── dashboard/                # Dashboard
│   │   ├── vehicle/                  # Vehicle management
│   │   ├── profile/                  # User profile
│   │   └── common/                   # Common screens
│   └── widgets/                      # Reusable widgets
├── android/                          # Android configuration
├── ios/                              # iOS configuration
├── pubspec.yaml                      # Flutter dependencies
└── README.md
```

## 🔧 Key Features Implemented

### ✅ Backend Features
- User authentication with JWT
- Password reset with email OTP
- Vehicle CRUD operations
- File upload for vehicle photos
- Dashboard statistics
- PDF and CSV export
- Data validation and error handling
- Security middleware (CORS, rate limiting, etc.)

### ✅ Frontend Features  
- App theming (Light/Dark mode)
- Provider-based state management
- API service layer
- Local notifications setup
- Routing system
- Splash screen with animations
- Basic screen structure

### 🚧 Features In Progress
- Complete UI implementation for all screens
- Vehicle form with image picker
- Dashboard with charts
- PDF generation and printing
- Search and filter functionality
- Offline data caching

## 🛠️ Development Commands

### Backend
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Start production server
npm start

# Run tests
npm test
```

### Frontend
```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Build APK
flutter build apk

# Build for iOS
flutter build ios

# Analyze code
flutter analyze

# Run tests
flutter test
```

## 📋 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/forgot-password` - Send OTP for password reset
- `POST /api/auth/reset-password` - Reset password with OTP
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update user profile
- `PUT /api/auth/change-password` - Change password

### Vehicles
- `GET /api/vehicles` - Get vehicles with pagination and filters
- `POST /api/vehicles/in` - Add new vehicle
- `GET /api/vehicles/:id` - Get vehicle details
- `PUT /api/vehicles/:id` - Update vehicle
- `DELETE /api/vehicles/:id` - Delete vehicle
- `POST /api/vehicles/:id/out` - Mark vehicle as sold
- `GET /api/vehicles/stats/dashboard` - Get dashboard statistics

### Export
- `GET /api/export/vehicles/pdf` - Export vehicles as PDF
- `GET /api/export/vehicles/csv` - Export vehicles as CSV
- `GET /api/export/vehicle/:id/pdf` - Generate vehicle PDF

## 🔒 Security Features

- JWT token-based authentication
- Password hashing with bcrypt
- Rate limiting on API endpoints
- Input validation and sanitization
- CORS configuration
- File upload security
- Environment variable configuration

## 📱 Mobile Features

- Cross-platform (Android & iOS)
- Responsive design
- Offline capability (planned)
- Local notifications
- Image picker for vehicle photos
- PDF viewing and sharing
- Dark/Light theme support

## 🚀 Deployment

### Backend Deployment (Render/Railway)
1. Create account on Render or Railway
2. Connect your GitHub repository
3. Set environment variables
4. Deploy with auto-deploy enabled

### Frontend Deployment
1. **Android:**
   ```bash
   flutter build apk --release
   ```
   
2. **iOS:**
   ```bash
   flutter build ios --release
   ```

3. **Web (if needed):**
   ```bash
   flutter build web
   ```

## 🧪 Testing

### Backend Testing
```bash
# Run API tests
npm test

# Test with Postman collection (included)
```

### Frontend Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📞 Support & Contact

For support or questions regarding Jivhala Motors:

- **Developer**: 5techG
- **Email**: support@5techg.com
- **Documentation**: This README file

## 📄 License

Copyright © 2025 5techG. All rights reserved.

---

**Jivhala Motors** - Your Trusted Vehicle Partner
