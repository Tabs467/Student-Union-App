# Student Union App

Main codebase is in the lib folder.

Android Setup
-----------------------------------------------------------------------------------------------------------------------------
These instructions are for Android Studio, instructions may vary slightly for other IDEs such as Visual Studio Code but setting up Flutter for Android is widely documented

Download and configure Flutter - https://docs.flutter.dev/get-started/install

Download Android SDK Command-line Tools under Android Studio System Settings -> Android SDK -> DSK Tools

Download the Flutter plugin and the Dart plugin for Android Studio

Under the Flutter plugin settings in Android Studio set the Flutter SDK path to wherever you downloaded it

Create a virtual Android device with the AVD Manager and launch it

You may need to activate symlink support on your machine by enabling Developer Mode in your system settings by running “ms-settings:developers” and then toggling Developer Mode on

In some cases, the project will need a newer version of the Kotlin Gradle Plugin, in this case:
Navigate to android/build.gradle
Then update ext.kotlin_version to the newest compatible version found at https://kotlinlang.org/docs/gradle.html#targeting-multiple-platforms

Run main.dart on the launched virtual device

If any dependency issues are found, get the project’s dependencies with Pub get 


iOS Setup
---------------------------------------------------------------------------------------------------------------------------
Download and configure Flutter - https://docs.flutter.dev/get-started/install

Run “flutter build ios” in the project directory
This should run successfully until it gets to an error that states that no iOS App Development provisioning profiles were found. It is not necessary to enable Automatic signing to generate a profile to run the app, so this error can be ignored.

Inside of the ios folder, open Runner.xcworkspace (NOT Runner.xcodeproj) in Xcode

Ensure the correct ios version is set in the Podfile, the line should be: “platform :ios, ’10.0’”
Ensure the iOS Deployment Target is set to 10.0 in the Project runner file

Run the app in the Xcode simulator
If given the error “The sandbox is not in sync with the Podfile.lock”, run “pod install” in the ios folder and rerun “flutter build ios” whilst also ensuring the previous iOS version numbers are set to 10.0
