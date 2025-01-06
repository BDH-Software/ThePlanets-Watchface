//Copyright Brent Hugh
//License available at project GitHub page:
//https://github.com/BDH-Software/ThePlanets-Widget

//Garmin App UUID for current version in IQ Store: 574f47c5-2ad5-45b3-bc11-cbb517cf58b4

import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.System;
import Toybox.Math;

var page = 0;
var pages_total = 25;
//var geo_cache;
//var sunrise_cache;
//var moon;

var Options_Dict = {};

var vspo87a;
var vsop_cache;
var allOrbitParms = null;
    //var view_mode = [0, 1,2,3,4,5]; //manual move ecl, minuts ecl, day ecl, inner orr, mid orr, full orr
    var view_mode = 1;
    var num_view_modes = 3;

    //unit is HOUR
    //all are chosen to be WHOLE DAYS however, to make the sun stand still when moving forward on the eliptical screens
    //But also closest unit to WHOLE YEARS (ie 183 instead of 180 or 182.621187, 61 instead of 60 or 60.873729)
    //Adde synodic month & solar yr as exact time options
    var speeds; //values loaded in .Delegate/initialize()
var speeds_index; //the currently used speed that will be added to TIME @ each update of screen  //
//var screen0Move_index = 33;

var started = false; //whether to move forward on an update, ie STOPPED or STARTED moving
var start_time_sec = 0;
var last_button_time_sec = 0;
var save_started = null;
var reset_date_stop = false; //set TRUE when reset date is called, which STOPS time.
var hz = 5.0; //updates per second (Requested from OS)
var run_oneTime = true; //set to TRUE by anything that once the screeupdate to run ONCE when it is stopped

var message = [];
var message_until = 0;
var animation_count = 0;
var buttonPresses = 0;
var orreryDraws = 0;

var time_add_hrs = 0.0; //cumulation of all time to be added to time.NOW when a screen is displayed

var show_intvl = 0; //whether or not to show current SPEED on display
var animSinceModeChange = 0; //used to tell when to blank screen etc.
var solarSystemView_class as SolarSystemBaseView?; //saved instance of main class 

//enum {exitApp, resetDate, orrZoomOption, thetaOption, labelDisplayOption, refreshOption, screen0MoveOption, planetSizeOption, planetsOption, helpOption, helpBanners}

//enum {EXIT_APP, RESET_DATE, ORR_ZOOM, THETA, LABEL_DISPLAY, REFRESH, PLANET_SIZE, PLANETS, HELP, HELP_BANNERS}

//By specifying values here, they will not change so ie the program STORAGE will not get messed up
//if we add a new enum.  Never change the VALUE of an enum once established.  YOu
//can just remove it or add another interspersed, but give the new one a new unique VALUE.
/*
enum {changeMode_enum= 0,
        resetDate_enum= 1,
        //orrZoomOption_enum= 2,
        //thetaOption_enum= 3,
        labelDisplayOption_enum= 4,
        refreshOption_enum= 5,
        gpsOption_enum= 15, //giving these new numbers so they won't read anything old in the storage
        latOption_enum= 16, // "
        lonOption_enum= 17, // "
        planetSizeOption_enum= 6,
        planetsOption_enum= 7,
        helpOption_enum= 8,
        helpBanners_enum= 9,
        lastLoc_enum = 10,
        } //screen0MoveOption_enum, 
        */

(:glance)
class SolarSystemBaseApp extends Application.AppBase {

    //enum {ECLIPTIC_STATIC, ECLIPTIC_MOVE, SMALL_ORRERY, MED_ORRERY, LARGE_ORRERY}
    //var view_mode = [ECLIPTIC_STATIC, ECLIPTIC_MOVE, SMALL_ORRERY, MED_ORRERY, LARGE_ORRERY];


    private var _solarSystemView as SolarSystemBaseView;
    //private var _solarSystemDelegate as SolarSystemBaseDelegate;

