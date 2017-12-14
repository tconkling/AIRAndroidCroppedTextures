package {

import flash.filesystem.File;

import react.Future;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;

import util.TextureLoader;

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
        if (_loading) {
            return;
        }

        disposeAllTextures();
        Future.sequence(TEX_PATHS.map(function (path :String, ..._) :Future {
            return TextureLoader.load(getUrl(path));
        })).onFailure(function (err :*) :void {
            _loading = false;
            trace("Failed to load textures: " + err);
        }).onSuccess(function (textures :Array) :void {
            _loading = false;
            disposeAllTextures();
            _loadedTextures = textures;
            displayTexture(textures[_texIndex]);
            _texIndex = (_texIndex + 1) % TEX_PATHS.length;
        });
    }

    private function disposeAllTextures () :void {
        if (_curImage != null) {
            _curImage.removeFromParent(true);
            _curImage = null;
        }
        if (_loadedTextures != null) {
            for each (var tex :Texture in _loadedTextures) {
                tex.dispose();
            }
            _loadedTextures = null;
        }
    }

    private function displayTexture (tex :Texture) :void {
        if (_curImage != null) {
            _curImage.removeFromParent(true);
            _curImage = null;
        }

        _curImage = new Image(tex);

        // Scale and center the image
        _curImage.scale = Math.min(
            Starling.current.stage.stageWidth / _curImage.width,
            Starling.current.stage.stageHeight / _curImage.height);
        _curImage.x = (Starling.current.stage.stageWidth - _curImage.width) * 0.5;
        _curImage.y = (Starling.current.stage.stageHeight - _curImage.height) * 0.5;
        addChild(_curImage);
    }

    private function getUrl (path :String) :String {
        return this.resourceRoot.resolvePath(path).url;
    }

    private var _loading :Boolean;
    private var _texIndex :int = 0;
    private var _loadedTextures :Array;
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
