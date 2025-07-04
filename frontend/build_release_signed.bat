@echo off
echo Building Jivhala Motors with Release Signing...
echo.

cd /d "%~dp0"

echo Step 1: Cleaning previous builds...
flutter clean

echo Step 2: Getting dependencies...
flutter pub get

echo Step 3: Building with release signing...
echo.
echo NOTE: This build will use Play App Signing (recommended)
echo Your upload keystore will be used for initial signing
echo Google Play will re-sign with their own key for distribution
echo.

flutter build appbundle ^
    --release ^
    --build-name=1.0.0 ^
    --build-number=1 ^
    --dart-define=flutter.inspector.structuredErrors=false

echo.
echo Build Analysis:
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo ✅ App Bundle created successfully
    echo 📁 Location: build\app\outputs\bundle\release\app-release.aab
    
    echo.
    echo File Information:
    dir "build\app\outputs\bundle\release\app-release.aab"
    
    echo.
    echo ✅ This bundle is ready for Google Play Console upload
    echo 🔐 Play App Signing will handle the final release signing
    echo.
) else (
    echo ❌ Build failed - App Bundle not found
    echo Check the build output above for errors
    echo.
)

echo.
echo Next Steps:
echo 1. Upload the .aab file to Google Play Console
echo 2. Google will handle the release signing automatically
echo 3. Your app will be properly signed for distribution
echo.
pause
