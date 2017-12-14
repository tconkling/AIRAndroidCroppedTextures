//
// react

package react {

public class BoolValue extends AbstractValue
    implements BoolView
{
    /**
     * Creates an instance with the supplied starting value.
     */
    public function BoolValue (value :Boolean = false) {
        _value = value;
    }

    public function get value () :Boolean {
        return _value;
    }

    /**
     * Updates this instance with the supplied value. Registered listeners are notified only if the
     * value differs from the current value.
     * @return the previous value contained by this instance.
     */
    public function set value (value :Boolean) :void {
        updateAndNotifyIf(value);
    }

    /**
     * Updates this instance with the supplied value. Registered listeners are notified regardless
     * of whether the new value is equal to the old value.
     * @return the previous value contained by this instance.
     */
    public function updateForce (value :Boolean) :Boolean {
        return updateAndNotify(value) as Boolean;
    }

    override public function get () :* {
        return _value;
    }

    override protected function updateLocal (value :Object) :Object {
        var oldValue :Boolean = _value;
        _value = value as Boolean;
        return oldValue;
    }

    protected var _value :Boolean;
}
}
