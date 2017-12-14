package util {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

import react.Future;
import react.Promise;

import starling.textures.Texture;

public class TextureLoader {
    public static function load (url :String) :Future {
        return new TextureLoader(url).begin();
    }

    public function TextureLoader (url :String) {
        _url = url;
    }

    /** @return Future<Texture>. Valid before `begin()` has been called. */
    public function get result () :Future {
        return _result;
    }

    public function begin () :Future {
        if (_began) {
            return _result;
        }
        _began = true;

        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorEvent);
        _loader.contentLoaderInfo.addEventListener(Event.INIT, function (e :Event) :void {
            var bitmap :Bitmap = Bitmap(_loader.content);
            onBitmapLoaded(bitmap.bitmapData);
        });

        try {
            _loader.load(new URLRequest(_url));
        } catch (e :Error) {
            _result.fail(e);
        }

        return _result;
    }

    protected function onBitmapLoaded (bmd :BitmapData) :void {
        var tex :Texture = Texture.fromBitmapData(bmd, false, false);
        _result.succeed(tex);
    }

    protected function onErrorEvent (e :Event) :void {
        if (!_result.isComplete.value) {
            _result.fail(e);
        }
    }

    protected const _result :Promise = new Promise();
    protected var _url :String;
    protected var _began :Boolean;
    protected var _loader :Loader;
}

}
