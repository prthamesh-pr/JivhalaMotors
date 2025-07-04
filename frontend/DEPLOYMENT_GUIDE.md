# Jivhala Motors - Deployment Guide

## Pre-deployment Checklist

### 1. App Configuration ✅
- [x] App name set to "Jivhala Motors"
- [x] App icon updated to use "image 1 (1).png"
- [x] Android and iOS permissions configured
- [x] Network security configuration added

### 2. Android Deployment

#### Keystore Configuration ✅
Your keystore has been created and configured:
- **File**: `android/upload-keystore.jks`
- **Alias**: `jivhala`
- **Store Password**: `jivhalams`
- **Key Password**: `jivhalams`

#### Build Release APK
```bash
# Option 1: Use the provided script
./build_release.bat

# Option 2: Manual command
flutter build apk --release
```

#### Build App Bundle for Play Store
```bash
# Option 1: Use the provided script (RECOMMENDED)
./build_playstore.bat

# Option 2: Manual command
flutter build appbundle --release
```

### 3. iOS Deployment

#### Requirements
- Apple Developer Account ($99/year)
- Xcode installed on macOS
- Valid provisioning profiles and certificates

#### Build for iOS
```bash
flutter build ios --release
```

#### Archive and Upload via Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Upload to App Store Connect

### 4. App Store Preparation

#### Required Assets
- App icon (1024x1024 PNG) - Already configured
- Screenshots for different device sizes
- App description and metadata
- Privacy policy URL (required for apps that collect data)

#### Play Store Requirements
- Target API level: Latest Android API
- App bundle size optimization
- Content rating questionnaire
- Store listing assets

#### App Store Requirements
- iOS version compatibility
- App Review Guidelines compliance
- Metadata and screenshots
- Privacy policy

### 5. Post-Deployment

#### Monitoring
- Set up crash reporting (Firebase Crashlytics recommended)
- Analytics integration
- Performance monitoring

#### Updates
- Version management in pubspec.yaml
- Release notes preparation
- Staged rollout strategy

## Important Notes

### Permissions Used
**Android:**
- Internet access
- Network state
- Camera access
- Storage read/write
- Media images access

**iOS:**
- Camera usage
- Photo library access
- Network access

### Network Configuration
- HTTP traffic is allowed for development
- Update network_security_config.xml with your production API domains
- Consider HTTPS for production APIs

### Security Considerations
- Remove debug flags in production
- Implement certificate pinning for API calls
- Validate all user inputs
- Use secure storage for sensitive data

## Build Commands Summary

### Development Build
```bash
flutter run
```

### Release Builds
```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

### Testing
```bash
# Run tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

## Troubleshooting

### Common Issues
1. **Keystore not found**: Ensure keystore path is correct in key.properties
2. **Permission denied**: Check all required permissions are declared
3. **Network issues**: Verify network security config allows your API domains
4. **Icon issues**: Ensure image is valid PNG format and proper dimensions

### Support
For deployment issues, refer to:
- [Flutter deployment documentation](https://docs.flutter.dev/deployment)
- [Play Store publishing guide](https://developer.android.com/distribute/console)
- [App Store submission guide](https://developer.apple.com/app-store/submissions/)
