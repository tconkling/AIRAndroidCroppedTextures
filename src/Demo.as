//
// aciv

package {

import flash.display.Bitmap;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.net.URLRequest;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;

public class Demo extends Sprite {
    public var resourceRoot :File = File.applicationDirectory;

    public function run () :void {
        addEventListener(TouchEvent.TOUCH, function (e :TouchEvent) :void {
            for each (var t :Touch in e.touches) {
                if (t.phase == TouchPhase.BEGAN) {
                    loadNextTexture();
                    return;
                }
            }
        });
        loadNextTexture();
    }

    public function loadNextTexture () :void {
        destroyCurTexture();
        loadTexture(TEX_PATHS[_texIndex], onTextureLoaded);
        _texIndex = (_texIndex + 1) % TEX_PATHS.length;
    }

    private function destroyCurTexture () :void {
        if (_curImage != null) {
            _curImage.removeFromParent(true);
            _curImage = null;
        }
        if (_curTex != null) {
            _curTex.dispose();
            _curTex = null;
        }
    }

    private function onTextureLoaded (tex :Texture) :void {
        destroyCurTexture();

        _curTex = tex;
        _curImage = new Image(tex);

        // Scale and center the image
        _curImage.scale = Math.min(
            Starling.current.stage.stageWidth / _curImage.width,
            Starling.current.stage.stageHeight / _curImage.height);
        _curImage.x = (Starling.current.stage.stageWidth - _curImage.width) * 0.5;
        _curImage.y = (Starling.current.stage.stageHeight - _curImage.height) * 0.5;
        addChild(_curImage);
    }

    private function loadTexture (path :String, onSuccess :Function) :void {
        var loader :Loader = new Loader();
        loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (err :Event) :void {
            trace("Failed to load texture '" + path + "': " + err.toString());
        });

        loader.contentLoaderInfo.addEventListener(Event.INIT, function (e :Event) :void {
            var bitmap :Bitmap = Bitmap(loader.content);
            var tex :Texture = Texture.fromBitmapData(bitmap.bitmapData, false, false);
            onSuccess(tex);
        });

        var url :String = this.resourceRoot.resolvePath(path).url;
        loader.load(new URLRequest(url));
    }

    private var _texIndex :int = 0;
    private var _curTex :Texture;
    private var _curImage :Image;

    private static const TEX_PATHS :Array = [
        "tex1.png",
        "tex2.png",
        "tex3.png",
        "tex4.png",
        "tex5.png",
    ];
}
}
