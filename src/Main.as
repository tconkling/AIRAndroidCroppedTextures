package {

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.InvokeEvent;
import flash.filesystem.File;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.Capabilities;

import starling.core.Starling;
import starling.events.Event;
import starling.utils.RectangleUtil;
import starling.utils.ScaleMode;

[SWF(width="640", height="480", frameRate="60", backgroundColor="#000000")]
public class Main extends Sprite {
    public function Main () {
        NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoked);
    }

    private function onInvoked (e :InvokeEvent) :void {
        NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoked);

        // support for running from IntellIJ. Passing "--resourceRoot rsrc" will allow
        // resources to be loaded from the rsrc directory.
        var resourceRoot :String = popNamedArg(e.arguments, "--resourceRoot");
        if (resourceRoot != null) {
            _resourceRoot = new File(resourceRoot);
        }

        var stageSize:Rectangle  = new Rectangle(0, 0, STAGE_WIDTH, STAGE_HEIGHT);
        var screenSize:Rectangle = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
        var viewPort:Rectangle = RectangleUtil.fit(stageSize, screenSize, ScaleMode.SHOW_ALL);

        Starling.multitouchEnabled = true;

        _starling = new Starling(Demo, stage, viewPort);
        _starling.stage.stageWidth    = STAGE_WIDTH;
        _starling.stage.stageHeight   = STAGE_HEIGHT;
        _starling.enableErrorChecking = Capabilities.isDebugger;

        _starling.addEventListener(Event.ROOT_CREATED, startDemo);
        _starling.start();
    }

    private function startDemo (..._) :void {
        _starling.addEventListener(Event.RESIZE, onScreenResized);
        onScreenResized();

        var demo :Demo = _starling.root as Demo;
        if (_resourceRoot != null) {
            demo.resourceRoot = _resourceRoot;
        }
        demo.run();
    }

    private function onScreenResized (..._) :void {
        var windowWidth :uint = this.stage.stageWidth;
        var windowHeight :uint = this.stage.stageHeight;

        var gameSize :Point = getGameSize(this.stage);
        Starling.current.stage.stageWidth = gameSize.x;
        Starling.current.stage.stageHeight = gameSize.y;

        Starling.current.viewPort = RectangleUtil.fit(
            new Rectangle(0, 0, gameSize.x, gameSize.y),
            new Rectangle(0, 0, windowWidth, windowHeight));
    }

    private static function getGameSize (stage :Stage) :Point {
        // find the closest power-of-two divisor for our target stage size
        // (the size of the stage that the game was designed for)
        var divisor :int = 1;
        while (stage.stageWidth / (divisor * 2) >= STAGE_WIDTH ||
        stage.stageHeight / (divisor * 2) >= STAGE_HEIGHT) {
            divisor *= 2;
        }

        return new Point(stage.stageWidth / divisor, stage.stageHeight / divisor);
    }

    private static function popNamedArg (args :Array, argName :String) :String {
        var idx :int = args.indexOf(argName);
        if (idx >= 0 && idx <= args.length - 2) {
            var value :String = args[idx + 1];
            args.splice(idx, 2);
            return value;
        } else {
            return null;
        }
    }

    private var _starling :Starling;
    private var _resourceRoot :File;

    private static const STAGE_WIDTH :int  = 640;
    private static const STAGE_HEIGHT :int = 480;
}

}
