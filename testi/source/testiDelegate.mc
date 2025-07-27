import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.System;
import Toybox.Application;

class testiDelegate extends WatchUi.BehaviorDelegate {
    private var _view = getView();
    public var price;
    function initialize() {
        BehaviorDelegate.initialize();
    }
    function updatePrices() {
        var today = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
        price = Storage.getValue(_view.getApp().formatDateAndHour(today));
        System.println("puu");
        if (price != null) {
            _view.setPrice(price);
        }
    }
    

}