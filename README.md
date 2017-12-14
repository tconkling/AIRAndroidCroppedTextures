# AIRAndroidCroppedTextures

[Adobe bug tracker issue](https://tracker.adobe.com/#/view/AIR-4198475)

[Starling discussion](https://github.com/Gamua/Starling-Framework/issues/1012)

This demonstrates an error in AIR for Android. Periodically, textures will be arbitrarily cropped.

## Building and running

- Ensure `ant` and the Android SDK are installed
- Build: `ant package-android -Dairsdk.dir=/path/to/your/AIRSDK`
- Install: `adb install -r dist/AIRAndroidCroppedTextures.apk`

## Expected behavior

The app loads 2048x2048 textures and displays them on screen. Tapping the screen will load and display another texture. If a texture doesn't appear square, the bug has occurred.

## Changelog:

1. Loading and displaying one texture at a time doesn't trigger the error.
