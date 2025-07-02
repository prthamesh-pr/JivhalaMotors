# Jivhala Motors API Testing & Frontend Setup Guide

## 🌐 API Base URL
```
Production: https://backend-0v1f.onrender.com
```

## 📋 Frontend Configuration Update

The frontend has been updated to use the production API URL. The changes made:

1. **Constants Updated** (`frontend/lib/config/constants.dart`):
   - Updated `baseUrl` to point to `https://backend-0v1f.onrender.com/api`
   - Removed unused development URL to eliminate lint warnings

2. **Android Permissions Added** (`frontend/android/app/src/main/AndroidManifest.xml`):
   - Added `INTERNET` permission for API calls
   - Added `ACCESS_NETWORK_STATE` permission
   - Added network security configuration for HTTPS requests

3. **Network Security Config** (`frontend/android/app/src/main/res/xml/network_security_config.xml`):
   - Configured to allow requests to the production API
   - Added support for localhost and development domains

## 🚀 Postman API Testing

### Files Created:
1. **`Jivhala_Motors_API_Collection.postman_collection.json`** - Complete API collection
2. **`Jivhala_Motors_Environment.postman_environment.json`** - Environment variables

### Import Instructions:
1. Open Postman
2. Click **Import** button
3. Import both JSON files:
   - `Jivhala_Motors_API_Collection.postman_collection.json`
   - `Jivhala_Motors_Environment.postman_environment.json`
4. Select "Jivhala Motors Environment" in the environment dropdown

### 📊 API Endpoints Available

#### 🔐 Authentication APIs
- **POST** `/api/auth/register` - Register new user
- **POST** `/api/auth/login` - User login
- **GET** `/api/auth/profile` - Get user profile
- **GET** `/api/auth/verify` - Verify token
- **POST** `/api/auth/change-password` - Change password
- **POST** `/api/auth/forgot-password` - Forgot password
- **POST** `/api/auth/reset-password` - Reset password

#### 🚗 Vehicle Management APIs
- **POST** `/api/vehicles/in` - Add vehicle (Vehicle In)
- **GET** `/api/vehicles` - Get all vehicles (with search & pagination)
- **GET** `/api/vehicles/:id` - Get vehicle by ID
- **PUT** `/api/vehicles/:id` - Update vehicle
- **POST** `/api/vehicles/:id/out` - Vehicle out
- **DELETE** `/api/vehicles/:id` - Delete vehicle
- **GET** `/api/vehicles/stats/dashboard` - Dashboard statistics

#### 📄 Export APIs
- **GET** `/api/export/vehicles/pdf` - Export vehicles as PDF
- **GET** `/api/export/vehicles/csv` - Export vehicles as CSV

#### 🏥 Health Check
- **GET** `/health` - API health check

## 🔧 Testing Workflow

### 1. First-time Setup:
```bash
# Test API health
GET {{base_url}}/health

# Register a user (if needed)
POST {{base_url}}/api/auth/register
{
  "username": "admin",
  "email": "admin@jivhalamotors.com", 
  "password": "password123",
  "name": "Administrator"
}

# Login to get token
POST {{base_url}}/api/auth/login
{
  "username": "admin",
  "password": "password123"
}
```

### 2. Vehicle Operations:
```bash
# Add a vehicle
POST {{base_url}}/api/vehicles/in
# (Use form-data with vehicle details)

# Get all vehicles
GET {{base_url}}/api/vehicles?page=1&limit=10

# Search vehicles
GET {{base_url}}/api/vehicles?search=swift&status=in

# Update vehicle (replace VEHICLE_ID_HERE with actual ID)
PUT {{base_url}}/api/vehicles/VEHICLE_ID_HERE

# Mark vehicle as out
POST {{base_url}}/api/vehicles/VEHICLE_ID_HERE/out
```

### 3. Export & Reports:
```bash
# Export PDF
GET {{base_url}}/api/export/vehicles/pdf?status=all

# Export CSV
GET {{base_url}}/api/export/vehicles/csv?status=all

# Dashboard stats
GET {{base_url}}/api/vehicles/stats/dashboard
```

## 🛠 Frontend Development

### Running the Flutter App:
```bash
# Navigate to frontend directory
cd frontend

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# For release build
flutter build apk --release
```

### Common Issues & Solutions:

1. **Network Request Failures**:
   - Ensure internet permissions are added (✅ Done)
   - Check network security config (✅ Done)
   - Verify API URL in constants (✅ Done)

2. **API Connection Issues**:
   - Test API endpoints in Postman first
   - Check if Render.com backend is active
   - Verify authentication token is valid

3. **Android Build Issues**:
   - Clean build: `flutter clean && flutter pub get`
   - Rebuild: `flutter build apk`

## 📱 App Features

The Jivhala Motors app includes:
- **User Authentication** (Login/Register)
- **Vehicle Management** (Add, View, Update, Delete)
- **Vehicle In/Out Tracking**
- **Search & Filter Vehicles**
- **Dashboard with Statistics**
- **PDF/CSV Export**
- **Image Upload for Vehicles**
- **Owner Information Management**

## 🔑 Environment Variables

For the Postman environment:
- `base_url`: https://backend-0v1f.onrender.com
- `auth_token`: (Auto-populated after login)
- `test_username`: admin
- `test_email`: admin@jivhalamotors.com
- `test_password`: password123

## 📞 Support

For technical support or questions:
- **Developed by**: 5techG
- **Email**: info@jivhalamotors.com

---

**Note**: The authentication token will be automatically set in Postman environment variables after successful login. All protected endpoints require this token in the Authorization header.
