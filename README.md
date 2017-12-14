# AIRAndroidCroppedTextures

This demonstrates an error in AIR for Android. Periodically, textures will be arbitrarily cropped.

* [Adobe bug tracker issue](https://tracker.adobe.com/#/view/AIR-4198475)
* [Starling discussion](https://github.com/Gamua/Starling-Framework/issues/1012)
* [Video of the bug in action](https://www.youtube.com/watch?v=v0M1Z00_rUU&t=27s)

## Building and running

- Ensure `ant` and the Android SDK are installed
- Build: `ant package-android -Dairsdk.dir=/path/to/your/AIRSDK`
- Install: `adb install -r dist/AIRAndroidCroppedTextures.apk`
- Run the app. It will load 5 2048x2048 textures simultaneously, and display one of those textures in the center of the screen. Tapping the image will reload all textures and display another one. Periodically, on devices the exhibit the bug, the displayed texture will be cropped.

## Expected behavior

The displayed textures should always be square. If a texture is cut off mid-screen, the bug has occurred. This happens for me most frequently on a newly-restarted tablet. It happens about once in every 10-15 taps.

I'm running this on an Nvidia Shield tablet running Android 7.0. The bug also occurred on the same tablet running Android 6.0. It's also been reported by the QA team on a Samsung Note 4. (Anecdotally, it's also been reported by many other developers, presumably on other devices -- see the discussions linked at the top of this README.)

## Possible workaround

I've been seeing this bug frequently in my game [Antihero](http://antihero-game.com), which I'm porting to Android. Currently, the game attempts to "validate" each loaded texture by rendering it to bitmap and doing a pixel-wise compare between the rendered bitmap and the original source bitmap:

```
public static function createFromBitmap (sourceBitmap :BitmapData, scale :Number, forcePotTexture :Boolean, name :String = null) :Texture {
    var renderBitmap :BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, true);
    var tex :Texture = null;
    var valid :Boolean = false;
    for (var ii :int = 0; ii < 3 && !valid; ++ii) {
        if (tex != null) {
            tex.dispose();
        }
        tex = Texture.fromBitmapData(sourceBitmap, false, false, scale, "bgra", forcePotTexture);
        var image :Image = new Image(tex);
        image.drawToBitmapData(renderBitmap, 0x0, 0.0);

        valid = compareAlpha(sourceBitmap, renderBitmap);
        if (!valid) {
            log.warning("Texture doesn't match source bitmap", "name", name, "tries", ii + 1);
        }
    }

    renderBitmap.dispose();

    return tex;
}

private static function compareAlpha (src :BitmapData, dst :BitmapData) :Boolean {
    if (src.width != dst.width || src.height != dst.height) {
        return false;
    }

    for (var yy :uint = 0; yy < src.height; ++yy) {
        for (var xx :uint = 0; xx < src.width; ++xx) {
            var srcPx :uint = src.getPixel32(xx, yy);
            var dstPx :uint = src.getPixel32(xx, yy);
            if (Color.getAlpha(srcPx) != 0 && srcPx != dstPx) {
                return false;
            }
        }
    }

    return true;
}
```

This _seems_ to fix the bug. However, the "Texture doesn't match source bitmap" warning is never emitted, which implies that there's some sort of race condition in texture creation in Android, and that executing this code prevents that race condition from triggering the error.

## Changelog:

1. Loading and displaying one texture at a time doesn't trigger the error.
2. Loading all textures simultaneously occasionally triggers the error (~1/10 times?). Running the demo on a newly-restarted tablet seems to increase the trigger frequency.
