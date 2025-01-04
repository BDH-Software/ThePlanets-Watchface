import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;
import Toybox.Position;
import Toybox.Time.Gregorian;
import Toybox.Time;

var GL_count = 0;
/*

(:glance)class SSGlanceApp extends Application.AppBase {
    private var _SSGlanceView as SSGlanceView;
    private var _SSGlanceDelegate as SSGlanceDelegate;
    
    public function initialize() {
        AppBase.initialize();
        System.println("init starting...");

        //_SSGlanceView = new $.SSGlanceBaseView();
        //_SSGlanceDelegate = new $.SSGlanceBaseDelegate(_SSGlanceView);
    }

    function getGlanceView() {
        return [ new SSGlanceView() ];
    }
    public function onStart(state as Dictionary?) as Void {
    }

    public function onStop(state as Dictionary?) as Void {
    }

    public function onPosition(info as Position.Info) as Void {
    }

    public function getInitialView() as [Views] or [Views, InputDelegates] {
        return [_SSGlanceView, _SSGlanceDelegate];
            _SSGlanceDelegate = null;
            _SSGlanceView = null;

    }
    
}
*/

/*
(:glance)class SSGlanceDelegate extends WatchUi.BehaviorDelegate {
    private var _mainview as SSGlanceView?;
    public function initialize() {}
}
*/
var sm; 

