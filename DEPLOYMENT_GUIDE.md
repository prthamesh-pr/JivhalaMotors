# Jivhala Motors Backend Deployment Guide

## 🔧 Fixed Issues

### 1. Package.json Start Script
- ✅ Fixed: Removed `NODE_ENV=production` from start script
- ✅ Now uses: `"start": "node server.js"`
- ✅ Render automatically sets NODE_ENV=production

### 2. Port Configuration
- ✅ Fixed: Server listens on `process.env.PORT || 3000`
- ✅ Fixed: Binds to `0.0.0.0` for Render compatibility
- ✅ Render automatically assigns PORT environment variable

### 3. CORS Configuration
- ✅ Fixed: Simplified CORS setup
- ✅ Fixed: Allows your frontend domain
- ✅ Fixed: Handles preflight requests properly

### 4. Environment Variables
- ✅ Fixed: Simplified environment loading
- ✅ Created: `.env.render` with required variables

## 🚀 Deployment Steps

### Step 1: Set Environment Variables in Render
Go to your Render service dashboard and add these environment variables:

```bash
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/jivhala_motors
JWT_SECRET=your-super-secure-jwt-secret-key-2024
JWT_EXPIRES_IN=24h
NODE_ENV=production
FRONTEND_URL=https://your-frontend-domain.onrender.com
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
```

### Step 2: MongoDB Atlas Setup
1. Go to MongoDB Atlas (https://cloud.mongodb.com)
2. Navigate to Network Access
3. Add IP Address: `0.0.0.0/0` (allows all IPs for Render)
4. Ensure your database user has read/write permissions

### Step 3: Deploy to Render
1. Push your code to GitHub
2. In Render dashboard, redeploy your service
3. Check the deployment logs for any errors

### Step 4: Test the Deployment
Test these endpoints:
- Health Check: `https://backend-0v1f.onrender.com/health`
- API Status: `https://backend-0v1f.onrender.com/`
- Login Test: `https://backend-0v1f.onrender.com/api/auth/login`

## 🔍 Testing Commands

### Test Local Server
```bash
cd backend
npm start
```

### Test Health Endpoint
```bash
curl https://backend-0v1f.onrender.com/health
```

### Test CORS
```bash
curl -H "Origin: https://your-frontend-domain.com" \
     -H "Access-Control-Request-Method: POST" \
     -X OPTIONS \
     https://backend-0v1f.onrender.com/api/auth/login
```

## 📊 Monitoring

### Check Logs in Render
1. Go to your service in Render dashboard
2. Click on "Logs" tab
3. Look for:
   - ✅ "MongoDB connected successfully"
   - ✅ "Jivhala Motors API Server"
   - ❌ Any error messages

### Health Check Response
Expected response from `/health`:
```json
{
  "status": "healthy",
  "timestamp": "2025-07-02T11:30:00.000Z",
  "environment": "production",
  "database": "connected",
  "uptime": 123.456
}
```

## 🛠 Troubleshooting

### If 502 Error Persists:
1. Check Render logs for startup errors
2. Verify MONGODB_URI is set correctly
3. Ensure MongoDB Atlas allows Render IPs (0.0.0.0/0)
4. Check if service is using correct PORT

### If CORS Errors:
1. Verify FRONTEND_URL environment variable
2. Check origin in browser network tab
3. Ensure preflight requests are handled

### Database Connection Issues:
1. Test MongoDB URI locally first
2. Check MongoDB Atlas network access
3. Verify database user permissions
4. Check connection string format

## 📝 Next Steps

1. Update your frontend to use the correct backend URL
2. Test all API endpoints
3. Set up proper MongoDB database
4. Configure email service for OTP functionality
5. Add proper error monitoring

## ⚡ Quick Fix Commands

If you need to redeploy quickly:
```bash
# From your project root
git add .
git commit -m "Fix backend deployment issues"
git push origin main
```

Then trigger a redeploy in Render dashboard.
