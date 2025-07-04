@echo off
echo Building Jivhala Motors Release App Bundle for Play Store...
echo.

cd /d "%~dp0"

echo Cleaning previous builds...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building release App Bundle with proper signing...
flutter build appbundle --release --build-name=1.0.0 --build-number=1

echo.
echo Build completed!
echo App Bundle location: build\app\outputs\bundle\release\app-release.aab
echo.
echo This .aab file is properly signed for Play Store release.
echo.
pause
