# Test Vehicle Data for Jivhala Motors

## Sample Vehicle Data for Testing Add Vehicle Functionality

### Test Case 1: Complete Vehicle Data
```json
{
  "vehicleInDate": "2025-01-01",
  "vehicleNumber": "GJ01AB1234",
  "vehicleHP": "15 HP",
  "chassisNo": "MB1234567890123456",
  "engineNo": "ENG123456789",
  "vehicleName": "Maruti Suzuki Swift",
  "modelYear": 2020,
  "ownerName": "Rajesh Kumar Patel",
  "ownerType": "1st",
  "mobileNo": "9876543210",
  "insuranceDate": "2025-12-31",
  "challan": "CH001",
  "documents": {
    "RC": true,
    "PUC": true,
    "NOC": false
  }
}
```

### Test Case 2: Minimum Required Fields
```json
{
  "vehicleNumber": "GJ05XY9876",
  "chassisNo": "HY9876543210987654",
  "engineNo": "HYN987654321",
  "vehicleName": "Hyundai i20",
  "modelYear": 2019,
  "ownerName": "Priya Shah",
  "ownerType": "2nd",
  "mobileNo": "8765432109",
  "documents": {
    "RC": true,
    "PUC": false,
    "NOC": false
  }
}
```

### Test Case 3: Commercial Vehicle
```json
{
  "vehicleInDate": "2024-12-25",
  "vehicleNumber": "GJ02AB5678",
  "vehicleHP": "75 HP",
  "chassisNo": "TT5678901234567890",
  "engineNo": "TTN567890123",
  "vehicleName": "Tata Ace",
  "modelYear": 2018,
  "ownerName": "Mukesh Bhai Patel",
  "ownerType": "3rd",
  "mobileNo": "7654321098",
  "insuranceDate": "2025-06-30",
  "challan": "CH002",
  "documents": {
    "RC": true,
    "PUC": true,
    "NOC": true
  }
}
```

### Test Case 4: Two Wheeler
```json
{
  "vehicleInDate": "2025-01-02",
  "vehicleNumber": "GJ01CD9999",
  "vehicleHP": "10 HP",
  "chassisNo": "BA9999888877776666",
  "engineNo": "BAN999888777",
  "vehicleName": "Bajaj Pulsar 150",
  "modelYear": 2021,
  "ownerName": "Amit Kumar",
  "ownerType": "1st",
  "mobileNo": "6543210987",
  "insuranceDate": "2025-08-15",
  "documents": {
    "RC": true,
    "PUC": true,
    "NOC": false
  }
}
```

## Frontend Testing Steps:

1. **Open the Jivhala Motors app**
2. **Login with demo credentials**
3. **Navigate to Add Vehicle screen**
4. **Fill in the form using one of the sample data above:**

### Example Form Fill (Test Case 1):
- **Vehicle In Date**: 2025-01-01
- **Vehicle Number**: GJ01AB1234
- **Vehicle HP**: 15 HP
- **Chassis No**: MB1234567890123456
- **Engine No**: ENG123456789
- **Vehicle Name**: Maruti Suzuki Swift
- **Model Year**: 2020
- **Owner Name**: Rajesh Kumar Patel
- **Owner Type**: 1st (from dropdown)
- **Mobile Number**: 9876543210
- **Insurance Date**: 2025-12-31
- **Challan**: CH001
- **Documents**: 
  - ✅ RC (Registration Certificate)
  - ✅ PUC (Pollution Under Control)
  - ❌ NOC (No Objection Certificate)
- **Photos**: Add 1-6 vehicle photos

5. **Click "Add Vehicle" button**
6. **Verify success message appears**
7. **Check vehicle appears in vehicle list**

## API Testing with Postman:

### POST Request to `/api/vehicles/in`
**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: multipart/form-data
```

**Body (form-data):**
```
vehicleInDate: 2025-01-01
vehicleNumber: GJ01AB1234
vehicleHP: 15 HP
chassisNo: MB1234567890123456
engineNo: ENG123456789
vehicleName: Maruti Suzuki Swift
modelYear: 2020
ownerName: Rajesh Kumar Patel
ownerType: 1st
mobileNo: 9876543210
insuranceDate: 2025-12-31
challan: CH001
RC: true
PUC: true
NOC: false
photos: [Upload image files]
```

**Expected Response:**
```json
{
  "message": "Vehicle added successfully",
  "vehicle": {
    "_id": "generated_id",
    "uniqueId": "JM-timestamp-randomstring",
    "vehicleInDate": "2025-01-01T00:00:00.000Z",
    "vehicleNumber": "GJ01AB1234",
    "vehicleHP": "15 HP",
    "chassisNo": "MB1234567890123456",
    "engineNo": "ENG123456789",
    "vehicleName": "Maruti Suzuki Swift",
    "modelYear": 2020,
    "ownerName": "Rajesh Kumar Patel",
    "ownerType": "1st",
    "mobileNo": "9876543210",
    "insuranceDate": "2025-12-31T00:00:00.000Z",
    "challan": "CH001",
    "documents": {
      "RC": true,
      "PUC": true,
      "NOC": false
    },
    "photos": [
      {
        "filename": "photos-timestamp-randomnumber.jpg",
        "originalName": "vehicle1.jpg",
        "path": "uploads/vehicles/photos-timestamp-randomnumber.jpg",
        "uploadDate": "2025-01-01T12:00:00.000Z"
      }
    ],
    "status": "in",
    "createdBy": "user_id",
    "createdAt": "2025-01-01T12:00:00.000Z",
    "updatedAt": "2025-01-01T12:00:00.000Z"
  }
}
```

## Common Issues and Solutions:

### 1. **Validation Errors**
- Ensure all required fields are filled
- Vehicle number should be in proper format (e.g., GJ01AB1234)
- Mobile number should be 10 digits starting with 6-9
- Model year should be between 1990 and current year + 1

### 2. **Photo Upload Issues**
- Photos should be in image format (jpg, png, etc.)
- Maximum 6 photos allowed
- File size should be under 5MB per photo

### 3. **Date Format Issues**
- Dates should be in YYYY-MM-DD format
- Insurance date is optional

### 4. **Backend Connection Issues**
- Ensure backend server is running on port 3000
- Check MongoDB connection
- Verify JWT token is valid