    //! Constructor
    public function initialize() {
        AppBase.initialize();
        System.println("init starting...");
        
        //geo_cache = new Geocentric_cache();
        
        $.now = System.getClockTime();
        $.time_now = Time.now();
        $.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);
        $.start_time_sec = $.time_now.value(); //start time of app in unix seconds

        
        
        //allPlanets = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
        //sunrise_cache = new sunRiseSet_cache2();        //works fine but not using it now..
        System.println("inited...");
        


        //System.println("ARR" + toArray("HI|THERE FRED|M<SYUEIJFJ |FIEJKDF:LKJF|SKDJFF|SDLKJSDFLKJ|THIESNEK|FJIEKJF","|",0));
        
        

    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void { 
        f.deBug("onstart",[]); 
        //System.println("onStart...");
        $.started = true; //for watch version, we just start, no titles etc.
        $.run_oneTime = true;
        $.timeWasAdded = true;
        $.buttonPresses = 1; //for watch version we auto-press that "first button" to clear titles etc
        $.animation_count = 0;
        $.countWhenMode0Started = 0;
        $.now = System.getClockTime(); //before ANY routines or functions run, so all can have access if necessary        
        $.time_now = Time.now();
        $.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);
        System.println ("onStart at " 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d") + " " + now_info.year + "-" + now_info.month + "-" + now_info.day);
        

        //readStorageValues();
        
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
        System.println ("onStop at " 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d"));
            
        //_solarSystemView.stopAnimationTimer();
        started = false;
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        _solarSystemView = null;
        //_solarSystemDelegate = null;
        //settings_view = null;
        //settings_delegate = null;

    }

    //! Update the current position
    //! @param info Position information
    public function onPosition(info as Info) as Void {
        System.println("onPosition... count: " + $.count);
        _solarSystemView.setPosition(info);

    }

    //! Return the initial view for the app
    //! @return Array [View]
    public function getInitialView() as [Views] or [Views, InputDelegates] {
        deBug("initialview",[]);        

        Options = [extraPlanets, planetLabels,
            // smallerBanners, 
            planetSizeL, planetSizeS, glanceType];
        defOptions = {extraPlanets => false,
                  planetLabels => true,      
                    //smallerBanners => true,
                    planetSizeL => false,
                    planetSizeS => false,
                    glanceType => false,
                    lastLoc_saved => [38, -94],
                    };

        //do this AFTER getting time & reading init storage values
        _solarSystemView = new $.SolarSystemBaseView();
        solarSystemView_class = _solarSystemView;
        //_solarSystemDelegate = new $.SolarSystemBaseDelegate(_solarSystemView);

        //These  2 must be done AFTER View class is inited
        //readStorageValues();
        if (!(Application has :Storage)) {
            $.Options_Dict = defOptions;
            return;
        }
        for (var i = 0; i < numOptions; i++) {
            var ret = Storage.getValue(Options[i]);  
            if (ret != null) { $.Options_Dict.put (Options[i], ret);}
            else {
                deBug("OD", [ Options[i], ret, defOptions[Options[i]]]);
                $.Options_Dict.put (0, false);
                $.Options_Dict.put (Options[i], defOptions[Options[i]]);
                
                }
        }
        defOptions = null;
        var ret = Storage.getValue(lastLoc_saved);
        if (ret != null) { $.Options_Dict.put(lastLoc_saved,ret);}

        _solarSystemView.setInitPosition(); //this must be done AFTER readStorageValues()
        //_solarSystemView.startAnimationTimer($.hz);

        view_mode=0;
        $.changeModes(null); //inits speeds_index properly        

        /*System.println ("getInitialView at " 
            +  now.hour.format("%02d") + ":" +
            now.min.format("%02d") + ":" +
            now.sec.format("%02d"));*/

        f.deBug("initview Finished", null);
        return [_solarSystemView];
        //_solarSystemDelegate = null;
        _solarSystemView = null;

    }

/*
    function getGlanceView() {
        f.deBug("getglanceview",[]);
        return [ new SSGlanceView() ];
    }
    */
    /*
    // settingsview works only for watch faces & data fields (?)
    public function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        System.println("6A");
        return [new $.SolarSystemSettingsMenu(), new $.SolarSystemInputDelegate()];
    }
    */

/*
    public function readAStorageValue(name, defoolt, size  ) {
        if (!(Application has :Storage)) {
            $.Options_Dict[name] = defoolt;
            return;
        }
        var temp = Storage.getValue(name);  
        //System.println((32.0).toNumber() + " " + temp);  
        if (!(temp instanceof Number)) {$.Options_Dict[name] = defoolt;}
        else { $.Options_Dict[name] = temp  != null ? temp : defoolt; }
        if ($.Options_Dict[name]>size-1) {$.Options_Dict[name] = defoolt;}
        if ($.Options_Dict[name]<0) {$.Options_Dict[name] = defoolt;}
        Storage.setValue(name,$.Options_Dict[name]);
    }
    */
/*
    //read stored settings & set default values if nothing stored
    public function readStorageValues() as Void {

        //System.println("STORAGE VALUES ARE READ - PROGRAM INIT!!!!");

        loadPlanetsOpt();
      
        //readAStorageValue("orrZoomOption", orrZoomOption_default, orrZoomOption_size );

        //readAStorageValue(orrZoomOption, thetaOption_default, thetaOption_size );

        //$.Options_Dict[thetaOption_enum] = 0; //just always default to TIME INTERVAL here.

        readAStorageValue(labelDisplayOption_enum,labelDisplayOption_default, labelDisplayOption_size );

        readAStorageValue(refreshOption_enum,refreshOption_default, refreshOption_size );
        
        readAStorageValue(latOption_enum,latOption_default, latOption_size );

        //readAStorageValue(refreshOption_enum,refreshOption_default, refreshOption_size );
        readAStorageValue(lonOption_enum,lonOption_default, lonOption_size );

        //readAStorageValue("Screen0 Move Option",screen0MoveOption_default, screen0MoveOption_size );

        readAStorageValue(planetSizeOption_enum, planetSizeOption_default, planetSizeOption_size );

        //readAStorageValue("Ecliptic Size Option", eclipticSizeOption_default, eclipticSizeOption_size );
/*
        readAStorageValue("Orbit Circles Option", orbitCirclesOption_default, orbitCirclesOption_size );

        readAStorageValue("resetDots", resetDots_default, resetDots_size );
        */

        //readAStorageValue(planetsOption_enum, planetsOption_default, planetsOption_size );        
/*
        //if you scramble up the order of the enums it will change which enum gets which value
        //so, best not to change the order, or come up with some scheme to check it or whatever
        var temp = Storage.getValue(helpBanners_enum);
        $.Options_Dict[helpBanners_enum] = temp != null ? (temp == true) : true;
        Storage.setValue(helpBanners_enum,$.Options_Dict[helpBanners_enum]); 

        temp = Storage.getValue(gpsOption_enum);
        $.Options_Dict[gpsOption_enum] = temp != null ? (temp == true) : true;
        Storage.setValue(gpsOption_enum,$.Options_Dict[gpsOption_enum]); 

       



        //Now IMPLEMENT the above values

        
        /*
        //#####SCREEN0 MOVE
        $.screen0Move_index = screen0MoveOption_values[$.Options_Dict["Screen0 Move Option"]];
        */
/*
        //###### REFRESH RATE
        $.hz = refreshOption_values[$.Options_Dict[refreshOption_enum]];                
        _solarSystemView.startAnimationTimer($.hz);           


        
        //###### MANUAL LATITUDE    
        //lat ranges 0 - 181 and lat is either val-90 or if ==181,  auto
        //lon ranges 0 - 361 and lon is either val-180 or if ==361,  auto
        //$.latlonOption_value=[];
        $.latlonOption_value= [$.Options_Dict[latOption_enum], $.Options_Dict[lonOption_enum]];                
            
        //$.hz = lonOption_values[$.Options_Dict[lonOption_enum]];                    
        

        //##### PLANET SIZE
        planetSizeFactor = planetSizeOption_values[$.Options_Dict[planetSizeOption_enum]];

        /*
        //##### ECLIPTIC SIZE
        eclipticSizeFactor = eclipticSizeOption_values[$.Options_Dict["Ecliptic Size Option"]];
        */

        //##### Display all or only planets
        //planetsOption_value = $.Options_Dict[planetsOption_enum]; //the number not the array (unusual) 

        /* //Sample binary option
        temp = Storage.getValue("Show Battery");
        $.Options_Dict["Show Battery"] = temp  != null ? temp : true;
        Storage.setValue("Show Battery",$.Options_Dict["Show Battery"]);        
        */

     
        
   // }


}


/*  SAMPLEs..
class SolarSystemInputDelegate extends WatchUi.InputDelegate {
    function onKey(keyEvent) {
        System.println("GOT KEEY!!!!!!!!!: " + keyEvent.getKey());         // e.g. KEY_MENU = 7
        return true;
    }

    function onTap(clickEvent) {
        System.println(clickEvent.getType());      // e.g. CLICK_TYPE_TAP = 0
        return true;
    }

    function onSwipe(swipeEvent) {
        System.println(swipeEvent.getDirection()); // e.g. SWIPE_DOWN = 2
        return true;
    }
}

*/


//picks up current mode from global $.view_mode
function changeModes(previousMode){
        //System.println("chmodes..." );
        
        $.timeWasAdded = true; //forces draw of screen in mode 0...
        $.animSinceModeChange = 0;
        $.show_intvl = 0; //used by showDate to decide when/how long to show (5 min) type labels


        var changeModeOption_short = f.toArray(WatchUi.loadResource($.Rez.Strings.changeModeOption_short) as String,  "|", 0);

        

            if ($.view_mode ==0) {$.view_mode = 1;}    
                
            if ($.view_mode ==1){
                //if (vsop_cache == null)  {vsop_cache = new VSOP87_cache();}
                //time_add_inc=1;
                //DON'T reset to present time here bec. we're usually coming from mode 0 or mode 2& can just continue seamlessly
                //$.time_add_hrs = .5; //reset to present time
                if (previousMode == null || (previousMode!=1 && previousMode !=2 ) ) {  //mode 5 often moves years into the future...
                    $.time_add_hrs = 0; //reset to present time
                }
                speeds_index = 39; //10 mins
                started = false;
                //if ($.Options_Dict[helpBanners_enum]){solarSystemView_class.sendMessage(5, ["==Current Sky (by hr)==", UUD, SS, null]);} 
                //if (!$.Options_Dict[smallerBanners]){solarSystemView_class.sendMessage(5, [dMsg[12], UUD, SS, null]);} 
                //else {
                    solarSystemView_class.sendMessage(2, [null, changeModeOption_short[1],"", null, null]);
                //}
            } 
            else {
                //if (vsop_cache == null)  {vsop_cache = new VSOP87_cache();}
                //time_add_inc = 24*3; //1 day
                //DON'T reset to present time here bec. we're usually coming from mode 0 or mode 2& can just continue seamlessly
                if (previousMode != null && previousMode==3 ) {  //mode 3 often moves years into the future...
                    $.time_add_hrs = 0; //reset to present time
                }
                speeds_index = 48; //1 day or 24 hrs
                started = false;
                //if ($.Options_Dict[smallerBanners]){solarSystemView_class.sendMessage(5, [dMsg[13], UUD, SS,null]);}
                //else {
                    solarSystemView_class.sendMessage(4, [changeModeOption_short[3], changeModeOption_short[2], null, null]);
                //}
            }
     

        

        changeModeOption_short = null;
        

}