(:glance)class SSGlanceView extends WatchUi.GlanceView {
    //private var _mainview as SSGlanceView?;

    var am,pm,up;
    var ampmORup; //1 am/pm, 2 what's up, 0 alternates between them
    var glanceTimer;

    public function initialize() {
        GlanceView.initialize();
        
        if (lastLoc == null) {
                var long = -98; 

                //approximate longitude from time zone offset if no other option
                //$.now = System.getClockTime();
                if ($.now != null && $.now.timeZoneOffset != null) { long = $.now.timeZoneOffset/3600*15;}
                lastLoc = new Position.Location(            
                    { :latitude => 39, :longitude => long, :format => :degrees }
                    ).toDegrees();
        }
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:glanceSetPosition));


        if ((Application has :Storage)) {
            var ret = Storage.getValue(glanceType);  
            if (ret == null) { ampmORup = 0;}
            else if (ret) { ampmORup = 1;}
            else {ampmORup = 2;}


        }

        lastLoc = [39.00894, 94.44008]; //for testing only
        doCalcs();
        glanceTimer= new Timer.Timer();
        GL_count = Math.rand()%2;
    }

    function doCalcs(){
        var obliq_deg;
        var pp;
        var moon_info3;

        

        obliq_deg=  f.calc_obliq_deg ($.now_info, $.now);

        var allPlanets = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
        var v = new vs();
        pp = v.planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs, :ecliptic_latlon, allPlanets.slice(0,10), :glance);
        v = null;
        allPlanets = null;

        sm = new simpleMoon();
        moon_info3 = sm.eclipticPos_moon ($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs);
        sm = null;

        

        pp.put("Moon", [moon_info3[0]]);    
        moon_info3=null; 
        //var gmst_now_deg = f.normalize(GMST_deg(jd));
        //var jd = f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, timeZoneOffset_sec/3600f, dst);
        //var lmst_now_deg = f.normalize((GMST_deg(jd) - lastLoc[0])); 

        var hor_ang_rad = intersectionPointsEclipticHorizon_rad (Math.toRadians(lastLoc[0]), Math.toRadians(f.normalize((GMST_deg(f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, $.now.timeZoneOffset/3600f, $.now.dst)) + lastLoc[1]))), Math.toRadians(obliq_deg));

        //must be PLUS longitude bec Meeus REVERSES the sign of the longitude in all his formulas. Compared to literally everyone else in the world. Aargh.

        //f.deBug("hor_ang", f.normalize(Math.toDegrees(hor_ang_rad)));

        //f.deBug("Sun", equatorialLong2eclipticLong_deg(pp["Sun"][0], obliq_deg));

        //f.deBug ("gmst", [f.normalize((GMST_deg(f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, $.now.timeZoneOffset/3600f, $.now.dst)) + lastLoc[1])),f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, $.now.timeZoneOffset/3600f, $.now.dst), now_info.year, $.now.timeZoneOffset, lastLoc[1],GMST_deg(f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, $.now.timeZoneOffset/3600f, $.now.dst))/15.0 ]);

        //var sun_adj_deg = (270 - equatorialLong2eclipticLong_deg(pp["Sun"][0], obliq_deg));

        //var hour_adj_deg = f.normalize($.now_info.hour*15 + time_add_hrs*15.0 + $.now_info.min*15/60);

        //var noon_adj_deg = 15 * -.37;

        //hor_ang_rad = -Math.toRadians(sun_adj_deg - hour_adj_deg - noon_adj_deg) + hor_ang_rad;

        //f.deBug("hor_ang", f.normalize(Math.toDegrees(hor_ang_rad)));

        //f.deBug("hor_ang", [f.normalize(Math.toDegrees(hor_ang_rad)), sun_adj_deg, hour_adj_deg, noon_adj_deg]);

        //var moon_age_deg = f.normalize ((pp["Moon"][0]) - (pp["Sun"][0]));

        var keys = pp.keys();
        var sorted_ang = new Array<Number> [keys.size()];
        for (var i = 0; i < keys.size(); i++) {
            var ky = keys[i];
            var ang_rad =  -equatorialLong2eclipticLong_rad(Math.toRadians(pp[ky][0]) , Math.toRadians(obliq_deg)); 

            pp.put(ky,(f.normalize(Math.toDegrees(ang_rad))).toNumber());
            //pp.put(ky,(f.normalize(Math.toDegrees(pp[ky][0]))*10).toNumber());
            
            //Create a sorted list of keys while we're at it..
            if (i==0) {sorted_ang[0] = i;
            } else {
                

                for (var j=0;j<=sorted_ang.size();j++) {
                    var myStats = System.getSystemStats();
                    //System.println("Mem" + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
                    //f.deBug("PP", [keys, ky, pp[ky], j, sorted_ang]);
                    if (sorted_ang[j] == null || pp[ky] < pp[keys[sorted_ang[j]]]) {

                        var s1 = sorted_ang.slice(0,j);
                        var s2 = sorted_ang.slice(j,sorted_ang.size()-1);
                        //f.deBug("SRT", [s1, s2, i, j]);
                        sorted_ang = s1;
                        sorted_ang.add(i);
                        sorted_ang.addAll(s2);
                        break;
                    }
                    //sorted_ang.add(i);
                }
            }
            

        }
        //f.deBug("angs", [sorted_ang, pp]);
        am = "A:";
        pm = "P:";
        up = "Up now:";
        //var w = "W:";
        var hitsun = 0;
        var hit_ehor = false;
        var hit_whor = false;
        var sun = 0;
        var sun_ang;
        var whor_deg = f.normalize(Math.toDegrees(hor_ang_rad));
        var ehor_deg = f.normalize(whor_deg+180);
        //f.deBug("ew", [whor_deg, ehor_deg]);
        

        for (var i = 0; i < sorted_ang.size() * 2; i++) {
            var ky = keys[sorted_ang[i % sorted_ang.size()]];
            //var ang_rad = -srs.equatorialLong2eclipticLong_rad(Math.to Radians(pp[ky][0]), Math.toRadians(obliq_deg));  
            //f.deBug("ky", [i,ky]);  

             if (f.normalize(pp[ky]-ehor_deg) <= 180 && !hit_whor) {
                hit_ehor = true;
                if (up.length()>8) { up += " ";}
                up += ky.substring(0,2);
                

            }
            if (f.normalize(pp[ky] - whor_deg) <180 && hit_ehor) {
                hit_whor = true;
            }   

            if (ky.equals("Sun")) {
                //if (hitsun) {break;}
                hitsun++; 
                sun_ang = pp[ky];
                sun = i;
                continue;
            }
            //f.deBug("ky", [i,ky,pp[ky], hitsun]);     
            if (hitsun ==1) {
                //f.deBug("norm1", [f.normalize(pp[ky] - sun_ang), pp[ky], ky, sun_ang]);
                if (f.normalize(pp[ky] - sun_ang) < 300) 
                {
                  am += ky.substring(0,2) + " "; 
                }
                //f.deBug("sas", (sun - i - 1 + 2* sorted_ang.size()) % sorted_ang.size());
                var k2= (2*sun - i + 2* sorted_ang.size())%sorted_ang.size();
                //f.deBug("norm2", [f.normalize(sun_ang - pp [keys[sorted_ang[k2]]]), pp[keys[sorted_ang[k2]]], k2, sun_ang, keys[sorted_ang[k2]]]);
                if ( f.normalize(sun_ang - pp[keys[sorted_ang[k2]]]) < 300) {
                    pm += keys[sorted_ang[k2]].substring(0,2) + " ";
                }
            }

           
            //f.deBug("APU", [am,pm, up]);
        }

        //up += ":W";
        
        //testStr = testStr.substring(0,14);
        
        
        
        pp = null;
        //f.deBug("APU final", [am,pm, up]);
        //speeds = null;
        //OptionsLabels = null;
        //Options = null;
        //defOptions = null;
        //srs.sunEventData = null;
        //Options_Dict = null;
        //allPlanets = null;
        //latlonOption_value = null;
        planetSizeOption_values = null;
        refreshOption_values = null;
        

        now_info = null;
        now = null;
        time_now = null;
        //f.deBug("mi3", moon_info3);
        

    }

    function onShow(){
        f.deBug("onShow",0);
        //WatchUi.requestUpdate();
        
        
        glanceTimer.start(method(:glanceTimerCallback), 6000, true);
    }

    function onHide(){
        f.deBug("onHide",0);
        //WatchUi.requestUpdate();
        
        
        glanceTimer.stop();
    }

    var glance_animation_count = 0;

    function glanceTimerCallback() as Void {
        glance_animation_count++;
        f.deBug("glanceTimer", [glance_animation_count,GL_count]);
        GL_count++;
        WatchUi.requestUpdate();

           
    }
    
    function onUpdate(dc) {
        //f.deBug("onupdate", [glance_animation_count,GL_count]);


        var screenwidth = dc.getWidth();

 
        var w = dc.getTextWidthInPixels(up, 3);
        var l = up.length();
        //f.deBug("WL", [w,l,screenwidth,up]);
        if (w>screenwidth) {        
            l = Math.round(up.length() *screenwidth/w.toFloat()).toNumber();
            l = l - l%3;
        }
        if (l<12) {l=12;}
        //f.deBug("WL", [w,l,up]);
        var up1 = up.substring(0, l);
        var up2 = up.substring(l, null);

        //$.now = System.getClockTime();
        var d1 = am;
        var d2 = pm;
        //if (($.now.sec/5)%2==1) {
        if (((ampmORup==0) && GL_count % 2 == 1) || (ampmORup ==2)) {
            d1 = up1;
            d2 = up2;
        }
        

        //f.deBug("now",[($.now.sec/5)%2,$.now.sec]);

        //dc.drawText(130,0, Graphics.FONT_SMALL, "Here we are!", Graphics.TEXT_JUSTIFY_CENTER);

        /*var zTime = Gregorian.utcInfo(Time.now(), Time.FORMAT_MEDIUM);
        var zuluTime = Lang.format("$1$:$2$", [zTime.hour.format("%02d"), zTime.min.format("%02d")])+" Z";
        */

        

        //var whh = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0); 

        

        //var pp = vs.planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs, :ecliptic_latlon, ["Sun", "Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn"]); 

        //f.deBug("ap", allPlanets);

        
        //allPlanets = null; 



        
        
       /*
        for (var rra_deg = 0; rra_deg<360;rra_deg += 360) {
            var ddecl = 0;
            if (rra_deg == 90) { ddecl = obliq_deg;}
            if (rra_deg == 270) { ddecl = obliq_deg;}
            //pp.put("Ecliptic"+rra_deg, [f.normalize(pp["Sun"][0] + rra_deg), ddecl]);
            pp.put("Ecliptic"+rra_deg, [rra_deg, ddecl, 50]);
        }
        */
    

        


        var testStr = d1;
        if (d2.length()>d1.length()) {testStr = d2;}
        testStr = testStr.substring(0,14);
        //var screenwidth = dc.getWidth();

        var fontsize = 3;
        for (var i = 1; i<5; i++) { //next fonts > 4 are number only 
            w = dc.getTextWidthInPixels(testStr, i);
            //f.deBug("width", [i, w]);
            if (w > screenwidth) {
                fontsize = i-1;
                break;
            }

        }
        
        //var angs ={};

        
        //var textWidth = getTextWidthInPixels(text as Lang.String, font as Graphics.FontType   
        
        



        

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0,0, fontsize, d1, Graphics.TEXT_JUSTIFY_LEFT );
        //dc.drawText(0,dc.getFontHeight(Graphics.FONT_MEDIUM), Graphics.FONT_MEDIUM, pm, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(0,dc.getHeight()/2.0, fontsize, d2, Graphics.TEXT_JUSTIFY_LEFT );



    }
}


(:glance)
function glanceSetPosition(pinfo){
    Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:setPosition));
    if (pinfo!= null && pinfo.position != null) { lastLoc = pinfo.position.toDegrees(); }
}


/*(:glance)function getApp() as SSGlanceApp {
    return Application.getApp() as SSGlanceApp;
}*/