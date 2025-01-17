//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

var orrZoomOption,labelDisplayOption,planetsOption,planetSizeOption,thetaOption,refreshOption;
var planetsOption_size = 3;
var planetsOption_default = 1;
var planetsOption_value = planetsOption_default; //use the NUMBER not the VALUES, slightly UNUSUAL



//TODO: User could tweak size of PLANETS & also radius of circle/overall scale
//var Options_Dict = {  };
/*var labelDisplayOption=[ "Always On", "Always Off", "Frequent Flash", "Infrequent Flash", "Random Flash"]; */
var labelDisplayOption_size = 5;
var labelDisplayOption_default = 2;



var refreshOption_values=[  //in HZ
        10.0,
        5.0,
        4.0, 
        3.0, 
        2.0, 
    ];    
var refreshOption_size = 5;
var refreshOption_default = 1;

var latOption_size = 181;  //ranges 0 to 180; lat is value-90
var latOption_default = 90;

var lonOption_size = 362;  //ranges 0 to 360; lat is value-180
var lonOption_default = 180;

var latlonOption_value= [38,-94];                



var planetSizeOption_values;//inited in View.mc/initialize()


var planetSizeFactor = 1.5;



var eclipticSizeFactor = 1.0;


//var Options_Dict = {  };
var Settings_ran = false;
var save_menu = null;

enum {
    extraPlanets =  0,
    planetLabels = 1,
    //smallerBanners = 2,
    planetSizeL = 3,
    planetSizeS = 4,
    //glanceType = 6, //don't use 5 as it's used for helpOption_enum
    showBattery = 6,
    showMinutes = 7,
    showDayMinutes = 8,
    showSteps = 9,
    showMove = 10,
    lastLoc_saved = 99,
}

/*

var infiniteSecondOptions=["No Second Hand","<1 min", "<2 min", "<3 min", "<4 min","<5 min","<10 min", "Always"];
var infiniteSecondLengths = [0, 1, 2, 3, 4, 5, 10, 1000000 ];
var infiniteSecondOptions_size = 8;
var infiniteSecondOptions_default = 2;

var secondDisplayOptions=[ "Main Face Large", "Main Face Center", "Inset Circle"];
var secondDisplayOptions_size = 3;
var secondDisplayOptions_default = 0;

var secondHandOptions=[ "Big Pointer", "Outline Pointer", "Big Blunt", "Outline Blunt",  "Big Needle", "Small Block", "Small Pointer","Small Needle"];
var secondHandOptions_size = 8;
var secondHandOptions_default = 1;

var dawnDuskOptions=[ "Dawn/Dusk Markers", "Sunrise/Set Markers", "Dawn/Dusk Inset Circle", "Sunrise/Set Inset Circle", "No Solar Clock", ];
var dawnDuskOptions_size = 5;
var dawnDuskOptions_default = 0;
*/

//! The app settings menu
class SolarSystemSettingsMenu extends WatchUi.Menu2 {

      
    (:hasJSON)
    public function initialize(){

        save_menu = self;
        
        $.Settings_ran = true;
        
        var clockTime = System.getClockTime();
        System.println(clockTime.hour +":" + clockTime.min + " - Settings running");

        Menu2.initialize({:title=>"Settings"});

        //var OptionsLabels = ["Show extra planets?", "Show planet labels?", "Draw planets larger?", "Draw planets smaller?", "Glance Morn/Eve or Up Now?"];
        var OptionsLabels = (WatchUi.loadResource( $.Rez.JsonData.OptionsLabels) as Array);

        for (var i = 0; i < numOptions; i++) {
        Menu2.addItem(new WatchUi.ToggleMenuItem(OptionsLabels[i], null, Options[i], $.Options_Dict[Options[i]]==true, null));
        }
        /*
        planetAbbreviation_index = 0;
        var pA = getPlanetAbbreviation();
        Menu2.addItem(new WatchUi.MenuItem(pA[0], pA[1],helpOption_enum, {}));
        save_menu = self;

            var boolean = Storage.getValue("Show Battery") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Battery %: No-Yes", null, "Show Battery", boolean, null));            

        boolean = Storage.getValue("Show Minutes") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Wkly Activity Minutes: No-Yes", null, "Show Minutes", boolean, null));

        boolean = Storage.getValue("Show Day Minutes") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Daily Activity Minutes: No-Yes", null, "Show Day Minutes", boolean, null));

        boolean = Storage.getValue("Show Steps") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Daily Steps: No-Yes", null, "Show Steps", boolean, null));

        boolean = Storage.getValue("Show Move") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Move Bar: No-Yes", null, "Show Move", boolean, null)); 
        */       
    }

