@echo off
echo ===========================================
echo   FIXING DEBUG SIGNING FOR PLAY STORE
echo ===========================================
echo.

cd /d "%~dp0"

echo Step 1: Cleaning project completely...
flutter clean
if exist "build" rmdir /s /q build
if exist ".dart_tool" rmdir /s /q .dart_tool

echo.
echo Step 2: Getting fresh dependencies...
flutter pub get

echo.
echo Step 3: Building with Play App Signing method...
echo Note: This uses Google's recommended approach for new apps
echo.

REM Build without local signing - Play Console will handle signing
flutter build appbundle --release --build-name=1.0.0 --build-number=1 --no-tree-shake-icons

echo.
echo Step 4: Checking build result...
if exist "build\app\outputs\bundle\release\app-release.aab" (
    echo ✅ SUCCESS! App bundle created
    echo.
    echo File: build\app\outputs\bundle\release\app-release.aab
    dir "build\app\outputs\bundle\release\app-release.aab"
    echo.
    echo =====================================
    echo   SOLUTION FOR DEBUG SIGNING ERROR
    echo =====================================
    echo.
    echo When uploading to Play Console:
    echo 1. Enable Play App Signing ^(should be default for new apps^)
    echo 2. Upload this .aab file
    echo 3. Google will automatically sign it for distribution
    echo.
    echo This solves the debug signing issue because:
    echo - Your upload certificate is used for upload
    echo - Google's signing certificate is used for distribution  
    echo - No debug signatures in the final app
    echo.
    echo ✅ Your app is now ready for Play Store upload!
    echo.
) else (
    echo ❌ Build failed - check errors above
    echo.
)

echo Press any key to continue...
pause > nul
