import Toybox.System;
import Toybox.WatchUi;

class noInternetDelegate extends WatchUi.BehaviorDelegate {
    private var _view as noInternetView?;

    function initialize(view as noInternetView) {
        _view = view;
        BehaviorDelegate.initialize();
    }
    

}