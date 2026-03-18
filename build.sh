export PUB_CACHE=/home/user/Documents/gits/QuitSmoking/flutter_application_1/.pub-cache
export ANDROID_HOME=/opt/android-sdk
flutter clean
flutter pub get
flutter build apk --release
flutter build apk --split-per-abi
flutter build web --base-href=/web/