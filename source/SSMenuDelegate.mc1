import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Position;


enum {
    extraPlanets =  0,
    planetLabels = 1,
    //smallerBanners = 2,
    planetSizeL = 3,
    planetSizeS = 4,
    glanceType = 6, //don't use 5 as it's used for helpOption_enum
    lastLoc_saved = 99,
}

var Options; //values added in getInitialView

var defOptions; //values added in getInitialView

var numOptions = 5;

var helpOption_enum = 5;

var save_menu as SSMenu?;

class SSMenu extends WatchUi.Menu2{
    
    (:hasJSON)
    public function initialize(){
        //var OptionsLabels = ["Show extra planets?", "Show planet labels?", "Draw planets larger?", "Draw planets smaller?", "Glance Morn/Eve or Up Now?"];
        var OptionsLabels = (WatchUi.loadResource( $.Rez.JsonData.OptionsLabels) as Array);

        for (var i = 0; i < numOptions; i++) {
        Menu2.addItem(new WatchUi.ToggleMenuItem(OptionsLabels[i], null, Options[i], $.Options_Dict[Options[i]]==true, null));
        }

        planetAbbreviation_index = 0;
        var pA = getPlanetAbbreviation();
        Menu2.addItem(new WatchUi.MenuItem(pA[0], pA[1],helpOption_enum, {}));
        save_menu = self;
    }

    (:noJSON)
    public function initialize(){
        var OptionsLabels = ["Show extra planets?", "Show planet labels?", "Draw planets larger?", "Draw planets smaller?", "Glance Morn/Eve or Up Now?"];
        //var OptionsLabels = (WatchUi.loadResource( $.Rez.JsonData.OptionsLabels) as Array);

        for (var i = 0; i < numOptions; i++) {
        Menu2.addItem(new WatchUi.ToggleMenuItem(OptionsLabels[i], null, Options[i], $.Options_Dict[Options[i]]==true, null));
        }

        planetAbbreviation_index = 0;
        var pA = getPlanetAbbreviation();
        Menu2.addItem(new WatchUi.MenuItem(pA[0], pA[1],helpOption_enum, {}));
        save_menu = self;
    }

    var planetAbbreviation_index = 0;
    
    // Function to generate planet abbreviation and name
    function getPlanetAbbreviation() {
        var allPlanets = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
        var helpSTR = (f.toArray(WatchUi.loadResource($.Rez.Strings.help_strings) as String,  "|", 0)).addAll(allPlanets.slice(1,15)); //start @ 1 to skip sun
        if (helpSTR.size()%2==1) { helpSTR.add(""); }
        
        var t1 = (planetAbbreviation_index<helpSTR.size()-allPlanets.size()) ? helpSTR[planetAbbreviation_index]: helpSTR[planetAbbreviation_index].substring(0,2) + " " + helpSTR[planetAbbreviation_index];

        var t2 = (planetAbbreviation_index + 1 <helpSTR.size()-allPlanets.size()) ? helpSTR[planetAbbreviation_index + 1]: helpSTR[planetAbbreviation_index + 1].substring(0,2) + " " + helpSTR[planetAbbreviation_index + 1];

        planetAbbreviation_index = (planetAbbreviation_index + 2) % (helpSTR.size()); //

        return [t1, t2];
        
        
    }
}

class SSMenuDel extends WatchUi.Menu2InputDelegate {

    
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


        } else {
            //helpOption
            if(ret.equals(helpOption_enum)) {
                //var index = $.Options_Dict[id] |0;                   
                var pA = save_menu.getPlanetAbbreviation();
                menuItem.setLabel(pA[0]);
                menuItem.setSubLabel(pA[1]);
            }
        }
    }

    function onBack() {
        save_menu = null;

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate(); //often the screen is black after return from Menu, at least in the sim
    }
}
