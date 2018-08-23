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
                    reloadTextures();
                    return;
                }
            }
        });
        reloadTextures();
    }

    public function reloadTextures () :void {
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
            displayTextures(textures);
        });
    }

    private function disposeAllTextures () :void {
        if (_sprite != null) {
            _sprite.removeFromParent(true);
            _sprite = null;
        }
        if (_loadedTextures != null) {
            for each (var tex :Texture in _loadedTextures) {
                tex.dispose();
            }
            _loadedTextures = null;
        }
    }

    private function displayTextures (textures: Array) :void {
        if (_sprite != null) {
            _sprite.removeFromParent(true);
            _sprite = null;
        }

        _sprite = new Sprite();
        var x: Number = 0;
        for each (var tex: Texture in textures) {
            var image: Image = new Image(tex);
            image.x = x;
            _sprite.addChild(image);
            x += image.width;
        }

        // Scale and center the image
        _sprite.scale = Math.min(
            Starling.current.stage.stageWidth / _sprite.width,
            Starling.current.stage.stageHeight / _sprite.height);
        _sprite.x = (Starling.current.stage.stageWidth - _sprite.width) * 0.5;
        _sprite.y = (Starling.current.stage.stageHeight - _sprite.height) * 0.5;
        addChild(_sprite);
    }

    private function getUrl (path :String) :String {
        return this.resourceRoot.resolvePath(path).url;
    }

    private var _loading :Boolean;
    private var _loadedTextures :Array;
    private var _sprite: Sprite;

    private static const TEX_PATHS :Array = [
        "tex1.png",
        "tex2.png",
        "tex3.png",
        "tex4.png",
        "tex5.png",
    ];
}
}