    (:noJSON)
    public function initialize(){
        
        $.Settings_ran = true;
        
        var clockTime = System.getClockTime();
        System.println(clockTime.hour +":" + clockTime.min + " - Settings running");

        Menu2.initialize({:title=>"Settings"});

        var OptionsLabels = ["Show extra planets?", "Show planet labels?", "Draw planets larger?", "Draw planets smaller?", "Show Battery %: No-Yes", "Show Wkly Activity Minutes: No-Yes", "Show Daily Activity Minutes: No-Yes", "Show Daily Steps: No-Yes", "Show Move Bar: No-Yes"];
        //var OptionsLabels = (WatchUi.loadResource( $.Rez.JsonData.OptionsLabels) as Array);

        for (var i = 0; i < numOptions; i++) {
        Menu2.addItem(new WatchUi.ToggleMenuItem(OptionsLabels[i], null, Options[i], $.Options_Dict[Options[i]]==true, null));
        }
        /*

        planetAbbreviation_index = 0;
        var pA = getPlanetAbbreviation();
        Menu2.addItem(new WatchUi.MenuItem(pA[0], pA[1],helpOption_enum, {}));
        save_menu = self;
    
        var boolean = Storage.getValue("Show Battery") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Battery %: No-Yes", null, "Show Battery", boolean, null));            

        boolean = Storage.getValue("Show Minutes") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Wkly Activity Minutes: No-Yes", null, "Show Minutes", boolean, null));

        boolean = Storage.getValue("Show Day Minutes") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Daily Activity Minutes: No-Yes", null, "Show Day Minutes", boolean, null));

        boolean = Storage.getValue("Show Steps") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Daily Steps: No-Yes", null, "Show Steps", boolean, null));

        boolean = Storage.getValue("Show Move") ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Move Bar: No-Yes", null, "Show Move", boolean, null));    
        */    

        
    }
}

/*
//! Input handler for the app settings menu
class SolarSystemSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    //var mainView;
    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
        //mainView = $.ElegantAnaView;
    }

    //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void {
        if (menuItem instanceof ToggleMenuItem) {
            Storage.setValue(menuItem.getId() as String, menuItem.isEnabled());
            $.Options_Dict[menuItem.getId() as String] = menuItem.isEnabled();
            $.Settings_ran = true;
        }

        var id=menuItem.getId();

        /*
        if(id.equals("Infinite Second Option")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%infiniteSecondOptions_size;
            menuItem.setSubLabel($.infiniteSecondOptions[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);            
            $.Settings_ran = true;
            //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
            //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
        }

        if(id.equals("Second Display")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%secondDisplayOptions_size;
            menuItem.setSubLabel($.secondDisplayOptions[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);            
            $.Settings_ran = true;
            //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
            //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
        }

        if(id.equals("Second Hand Option")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%secondHandOptions_size;
            menuItem.setSubLabel($.secondHandOptions[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);            
            $.Settings_ran = true;
            //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
            //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
        }

        if(id.equals("Dawn/Dusk Markers")) {
            $.Options_Dict[id]=($.Options_Dict[id]+1)%dawnDuskOptions_size;
            menuItem.setSubLabel($.dawnDuskOptions[$.Options_Dict[id]]);

            Storage.setValue(id as String, $.Options_Dict[id]);            
            $.Settings_ran = true;
            //MySettings.writeKey(MySettings.backgroundKey,MySettings.backgroundIdx);
            //MySettings.background=MySettings.getColor(null,null,null,MySettings.backgroundIdx);
        }
        */ 
        /*
    }
    */

    class SolarSystemSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    
    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    } 

    public function onSelect(menuItem as MenuItem) as Void { 
        
        var ret = menuItem.getId();  
        if (menuItem instanceof ToggleMenuItem) {
            
            
            //deBug("menret", [ret, menuItem]);
            $.Options_Dict[ret] = menuItem.isEnabled();
            Storage.setValue(ret, menuItem.isEnabled());   

            //f.deBug("menu", [Options_Dict[extraPlanets], Options_Dict]);   
            if (ret == planetSizeL && menuItem.isEnabled) {                
                $.Options_Dict[planetSizeS] =false;
                Storage.setValue(planetSizeS, false);
                var r2 =  save_menu.findItemById(planetSizeS);
                //f.deBug("r2", r2);
                var x = save_menu.getItem(r2);
                //f.deBug("xr2", x);
                x.setEnabled(false);
            }   
            if (ret == planetSizeS && menuItem.isEnabled) {                
                $.Options_Dict[planetSizeL] =false;
                Storage.setValue(planetSizeL, false);
                var r2 =  save_menu.findItemById(planetSizeL);
                var x = save_menu.getItem(r2);
                x.setEnabled(false);
            }
            
        }
    }

    function onBack() {
        save_menu = null;

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate(); //often the screen is black after return from Menu, at least in the sim
    }
   


}