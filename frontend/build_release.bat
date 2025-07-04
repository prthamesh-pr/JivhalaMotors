@echo off
echo Building Jivhala Motors Release APK...
echo.

cd /d "%~dp0"

echo Cleaning previous builds...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building release APK...
flutter build apk --release

echo.
echo Build completed!
echo APK location: build\app\outputs\flutter-apk\app-release.apk
echo.
pause
