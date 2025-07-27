import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;

class testiApp extends Application.AppBase {
    private var _view;
    private var _lastDate;
    private var _lastHour;
    private var _lastSavedTodayHour;
    private var _lastSavedTomorrowHour;
    private var _currentFormatedDate;
    private var _currentHour;
    private var _today = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
    private var _nextTodayHour;
    private var _nextTomorrowHour;


    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        savePrices();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        Storage.setValue("last_saved_today_hour", _nextTodayHour);
        Storage.setValue("last_saved_tomorrow_hour", _nextTomorrowHour);
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        _view = new testiView();
        return [ _view, new testiDelegate() ];
    }
    function getView() {
        return _view;
    }
    public function savePrices() as Void {
        //Lisää kesäaika-talviaika tuki
        //Tee hintojen latausikkuna(ehkä/tarvittaessa)
        //HUOM! kaikki hinnat tallentuu yhteen avaimeen BUG! 1. sijalla korjauksessa

        _currentFormatedDate = formatDate(_today);
        _currentHour = utcToFinnishTime(_today.hour.toNumber()).format("%02d").toString();
        _lastDate = Storage.getValue("last_date");
        _lastHour = Storage.getValue("last_hour");
        _lastSavedTodayHour = Storage.getValue("last_saved_today_hour");
        _lastSavedTomorrowHour = Storage.getValue("last_saved_tomorrow_hour");
        Storage.setValue("last_date", _currentFormatedDate);
        Storage.setValue("last_hour", _currentHour);
        if (_lastDate == null || _lastSavedTodayHour == null || _lastSavedTomorrowHour == null || _lastSavedTodayHour < 4) {
            _nextTodayHour = 0;
            searchPricesFromWeb(_currentFormatedDate, _nextTodayHour.format("%02d"), false);
        } else if (Storage.getValue(formatDateAndHourWithExternalHour(_today, 1)) != null && _lastSavedTomorrowHour.toNumber() == 24 && _lastSavedTodayHour.toNumber() == 24) {
            _nextTodayHour = 24;
        } else if (Storage.getValue(formatDateAndHourWithExternalHour(_today, 1)) != null && (_lastSavedTodayHour.toNumber() < 24 || _lastSavedTomorrowHour.toNumber() < 24)) {
            if (_lastDate.substring(8, 10).toNumber() == _today.day.toString().format("%02d").toNumber) {
                _nextTodayHour = _lastSavedTodayHour;
                searchPricesFromWeb(_currentFormatedDate, _nextTodayHour.format("%02d"), false);
            } else if (_lastDate.substring(8, 10).toNumber() + 1 == _today.day.toString().format("%02d").toNumber) {
                _nextTodayHour = _lastSavedTomorrowHour;
                searchPricesFromWeb(_currentFormatedDate, _nextTodayHour.format("%02d"), false);
            } else {
                throw new Exception();
            }

        } else {
            _nextTodayHour = 0;
            searchPricesFromWeb(_currentFormatedDate, _nextTodayHour.format("%02d"), false);
        }

        if (utcToFinnishTime(_today.hour) >= 14 && _today.min >= 10) {
            if (_lastDate == null || _lastSavedTomorrowHour == null || _lastSavedTomorrowHour < 4) {
                _nextTomorrowHour = 0;
                searchPricesFromWeb(formatTomorrowDate(_today), _nextTomorrowHour.format("%02d"), true);
            } else if (_lastDate.equals(_currentFormatedDate) && _lastSavedTomorrowHour == 24) {
                _nextTomorrowHour = 24;
            } else if (_lastDate.equals(_currentFormatedDate) && _lastSavedTomorrowHour < 24) {
                _nextTomorrowHour = _lastSavedTomorrowHour;
                searchPricesFromWeb(formatTomorrowDate(_today), _nextTomorrowHour.format("%02d"), true);
            }
        }

    }
    public function utcToFinnishTime(utc as Number) as Number {
        return utc + 3;
    }
    public function formatDate(time as Gregorian.Info) as String {
        return Lang.format(
            "$1$-$2$-$3$",
            [
                time.year,
                time.month.format("%02d"),
                time.day.format("%02d")
            ]
        );
    }
    public function formatTomorrowDate(time as Gregorian.Info) as String {
        return Lang.format(
            "$1$-$2$-$3$",
            [
                time.year,
                time.month.format("%02d"),
                (time.day + 1).format("%02d")
            ]
        );
    }
    public function formatDateAndHour(time as Gregorian.Info) as String {
        return Lang.format(
            "$1$-$2$-$3$:$4$",
            [
                time.year,
                time.month.format("%02d"),
                time.day.format("%02d"),
                utcToFinnishTime(time.hour.toNumber()).format("%02d").toString()
            ]
        );
    }
    public function formatDateAndHourWithExternalHour(time as Gregorian.Info, finnishHour as String or Number) as String {
        return Lang.format(
            "$1$-$2$-$3$:$4$",
            [
                time.year,
                time.month.format("%02d"),
                time.day.format("%02d"),
                finnishHour.toNumber().format("%02d").toString()
            ]
        );
    }
    public function formatTomorrowDateAndHourWithExternalHour(time as Gregorian.Info, finnishHour as String or Number) as String {
        return Lang.format(
            "$1$-$2$-$3$:$4$",
            [
                time.year,
                time.month.format("%02d"),
                (time.day.toNumber() + 1).format("%02d"),
                finnishHour.toNumber().format("%02d").toString()
            ]
        );
    }
    function todayWebRequestCallback(responseCode as Number, data as Dictionary?) as Void {
        System.println(responseCode);
        if (responseCode == 200) {
            var price = data.get("price").toString().toFloat().toString().substring(0, 4);
            Storage.setValue(formatDateAndHourWithExternalHour(_today, _nextTodayHour), price); 
        } else {
            Storage.setValue(formatDateAndHourWithExternalHour(_today, _nextTodayHour), null);
        }
        if (_nextTodayHour < 24) {
            _nextTodayHour++;
            searchPricesFromWeb(_currentFormatedDate, _nextTodayHour.format("%02d"), false);
        }
    }
    function tomorrowWebRequestCallback(responseCode as Number, data as Dictionary?) as Void {
        System.println(responseCode);
        if (responseCode == 200) {
            //MUUTA SUBSTRING FORMATIKSI
            var price = data.get("price").toString().toFloat().toString().substring(0, 4);
            Storage.setValue(formatTomorrowDateAndHourWithExternalHour(_today, _nextTomorrowHour), price); 
        } else {
            Storage.setValue(formatTomorrowDateAndHourWithExternalHour(_today, _nextTomorrowHour), null);
        }
        if (_nextTomorrowHour < 24) {
            _nextTomorrowHour++;
            searchPricesFromWeb(formatTomorrowDate(_today), _nextTomorrowHour.format("%02d"), true);
        }
    }
    public function searchPricesFromWeb(dateString as String, hourString as String, tomorrow as Boolean) {
        var url = "https://api.porssisahko.net/v1/price.json";                         // set the url

        var params = {                                              // set the parameters
            "date" => dateString,
            "hour" => hourString
        };

        var options = {                                             // set the options
            :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
            :headers => {                                           // set headers
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
            // set response type
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        // onReceive() method
        // Make the Communications.makeWebRequest() call
        if (tomorrow) {
            Communications.makeWebRequest(url, params, options, method(:tomorrowWebRequestCallback));
        } else {
            Communications.makeWebRequest(url, params, options, method(:todayWebRequestCallback));
        }
        
    }


}

function getApp() as testiApp {
    return Application.getApp() as testiApp;
}
function getView() {
    return Application.getApp().getView();
}