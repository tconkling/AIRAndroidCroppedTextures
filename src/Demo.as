package {

import flash.display.BitmapData;
import flash.filesystem.File;
import flash.geom.Rectangle;

import react.Future;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.text.TextFormat;
import starling.textures.Texture;
import starling.utils.Align;

import util.BitmapLoader;

public class Demo extends Sprite {
    public var resourceRoot :File = File.applicationDirectory;

    public function run () :void {
        _statusText = createTextField(Starling.current.stage.stageWidth);
        this.addChild(_statusText);
        reloadTextures();
    }

    private function reloadTextures () :void {
        var paths: Array = TEX_PATHS.concat(TEX_PATHS).concat(TEX_PATHS);
        _statusText.text = "Reloading " + paths.length + " textures (attempt " + (_numTries + 1) + ")...";
        _numTries++;

        Future.sequence(paths.map(function (path :String, ..._) :Future {
            return BitmapLoader.load(getUrl(path));
        })).onFailure(function (err :*) :void {
            _statusText.text = "Failed to load textures:\n" + err;
        }).onSuccess(function (bitmaps :Array) :void {
            var hasBadBitmap: Boolean = false;
            for each (var bitmap: BitmapData in bitmaps) {
                var percentLoaded: Number = validateBitmap(bitmap, 2048);
                if (percentLoaded == 1) {
                    bitmap.dispose();
                } else {
                    // Scale and center the image
                    var image: Image = new Image(Texture.fromBitmapData(bitmap));
                    image.scale = Math.min(
                            Starling.current.stage.stageWidth / image.width,
                            Starling.current.stage.stageHeight / image.height);
                    image.x = (Starling.current.stage.stageWidth - image.width) * 0.5;
                    image.y = (Starling.current.stage.stageHeight - image.height) * 0.5;
                    addChildAt(image, 0);

                    _statusText.text =
                        "Broken image! (" + int(percentLoaded * 100) + "% loaded)\n" +
                        "(After " + _numTries + " attempts)";
                    hasBadBitmap = true;
                    break;
                }
            }

            if (!hasBadBitmap) {
                reloadTextures();
            }
        });
    }

    private function getUrl (path :String) :String {
        return this.resourceRoot.resolvePath(path).url;
    }

    private static function validateBitmap (bitmapData :BitmapData, expectedBottomRow: uint) :Number {
        var bottomRow :Number = getBottomPixelRow(bitmapData);
        if (expectedBottomRow - bottomRow >= 1) {
            return (bottomRow / expectedBottomRow);
        } else {
            return 1;
        }
    }

    private static function getBottomPixelRow (bitmapData :BitmapData) :Number {
        var bounds :Rectangle = bitmapData.transparent ?
                bitmapData.getColorBoundsRect(0xFF000000, 0x0, false) :
                bitmapData.getColorBoundsRect(0xFFFFFFFF, 0x0, false);
        return bounds.bottom;
    }

    private static function createTextField (width: Number): TextField {
        var format: TextFormat = new TextFormat();
        format.color = 0xffffff;
        format.size = 20;
        format.horizontalAlign = Align.CENTER;
        var tf: TextField = new TextField(width, 100, "", format);
        tf.autoSize = TextFieldAutoSize.VERTICAL;
        return tf;
    }

    private var _statusText: TextField;
    private var _numTries: int;

    private static const TEX_PATHS :Array = [
        "tex1.png",
        "tex2.png",
        "tex3.png",
        "tex4.png",
        "tex5.png",
    ];
}
}
