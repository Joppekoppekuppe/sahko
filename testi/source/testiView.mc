import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;


class testiView extends WatchUi.View {
    private var _pricetext;
    private var price;
    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _pricetext =  findDrawableById("price");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }
    public function setPrice(pricep as String) as Void {
        _pricetext.setText(pricep + "c/kWh");
        WatchUi.requestUpdate();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        var today = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
        price = Storage.getValue(getApp().formatDateAndHour(today));
        System.println(getApp().formatDateAndHour(today));
        if (price != null) {
            System.println("puu");
            setPrice(price);
        }
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
