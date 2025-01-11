
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;
import Toybox.Application.Storage;

//var _planetIcon as BitmapResource?;
var newModeOrZoom = false;
var speedWasChanged = false;
var timeWasAdded = true; //helpful if this is true to make sure we DRAW SOMETHING at the start.
var countWhenMode0Started  = 0;
var drawPlanetCount =0;
var count = 0;
var now, time_now, now_info;

var the_rad = 0; //angles to rotate, theta & gamma
var ga_rad = 0 ;
var LORR_orient_horizon = true;
var LORR_show_horizon_line = true;
var LORR_oh_save_time_add_hrs = 0.158348;
var LORR_oh_save_ga_rad = 25.158348;
var obliq_deg;
var asteroidsRendered = false;

var save_local_animation_count;

var ssbv_init_count_global = 0;

var small_whh, /*full_whh,*/ zoomy_whh, whh0, whh1;
var lastLoc as Lang.float;

//! This view displays the position information
class SolarSystemBaseView extends WatchUi.WatchFace {

   
    private var _lines as Array<String>;
    private var _offscreenBuffer as BufferedBitmap?;    
    
    public var xc, yc, min_c, max_c, screenHeight, screenWidth, targetDc, screenShape, thisSys;
    private var ssbv_init_count;
    var dirty = true;
    
    
    
    //private var page;
    
    //! Constructor
    public function initialize() {
        f.deBug("viewInit start", null);
        View.initialize();
        //page = pg;

        //if _global ever gets incremented we know there is anotherBaseView running & we should vamoosky

        ssbv_init_count_global ++;        
        ssbv_init_count = ssbv_init_count_global;
        System.println("SsView init #"+ssbv_init_count);
        dirty = true;

        //speeds_index = 19; //inited in app.mc where the var is located
        view_mode = 0;
        Math.srand(start_time_sec);
        

        
        // Get the Initial POSITION value shown until we have the "real" position data from setPOosition
        //setPosition(); //Don't call setPosition() until the device is ready &
        //calls it via a callback (all set up in main app). Instead this INIT function will load
        //some semi, sensible data and thne setPOisition() will fill in the rest
        //later as available.  Also this & setPosition save position found
        //to the date store so initposition can use it next time.
        //UPDATE: can't do this until AFTER reading the storage values
        //But can't read storage values until this class is inited!
        //so we'll do it in BaseApp, after init of this class.
        //setInitPosition();

    

        //_planetIcon = WatchUi.loadResource($.Rez.Drawables.Jupiter) as BitmapResource;        
        //allPlanets = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);

        planetSizeOption_values=[
            0.5, 
            0.75, 
            1.0, 
            1.5, 
            2.0, 
            3.0,
            3.5

        ];
        
        //startAnimationTimer($.hz);


        //small_whh = f.toArray(WatchUi.loadResource($.Rez.Strings.small_whh_arr) as String,  "|", 0);
        //full_whh = f.toArray(WatchUi.loadResource($.Rez.Strings.full_whh_arr) as String,  "|", 0);
        //zoomy_whh = f.toArray(WatchUi.loadResource($.Rez.Strings.zoom_whh_arr) as String,  "|", 0);
        
        //whh0 = f.toArray(WatchUi.loadResource($.Rez.Strings.whh0) as String,  "|", 0);
        //whh1 = f.toArray(WatchUi.loadResource($.Rez.Strings.whh1) as String,  "|", 0);
        
  

        //helpOption = f.toArray(WatchUi.loadResource($.Rez.Strings.plan_abbr) as String,  "|", 0);
        //helpOption_size = helpOption.size();

        
        //orrZoomOption_values =  f.toArray(WatchUi.loadResource($.Rez.Strings.orrzoom_values) as String,  "|", 1);

        /*System.println("POs: " + planetsOption_values);
        System.println("POs0: " + whh0);
        System.println("POs1: " + whh1);
        System.println("POs1: " + small_whh);
        System.println("POs1: " + full_whh);
        System.println("POs1: " + zoomy_whh);*/

        f.deBug("viewInit finish", null);
        

    }

    //msg lines in an array to display & how long to display them
    //3 or 4 usually fit
    public function sendMessage (time_sec, msgs) {
        // /2.0 cuts display timein half, need a better solution involving actual
        //clock than guessing about animation  frequency
        //message_until = $.animation_count + time_sec * hz/2.0;
        message_until = time_now.value() + time_sec;
        //message = [msg1, msg2, msg3, msg4, $.animation_count + time_sec * hz/2.0 ];
        message = [message_until];
        //System.println("sm: " + time_sec + " "+ message +  " : " + msgs);
        message = message.addAll(msgs);        
        //System.println("sm2: " + time_sec + " "+ message +  " : " + msgs);
        
    }

    /*
    var local_animation_count = 0;

    function animationTimerCallback() as Void {

           //if ($.view_modes[$.view_mode] == 0 ) {
           // started = true;
           //}
           //if (local_animation_count < save_local_animation_count )
            //  {killExtraBaseView();}
            //local_animation_count++;
            //save_local_animation_count = local_animation_count;
           $.animation_count ++;
           animSinceModeChange ++;

           /*if ($.started
                && ($.view_mode>0) ) {
                $.time_add_hrs += $.speeds[$.speeds_index];
              
            }*/
            /*

           WatchUi.requestUpdate();
           
            //WatchUi.requestUpdate();
            // } else if ($.view_modes[$.view_mode] == 0) { //view_mode==0, we always request the update & let it figure it out
             //   WatchUi.requestUpdate();
             //}
             //} else if (mod($.animation_count,$.hz)==0) {
                //update screen #0 at 1 $.hz, much like a watchface...
                //WatchUi.requestUpdate();
                
             //}
             
            
           //Allow msgs etc when screen is stopped, but just @ a lower $.hz 
           //} else if ($.animation_count%3 == 0) {
           //  WatchUi.requestUpdate();
           //}
           //System.println("animationTimer: " + $.animation_count + " started: " + $.started + $.speedWasChanged +$.timeWasAdded);
    }

    */

    /*
    var animationTimer=null;
    public function startAnimationTimer(hertz){
        var now2 = System.getClockTime();
        System.println ("AnimTimer:" 
            +  now2.hour.format("%02d") + ":" +
            now2.min.format("%02d") + ":" +
            now2.sec.format("%02d"));

        if (animationTimer != null) {
            try {
                animationTimer.stop();
                animationTimer = null;
            } catch (e) {

            }

        }

        WatchUi.requestUpdate(); //sometimes screen doesn't show when returning from settings etc, trying to solve

        animationTimer= new Timer.Timer();
        
        animationTimer.start(method(:animationTimerCallback), 1000/hertz, true);
        //$.started = true;
        //if ($.reset_date_stop) {$.started=false;}
    } */
    /*
    public function stopAnimationTimer(){

        System.println ("Stop Animation Timer at " 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d"));

        if (animationTimer != null) {
            try {
                animationTimer.stop();
                animationTimer = null;
            } catch (e) {

            }

        }
    }
    */

    //Two views have been created, somehow, & they are competing.   Kill the newest one.
    public function exitExtraBaseView(){

        //stopAnimationTimer();
        self=null;
    }


    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void {
        System.println ("onLayout at " 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d"));
            

        thisSys = System.getDeviceSettings();
        
        screenHeight = dc.getWidth();
        screenWidth = dc.getHeight();

        xc = dc.getWidth() / 2;
        yc = dc.getHeight() / 2;

        min_c  = (xc < yc) ? xc : yc;
        max_c = (xc > yc) ? xc : yc;
        screenShape = thisSys.screenShape;

        //startAnimationTimer($.hz);
        thisSys = null;       

        
    
    }

    //! Handle view being hidden
    public function onHide() as Void {
        /*System.println ("onHide:" 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d")); */
        $.save_started = $.started;
        $.started = false;
        dirty = true;
        

    }

    //! Restore the state of the app and prepare the view to be shown
    public function onShow() as Void {
        /* System.println ("onShow:" 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d")); */
        $.started = $.save_started != null ? $.save_started : true;
        if ($.reset_date_stop) {$.started = false;} // after a Date Reset we STOP at that moment until user wants to start.
        timeWasAdded = true;
        //settings_view = null;
        //settings_delegate = null;
        //startAnimationTimer($.hz);

        //Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:setPosition)); 
        dirty = true;

    }

    /*

    var offScreenBuffer_started = false;

    function startOffScreenBuffer (dc){ 
        if (offScreenBuffer_started) {return;}

        var offscreenBufferOptions = {
                    :width=>dc.getWidth(),
                    :height=>dc.getHeight(),
                    :palette=> [
                        //Graphics.COLOR_DK_GREEN,
                        //Graphics.COLOR_GREEN,
                                            
                        Graphics.COLOR_BLACK,
                        Graphics.COLOR_WHITE,
    
                    ]
                };

            if (Graphics has :createBufferedBitmap) {
                // get() used to return resource as Graphics.BufferedBitmap
                _offscreenBuffer = Graphics.createBufferedBitmap(offscreenBufferOptions).get() as BufferedBitmap;
            } else if (Graphics has :BufferedBitmap) { // If this device supports BufferedBitmap, allocate the buffers we use for drawing
                // Allocate a full screen size buffer with a palette of only 4 colors to draw
                // the background image of the watchface.  This is used to facilitate blanking
                // the second hand during partial updates of the display
                _offscreenBuffer = new Graphics.BufferedBitmap(offscreenBufferOptions);

            } else {
                _offscreenBuffer = null;
                
            }
            /*
            if (null != _offscreenBuffer) {
                // If we have an offscreen buffer that we are using to draw the background,
                // set the draw context of that buffer as our target.
                targetDc = _offscreenBuffer.getDc();
                
            } else {
                targetDc = dc;
                
            }
            */
            /*
            offScreenBuffer_started = true;
    }

    function stopOffScreenBuffer(){
        _offscreenBuffer = null;
        targetDc = null;
        offScreenBuffer_started = false;
        asteroidsRendered = false;

    }

    */

    //hr are in hours, so *15 to get degrees
    //drawArc start at 3'oclock & goes CCW in degrees
    //whereas hrs start at midnight (6'oclock position) and proceed clockwise.  Thus 270 - hr*15.
    public function drawARC (dc, hr1, hr2, xc, yc, r, width, color) {
        
        if (hr1 == null || hr2 == null) {return false;}
        dc.setPenWidth(width);
        if (color != null) {dc.setColor(color, Graphics.COLOR_TRANSPARENT);}
        dc.drawArc(xc, yc, r, Graphics.ARC_CLOCKWISE, 270.0 - hr1 * 15.0, 270.0 - hr2 *15.0);   
        //deBug("drawArc", [270.0 - hr1 * 15.0, 270.0 - hr2 *15.0, hr1, hr2]);
        return true;
    }

    /*
    //dashed line 
    //Note len_line can be ZERO - in that case it just draws a single pixel/dot for each "dash"
    public function drawDashedLine (myDc,x1, y1, x2, y2, len_line, len_skip, width, color) {
                
        myDc.setPenWidth(width);
        if (color != null) {myDc.setColor(color, Graphics.COLOR_TRANSPARENT);}

        var x_diff = x2 - x1;
        var y_diff = y2 - y1;
        var length = Math.round(Math.sqrt(x_diff * x_diff + y_diff * y_diff));
        if (length==0) {length = 1;}
        
        for (var i = 0; i < length; i += len_line + len_skip) {
            var x = x1 + (x_diff * i / length);
            var y = y1 + (y_diff * i / length);
            if (len_line < 1) {
                myDc.drawPoint(x,y);
            } else {                
                var x_2 = x1 + (x_diff * (i + len_line) / length);
                var y_2 = y1 + (y_diff * (i + len_line) / length);
                myDc.drawLine(x,y,x_2,y_2);
            }
        }
    }
    */

    //Triangle pointing in the direction  dir_x, dir_y to x1,y1, pointing outwards from x1,y1
    //coord = [dir_x, dir_y, x1, y1]
    public function drawTrianglePointer (myDc, coord, length, base_width, line_width, color, outline, pointer_line) {
                
        myDc.setPenWidth(line_width);
        if (color != null) {myDc.setColor(color, Graphics.COLOR_TRANSPARENT);}

        var x_diff = coord[2] - coord[0];
        var y_diff = coord[3] - coord[1];
        var dir_length = Math.round(Math.sqrt(x_diff * x_diff + y_diff * y_diff));
        var x2 = coord[2] + (x_diff * length / dir_length);
        var y2 = coord[3] + (y_diff * length / dir_length);
        var y3 = coord[3] + (x_diff * 0.5*base_width / dir_length) ;
        var x3 = coord[2] - (y_diff * 0.5*base_width / dir_length);
        var y4 = coord[3] - (x_diff * 0.5*base_width / dir_length);
        var x4 = coord[2] + (y_diff * 0.5*base_width / dir_length);

        if (pointer_line) {
            myDc.drawLine(coord[2], coord[3], coord[0], coord[1]);
        }
        if (outline) {
            myDc.drawLine(x4,y4,x3,y3);
            myDc.drawLine(x3,y3, x2,y2);
            myDc.drawLine(x2,y2,x4,y4);
        } else {
            myDc.fillPolygon([[x4,y4],[x3,y3],[x2,y2],[x4,y4]]);
        }
        
        
    }


    public function doUpdate(dc, move){
        largeEcliptic(dc, 0);
        if ($.view_mode == 0 || $.view_mode ==1 ) {
            //largeEcliptic(dc, 0);
            $.timeWasAdded = false;
            if (buttonPresses<1){started = false;}
        }
    }
        /*switch($.view_mode){
            case (0): //manual ecliptic (& follows clock time)
                /*stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                $.timeWasAdded = false;
                break;*/
                /*
            case (1):  //slow-moving animated ecliptic
                //stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                $.timeWasAdded = false;
                if (buttonPresses<1){started = false;}
                //if ($.started) {WatchUi.requestUpdate();}
                break;
            case (2):  //animation moving at one frame/day; sun frozen
                //stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                
                //if ($.started) {WatchUi.requestUpdate();}
                break;   
                

            */ 

            /*    
            case(3): //top view of center 4 planets
            case (4): //oblique
                //time_add_inc = 24*3;
                
                startOffScreenBuffer(dc);
                largeOrrery(dc, 0);
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                //if ($.started) {WatchUi.requestUpdate();}
                break;
            case(5): //top view of main planets
            case(6): //oblique view of main planets
               
                startOffScreenBuffer(dc);
                largeOrrery(dc, 1);
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                //if ($.started) {WatchUi.requestUpdate();}

                break;
            
            case(7):  //top view taking in some trans-neptunian objects
            case(8):  //top view taking in some trans-neptunian objects
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                
                startOffScreenBuffer(dc);
                largeOrrery(dc, 2);
                //if ($.started) {WatchUi.requestUpdate();}

                break;
            default:
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                
                //if ($.started) {WatchUi.requestUpdate();}
            */    
            


        //}
    //}

    //! Update the view
    //! @param dc Device context    
    var save_count =-10;
    var stopping_completed = true;
    var textDisplay_count = 0;
    var old_mode = -1;
    
    var planetRand = 0;
    
    var ranvar = 0;
    
    public function onUpdate(dc as Dc) as Void {

        $.time_add_hrs = 0;

        //f.deBug("onUPdateInit start", null);
        



        $.count++;

        

        $.now = System.getClockTime(); //for testing

        /*
        for (var i = 0; i< 0.4; i+=0.03) {
            //System.println("i: " + i + " " + Math.sin(i));
            drawHorizon2(dc, 23, i, xc, yc, xc, true);
        } 
        */  

        /*
        //If stopping, we need to run ONCE with the updates to text/titles, then hold there.  Tricky
        if (
                !started 
                ||  (
                    ($.view_mode == 0 && !$.timeWasAdded)
                    && $.buttonPresses > 0 
                    && $.animation_count - $.countWhenMode0Started>3*$.hz
                
                    )  
                || (
                    time_now.value()<message_until && !started 
                   )    
                
            )
        {
            //when stopped, we do run ONCE every FIVE MINUTES so as to update the 
            //display to current time
            //Thus you could use this as a kind of a clock face
            //var run_once = $.now.min%5==0 && $.now.sec==0;

            //UPDATE: Need to run it once per MINUTE in order to update the 
            //time shown...
            var run_once = (($.now.sec==0)  || $.newModeOrZoom || $.speedWasChanged
             || msgDisplayed  );
            
            //System.println ("NMZ SWC: " + $.newModeOrZoom + $.speedWasChanged + $.buttonPresses +":" + msgSaveButtonPress  + $.run_oneTime + message_until + " " + time_now.value());
            
            if (stopping_completed && !run_once && !$.run_oneTime ) {return;}
            //System.println ("NMZ SWC 1");
            
            if ($.run_oneTime || run_once) {
                ranvar = Math.rand();
                //System.println("This is the one time!!!!" + ranvar);
                $.run_oneTime = false;
                stopping_completed =false;
                //System.println ("NMZ SWC 2");
                //then proceed to run entire onupdate rather than returning....

            } else {
                /*
                if ($.view_mode >=3 ) {
                    showDate(dc, $.now_info, $.time_now, time_add_hrs,  xc, yc, true, true, :orrery);
                    //System.println ("NMZ SWC 3");
                } else {
                    showDate(dc, $.now_info, $.time_now, time_add_hrs, xc, yc, true, true, :ecliptic_latlon);
                    //System.println ("NMZ SWC 4");
                }
                */
                /*
                stopping_completed = true;
                //System.println ("NMZ SWC 5");
                //return;
            }

        } else {
            //System.println ("NMZ SWC 6");
            stopping_completed =false;
        }
        */

        //System.println ("NMZ SWC 7");
        //System.println("made it one time!!!!" + ranvar);

        //if ( ssbv_init_count < ssbv_init_count_global ) {exitExtraBaseView(); }
        //System.println("count: " + count + "angles: " + the_rad + " " + ga_rad + " timeadd: " + time_add_hrs + " speeds: " + $.speeds_index + " started:" + started + " animation count: " +  $.animation_count + " messageuntil: " + $.message_until + " ");

        //        System.println("started: " + $.started + " run_oneTime" + $.run_oneTime + + " run_once" + ($.now.sec==0) + " stoppingcompleted " + stopping_completed + " viewmode: " + $.view_mode + " timewasadded: " + $.timeWasAdded + " buttonpresses:" + $.buttonPresses + " animation count: " +  $.animation_count + " messageuntil: " + $.message_until + " ");

        //$.run_oneTime = false;
        $.time_now = Time.now();
        
        /*
        //In case a button hasn't been pressed in X seconds, stop.  So as to preserve battery.
        if ($.time_now.value() > $.last_button_time_sec + 60 ) {
        //if ($.time_now.value() > $.last_button_time_sec + 30 ) {  //for testing
            $.started = false;
            //$.run_oneTime = true;
        }
        */

        //$.time_now = now; //for testing
        $.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);
        
        deBug("oud-exiting?", [$.now_info.min%5, dirty, $.now_info.sec]);

        if ($.now_info.min%5 !=0 && !dirty &&  $.now_info.sec == 0) {
            showDate(dc, $.now_info, $.time_now, time_add_hrs, xc, yc, true, true, :ecliptic_latlon);
            deBug("oud-exiting yes", $.now_info.min%5);
            return;
        }
        dirty = false;
   

        /*         if ($.view_mode>0 && !reset_date_stop && started)  {
                //deBug("speeds Index", [$.speeds_index]);
                $.time_add_hrs += $.speeds[$.speeds_index];
         }*/

        /*
        if ($.view_mode>0 && !reset_date_stop && started)  {
            //deBug("speeds Index", [$.speeds_index]);
            $.speeds = WatchUi.loadResource( $.Rez.JsonData.speeds) as Array;
            $.time_add_hrs += $.speeds[$.speeds_index];
            $.speeds = null;
        }
        */





        textDisplay_count ++;
        $.reset_date_stop = false;
        $.drawPlanetCount =0; //incremented when drawing each planet; refreshed on each new screen draw
        //if($.buttonPresses>0) {_planetIcon = null;}
        planetRand = Math.rand(); //1 new random number for drawPlanet, per screen refresh

        if ($.view_mode != old_mode) {
            textDisplay_count =0;
            old_mode = $.view_mode;
        }

        


        /*
        //In case we are holding @ beginning of mode & not started
        //we just print dates & msgs and that's it. exit.
        if (time_now.value()>message_until && !started ) {

            if ($.view_mode >3 ) {
                showDate(dc, $.now_info, $.time_now, time_add_hrs,  xc, yc, true, true, :orrery);
            } else {
                 showDate(dc, $.now_info, $.time_now, time_add_hrs, xc, yc, true, true, :ecliptic_latlon);
            }

            return;
            
        }
        */
        //largeEcliptic(dc, 0);
        
         doUpdate(dc, started);
        


        


        /*
        System.println("View Equatorial:");
        var h = new Geocentric(2024, 12, 7, 12, 14, 0, 0,"equatorial");
        var hpos = h.position();
        System.println(hpos);
        var kys = hpos.keys();
        for (var i=0; i<hpos.size(); i++) {
            var ky = kys[i];
            //System.println(i +"  " + hpos[ky]);
            //System.println(i +"  " + hpos[i][0] + "  " +
             //(hpos[i][1])+ "  " + (hpos[i][2]));
            System.println(ky +"  " + decimal2hms(hpos[ky][0]) + "  " +
             decimal2arcs(hpos[ky][1])+ "  " + Math.round(hpos[ky][2]));
        }

        System.println("View Horizontal:");

        var gg = new Heliocentric(2024, 12, 7, 12, 14, 0, 0,"horizontal");
        System.println(gg.planets());

        System.println("View Rectangular:");
        var hh = new Heliocentric(2024, 12, 7, 12, 14, 0, 0,"rectangular");
        System.println(hh.planets());
        */
    }

    var r, whh_sun, vspo_rep, font, srs, sunrise_events, sunrise_events2, pp, pp2, pp_sun, moon_info, moon_info2, moon_info3, moon_info4, elp82, sun_info3, now, sid, x as Lang.float, y as Lang.float, y0 as Lang.float,  z0 as Lang.float, x2 as Lang.float, y2 as Lang.float;
    var ang_deg as Lang.float, ang_rad as Lang.float, size as Lang.float, mult as Lang.float, sub, key, key1, textHeight, kys, add_duration as Lang.float, col;
    var sun_adj_deg as Lang.float, hour_adj_deg as Lang.float,final_adj_deg as Lang.float, final_adj_rad as Lang.float, noon_adj_hrs as Lang.float, noon_adj_deg as Lang.float, moon_age_deg as Lang.float;
    var input as Lang.boolean;

/*
    public function smallEcliptic(dc) {
         // Set background color
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        getMessage();
        //setPosition(Position.getInfo());
        //var xc = dc.getWidth() / 2;
        //var yc = dc.getHeight() / 2;
        xc = 145;
        yc = 30;
        r = (xc < yc) ? xc : yc;
        r = .9 * r;

        font = Graphics.FONT_TINY;
        textHeight = dc.getFontHeight(font);
        //textWidght = dc.getFontW
        /*
        y -= (_lines.size() * textHeight) / 2;
        //dc.drawText(x, y+50, Graphics.FONT_SMALL, "Get Lost", Graphics.TEXT_JUSTIFY_CENTER);
        for (var i = 0; i < _lines.size(); ++i) {
            dc.drawText(x, y, Graphics.FONT_TINY, _lines[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += textHeight;
        }
        //dc.drawText(x, y-50, Graphics.FONT_SMALL, "Bug Off", Graphics.TEXT_JUSTIFY_CENTER);
        */

        //planetnames = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"];
/*        
        whh = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn"];

        System.println("View Ecliptic:");

        add_duration = new Time.Duration($.time_add_hrs*3600);
        System.println("View Ecliptic:" + add_duration + " " + $.time_add_hrs);
        now = System.getClockTime();
        var now_info = Time.Gregorian.info(Time.now().add(add_duration), Time.FORMAT_SHORT);

        System.println("View Ecliptic:" + now_info.year + " " + $.now_info.month + " " + $.now_info.day + " " + $.now_info.hour + " " + $.now_info.min + " " + $.now.timeZoneOffset/3600 + " " + $.now.dst);
        
        //g = new Geocentric($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst,"ecliptic", whh);

        //geo_cache actually ignores UT, dst, which - we'll correct for that later
        //        g = geo_cache.fetch($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst,"ecliptic", whh);
        
        //setPosition();

        showDate(dc, $.now_info, xc, yc, true,Graphics.TEXT_JUSTIFY_CENTER);

        //srs = new sunRiseSet($.now_info.year, $.now_info.month, $.now_info.day, $.now.timeZoneOffset/3600, $.now.dst, lastLoc[0], lastLoc[1]);
        
        //sunrise_events = srs.riseSet();
        sunrise_events = sunrise_cache.fetch($.now_info.year, $.now_info.month, $.now_info.day, $.now.timeZoneOffset/3600, $.now.dst, lastLoc[0], lastLoc[1]);

        System.println("Sunrise_set: " + sunrise_events);
        //sunrise_set = [sunrise_set[0]*15, sunrise_set[1]*15]; //hrs to degrees

        //dc.setPenWidth(1);
        //dc.drawArc(xc, yc, r,Graphics.ARC_CLOCKWISE, 0,360);
        dc.drawCircle(xc, yc, r);

        drawARC (dc, sunrise_events[:SUNRISE][0], sunrise_events[:SUNSET][0], xc, yc, r, 2, Graphics.COLOR_WHITE);
        drawARC (dc, sunrise_events[:DAWN][0], sunrise_events[:SUNRISE][0], xc, yc, r, 1,Graphics.COLOR_BLACK);
        drawARC (dc, sunrise_events[:SUNSET][0], sunrise_events[:DUSK][0], xc, yc, r, 1,Graphics.COLOR_BLACK);
        dc.setPenWidth(1);
        
        
        //pp=g.position();
        //geo_cache actually ignores UT, dst, which - we'll correct for that later
        pp = $.geo_cache.fetch($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst,"ecliptic", whh);
        kys = pp.keys();
        //dc.drawCircle(xc, yc, r);
        
        var sid_old = $.now_info.hour*15 + $.now_info.min*15/60; //approx.....
        //sid = sunrise_events[SIDEREAL_TIME][0] * 15;
        sid = srs.siderealTime($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst, lastLoc[0], lastLoc[1]);

        //g = null;
        srs = null;

        System.println("SID approx " + sid_old + "SIDEREAL_TIME" + sid + "daily: " + sunrise_events[:SIDEREAL_TIME][0]);

        //init_findSpot();
        for (var i = 0; i<kys.size(); i++) {

            var key = kys[i];
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}
            var x = r* Math.cos(Math.toRadians(-pp[key][0] + sid)) + xc;
            var y = r* Math.sin(Math.toRadians(-pp[key][0]+sid)) + yc;
            //var x2 = .65*r* Math.cos(Math.toRadians(-pp[key][0]+sid)) + xc;
            //var y2 = .65* r* Math.sin(Math.toRadians(-pp[key][0]+sid)) + yc;
            var size = 5;
            col = Graphics.COLOR_WHITE;
            if (key.equals("Sun")) {size = 5;}
            switch (key) {
                case "Mercury":
                    size = 2;
                    col = Graphics.COLOR_DK_GRAY;
                    break;
                case "Venus":
                    size =2;
                    col = 0xe3db98;
                    break;

                case "Mars":
                    size =2;
                    col = Graphics.COLOR_RED;
                    break;
                case "Saturn":
                    size =3;
                    col = 0x5500AA;
                    break;
                case "Jupiter":
                    size =4;
                    col = Graphics.COLOR_RED;
                    break;
            }

            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
            dc.fillCircle(x, y, size);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, size);
            if (key.equals("Sun") || key.equals("Venus")) {dc.fillCircle(x, y, size);}

            if (key.equals("Venus")) {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
                dc.fillCircle(x, y, 1);
            }

            if (!key.equals("Sun"))  {
                //dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,1), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
            }
        }
        pp=null;
        pp_sun = null;
        kys =  null;
        keys = null;
        srs = null;
        sunrise_events  = null;
        whh = null;
        whh_sun = null;

    }

*/
    private function sunriseHelper(){

         //sunrise_events = sunrise_cache.fetch($.now_info.year, $.now_info.month, $.now_info.day, $.now.timeZoneOffset/3600, $.now.dst, time_add_hrs, lastLoc[0], lastLoc[1]);

        //System.println("Sunrise_set: " + sunrise_events);

        //lastLoc = [59.00894, -94.44008]; //for testing
        var sr = new srs();
        sunrise_events2 = sr.getRiseSetfromDate_hr($.now_info, $.now.timeZoneOffset, $.now.dst, 0,lastLoc[0], lastLoc[1], pp["Sun"]);
        

        //System.println("Sunrise_set2%%%%%%%: " + sunrise_events2);
        //deBug("Sunrise_set2%: ", [sunrise_events2[:SUNRISE][0] , sunrise_events2[:SUNRISE][1] , sunrise_events2[:NOON] , sunrise_events2[:HORIZON][0] , sunrise_events2[:HORIZON][1] ]);

        //System.println("Sunrise_set: " + sunrise_set);
        //sunrise_set = [sunrise_set[0]*15, sunrise_set[1]*15]; //hrs to degrees

        //This puts our midnight sun @ the bottom of the graph; everything else relative to it
        //geo_cache.fetch brings back the positions for UTC & no dst, so we'll need to correct
        //for that
        //TODO: We could put in a correction for EXACT LONGITUDE instead of just depending on 
        //$.now_info.hour=0 being the actual local midnight.
        //pp/ecliptic degrees start at midnight (bottom of circle) & proceed COUNTERclockwise.
        //sun_adj_deg = (270 - pp["Sun"][0]);// 

        //&&&&&&&&&&&&&&&&&&&&&&&&
        sun_adj_deg = (270 - sr.equatorialLong2eclipticLong_deg(pp["Sun"][0], obliq_deg));// 

        sr = null;

        //sun_adj_deg = 270 - pp["Sun"][0];// 
        
        //hour_adj_deg = f.normalize($.now_info.hour*15 + time_add_hrs*15.0 + $.now_info.min*15/60)* sidereal_to_solar;
        hour_adj_deg = f.normalize($.now_info.hour*15 + time_add_hrs*15.0 + $.now_info.min*15/60);
        //We align everything so that NOON is directly up (SOLAR noon, NOT 12:00pm)

        //System.println("Sunrise_set2B: " + sunrise_events2);
        //System.println("Sunrise_set2C: " + sunrise_events2[:NOON]);

        //What happens in arctic when noon is never above horizon?  
        //We should still have "noon" in the sense of highest DECL reached by the sun; we'll see...
        noon_adj_hrs = 12 - sunrise_events2[:NOON][0]; //[0] is long in equatorial coords, [1] is long along the ecliptic.  
        //noon_adj_hrs = sunrise_events2[:NOON] - 12.0f;
        noon_adj_deg = 15 * noon_adj_hrs;
        final_adj_deg = (sun_adj_deg - hour_adj_deg - noon_adj_deg).toFloat();
        final_adj_rad = Math.toRadians(final_adj_deg);
    }

    var time_last_calcs_sec = 0;
    var whh;
    var no_calc_times = 0;

    //big_small = 0 for small (selectio nof visible planets) & 1 for big (all planets)
    public function largeEcliptic(dc, big_small) {
        

         // Set background color
        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        //getMessage();
        speedWasChanged = false;
        //setPosition(Position.getInfo());
        //xc = dc.getWidth() / 2;
        //yc = dc.getHeight() / 2;
        //if (obliq_deg == 0 || (obliq_calc_time_hr - time_add_hrs).abs() > 4380000 ) {

        //obliq_deg= obliquityEcliptic_deg ($.now_info.year, $.now_info.month, $.now_info.day + time_add_hrs, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst);

        var time_since_last_calcs_sec = $.time_now.value() - time_last_calcs_sec;

        var do_calc =  (time_since_last_calcs_sec >= 5*60 || time_since_last_calcs_sec < 0
        ||no_calc_times>1000) ? true : false;

        deBug("docalc", [time_since_last_calcs_sec, $.time_now.value(), time_last_calcs_sec, do_calc]); 

        if (!do_calc) {no_calc_times++;}       

        if (do_calc) {
            no_calc_times = 0;

            time_last_calcs_sec=$.time_now.value();

            obliq_deg=  f.calc_obliq_deg ($.now_info, $.now);
    
            r = (xc < yc) ? xc : yc;
            r = .85 * r * eclipticSizeFactor; //was .9 but edge of screen a bit crowded???

            font = Graphics.FONT_TINY;
            textHeight = dc.getFontHeight(font);
            /*
            y -= (_lines.size() * textHeight) / 2;
            //dc.drawText(x, y+50, Graphics.FONT_SMALL, "Get Lost", Graphics.TEXT_JUSTIFY_CENTER);
            for (var i = 0; i < _lines.size(); ++i) {
                dc.drawText(x, y, Graphics.FONT_TINY, _lines[i], Graphics.TEXT_JUSTIFY_CENTER);
                y += textHeight;
            }
            //dc.drawText(x, y-50, Graphics.FONT_SMALL, "Bug Off", Graphics.TEXT_JUSTIFY_CENTER);
            */

            //planetnames = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"];
            
            whh_sun  = ["Sun"];
            //whh = ["Sun", "Moon", "Mercury","Venus","Mars","Jupiter","Saturn"];
            //whh = whh0;
            //whh = allPlanets.slice(0,4).add(allPlanets[5].addAll(allPlanets.slice(9,14))
            //whh = allPlanets; //

            var allPlanets = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);

            //deBug("allpl", allPlanets);
            whh = ["Ec0", "Ec90", "Ec180", "Ec270",allPlanets[4]]; //put first so they are UNDER the planets.  Moon is next so planets will go in front of it (it's large)
            
            whh.addAll( allPlanets.slice(0,3)); ///so, array2 = array1 only passes a REFERENCE to the array, they are both still the same array with different names.  AARRGGgH!!
            //f.deBug("ap1", whh);
            whh.addAll(allPlanets.slice(5,8));
            //f.deBug("ap2", whh);
            if (Options_Dict[extraPlanets]) {
                whh.addAll(allPlanets.slice(8,12));
            }
            allPlanets = null;

            //f.deBug("ap3", [whh, Options_Dict[extraPlanets], Options_Dict]);

            //we add these last so they show up on top of planets etc
            

            //deBug ("www - whh0", whh);
            //vspo_rep = ["Sun", "Moon", "Mercury","Venus","Mars","Jupiter","Saturn", "Uranus","Neptune"];
            /*
            if (big_small == 1) {
                //whh = ["Sun", "Moon", "Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris", "Gonggong"]; 
                whh = whh1;
                whh = allPlanets.slice(0,3).add(allPlanets[5].addAll(allPlanets.slice(9,16))
            }
            */


            //TODO: Make all this JUlian Time so we don't need to worry about Unix seconds & all that
            //add_duration = new Time.Duration($.time_add_hrs*3600);
            //System.println("View Ecliptic:" + add_duration + " " + $.time_add_hrs);

            //now = System.getClockTime();
            //var $.now_info = Time.Gregorian.info(Time.now().add(add_duration), Time.FORMAT_SHORT);
            //var $.time_now = Time.now();
            //var $.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);
            



            //System.println("View Ecliptic:" + $.now_info.year + " " + $.now_info.month + " " + $.now_info.day + " " + $.now_info.hour + " " + $.now_info.min + " " + $.now.timeZoneOffset/3600 + " " + $.now.dst);
            //g = new Geocentric($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst,"ecliptic", whh);

            //pp=g.position();
            //kys = pp.keys();

            //Geo_cache.fetch always returns the info for Midnight UTCH
            //Which we then add the correct # of hours to (depending on )
            //current  time zone, DST, etc, in order to put the 
            //sun @ the correct time.  We also put in a small adjustment
            //So that local solar noon is always directly UP & solor 
            //midnight is directly DOWN on the circle.
            //pp2 = $.geo_cache.fetch($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst,"ecliptic", whh);
            //moon_info = simple_moon.lunarPhase($.now_info, $.now.timeZoneOffset, $.now.dst);

            /* input = {:year => $.now_info.year,
            :month => $.now_info.month,
            :day => $.now_info.day,
            :hour => $.now_info.hour,
            :minute => $.now_info.min,
            :UT => $.now.timeZoneOffset/3600,
            :dst => $.now.dst,
            :longitude => lastLoc[0], 
            :latitude => lastLoc[1],
            :topographic => false, 
            };
            moon = new Moon(input);
            */

            //    $.time_now = Time.now();
            //$.time_now = now; //for testing
            //$.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);   
            //simple_moon = new simpleMoon();
            //deBug ("moon_infe ", [$.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs]);

            //deBug("moon_infe: ", [$.now.hour, $.now.min, $.now.sec, $.now_info.day, $.now_info.month, $.now_info.year, $.time_now.value(), $.now_info, $.run_oneTime, $.time_add_hrs, $.speeds, $.speeds_index]);
            

            //deBug("moon_inf", moon_info3);

            //sun_info3 =  simple_moon.eclipticSunPos ($.now_info, $.now.timeZoneOffset, $.now.dst); 
            //simple_moon = null;

            //elp82 = new ELP82();
            //moon_info4 = elp82.eclipticMoonELP82 ($.now_info, $.now.timeZoneOffset, $.now.dst);
            //elp82 = null;

            
            // moon_info2 = simple_moon.lunarPhase($.now_info, $.now.timeZoneOffset, $.now.dst);
            //moon_info = moon.position();
            //vspo87a = new vsop87a_nano();
            //vspo87a = new vsop87a_pico();
            //pp = vspo87a.planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst, :ecliptic_latlon);
            //pp = vsop_cache.fetch($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs, :ecliptic_latlon, whh);   
            
            
            var v = new vs();
            pp = v.planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst, 0, :ecliptic_latlon, whh, :widget);   
            v = null;
            
            //vspo87a = null;

            
            //Add 4 ecliptic points to the planets
            for (var rra_deg = 0; rra_deg<360;rra_deg += 90) {
                    var ddecl = 0;
                    if (rra_deg == 90) { ddecl = obliq_deg;}
                    if (rra_deg == 270) { ddecl = obliq_deg;}
                    //pp.put("Ecliptic"+rra_deg, [f.normalize(pp["Sun"][0] + rra_deg), ddecl]);
                    pp.put("Ec"+rra_deg, [rra_deg, ddecl, 50]);
            }

            //flattenEclipticPP(obliq_deg);     

            //deBug("pp: ", pp);

            //System.println("Moon simple3: " + moon_info3 + " elp82: "+ moon_info4);
            //System.println("Moon simple2: " + moon_info2);
            //System.println("Moon ecl pos: " + moon_info);
            //pp.put("Moon", [pp["Sun"][0] + moon_info[0]]);
            //deBug("moon, ", [moon_info3[0]]);

            
            
            //pp["Sun"] = [sun_info3[:lat], sun_info3[:lon], sun_info3[:r]];
            //System.println("Sun info3: " + sun_info3);
            //System.println("Moon info: " + moon_info);
            //System.println("Sun-moon: " + pp["Sun"][0] + " " + pp["Moon"][0] );
            //System.println("Sun simple3: " + sun_info3);
            //System.println("pp: " + pp);
            //System.println("pp2: " + pp2);


            
            //g = null;

            //g = new Geocentric($.now_info.year, $.now_info.month, $.now_info.day, 0, 0, $.now.timeZoneOffset/3600, $.now.dst,"ecliptic", whh_sun);

            //pp_sun = g.position();



            //g = null;

            //setPosition();
            //var pos_info = self.lastLoc.getInfo();
            //var deg = pos_info.position.toDegrees();

            //srs = new sunRiseSet($.now_info.year, $.now_info.month, $.now_info.day, $.now.timeZoneOffset/3600, $.now.dst, lastLoc[0], lastLoc[1]);
            //sunrise_events = srs.riseSet();
            /*

            sunrise_events = sunrise_cache.fetch($.now_info.year, $.now_info.month, $.now_info.day, $.now.timeZoneOffset/3600, $.now.dst, time_add_hrs, lastLoc[0], lastLoc[1]);

            //System.println("Sunrise_set: " + sunrise_events);
            //System.println("Sunrise_set: " + sunrise_set);
            //sunrise_set = [sunrise_set[0]*15, sunrise_set[1]*15]; //hrs to degrees

            //This puts our midnight sun @ the bottom of the graph; everything else relative to it
            //geo_cache.fetch brings back the positions for UTC & no dst, so we'll need to correct
            //for that
            //TODO: We could put in a correction for EXACT LONGITUDE instead of just depending on 
            //$.now_info.hour=0 being the actual local midnight.
            //pp/ecliptic degrees start at midnight (bottom of circle) & proceed COUNTERclockwise.
            sun_adj_deg = 270 - pp["Sun"][0];
            hour_adj_deg = f.normalize($.now_info.hour*15 + time_add_hrs*15.0 + $.now_info.min*15/60);
            //We align everything so that NOON is directly up (SOLAR noon, NOT 12:00pm)
            noon_adj_hrs = 12 - sunrise_events[:NOON][0];
            noon_adj_deg = 15 * noon_adj_hrs;
            final_adj_deg = sun_adj_deg - hour_adj_deg - noon_adj_deg;
            */

            sunriseHelper();

            //System.println("pp_sun:" + pp_sun);
            //System.println("sun_a:" + sun_adj_deg + " hour_ad " + hour_adj_deg + "final_a " + final_adj_deg);        

        }

        //dc.setPenWidth(1);
        //dc.drawArc(xc, yc, r,Graphics.ARC_CLOCKWISE, 0,360);
        dc.drawCircle(xc, yc, r);


        /* old way - sunriseset.mc
        //Draws horizon & meridian, per time of day
        drawHorizon(dc, sunrise_events[:HORIZON_PM][0], noon_adj_deg, hour_adj_deg - noon_adj_deg, xc, yc, r, false);

        //System.println( sunrise_events[:SUNRISE][0] + " " +sunrise_events[:HORIZON_AM][0] + " " + sunrise_events[:NOON][0] + " " + sunrise_events[:SUNSET][0]+ " " +  sunrise_events[:HORIZON_PM][0] + " " + sunrise_events[:DUSK][0] + " " + sunrise_events[:DAWN][0] );
        drawARC (dc, sunrise_events[:SUNRISE][0] + noon_adj_hrs, sunrise_events[:SUNSET][0]+ noon_adj_hrs, xc, yc, r, 6, Graphics.COLOR_WHITE);
        //NOON mark
        drawARC (dc, sunrise_events[:NOON][0]-0.1+ noon_adj_hrs, sunrise_events[:NOON][0]+0.1+ noon_adj_hrs, xc, yc, r, 10, Graphics.COLOR_WHITE);
        //MIDNIGHT mark
        drawARC (dc, sunrise_events[:NOON][0]-0.05+ noon_adj_hrs +  12, sunrise_events[:NOON][0]+0.05+ noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE);
        drawARC (dc, sunrise_events[:DAWN][0]+ noon_adj_hrs, sunrise_events[:SUNRISE][0]+ noon_adj_hrs, xc, yc, r, 4,Graphics.COLOR_LT_GRAY);
        drawARC (dc, sunrise_events[:SUNSET][0]+ noon_adj_hrs, sunrise_events[:DUSK][0]+ noon_adj_hrs, xc, yc, r, 4,Graphics.COLOR_LT_GRAY);
        drawARC (dc, sunrise_events[:ASTRO_DAWN][0]+ noon_adj_hrs, sunrise_events[:DAWN][0]+ noon_adj_hrs, xc, yc, r, 2,Graphics.COLOR_DK_GRAY);
        drawARC (dc, sunrise_events[:DUSK][0]+ noon_adj_hrs, sunrise_events[:ASTRO_DUSK][0]+ noon_adj_hrs, xc, yc, r, 2,Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(1);
        */

        //System.println("se2 - horizon:" + sunrise_events2);
        //deBug("nhorizon: ", [noon_adj_deg, hour_adj_deg, noon_adj_hrs, xc, yc, r]);
        //Draws horizon & meridian, per time of day
        //drawHorizon(dc, sunrise_events2[:HORIZON][1], noon_adj_deg, hour_adj_deg - noon_adj_deg, xc, yc, r, false);

        //drawHorizon(dc, sunrise_events2[:HORIZON][1], noon_adj_deg, hour_adj_deg + noon_adj_deg, xc, yc, r, false);
        
        //drawHorizon3(dc, sunrise_events2[:HORIZON][1], noon_adj_deg, hour_adj_deg + noon_adj_deg, sunrise_events2["Ecliptic270"][1], pp["Sun"][0], xc, yc, r);

        //drawHorizon3(dc, sunrise_events2[:HORIZON][1], noon_adj_deg, hour_adj_deg + noon_adj_deg, sunrise_events2["Ecliptic270"][1], pp["Sun"][0], xc, yc, r);

        drawHorizon4(dc, xc, yc, r);

        /*
        drawHorizon4(dc, now_info,  $.now.timeZoneOffset, $.now.dst, time_add_hrs, xc, yc, r, false); */

        //drawHorizon3(dc, horizon_pm as Lang.float, noon_adj_dg as Lang.float, win_sol_eve_hr as Lang.float, xct as Lang.float, yct as Lang.float, radius as Lang.float, drawCircle)

        //System.println( sunrise_events[:SUNRISE][0] + " " +sunrise_events[:HORIZON_AM][0] + " " + sunrise_events[:NOON][0] + " " + sunrise_events[:SUNSET][0]+ " " +  sunrise_events[:HORIZON_PM][0] + " " + sunrise_events[:DUSK][0] + " " + sunrise_events[:DAWN][0] );

        //deBug("sunrise_events2: ", [sunrise_events2[:SUNRISE][0] + noon_adj_hrs, sunrise_events2[:SUNRISE][1]+ noon_adj_hrs, 12-(sunrise_events2[:SUNRISE][0] + noon_adj_hrs), (sunrise_events2[:SUNRISE][1] + noon_adj_hrs) - 12] );


        //deBug("sunrise_events23T][1]+ noon_adj_hrs, 12-(sunrise_events2[:SUNRISE][0] + noon_adj_hrs), (sunrise_events2[:SUNRISE][1] + noon_adj_hrs) - 12] );

        //deBug ("sunrise_events2", [ noon_adj_hrs, sunrise_events2[:NOON][0] + noon_adj_hrs, sunrise_events2[:SUNRISE][0] + noon_adj_hrs, sunrise_events2[:SUNRISE][1] + noon_adj_hrs, sunrise_events2[:NOON][0]- sunrise_events2[:SUNRISE][0], sunrise_events2[:SUNRISE][1] - sunrise_events2[:NOON][0], sunrise_events2[:NOON][0]]);
        //deBug("sr2:", sunrise_events2);

        if (sunrise_events2 != null ) {

            if (sunrise_events2[:SUNRISE] != null) {drawARC (dc, sunrise_events2[:SUNRISE][0] + noon_adj_hrs, sunrise_events2[:SUNRISE][1]+ noon_adj_hrs, xc, yc, r, 6, Graphics.COLOR_WHITE); }

            //NOON mark
            if (sunrise_events2[:NOON] != null) {drawARC (dc, sunrise_events2[:NOON][0]-0.1+ noon_adj_hrs, sunrise_events2[:NOON][0]+0.1+ noon_adj_hrs, xc, yc, r, 10, Graphics.COLOR_WHITE); }
            
            //MIDNIGHT mark
            if (sunrise_events2[:NOON] != null) {drawARC (dc, sunrise_events2[:NOON][0]-0.05+ noon_adj_hrs +  12, sunrise_events2[:NOON][0]+0.05+ noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE); }

            //if (sunrise_events2[:SUNRISE] != null && sunrise_events2[:DAWN] != null) {}

            if (sunrise_events2[:SUNRISE] != null && sunrise_events2[:DAWN] != null &&
               (sunrise_events2[:DAWN][1]- sunrise_events2[:DAWN][0]).abs()>0.01) 
            {
                drawARC (dc, sunrise_events2[:SUNRISE][1]+ noon_adj_hrs, sunrise_events2[:DAWN][1]+ noon_adj_hrs, xc, yc, r, 4,Graphics.COLOR_LT_GRAY); 
                drawARC (dc, sunrise_events2[:DAWN][0]+ noon_adj_hrs, sunrise_events2[:SUNRISE][0]+ noon_adj_hrs, xc, yc, r, 4,Graphics.COLOR_LT_GRAY); 
            }

            if (sunrise_events2[:ASTRO_DAWN] != null && sunrise_events2[:DAWN] != null
               && (sunrise_events2[:ASTRO_DAWN][1]- sunrise_events2[:ASTRO_DAWN][0]).abs()>0.01) 
            {
                drawARC (dc, sunrise_events2[:ASTRO_DAWN][0]+ noon_adj_hrs, sunrise_events2[:DAWN][0]+ noon_adj_hrs, xc, yc, r, 2,Graphics.COLOR_DK_GRAY); 
            
                drawARC (dc, sunrise_events2[:DAWN][1]+ noon_adj_hrs, sunrise_events2[:ASTRO_DAWN][1]+ noon_adj_hrs, xc, yc, r, 2,Graphics.COLOR_DK_GRAY); 
            }
        
            dc.setPenWidth(1);
        }

        //sunrise_events2=null;

        //sun_adj_deg = (270 - pp["Sun"][0]);// 
        /*
        var rise_hour_adj_deg = f.normalize( 15.0 * sunrise_events2[:SUNRISE][0])* sidereal_to_solar;
        var re = f.mod (sunrise_events2[:SUNRISE][2] - sun_adj_deg/15.0 + rise_hour_adj_deg/15.0 - noon_adj_deg/15.0,24.0);
        var set_hour_adj_deg = f.normalize( 15.0 * sunrise_events2[:SUNRISE][1])* sidereal_to_solar;
        var se = f.mod (sunrise_events2[:SUNRISE][3] - sun_adj_deg/15.0 + set_hour_adj_deg/15.0 - noon_adj_deg/15.0,24.0);

        deBug("RESE: ", [re,se]);

        drawARC (dc, re , se, xc, yc, r, 6, Graphics.COLOR_WHITE);
        */

/*
        drawARC (dc, sunrise_events2[:SUNRISE][0] - noon_adj_hrs, sunrise_events2[:SUNRISE][1] - noon_adj_hrs, xc, yc, r, 6, Graphics.COLOR_WHITE);
        //NOON mark
        drawARC (dc, sunrise_events2[:NOON]-0.1- noon_adj_hrs, sunrise_events2[:NOON]+0.1 - noon_adj_hrs, xc, yc, r, 10, Graphics.COLOR_WHITE);
        //MIDNIGHT mark
        drawARC (dc, sunrise_events2[:NOON]-0.05- noon_adj_hrs +  12, sunrise_events2[:NOON]+0.05 - noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE);
        drawARC (dc, sunrise_events2[:DAWN][0]- noon_adj_hrs, sunrise_events2[:SUNRISE][0]- noon_adj_hrs, xc, yc, r, 4,Graphics.COLOR_LT_GRAY);
        drawARC (dc, sunrise_events2[:SUNRISE][1]- noon_adj_hrs, sunrise_events2[:DAWN][1]- noon_adj_hrs, xc, yc, r, 4,Graphics.COLOR_LT_GRAY);
        drawARC (dc, sunrise_events2[:ASTRO_DAWN][0]- noon_adj_hrs, sunrise_events2[:DAWN][0]- noon_adj_hrs, xc, yc, r, 2,Graphics.COLOR_DK_GRAY);
        drawARC (dc, sunrise_events2[:DAWN][1]- noon_adj_hrs, sunrise_events2[:ASTRO_DAWN][1]- noon_adj_hrs, xc, yc, r, 2,Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(1);

*/
            if (do_calc) {

            //&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
            //MOOOOON&&&&&&&&&&&&&&&&&&&&&&&&&&&
            var sm = new simpleMoon();
            moon_info3 = sm.eclipticPos_moon ($.now_info, $.now.timeZoneOffset, $.now.dst, 0); 
            sm = null;

            
            pp.put("Moon", [moon_info3[0]]);
            moon_info3 = null;

            //moon_age_deg = f.normalize (equatorialLong2eclipticLong_deg(pp["Moon"][0], obliq_deg) - equatorialLong2eclipticLong_deg(pp["Sun"][0], obliq_deg)); //0-360 with 0 being new moon, 90 1st q, 180 full, 270 last q
            //deBug("PP:", pp);
            moon_age_deg = f.normalize ((pp["Moon"][0]) - (pp["Sun"][0])); //0-360 with 0 being new moon, 90 1st q, 180 full, 270 last q
        

        }
        
        
        
        //sid = $.now_info.hour*15 + $.now_info.min*15/60; //approx.....

        
        //sid = sunrise_events[SIDEREAL_TIME][0] * 15;
        //sid = srs.siderealTime($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst, lastLoc[0], lastLoc[1]);        

        //srs = null;

        //System.println("SID approx " + sid_old + "SIDEREAL_TIME" + sid + "daily: " + sunrise_events[SIDEREAL_TIME][0]);

        sid = 0;
        
        eclipticSizeFactor = 1.0;
        planetSizeFactor = 1.75;
        if ( $.Options_Dict[planetSizeS]) {planetSizeFactor = 0.95;}    
        else if ( $.Options_Dict[planetSizeL] ) { planetSizeFactor = 2.5;}
        if (planetSizeFactor> 2.0) {eclipticSizeFactor = .9; }
        else if (planetSizeFactor>= 1.5) {eclipticSizeFactor = .95; }

        //sid = 5.5*15;
        init_findSpot();
        for (var i = 0; i<whh.size(); i++) {
        //for (var i = 0; i<kys.size(); i++) {            

            //key = kys[i];
            key = whh[i];
            //System.println ("kys: " + key + " " + key1);
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}
            if (pp[key] == null) {continue;}

            //&&&&&&&&&&&&&&&&&&&&&&&&
            //ang_deg =  -pp[key][0] - final_adj_deg;
            //ang_rad = Math.toRadians(ang_deg);
            var sr = new srs();
            ang_rad =  -sr.equatorialLong2eclipticLong_rad(Math.toRadians(pp[key][0]) , Math.toRadians(obliq_deg)) - final_adj_rad;
            sr = null;

            //var ang_rad2 = -Math.toRadians(pp[key][0]) - final_adj_rad;

            //System.println  ("key: " + key + " ang_rad: " + Math.toDegrees(ang_rad) + " " + f.mod(ang_rad/2.0/Math.PI*24,24.0) + " " +  Math.toDegrees(ang_rad2) + " " + f.mod(ang_rad2/2.0/Math.PI*24,24.0));
            
            x = r* Math.cos(ang_rad) + xc;
            y = r* Math.sin(ang_rad) + yc;
                    //array is:  [x,y,z, radius (of orbit)]
            drawPlanet(dc, key, [x, y,0, r], 2, ang_rad, :ecliptic, null, null);   
            
        }

        if ($.show_intvl < 5 * $.hz && $.view_mode != 0) {
            showDate(dc, $.now_info, $.time_now, 0, xc, yc, true, true, :ecliptic_latlon);
            $.show_intvl++;
        } else {
            showDate(dc, $.now_info, $.time_now, 0, xc, yc, true, false, :ecliptic_latlon);
        }
        /*
        pp=null;
        pp_sun = null;
        //kys =  null;
        //keys = null;
        srs = null;
        sunrise_events  = null;
        sunrise_events2 = null;
        whh = null;
        whh_sun = null;
        spots = null;
        */

    }
    
    /*
    var x1, y1;

    var scale = 1;
    
    
    //big_small = 0 for small (selectio nof visible planets) & 1 for big (all planets)
    public function largeOrrery(dc, big_small) {
         //deBug("RDSWC2: ", allPlanets);
         var zoom_whh, whh;
         // Set background color
         $.orreryDraws++;


        
        //if (LORR_orient_horizon || 
            ((LORR_oh_save_time_add_hrs - time_add_hrs).toNumber()%24 == 0 ) 
              && LORR_oh_save_ga_rad == ga_rad) {

        if (LORR_orient_horizon)
        {
            //tells large_orrery to orient the graph so earth's horizon is horizontal & meridian is UP in the viewpoint.  which we do only the first time LORR is run.

            pp = planetCoord ($.now_info, $.now.timeZoneOffset, $.now.dst, 0, :ecliptic_latlon, ["Sun"]);
            //LORR_oh_save_time_add_hrs = time_add_hrs;

            

            sunriseHelper();  //gets the orientation/angle toward sun @ local noon, then adds in the current hr of the day so we can use it to orient the entire graph so that UP is the direction of the local curren meridian when they first look at it.
            ga_rad = Math.toRadians(sun_adj_deg-hour_adj_deg) ;
            sunrise_events2=null;
            //LORR_oh_save_ga_rad = ga_rad;
            //ga_rad = 0;

            //System.println("sun_adj_deg" + sun_adj_deg + " hor" + hour_adj_deg + " ga " + ga_rad + " pp " + pp["Sun"]) ;

            //sunrise_cache.empty();  //this works good but not using it now

            
         
        }
        // else {
        //    LORR_oh_save_time_add_hrs = 0.158348;// some random #
        //    LORR_oh_save_ga_rad = 25.158348;
        //}
        LORR_orient_horizon = false;

         //th += Math.PI/240;
         //ga_rad += Math.PI/240;

        //don't need these caches in the Orrery view & we are having out of memory
        //errors at times here....
        //geo_cache.empty();
        
        pp= null;

        //dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        //dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        //getMessage();

        
        //setPosition(Position.getInfo());
        //xc = dc.getWidth() / 2;
        //yc = dc.getHeight() / 2;
   
        r = (xc < yc) ? xc : yc;
        r = .9 * r;

        //deBug("RDSWC3: ", allPlanets);

        font = Graphics.FONT_TINY;
        textHeight = dc.getFontHeight(font);
        /*
        y -= (_lines.size() * textHeight) / 2;
        //dc.drawText(x, y+50, Graphics.FONT_SMALL, "Get Lost", Graphics.TEXT_JUSTIFY_CENTER);
        for (var i = 0; i < _lines.size(); ++i) {
            dc.drawText(x, y, Graphics.FONT_TINY, _lines[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += textHeight;
        }
        //dc.drawText(x, y-50, Graphics.FONT_SMALL, "Bug Off", Graphics.TEXT_JUSTIFY_CENTER);
        */
        /*

        //planetnames = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"];
        
        //whh_sun  = ["Sun"];
        //var small_whh = ["Sun","Mercury","Venus","Earth", "Mars", "Ceres"];
        //var small_whh = ["Sun","Mercury","Venus","Earth", "Moon", "Mars", "AsteroidA", "AsteroidB"];
        //var full_whh =  ["Sun", "Mercury","Venus","Earth", "Mars", "AsteroidA", "AsteroidB", "Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris", "Gonggong","Quaoar", "Makemake", "Haumea"];
        //whh = full_whh; //new way, now we have zoom
        //whh = planetsOption_values[planetsOption_value];
        whh = makePlanetsOpt(planetsOption_value);
        
        //zoom_whh = small_whh;
        var aP = allPlanets;
        zoom_whh = aP.slice(0,8);
        //deBug ("www - zoom_whh", zoom_whh);
        //deBug("www - zoom_whh slice 0-8 sourcecopy", aP);
        //deBug("www - zoom_whh slice 0-8 source", allPlanets);
        if (big_small == 1) {
             //whh = ["Sun","Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron"]; 
             //zoom_whh = ["Sun","Mercury","Venus","Earth", "Mars", "AsteroidA", "AsteroidB", "Ceres","Jupiter","Saturn","Uranus","Neptune"]; 
             //zoom_whh = zoomy_whh;
             zoom_whh = (aP.slice(0,4));
             zoom_whh.addAll(aP.slice(5,14)) ;
             //zoom_whh.add (aP[13]);
             //deBug ("www - zoomy_whh", zoom_whh);
             //deBug("www - zoom_whh slice 0-4, 5-12, 13 - source copy", aP);
             //deBug("www - zoom_whh slice 0-8 source", allPlanets);
        }
        if (big_small == 2) {
             //whh = ["Sun","Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron"]; 
             //whh = ["Mercury","Venus","Earth","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris"]; 
             //zoom_whh = ["Sun", "Mercury","Venus","Mars","Jupiter","Saturn","Uranus","Neptune","Pluto","Ceres","Chiron","Eris", "Gonggong"];
             //zoom_whh = full_whh;
             zoom_whh = aP;
             //deBug ("www - zoom_whh", zoom_whh);
             //deBug("www - zoom_whh full - source copy", aP);
             //deBug("www - zoom_whh slice 0-8 source", allPlanets);
        }

        aP = null;
        

        //deBug("RDSWC4: ", allPlanets);

        //add_duration = new Time.Duration($.time_add_hrs*3600);
        //System.println("View Rectangular:" + add_duration + " " + $.time_add_hrs);

        //now = System.getClockTime();
        //var $.now_info = Time.Gregorian.info(Time.now().add(add_duration), Time.FORMAT_SHORT);
        //var $.time_now = Time.now();
        //var $.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);



        //System.println("View Rectangular:" + $.now_info.year + " " + $.now_info.month + " " + $.now_info.day + " " + $.now_info.hour + " " + $.now_info.min + " " + $.now.timeZoneOffset/3600 + " " + $.now.dst);
        //g = new Heliocentric($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour, $.now_info.min, $.now.timeZoneOffset/3600, $.now.dst,"rectangular", whh);

        //System.println( "NOw: " + $.now_info + " " +$.now.timeZoneOffset + " " +$.now.dst + " " +time_add_hrs);

     

        

        //pp=g.planets();
        //vspo87a = new vsop87a_pico();
        //pp = vspo87a.planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst, :helio_xyz);
        //pp = vsop_cache.fetch($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs, :helio_xyz);
        //deBug("RDSWC6: ", allPlanets);
        //We shouldn't use the CACHE here bec. we can't use the little trick of 
        //adding hours to rotate around by 360deg for the day anyway...

        zoom_whh = intersect_array(zoom_whh, whh); //only calculate the planets in this view AND selected in settings; keeping the others just makes it too slow
        pp = planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs, :helio_xyz, zoom_whh);
        //calc_whh = null;

        //vspo87a = null;

        //deBug("RDSWC7: ", allPlanets);
        
        //g = null;
        //pp.put("Sun",[0,0,0]);
        kys = pp.keys();

        //System.println("planets: " + pp);
        //System.println("planets keys: " + kys);
        //System.println("whh: " + whh);




        //g = new Geocentric($.now_info.year, $.now_info.month, $.now_info.day, 0, 0, $.now.timeZoneOffset/3600, $.now.dst,"ecliptic", whh_sun);

        //pp_sun = g.position();

        //This puts our midnight sun @ the bottom of the graph; everything else relative to it
        //sun_adj_deg = 270 - pp_sun["Sun"][0];
        //hour_adj_deg = $.now_info.hour*15 + $.now_info.min*15/60;
        //final_adj_deg = sun_adj_deg - hour_adj_deg;

        //System.println("pp_sun:" + pp_sun);
        //System.println("sun_a:" + sun_adj_deg + " hour_ad " + hour_adj_deg + "final_a " + final_adj_deg);


        //*********** SET SCALE/ZOOM LEVEL****************
        var max =0.00001;        
        
        for (var i = 0; i<zoom_whh.size(); i++) {
            key = zoom_whh[i];
            if (whh.indexOf(key)<0) {continue;} //in case dwarf planet/asteroids eliminated by ***planetsOption***
            //System.println("KEY whh: " + key);
            if (pp[key] == null) {continue;}
            var rd = pp[key][0]*pp[key][0]+pp[key][1]*pp[key][1]
               + pp[key][2]*pp[key][2];
            if (rd> max) {max = rd;}
            //System.println("MM: " + key + " " + pp[key][0] + " " + pp[key][1] + " " + rd);
            //if ((pp[key][0]).abs() > maxX) { maxX = (pp[key][0]).abs();}
            //if ((pp[key][1]).abs() > maxY) { maxY = (pp[key][1]).abs();}
        }

        //deBug("RDSWC8: ", allPlanets);

        if (zoom_whh.indexOf("Moon")>-1 && zoom_whh.indexOf("Earth")>-1) {
            //simple_moon = new simpleMoon();

            //eclip lon/lat of moon, in degrees.  Relative to earth.
            moon_info3 = eclipticPos_moon ($.now_info, $.now.timeZoneOffset, $.now.dst, time_add_hrs); 
            //sun_info3 =  simple_moon.eclipticSunPos ($.now_info, $.now.timeZoneOffset, $.now.dst); 
            //simple_moon = null;
            //var ang = Math.arctan2(-x,y);

            var ang_rad = Math.toRadians(moon_info3[0]); //change to screen coord system (270-theta) then to rads
            //var radius_au = 0.002569;//au, is it 384,399km ; ok, that doesn't work

            var radius_au = 0.11; //WAG , was .07, really nds to be see per earth size as drawn...

            var xm=Math.cos ( ang_rad) * radius_au + pp["Earth"][0];
            var ym=Math.sin ( ang_rad) * radius_au + pp["Earth"][1];

            pp.put("Moon", [xm,ym,pp["Earth"][2]]);
            kys.add("Moon");

        }
        //deBug("RDSWC9: ", allPlanets);
        var distA = big_small==0 ? 2.2 : 3.2; //Asteroid belt varies 2.2-3.2 AU but it will look better closer to 2.2 in closeups & 3.2 for large views
        
        //pp.put ("AsteroidA", [2.7,0,0]);
        //pp.put ("AsteroidB", [0,2.7,0]);
        pp.put ("AsteroidA", [distA,0,0]);
        pp.put ("AsteroidB", [0,distA,0]);
        kys.add("AsteroidA");
        kys.add("AsteroidB");

        //reset screen when changing speed, but ONLY if the setting requires it (resetDots)
        //var showWithSpeedChange = false;
        //if ($.Options_Dict["resetDots"] == 1 && $.speedWasChanged ) {showWithSpeedChange = true;}
        //if ($.speedWasChanged ) {showWithSpeedChange = true;}
        //System.println("RDSWC: " +$.Options_Dict["resetDots"] + " " + showWithSpeedChange + " " + $.newModeOrZoom );
        //deBug("RDSWC10: ", allPlanets);
        //Things we do ONLY WHEN FIRST STARTING OUT IN THIS MODE & ZOOM LEVEL
        //if ($.newModeOrZoom || showWithSpeedChange) {//gives signal to reset the dots 
        if ($.newModeOrZoom || $.speedWasChanged ) {//gives signal to reset the dots 
            //var oldscale = scale;
                //System.println("RDSWC - new scale & targetDc: "  + $.speedWasChanged + " " + $.newModeOrZoom );
            
                scale = (min_c*0.85*eclipticSizeFactor)/Math.sqrt(max) * $.orrZoomOption_values[$.Options_Dict[orrZoomOption_enum]] ;  
                asteroidsRendered = false;

            //must clear screen if scale has changed, otherwise clear it per resetDots setting
            

                if (null != _offscreenBuffer) {
                    targetDc = _offscreenBuffer.getDc();                      
                    targetDc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
                    targetDc.clear();        
                    targetDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    targetDc = null;
                    //System.println ("Using offscreenBUFFER");

                } else {
                    targetDc = dc;
                    //System.println ("NOTTTTT Using offscreenBUFFER");
                }
            
            $.newModeOrZoom = false;
            $.speedWasChanged = false;
        }
        
        //deBug("RDSWC11: ", allPlanets);
        //}

        //if (animSinceModeChange <= 1) {
         //targetDc.fillRectangle(0, 0, targetDc.getWidth(), targetDc.getHeight());
         //don't change scale it messes w/"trail" points of planets

        

        /*if ($.orreryDraws == 1) {
            allOrbitParms = generateAllParms($.now_info, time_add_hrs, full_whh, pp);
            System.println("allorbit: " + allOrbitParms);
        } */




        /*if ($.show_intvl > -1) {
            //drawOrbits(dc, allOrbitParms[0], scale, xc, yc, big_small, whh, small_whh, Graphics.COLOR_WHITE); 
            //drawOrbits2(dc, scale, xc, yc, big_small, whh, small_whh, Graphics.COLOR_WHITE); 
            } */

            //var tDc = dc;
            //if (big_small == 3) {tDc = targetDc;}
        //var mx = Math.sqrt(max);    

        //System.println(" ga th " + ga_rad + " " + the_rad);
        /*
        
        if (ga_rad.abs()>.001 || the_rad.abs() > 0.001) {

            //var oblecl=  obliquityEcliptic_rad ($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour + time_add_hrs, 0, 0, 0);

            var oblecl = Math.toRadians( f.calc_obliq_deg ($.now_info, $.now));
            
            var mcob = Math.cos(oblecl);
            var msob = Math.sin(oblecl);
            var mcgr = Math.cos(ga_rad);
            var msgr = Math.sin(ga_rad);
            var mctr = Math.cos(the_rad);
            var mstr = Math.sin(the_rad);

            //var min_z = 10000000.0f;
            //var max_z = -10000000.0f;
            //var sorter = new [1001];

            for (var i = 0; i<kys.size(); i++) {
                key = kys[i];

                var aster = false;
                if (key.equals("AsteroidA") || key.equals("AsteroidB")) { aster = true;}
                //System.println("ga th: " + ga_rad + " " + the_rad) ;
                //System.println("XYZ PERS: " + key + pp[key]);

                //First we have t ocorrect for the obliquity of the ecliptic
                //which makes the plan of the solar system at a "tilt" to
                //the equatorial coordinates.

                if (aster) {  //asteroid belt, our points represent two points, which we DON'T want to correct for ecliptic (bec. it is already on that plane) and we DON'T want to rotate around Z axis (bec. we want points on the X & Y axis in the final result, for ease of ellipse drawing).
                    y0 = pp[key][1];
                    z0 = pp[key][2];
                    x1 = pp[key][0];
                    y1 = y0;

                }
                else {
                    z0 = pp[key][2] * mcob - pp[key][1] * msob;
                    y0 = pp[key][1] * mcob + pp[key][2] * msob;
                    
                    x1 = pp[key][0] * mcgr - y0 *msgr;
                    y1 = y0 *mcgr + pp[key][0] * msgr;
                    
                }
                //x1 = x;

                y2 = y1 * mctr - z0* mstr;
                var z2 = y1 *mstr + pp[key][2] * mctr;
                //y2 = y1;
                //var pers_fact = (5*mx + (z2+ mx)/2)/6.0/mx;
                pp[key][0] = x1;// *pers_fact;
                pp[key][1] = y2;// * pers_fact; // * pers_fact;
                pp[key][2] = z2;  
                //var z_sort = (Math.floor(z2 * 50).toNumber()) + 500;
                //if (z_sort>1000) {z_sort=1000;}
                //if (z_sort<0) {z_sort=0;}
                
                //if (sorter[z_sort] == null) {sorter[z_sort] = [key];}
                //else {sorter[z_sort].add(key);}
                //if (z2<min_z) {min_z = z2;}
                //if (z2> max_z) {max_z = z2;}
                
                //System.println("XYZ' PERS: " + x2 + " " + y1 + " " );
            }
            //System.println("whhbefore: " + whh);
            //deBug("RDSWC11A: ", allPlanets);
            //deBug("RDSWC11Awhh: ", whh);

            //We need to sort by Z values but if the_rad is close to 0 deg or 180 deg we can skip it
            var trmpi = f.mod(the_rad, Math.PI);
            if (trmpi > Math.PI/4.0 && trmpi < 3* Math.PI/4.0) {
                //zoom_whh = insertionSort(zoom_whh, pp, 2);
                zoom_whh = quickSort(zoom_whh, pp, 2); //was slower than insertion sort.  But on a second try, faster.  Both are probably about the same, sometimes one is better, sometimes the other.
                
                /*zoom_whh = [];
                for (var j = 0; j < sorter.size(); j++) {
                    if (sorter[j]!= null) {
                        zoom_whh.addAll(sorter[j]);
                    }
                }*/
                /*
            }
            
            //zoom_whh = countingSort(zoom_whh, pp, 3, Math.floor(min_z * 10).toNumber(), Math.floor(max_z * 10).toNumber()); //didnt' really work out
            
            //deBug("RDSWC11B: ", allPlanets);
            //deBug("RDSWC11Bwhh: ", whh);
            //System.println("whhafter: " + whh);
        }
        
        
        //deBug("RDSWC12: ", allPlanets);

        //*************** PLANET TRACKS **********************************    

        //System.println ("nearly to drawOrbits3");
        //if ($.Options_Dict["Orbit Circles Option"]==0 ) {

       

            //System.println ("going to drawOrbits3 " + dc + " " + targetDc + " " + (dc==targetDc));
            //targetDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

            if (_offscreenBuffer == null) {
                //for SOME REASON just setting targetDc = dc DOESN"T WORK !!!!??!?!?!?!??!
                drawOrbits3(dc, pp, scale, xc, yc, big_small, zoom_whh, Graphics.COLOR_WHITE); 
            } else {      
                targetDc = _offscreenBuffer.getDc();      
                drawOrbits3(targetDc, pp, scale, xc, yc, big_small, zoom_whh, Graphics.COLOR_WHITE);

                //DRAW THE ASTEROID BELT
                if (!asteroidsRendered) {
                                        
                    //targetDc.setPenWidth(1);
                    //targetDc.drawEllipse (xc,yc, pp["AsteroidA"][0].abs() * scale, pp["AsteroidB"][1].abs() * scale );        
                    drawFuzzyEllipse (targetDc,screenWidth, screenHeight, xc,yc, pp["AsteroidA"][0].abs() * scale, pp["AsteroidB"][1].abs() * scale); // ,:high 
                    asteroidsRendered = true;
                } 
                /*else {
                     //targetDc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);                    
                    //targetDc.setPenWidth(1);
                    if (Math.rand()%2 == 0) {
                        targetDc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                    }
                    drawFuzzyEllipse (targetDc,screenWidth, screenHeight, xc,yc, pp["AsteroidA"][0].abs() * scale, pp["AsteroidB"][1].abs() * scale, :low );
                    asteroidsRendered = true;

                }*/
                /*
                //Sooo .  . . bitmap2 disallows use of palette in the _offscreenbuffer
                //and so isntead of SMALL 2 bit it is very large & overflows memory.
                //figure it out....
                if (dc has :drawBitmap2) {
                    var opt = {
                    //:bitmapX => 0,
                    //:bitmapY => 0,
                    //:bitmapWidth => dc.getWidth(),
                    //:bitmapHeight => dc.getHeight(),
                    :tintColor => Graphics.COLOR_LT_GRAY,
                    //:filterMode => Graphics.FILTER_MODE_POINT,
                    //:transform => trans,
                    
                        };
                    dc.drawBitmap2(0,0,_offscreenBuffer, opt);

                } else { */
                /*

                    dc.drawBitmap(0, 0, _offscreenBuffer);
                
                //drawBitmap2(x as Lang.Numeric, y as Lang.Numeric, bitmap as Graphics.BitmapType, options as { :bitmapX as Lang.Number, :bitmapY as Lang.Number, :bitmapWidth as Lang.Number, :bitmapHeight as Lang.Number, :tintColor as Graphics.ColorType, :filterMode as Graphics.FilterMode, :transform as Graphics.AffineTransform } or Null) 
                /*
                var trans = new  Graphics.AffineTransform ();
                trans.setToTranslation(xc,yc);
                //trans.rotate(.4);

                trans.translate(-xc,-yc);
                //trans.shear(.01, .02);
                var opt = {
                    :bitmapX => 0,
                    :bitmapY => 0,
                    :bitmapWidth => dc.getWidth(),
                    :bitmapHeight => dc.getHeight(),
                    :tintColor => Graphics.COLOR_LT_GRAY,
                    :filterMode => Graphics.FILTER_MODE_POINT,
                    :transform => trans,
                    
                    };
                dc.drawBitmap2(0,0,_offscreenBuffer, opt);
                */
                /*

                targetDc = null;
                
            }
        
            //deBug("RDSWC13: ", allPlanets);
            
            
            /*if (null != _offscreenBuffer) {
                
                //System.println ("Using offscreenBUFFER");
            }*/ 
        //}

        //System.println("MM2: " + min_c + " " + scale + " " + max + " ");

        //drawEllipse(x as Lang.Numeric, y as Lang.Numeric, a as Lang.Numeric, b as Lang.Numeric) as Void
        
        /*
        //sid = 5.5*15;
        init_findSpotRect();
        LORR_horizon_line_drawn = false;
        //System.println("kys whh " + kys + " \n" + whh);
        for (var i = 0; i<zoom_whh.size(); i++) {
        //for (var i = 0; i<kys.size(); i++) {

            //key1 = kys[i];
            key = zoom_whh[i];
            //System.println ("kys: " + key + " " + key1);
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}
            if (key == null || pp[key] == null) {continue;} //not much else to do...
            //if (key1 == null || pp[key1] == null) {continue;} //not much else to do...



            x = scale * pp[key][0] + xc;
            
            y = scale * pp[key][1] + yc;

            var z = scale * pp[key][2];



            var radius = Math.sqrt(pp[key][0]*pp[key][0] + pp[key][1]*pp[key][1] 
                + pp[key][2]*pp[key][2])*scale;

            //Draw the circle of the Orbit
            //TODO: Approximate the elliptical orbit & draw it somehow
            //dc.setColor(orbitCirclesOption_values[$.Options_Dict["Orbit Circles Option"]], Graphics.COLOR_TRANSPARENT);
            //dc.drawCircle(xc, yc, radius);
            
            //save some by not drawing if very close to sun.  Would save more
            //by not even calcing their position, somehow...
            //System.println("key12: " + key);
            if (
                  (    (radius > 0.11 * min_c && x < 1.1 * screenWidth && y < 1.1 * screenHeight && x> -0.1 * screenHeight && y > -0.1 * screenWidth) 
                    || key.equals("Sun") || key.equals("Earth")
                  ) && (
                    !key.equals("AsteroidA")  && !key.equals("AsteroidB") 
                  ) 
                ) {            
                fillSpotRect(x,y);//try to avoid putting labels on top of a planet
                drawPlanet(dc, key, [x, y, z, radius], 4, ang_rad, :orrery, big_small, small_whh);
                
            }

            //if (key.equals("Earth")) {drawHorizon(dc, 0, 0, 0, x, y, xc, true);}

            
            
            
            /*
            size = 2;
            if (key.equals("Sun")) {size = 8;}
            switch (key) {
                case "Mercury":
                    size = 2;
                    break;
                case "Venus":
                    size =4;
                    break;

                case "Mars":
                    size =3;
                    break;
                case "Saturn":
                    size =5;
                    break;
                case "Jupiter":
                    size =6;
                    break;
            }

            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
            dc.fillCircle(x, y, size);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(x, y, size);
            if (key.equals("Sun") ) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, size);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }

            

            if (key.equals("Venus")) {
                dc.fillCircle(x, y, size);
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);        
                dc.fillCircle(x, y, 1);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
            }

            if (!key.equals("Sun") && (big_small==0 || small_whh.indexOf(key)==-1))  {
                sub = findSpot(-pp[key][0]+sid);
                mult = 2 + sub;
                x2 = mult*8 + x;
                y2 = mult*8 + y;
                dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
            }

            */
            /*
        }

        if ( !LORR_horizon_line_drawn && LORR_show_horizon_line ) {
                drawDashedLine(dc, 0, yc+1, 2*xc, yc+1, 0, 3, 1, Graphics.COLOR_LT_GRAY);
                LORR_horizon_line_drawn = true;
        }

        if ($.show_intvl < 5 * $.hz ) { 
            showDate(dc, $.now_info, $.time_now, time_add_hrs,  xc, yc, true, true, :orrery);
            $.show_intvl++;}
            else {
                showDate(dc, $.now_info, $.time_now, time_add_hrs,  xc, yc, true, false, :orrery);
        }

        //deBug("RDSWC14: ", allPlanets);

        pp=null;
        pp_sun = null;
        kys =  null;
        keys = null;
        srs = null;
        sunrise_events  = null;
        whh = null;
        whh_sun = null;
        //g = null;
        spots_rect = null;

        //deBug("RDSWC15: ", allPlanets);


    }
    */

    var spots;    
    
    //VivoactiveHR and maybe some others don't have Lang.ByteArray
    (:hasByteArray)
    function init_findSpot(){
        //spots = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];            
            spots = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]b;
            //deBug("Byte spots", [spots]);

    }

    (:noByteArray)
    function init_findSpot(){
        //spots = [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];
        spots = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    }


    function findSpot (angle) {
        angle = f.normalize (angle);
        if (angle == 360) {angle =0;}
        var num = (Math.floor( angle * 13 / 360.0)).toNumber();
        //System.println("spot " + spots[num]);
        if (spots[num]<254) {spots[num]++;}
        return (spots[num]).toNumber() - 1 ;        

    }

    /*
    var sr_x =8f;
    var sr_y = 8f;
    var spots_rect; //0 = spot unoccupied, 1 = spot occupied
    var sr_xc = 4f;
    var sr_yc = 4f;
    var sr_minc = 4f;
    var diffy, diffx, sr_minc2;
    

    (:hasByteArray)
    function init_findSpotRect(){
        sr_minc2=sr_minc*sr_minc;
        spots_rect=new [sr_x];
        for (var i = 0; i<sr_x; i++) {
             var tmp = new [sr_y]b;        
            //spots_rect.add(tmp);
            for (var j = 0; j<sr_y; j++) {
                //spots_rect[i].add(0);
                var add=0;
                diffx = i-sr_xc;
                diffy = j-sr_yc;
                if ( diffx*diffx + diffy*diffy > sr_minc2){
                    add = 1; //occupied/don't write in corners of our circular display...
                }
                tmp[j]=(add);
            }
            spots_rect[i] = tmp;
        }
    }

    (:noByteArray)
    function init_findSpotRect(){
        sr_minc2=sr_minc*sr_minc;
        spots_rect=new [sr_x];
        for (var i = 0; i<sr_x; i++) {
             var tmp = new [sr_y];        
            //spots_rect.add(tmp);
            for (var j = 0; j<sr_y; j++) {
                //spots_rect[i].add(0);
                var add=0;
                diffx = i-sr_xc;
                diffy = j-sr_yc;
                if ( diffx*diffx + diffy*diffy > sr_minc2){
                    add = 1; //occupied/don't write in corners of our circular display...
                }
                tmp[j]=(add);
            }
            spots_rect[i] = tmp;
        }
    }



    function fillSpotRect (x,y){
        var x2 = Math.round(x/sr_x).toNumber();
        var y2 = Math.round(y/sr_y).toNumber();
        if (x2 >= sr_x || y2 >= sr_y || x2<0 || y2< 0) {return;}
        //System.println("FillsR: " + x2+ " " + y2+ " " + spots_rect);
        spots_rect[x2][y2] = 1;

    }
    function findSpotRect (x,y) {
        //x = x - textHeight/4; //
        //y = y - textHeight/2;
        var x2 = Math.round(x/sr_x).toNumber();
        var y2 = Math.round(y/sr_y).toNumber();
        var x_rem = x.toNumber()%sr_x.toNumber();
        var y_rem = y.toNumber()%sr_y.toNumber();
        
        for (var k = 1; k <4; k++) {
            for (var i = x2-k; i<x2+k; i++) {
                if (i<0 || i >= sr_x) {continue;}
                for (var j = y2-k; j<y2+k; j++) {
                    if (j<0 || j >= sr_y) {continue;}
                    if (spots_rect[i][j] == 0){
                        //spots_rect[i][j] = 1;
                        return findSpotRect_fix( [i*sr_x + x_rem, j*sr_y+ y_rem], [x,y]);
                    }
                }
            }
        }
        //more desperate attempt to find a place
        var xy_desp = new [2];
        //xy_desp[0]=new [2];
        //xy_desp[1]=new [2];
        var x_desp = new [2];
        var y_desp = new [2];
        xy_desp[0] = x_desp;
        xy_desp[1] = y_desp;
        xy_desp[0][0]= ( (x-xc)/xc * 2*xc/sr_x + x);
        xy_desp[1][0]=( (y-yc)/yc * 2*yc/sr_y + y);
        xy_desp[0][1]=( (x-xc)/xc * 2*xc/sr_x - x);
        xy_desp[1][1]=( (y-yc)/yc * 2*yc/sr_y - y);

        /*
        var xy_max = 0;
        var x_ret =0;
        var y_ret = 0;
        var x_try = 0;

        var y_try = 0;

        for (var i = 0; i<2; i++) {
            x_try = xy_desp[0][i];
            if (x_try == null) {x_try =1;} //for SOME REASON the compiler won't believe that x_try will be a number; thinks it's a NULL.  So it won't compile without this little trick.  Same for y_try.

            /* *** this part never worked for some reason
            for (var j = 0; j<2; j++) {
                y_try = xy_desp[1][j];
                if (y_try == null) {y_try =1;}
                //System.println("TRIES: " + x_try + " " + y_try);

                var sq = x_try*x_try + y_try*y_try;


                //var sq = xy_desp[0][i]*xy_desp[0][i] + xy_desp[1][j]*xy_desp[1][j];
                /*
                if ( sq <= min_c*min_c && sq>xy_max){
                    xy_max = sq;
                    x_ret = x_try;
                    y_ret = y_try;
                }
                */
            //}
            /*
        }
        if (xy_max > 0) {
            //fillSpotRect (x_ret,y_ret);
            return findSpotRect_fix([x_ret, y_ret], [x,y]);
        } 
        */
        /*

        //last resort
        return [x+xc/10.0, y + yc/10.0];
        


        

    }

    function findSpotRect_fix(xy_new, xy_orig){
        
        //System.println("FSR: " + xy_new + " " + xy_orig + " " + textheight);
        //if (xy_new[0] < xy_orig[0]) {xy_new[0] += textHeight/4.0; }
        //if (xy_new[1] < xy_orig[1]) {xy_new[1] += textHeight/2.0;}
        fillSpotRect(xy_new[0], xy_new[1]);
        return xy_new;


    }
    */
    /*
    var helpMSG_shownTimes = 0;
    var helpMSG_current = null;
    var helpMSGs = [
        "Start: Start or next scrn",
        "Back: Stop or prv scrn",
        "Up: Faster or fwd",
        "Down: Slower or bcwd",
        "Menu: Options & help",
        "Try Up Down or Start...",
    ];

    function helpMSG () {
        if (helpMSG_current != null && helpMSG_shownTimes < 5*$.hz) {
            helpMSG_shownTimes ++;
            return helpMSG_current;
        }
        helpMSG_current = helpMSGs[Math.rand()%helpMSGs.size()];
        helpMSG_shownTimes = 0;
        return helpMSG_current;

    }
    */
    var msgSaveButtonPress = 0;
    var msgDisplayed = false;
    var savedMSG_hash = null;
    var startTime = null;
    //shows msg & returns 0 = nothing displayed, 1 = normal msg displayed , 2 = special introductory msg displayed
    function showMessage(dc, jstify) {
        var msg = message;
        if ($.buttonPresses < 1) {
            //var intro_msg = f.toArray(WatchUi.loadResource($.Rez.Strings.introMessages) as String,  "|", 0);
            //var tp = intro_msg[0];
            /*
            if (!$.Options_Dict[smallerBanners]) {
                //making all timings 1/2 the rate because it is so much
                //slower on real watch vs simulator.  But needs a better solution involving actual clock time probably
                //$.Options_Dict[ret]
                if (startTime == null) {startTime = $.time_now.value();}
                //System.println("showM " + $.time_now.value() + " " + $.time_now.value()/(3) + " " + f.mod(75,7) + " : " + $.time_now.value()/(3)%7 + " :: " + f.mod($.time_now.value()/(3),7.0).toNumber() );

                //DISPLAY ALL THE INTRO MSGS - which are in strings.xml resource introMessages
                
                var switcher = ((($.time_now.value()-startTime)/3)%7);
                if (switcher == 6 || switcher == 0) {msg = [$.time_now.value() + 1," ", tp.substring(0,3),tp.substring(4,tp.length()), " ", " "];}  //"THE" "PLANETS" + jupiter image
                else {
                    msg = [$.time_now.value() + 1, tp," ", intro_msg[(switcher - 1) *3  +1 ],intro_msg[(switcher - 1) *3 +2], intro_msg[(switcher - 1) *3 +3]];
                }
                               
            } else 
            */

            /*if ( ($.time_now.value() - $.start_time_sec) < 4 ) {
                msg = [$.time_now.value() + 1, "THE", "PLANETS", " ", "Now..."];    
            } else {*/
                $.buttonPresses ++; //if we are in "no help banners" mode & the banner disappears, then we no longer want to trap that very first buttonpress
            //}
        }

        if (msg == null || !(msg instanceof Array) || msg.size() == 0) { msgDisplayed = false; return 0;}
        //System.println("msg[0] " + msg);
        //System.println("time_now : " + $.time_now.value());
        if (msg[0] < $.time_now.value() ){ msgDisplayed = false; 
            message = null;
            //System.println("ShowMSG: Exiting current msg time expired");
            return 0;
        }

        //System.println("ShowMSG: curr msg = prev: " + msg.toString().equals(savedMSG_hash.toString()) + " 2nd way: " + msg == savedMSG_hash );

        //System.println("ShowMSG: Hi MOM!"); 

        //System.println("ShowMSG: curr msg = prev: " + msg.toString().equals(savedMSG_hash.toString()));
        //System.println("ShowMSG: curr msg = prev 2nd way: " + (msg == savedMSG_hash) );
        //keeping track of buttonepressses & whether a msg is displayed allows us to 
        //cut out of msg display as soon as a button is pressed after any msg is displayed
        if ($.buttonPresses > msgSaveButtonPress && msgDisplayed ==true && msg.hashCode()==savedMSG_hash) {
            message = null; //have to remove the msg or it keeps popping back  up
            msgDisplayed = false; 
            //System.println("ShowMSG: Exiting current msg; a button was pressed after display.");
            return 0;
            }   //but out of msg as soon as a button presses

        //System.println("ShowMSG: we are displaying the msg...");  
        savedMSG_hash = msg.hashCode();  
        var numMsg=0;
        for (var i = 1; i<msg.size(); i++) {if (msg[i] != null && msg[i].length()>0 ) { numMsg++;}}
        var ystart = 1.5 * yc - textHeight*numMsg/2;
        var xstart = xc;

        if ($.buttonPresses < 1) { ystart = yc - textHeight*numMsg/2;}

        if (jstify == Graphics.TEXT_JUSTIFY_LEFT) {
                jstify = Graphics.TEXT_JUSTIFY_RIGHT;
                ystart = yc - textHeight*numMsg/2;
                xstart = 1.95*xc;

        }

        //Could draw a BAKCGROUND behind this text...
        
        msgSaveButtonPress = $.buttonPresses;

        msgDisplayed = true; 
        
        font = Graphics.FONT_TINY;

        var lineHeight = textHeight;
        
        var planetIcon = WatchUi.loadResource($.Rez.Drawables.Jupiter) as BitmapResource;

        var hgt = planetIcon == null ? lineHeight : planetIcon.getHeight();
        //var hgt = lineHeight;

        if (hgt>lineHeight) {lineHeight = (lineHeight + hgt)/2.0 ;}

        
        var ct_i = 0;      
        var lined = false;          
        for (var i = 0; i<msg.size()-1; i++) {
            //System.println(" msg[i+1] " +  msg[i+1]);
            if (msg[i+1] != null ) { 
                
                ct_i++;
                if (msg[i+1].length()==0){
                    //a blank line =""
                    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    dc.drawLine(0, ystart + (i)*lineHeight, dc.getWidth(), ystart + i*lineHeight);
                    lined = false;
                    continue;
                }
                
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(0, ystart + i*lineHeight -1 , dc.getWidth(), lineHeight +1);
                
                
                
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);

                dc.drawText(xstart, ystart + i*lineHeight, font, msg[i+1], jstify);
                
                if (i>2 && msg[i-2]!=null &&  msg[i-2].find("THE") != null) { //"THE PLANETS" or "PLANETS"
                    //deBug("drawing0", [i, msg,[i-2], msg[i-1], msg[i]]);

                    if (planetIcon != null) {
                        //deBug("drawing", [msg[i], msg[i+1], msg[i-1]]);
                        
                        //var hgt = planetIcon.getHeight();
                        var wdt = planetIcon.getWidth();
                        //System.println("Hgt " + hgt);
                        //var ht = (2*lineHeight-2 - hgt)/2.0;//40=height of icon
                        var ht =(i-1)*lineHeight;//40=height of icon  "THE"
                        //var xtart = xc;

                        /* //skip this for widget
                        if (msg[i-2].length()>8) { //"THE PLANETS"
                            ht = (i-1.9) * lineHeight;
                            if (hgt>=textHeight) {
                                ht = (i-2.2)*lineHeight;
                            }
                            //xtart = 0.2*xc;
                        }
                        */

                        if (ht<0) {ht=0;}
                        //dc.setClip (0, ystart+2 + (i-1)*lineHeight,  2*xc,  (i+3)* lineHeight -2  );
                        dc.drawBitmap(xstart - wdt/2.0, ht + ystart +2, planetIcon);
                        //deBug("drawing", [xstart - wdt/2.0, ht + ystart + 2]);
                        dc.clearClip();
                    }
                }

                if (!lined) {
                    if (i==0) { 
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                        }
                    else {
                            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                        }
                    dc.drawLine(0, i*lineHeight + ystart , dc.getWidth(), i*lineHeight + ystart);
                    lined = true;
                }
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, ystart + (ct_i)*lineHeight, dc.getWidth(), ystart + ct_i*lineHeight);

        if ($.buttonPresses < 1) { return 2;}
        return 1;
        
        

    }

    function showDate(dc, date, time_nw, addTime_hrs ,xcent as Lang.float, ycent as Lang.float, incl_years, show, type){
        font = Graphics.FONT_TINY;
        var bigfont = Graphics.FONT_LARGE;
        textHeight =  dc.getFontHeight(font);        
        var bigTextHeight = dc.getFontHeight(bigfont);        
        var justify = Graphics.TEXT_JUSTIFY_CENTER;
        
        addTime_hrs = 0;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        //var sm_ret = showMessage(dc, justify);  //will use same color font, textHeight as above

        //if (sm_ret> 0 ) { return; }  //any msg displayed, we just skip all these dates etc

        //System.println("showDate" + show);
        var targTime_sec = (addTime_hrs*3600).toLong() + time_nw.value();
        var xcent1  = xcent;  //DATE location
        var ycent1   = ycent -  0 *textHeight; //DATE location
        
        var xcent3   = xcent; //time location
        var ycent3   = ycent - 1 * bigTextHeight; //time location

        //var xcent2   = xcent;  //speed or "stopped" location //could be for battery etc
        //var ycent2   = ycent + 0.5* textHeight; 

        /*
        
        if (type ==:orrery) {
            ycent1 = 0.1*textHeight;  //date & time top center
            ycent3 = ycent1 + textHeight; //time below date
            ycent2 = 2* ycent - textHeight*1.5; //speed or stopped lower center
            
            if (screenShape == System.SCREEN_SHAPE_RECTANGLE)
            {
                ycent1 = 0.1*ycent; //date top right
                xcent1 = 1.4*xcent;            

                ycent3 = ycent1 + textHeight; //time below date
                xcent3 = 1.4* xcent;

                ycent2= 2* ycent - textHeight;//speed or stopped bottom right
                xcent2=1.35*xcent;
            }
            if( screenShape== System.SCREEN_SHAPE_SEMI_OCTAGON) {
                ycent1 = 0.26*ycent; //DATE in small circle upper right
                xcent1 = 1.68*xcent;
                
                ycent3 = 0.0*ycent; //time in upper left
                xcent3 = .7*xcent;

                ycent2= 2* ycent - textHeight;//speed or stopped bottom right //Speed or stopped in lower left
                xcent2 = xcent;
            }
        }
        */
        
        //System.println("DATE!!!!!: " + new_date.value() + " OR... " + targTime_sec + " yr: "+ new_date_info.year + "add_hjrs "+ addTime_hrs);

        //var stop = !$.started && $.view_mode!=0;

        if (incl_years == null) { incl_years = false; }
        

        //showMessage(dc, justify);  //will use same font, textHeight as above

        //var msg = null;
        //var moveup = 0.5f;

        //if (type == :orrery) {moveup -= 1.0;} //no time to display for orrery

        
        
        //var new_date = new Time.Moment(targTime_sec);
    
        var new_date_info_med = Time.Gregorian.info(new Time.Moment(targTime_sec), Time.FORMAT_MEDIUM);
        var new_date_info = Time.Gregorian.info(new Time.Moment(targTime_sec), Time.FORMAT_SHORT);

        ///#### SHOW DATE #####
        //y -= (_lines.size() * textHeight) / 2;
        //var addStop = "";
        //if (!started) {addStop = "s";}

        //var modeInd = "";
        //if (type ==:orrery) {modeInd = $.Options_Dict[thetaOption_enum] == 0 ? " [T]" : " [V]" ;}

        if (addTime_hrs < 700000 && addTime_hrs > -500000)// && type != :orrery) {
            {

            var dt = new_date_info.day.format("%02d") + " " + new_date_info_med.month;

            var yr = "";

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

            if (incl_years) { 
                yr = new_date_info.year.format("%02d").substring(2,4);
                if (new_date_info.year>2099 || new_date_info.year< 1930 ) { yr = new_date_info.year.format("%04d");}
                //dt =  dt + yr ;
                
            }
            /*if( screenShape== System.SCREEN_SHAPE_SEMI_OCTAGON  && type == :orrery) {
                dc.drawText(xcent1, ycent1 - textHeight/2.1, font, dt, justify);
                dc.drawText(xcent1, ycent1 + textHeight/2.1, font, yr, justify);
            } else { */
                var wid = dc.getTextWidthInPixels(dt + " " + yr, font);
                dc.setClip (xcent1-wid/2.0, ycent1,wid, textHeight );
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
                //dc.setColor(Graphics.COLOR_DK_GREEN, Graphics.COLOR_RED);
                dc.clear();
                dc.drawText(xcent1, ycent1, font, dt + " " + yr, justify);

            //}
            
            
            //if (new_date_info.year<2100 && new_date_info.year>1900 && type != :orrery) 
            //##### ADD THE HR & MIN if between 1900  & 2100AD ####
            var mySettings = System.getDeviceSettings();
            var is24Hr = mySettings.is24Hour;
            if (new_date_info.year<2100 && new_date_info.year>1900) 
            { 
                if (is24Hr)
                { dc.drawText(xcent3, ycent3, bigfont, new_date_info.hour.format("%02d")+":" + new_date_info.min.format("%02d"), justify);}
                else {

                    var hr = new_date_info.hour%12;
                    if (hr == 0) {hr = 12;}
                    var ampm = "am";
                    if (new_date_info.hour >=12) {
                        ampm = "pm";
                    }
                    var txt = hr.format("%d")+":" + new_date_info.min.format("%02d") + ampm;

                    var widt = dc.getTextWidthInPixels(txt, bigfont);
                    dc.setClip (xcent3-widt/2, ycent3,widt , bigTextHeight );
                    dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);

                    //dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_YELLOW);
                    dc.clear();
                    dc.drawText(xcent3, ycent3, bigfont, txt , justify);

                }
            }

        } else {
            // ##### DATE JULIAN VERSION FOR MANY YEARS PAST/FUTURE ####
            //var j2 = f.j2000Date (new_date_info.year, new_date_info.month, new_date_info.day, new_date_info.hour, new_date_info.min, 0, 0);

            //var targDate_days = f.j2000Date (new_date_info.year, new_date_info.month, new_date_info.day, new_date_info.hour, new_date_info.min, 0, 0) + addTime_hrs/24l;
            var targDate_days = j2000Date ($.now_info.year, $.now_info.month, $.now_info.day,$.now_info.hour, $.now_info.min,$.now.timeZoneOffset/3600, $.now.dst); //So GREGORIAN malfunctions around 2100 or 2110 and similarly in the past; so we transition to using TODAY'S DATE together with the addTime.HRS instead, as Julian
            var targDate_years = (targDate_days/365.25d + 2000d).toFloat(); 


            var txt = targDate_years.format("%.2f");

            var wid = dc.getTextWidthInPixels(txt, bigfont);
            dc.setClip (xcent1-wid/2-4, ycent1-2,wid + 8, bigTextHeight+4 );
            dc.drawText(xcent1, ycent1, font, txt, justify);

        }
        dc.clearClip();
        /*
        // #### STOPPED ####
        if (stop) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(xcent2 - .25* dc.getWidth(), ycent2+ .5*textHeight, .5*dc.getWidth(), textHeight);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xcent2, ycent2+ .5*textHeight, font, "(stopped)", justify);
            
            return;
        }
        */

        // #### SPEED ####
        //if (show && (sm_ret == 0 )) { //msg_ret ==0 means, don't show this when there is a special msg up
        /*
        if (true) {
            var sep = ">";
            //var ssi=$.speeds[$.speeds_index] ;
            var ssi = (WatchUi.loadResource( $.Rez.JsonData.speeds) as Array)[$.speeds_index];

            if (ssi < 0) { sep = "<";}
            if (!started || ssi == 0 || $.view_mode == 0) { sep = "|";}
            ssi = ssi.abs();

            var intvl = ""; //Lang.format("($1$ hr)",[ssi]);
            if (ssi < 1) {
                intvl = Lang.format("$1$ min",[(ssi*60).format("%d")]);
            }
            else if (ssi>=50 && ssi<=367*24 ) {
                var dv = ssi/24.0;
                if (dv == Math.floor(dv+.00000001)) {
                    intvl = dv.format("%.0d") + " day";
                } else {
                    intvl = dv.format("%.2f") + " day";
                }
            }
            else if(ssi>24*367 ) {
                var dv = ssi/(24.0*365.0);
                if (dv == Math.floor(dv+.00000001)) {
                    intvl = dv.format("%.d") + " yr";
                } else {
                    intvl = dv.format("%.4f") + " yr";
                }
            }
            else {
                var dv = ssi;
                //System.println("DV " + dv);
                if (dv == Math.floor(dv)) {
                    intvl = "" + dv.format("%.1d") + " hr";
                }else{
                    intvl = "" + dv.format("%.1f") + " hr";
                }
            }            
            
            //dc.drawText(xcent2, ycent2, font, sep + intvl + sep + modeInd , justify);
            dc.drawText(xcent2, ycent2, font, sep + intvl + sep, justify);
            //$.show_intvl = false;
        }
        */
        
        /* else if ((15*$.hz).toNumber() < 2.0* $.hz) {
            dc.drawText(xcent2, ycent2+ .5*textHeight, font, msg, justify);
        } */
        
    }

    var def_size = 175.0 /2;
    var b_size = 2.0;
    var jup_size = 4.0;
    var min_size = 1.0;
    var fillcol= Graphics.COLOR_BLACK;
    //var col = Graphics.COLOR_WHITE;

    public function drawPlanet(dc, key, xyr, base_size, ang_rad, type, big_small, small_whh) {
        //System.println("key: " + key);

        $.drawPlanetCount++;
        var x = xyr[0];
        var y = xyr[1];
        //var z = xyr[2];
        //var radius = xyr[3];

        col = Graphics.COLOR_WHITE;
        fillcol = Graphics.COLOR_BLACK;
        b_size = base_size/def_size*min_c;
        min_size = 2.0/def_size*min_c;
        size = b_size;

        
        //if (type == :orrery) { size = b_size/32.0;}
        if (key.equals("Sun")) {
            size = 8*b_size;
            //if (type == :orrery) {size = 2*b_size;}
            col = 0xf7ef05;
            fillcol = 0xf7ef05;
            //if (type == :orrery) { size = b_size;}
            
        }
        //switch (key) {
        if (key.equals("Mercury")) {
                size = b_size *jup_size*0.03488721374;
                col = 0x8f8aae;
                fillcol = 0x70708f;
        }
        else if (key.equals("Venus")) {
                size =b_size*jup_size * 0.08655290298;
                //col = 0xffff88;
                //fillcol = 0x838370;
                col = 0xffff88;
                fillcol = 0xeeee88;
                } else

            if (key.equals("Mars")) {
                size =b_size*jup_size * 0.04847591938;
                col = 0xff9a8e;
                fillcol = 0x9f4a5e;

                } else
            if (key.equals("Saturn")) {
                size =b_size *jup_size * 0.832944744;
                col = 0x947ec2;
                } else
            if (key.equals("Jupiter")) {
                size =b_size *jup_size;
                col = 0xcf9c63;
                } else
            if (key.equals("Neptune")) {
                size =b_size *jup_size * 0.3521906424;
                col = Graphics.COLOR_BLUE;
                fillcol = col;
                } else
            if (key.equals("Uranus")) {
                size =b_size *jup_size * 0.3627755289;
                col = Graphics.COLOR_BLUE;
                fillcol = Graphics.COLOR_GREEN;
                } else
            if (key.equals("Earth")) {
                size =b_size *jup_size * 0.09113015119;
                col = Graphics.COLOR_BLUE;
                fillcol = Graphics.COLOR_BLUE;
                } else   
            if (key.equals("Moon")) {
                size =b_size *jup_size * 0.09113015119; //same as EARTH here, we adjust to true size rel. to earth below
                col = 0xe0e0e0;        
                fillcol = 0x171f25;                                
                } else                
                
             if (key.equals("Pluto")) {
                size =b_size *jup_size * 0.016993034; 
                col = Graphics.COLOR_WHITE;
                fillcol = Graphics.COLOR_RED;
                } else   
             if (key.equals("Ceres")) {
                size =b_size *jup_size * 0.006708529416; //1/3 of pluto
                col = Graphics.COLOR_LT_GRAY;
            }
             /*   
             case "Chiron": //rings, light brownish???
                size =b_size *jup_size*0.001544821273; //100-200km only, 1/10th of Pluto
                col = Graphics.COLOR_LT_GRAY;
                break;   
             case "Eris": //white & uniform, has a dark moon
                size =b_size *jup_size * 0.01663543648; //nearly identical to pluto
                col = Graphics.COLOR_WHITE;
                break;   
             case "Quaoar":
                size =b_size *jup_size * 0.007767018066;
                col = Graphics.COLOR_LT_GRAY;
                break; 
             case "Makemake":
                size =b_size *jup_size * 0.01022728898;
                col = Graphics.COLOR_LT_GRAY;
                break;        
             case "Eris":
                size =b_size *jup_size * 0.01663543648;
                col = Graphics.COLOR_LT_GRAY;
                break;
             case "Gonggong":
                size =b_size *jup_size * 0.008796898914;
                col = Graphics.COLOR_LT_GRAY;
                break;              
             case "Haumea":
                size =b_size *jup_size * 0.01127147373;
                col = Graphics.COLOR_LT_GRAY;
                break;     
                */            
        //}
        
        //to allow earth, moon, venus, mars to be shown more @ real size in 
        //this view
        //var preserve_size = false;
        /*
        if (type == :orrery && big_small == 0 && !key.equals("Sun")) {size = 1.5* size; min_size = min_size/2.0; preserve_size = true;}

        else if (type == :orrery && (big_small ==1) && planetsOption_value ==2 && !key.equals("Sun")) {size = 1.5* size; min_size = min_size/2.0; preserve_size = true;}

        //When look@ dwarf planets only, allow THOSE TO set the size value
        else if (type == :orrery && (big_small ==2) && planetsOption_value ==2 && !key.equals("Sun")) {size = 12*size;min_size = min_size/2.0; preserve_size = true;}
        
        else if (type == :orrery &&  (big_small ==2) && planetsOption_value ==1 && !key.equals("Sun")) {size = size/8.0;min_size = min_size/2.0; preserve_size = true;}
        
        else if (type == :orrery &&  (big_small ==2) && !key.equals("Sun")) {size = size/4.0;min_size = min_size/1.5; preserve_size = true;}

        else if (type == :orrery &&  (big_small ==1) && planetsOption_value ==1 && !key.equals("Sun")) {size = size/8.0;min_size = min_size/2.0; preserve_size = true;}

        else if (type == :orrery &&  (big_small ==1) && !key.equals("Sun")) {size = size/6.0;min_size = min_size/2.0; preserve_size = true;}
        */

        var correction =  1;
        /*
        if (type == :orrery) { 
            if (!preserve_size) {size = Math.sqrt(size);}

            if (min_c > 120) { //for higher res watches where things tend to come out tiny
                //trying to make the largest things about as large as half the letter's height
             correction = 0.3 * textHeight/ Math.sqrt(8*b_size);
             //System.println("orrery correction " + correction);
             if (correction< 1) {correction=1;}
             if (correction< 1.5) {correction=1.5;}             
              size = size * correction;
            }
            //if (key.equals("Moon")){size /= 3.667;} //real-life factor
            
            }
        else if (type == :ecliptic) {
        */
            if (key.equals("Moon")){size =  8*b_size;} //same as sun
            size = Math.sqrt(Math.sqrt(Math.sqrt(size))) * 5;
            
            if (min_c > 120) { //for higher res watches where things tend to come out tiny
                correction = 0.3 * textHeight/    Math.sqrt(Math.sqrt(Math.sqrt(size))) / 5;
                //System.println("ecliptic correction " + correction);
                if (correction< 1) {correction=1;}
                if (correction< 1.5) {correction=1.5;}             
                size = size * correction;
            }
        //}

        if (size < min_size) { size = min_size; }

        //if (type == :orrery && big_small == 1 && key.equals("Sun")) {size = size/2.0;}
        //if (type == :orrery && big_small == 2 && key.equals("Sun")) {size = size/4.0;}
        
        /* {
            if (key.equals("Moon"))
            { size = min_size/2.0; }
            
            else 
        }*/
        //System.println("size " + key + " " + size);
        /*
        if (type == :orrery && (key.equals("Moon"))) {
            if (big_small == 0)  {
                //we set moon's size equal to earth above
                //now we adj the end product to get
                //the right proportions (with no MIN for moon as for all  other objects)
                size = size/3.671; //EXACT for orrery mode 1

            } else {                            
                size = size/3.2; //a little less exact for modes 2,3
                
            }
            if (size<0.5) {size=0.5;} //keep it from comppletely disappearing no matter what
        }
        */
        //System.println("size2 " + key + " " + size + " " + min_size);

        size *= planetSizeFactor; //factor from settings

        if (key.find("Ec") != null) {
            var trisize = min_c/15.0*2.25;
            var tribase = trisize/3/2.25;
            size = min_c/60.0;
            //var fill = false;
            
            if (key.equals("Ec0") || key.equals("Ec180") ) {
                //fillcol = Graphics.COLOR_DK_GRAY;
                //fill = true;
                tribase = 1.5*tribase;
                if (key.equals("Ec0")) {tribase *= 1.8; trisize *= 1.15;}
            }

            
            drawTrianglePointer (dc, [xc, yc, x, y,], trisize, tribase, 1, Graphics.COLOR_WHITE, false, false);

            
        } //solstice & equinox points, small circles
            

        //var pers = 1;
        
        /*
        var max_p = 1.0;
        var pers =  z/max_c/2.0 + 0.5;            //ranges 0-1
        pers = ( 0.5  + pers)/1.5;  //between 2-3/2.5, when z=0, pers = 1;
        if (pers> max_p) {pers = max_p; }
        if (pers < 0.05   ) {pers = 0.05;}
        */

        //Handle perspective for orrery modes
        /*
        if (type == :orrery) {
            if (z>1.5 * max_c) {return;} //this one is "behind" us, don't draw it
            if (size > radius * .8 && !key.equals("Sun")) {return;} 
            if (z>max_c) {z= max_c;}
            var pers = 2*max_c / (2.0* max_c - z);

            if (pers < 0.05   ) {pers = 0.05;}

            size *= pers;
        }
        */

        var pen = Math.round(size/10.0).toNumber();
        if (pen<1) {pen=1;}
        dc.setPenWidth(pen);
        dc.setColor(fillcol, Graphics.COLOR_BLACK);        
        if (size>1) {dc.fillCircle(x, y, size);}
        dc.setColor(col, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y, size);
        
        switch (key) {
            case "Sun" :
                //dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.setColor(0xf7ef05, Graphics.COLOR_TRANSPARENT);
                //if (type == :orrery) {break;}
                
                dc.fillCircle(x, y, size);
                for (var i = 0; i< 2*Math.PI; i += 2*Math.PI/8.0) {
                    var r1 = size *1.2;
                    var r2 = size * 1.5;
                    var x1 = x + Math.cos (i) * r1;
                    var y1 = y + Math.sin (i) * r1;
                    var x2 = x + Math.cos (i) * r2;
                    var y2 = y + Math.sin (i) * r2;
                    dc.drawLine(x1,y1,x2,y2);

                }
                break;
            case "Mercury" :                
                dc.setColor(0xffffff, Graphics.COLOR_TRANSPARENT);        
                drawARC (dc, 17, 7, x, y - size/2.0,size/2.25, pen, null);
                drawARC (dc, 0, 24, x, y + size/3.0,size/2.25, pen, null);
                break;
            case "Venus":
                //dc.fillCircle(x, y, size);
                //dc.setColor(0x737348, Graphics.COLOR_TRANSPARENT);        
                //drawARC (dc, 17, 7, x, y - size/2.5,size/2.3, 1, null);
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT); 
                drawARC (dc, 0, 24, x, y - size/5.0,size/2.2, pen, null);
                dc.drawLine (x, y - size/5.0 + size/2.2, x, y+3.8*size/5.0);

                dc.drawLine (x-size/5.0, y + size/2.0, x+size/5.0, y + size/2.0);

                //dc.fillCircle(x, y,size/4);
                break;
            case "Mars":
                //dc.fillCircle(x, y, size);
                //dc.setColor(0x734348, Graphics.COLOR_TRANSPARENT);        
                      var x1 = x - size/12.0;
                var y1 = y + size/12.0;
                //drawARC (dc, 17, 7, x, y - size/2.5,size/2.3, 1, null);
                drawARC (dc, 0, 24, x1, y1 ,size/2.0, pen, null);
          
                dc.drawLine (x1 + size/4.0 + size/18.0 , y1 - size/2.0 - size/18.00,x1 + size/2.0+ size/18.0, y1 - size/2.0 - size/18.0);
                dc.drawLine (x1 + size/2.0 + size/18.0, y1 - size/4.0- size/18.0,x1 + size/2.0+ size/18.0, y1 - size/2.0 - size/18.0);

                //dc.drawLine (x-size/5.0, y + size/2.0, x+size/5.0, y + size/2.0);

                //dc.fillCircle(x, y,size/4);
                break;    
            case "Jupiter":
                dc.drawLine(x-size*.968+pen/3.0, y-size/4, x+size*.968-pen/3.0, y-size/4);
                dc.drawLine(x-size*.968+pen/3.0, y+size/4, x+size*.968-pen/3.0, y+size/4);
                break;
            case "Saturn":
                dc.drawLine(x-size*1.7, y+size/3, x+size*1.7, y-size/3);
                //dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x-size*1.6, y+size*.37 , x+size*1.6, y-size*.21);
                //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x-size*1.5, y+size*.41 , x+size*1.5, y-size*.15);
                //dc.drawLine(x-size, y+size/4, x+size, y+size/4);
                break;
            case "Neptune" :
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);   
                y1 = y + size/12.0;             //
                dc.drawLine(x, y1+3*size/5.5, x, y1-3*size/4);
                drawARC (dc, 18, 6, x, y1 - 1*size/2.0, size*2/3.0, pen, null);
                break;
            case "Uranus" :
                
                //dc.drawLine(x, y+4*size/5, x, y-4*size/5);
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);                //
                dc.fillCircle (x, y, size/3);  
                if (size>4) {drawARC (dc, 0, 24, x, y,3*size/4.0, pen, null);}
                break;
             case "Pluto" :
                
                //dc.drawLine(x, y+4*size/5, x, y-4*size/5);
                dc.drawLine(x-size/7.0, y+2*size/4, x-size/7.0, y-2*size/4);                      
                //dc.drawLine(x-size/3.0, y+3*size/4, x-size/3.0, y-3*size/4);                      
                drawARC (dc, 10, 27, x+size/10.0, y-size/6,size/2.8, pen, null);
                break;
            case "Ceres" :
                
                //dc.drawLine(x, y+4*size/5, x, y-4*size/5);
                //dc.drawLine(x-size/7.0, y+2*size/4, x-size/7.0, y-2*size/4);                      
                //dc.drawLine(x-size/3.0, y+3*size/4, x-size/3.0, y-3*size/4);                      
                drawARC (dc, 10,2.5, x-size/30, y,size/1.9, pen, null);
                break;       

             /*
             case "Chiron" :
                
                //dc.drawLine(x, y+4*size/5, x, y-4*size/5);
                //dc.drawLine(x-size/7.0, y+2*size/4, x-size/7.0, y-2*size/4);                      
                //dc.drawLine(x-size/3.0, y+3*size/4, x-size/3.0, y-3*size/4);                      
                drawARC (dc, 23,13, x+size/7, y,size/1.9, pen, null);
                break;
            case "Eris" :
                
                //dc.drawLine(x, y+4*size/5, x, y-4*size/5);
                //dc.drawLine(x-size/7.0, y+2*size/4, x-size/7.0, y-2*size/4);                      
                //dc.drawLine(x-size/3.0, y+3*size/4, x-size/3.0, y-3*size/4);                      
                drawARC (dc, 23, 13, x+size/7, y,size/1.8, pen, null);
                dc.drawLine(x+size/7-size/1.5, y, x+size/3.4,y);
                break;  
            case "Makemake" :                
                dc.drawLine(x, y+4*size/8.0, x, y-3*size/8.0);
                dc.drawLine(x - 2*size/4.0, y-3*size/8, x + 2*size/4.0, y-3*size/8);
            
                break;
            case "Gonggong" :                
                //dc.drawLine(x-size/4.0 + size/15, y-size/2.0, x - size/4.0, y+size/2.0);
                //dc.drawLine(x+size/4.0 + size/15, y-size/2.0, x + size/4.0, y+size/2.0);
                dc.drawLine(x + size/15, y-size/1.8, x - size/15.0, y+size/1.8);
                dc.drawLine(x+size/2.0, y-size/4.0, x - size/2.0, y-size/4.0);
                dc.drawLine(x+size/2.0, y+size/4.0, x - size/2.0, y+size/4.0);
                break;
                
            case "Quaoar" :                
                dc.drawLine(x , y-size/1.7, x + size/2.0, y);
                dc.drawLine(x + size/2.0, y,x , y+size/1.7);
                dc.drawLine(x, y+size/1.7,x - size/2.0, y);
                dc.drawLine(x - size/2.0, y, x , y-size/1.7);
                break; 
             case "Haumea" :                
                drawARC (dc, 0, 24, x, y - size/3,size/3, pen, null);
                drawARC (dc, 0, 24, x, y + size/3,size/3, pen, null);
                
                break;    
            */                                  

            case "Moon" :  
                /*
                if( type == :orrery) {
                        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);  
                        //System.println("Orrery moon..");
                        dc.drawCircle(x, y, size);              
                        
                        dc.fillCircle(x, y, size);
                        break;
                }  else {
                */

                    if (moon_age_deg >= 94 && moon_age_deg < 175) {
                         dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);                //0x171f25
                         dc.fillEllipse(x, y, size * Math.sqrt(moon_age_deg - 90 )/9.48683, size);
                         //dc.fillEllipse(x, y, size * (moon_age_deg - 90 )/90.0, size);
                    }

                    if (moon_age_deg >= 185 && moon_age_deg < 266) {
                         dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);                //0x171f25
                         dc.fillEllipse(x, y, size * Math.sqrt(270-moon_age_deg)/9.48683, size);
                         //dc.fillEllipse(x, y, size * (270-moon_age_deg)/90.0, size);
                    }

                    if (moon_age_deg >= 358 || moon_age_deg <= 2) { //NEW moon

                            dc.setColor(0x171f25, Graphics.COLOR_TRANSPARENT);                //0x171f25
                            dc.fillCircle(x, y, size);
                            //dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            //dc.drawCircle(x, y, size);
                    }

                    else if (moon_age_deg > 2 && moon_age_deg <= 175) { //1st quarter
                            //dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);                
                            //dc.drawCircle(x, y, size);
                            dc.setClip (x, y-size,size+1, size*2);                        
                            dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            dc.fillCircle(x, y, size);
                            dc.clearClip();
                            

                    }
                    else if (moon_age_deg > 175 && moon_age_deg <= 185) { //FULL
                            
                            dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            
                            //dc.drawCircle(x, y, size);              
                            
                            dc.fillCircle(x, y, size);
                    }
                    else if (moon_age_deg > 185 && moon_age_deg < 358) { //Last quarter
                            
                            //dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            //dc.drawCircle(x, y, size);
                            
                            dc.setClip (x-size, y-size,size, size*2+2);
                            dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            dc.fillCircle(x, y, size);
                            dc.clearClip();
                    }
                    //black OR white ellipse to blank out or add some/all of the half moon to show
                    //phases in between quarters
                    //This can be refined more to show exact lit percentages, if desireds.
                    if (moon_age_deg > 0 && moon_age_deg < 86){
                         dc.setColor(0x171f25, Graphics.COLOR_TRANSPARENT);                //0x171f25
                         dc.fillEllipse(x, y, size * Math.sqrt(90-moon_age_deg)/9.48683, size);
                    }

                    else if (moon_age_deg > 274 && moon_age_deg < 360){
                         dc.setColor(0x171f25, Graphics.COLOR_TRANSPARENT);                //0x171f25
                         dc.fillEllipse(x, y, size * Math.sqrt(moon_age_deg-270)/9.48683, size);
                    }

                    //white ellipse to add to the half moon after 1st quarter

                    
                    //draw the full circle last so it always looks like a full round circle w/ phases
                    dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                    dc.drawCircle(x, y, size);
                    //deBug("Moon!", moon_age_deg);
                    
                //}
                break;
            //"HORIZON" line in :orrery view
            /*case "Earth" : 
                
                if (type == :orrery && LORR_show_horizon_line) 
                {
                    
                    //dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);                    
                    //length 0 doesn't SHOW UP on the INSTINCT for some reason, so sticking with size 1
                    drawDashedLine(dc, 0,y - size/5.0, 2*xc, y - size/5.0, 0, 3, 1, Graphics.COLOR_LT_GRAY);
                    //drawDashedLine(dc, 0,y - size, 2*xc, y - size, 0, 3, 1, Graphics.COLOR_WHITE);
                    LORR_horizon_line_drawn = true;
                }
                break;    
                */      
        }

        //If it might be behind the sun, draw the Sun on top...
        /*if (!key.equals("Sun") && radius<3*size && z<0) {
            drawPlanet(dc, "Sun", [0, 0, 0, 0], base_size, ang_rad, type, big_small, small_whh);

        }*/
        /*
        if (key.equals("Sun") ) {
            
            //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        } else  if (key.equals("Venus")) {
            
            //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        }
        */
        var drawThis=false;
        if ($.Options_Dict[planetLabels]){

            var mlt = 4;
            //if ($.Options_Dict[labelDisplayOption_enum]==3) {mlt = 8;}
            //else if ($.Options_Dict[labelDisplayOption_enum]==0 ) {mlt = 1;}
            //else if ($.Options_Dict[labelDisplayOption_enum]==4 ) {
                
                    //sparkly labels effect/random 1/4 of the planets @ any time
                  drawThis = (planetRand + $.drawPlanetCount)%pp.size()<pp.size()/8;
                  mlt = 20;
                
            //}
            //System.println ("1328: " + " " + textDisplay_count + " " + mlt + " " + $.hz + " " + drawThis);
            var hez = 5;
            var mlt2 = 1;
            if ($.hz == null ) {hez = 5;} 
            else { hez = $.hz * 4; mlt2 = 4;}

            ///########### SHOW NAME ABBREVIATION ##########################
            if ((textDisplay_count * mlt2) % (mlt*hez).toNumber() < hez || drawThis) {
            
                //if (type == :ecliptic) {
                    if (!key.equals("Sun") && key.find("Ec")==null)  {
                        sub = findSpot(-pp[key][0]+sid);
                        mult = 0.8 - (.23 * sub);
                        x2 = mult*r* Math.cos(ang_rad) + xc;
                        y2 = mult* r* Math.sin(ang_rad) + yc;

                        dc.setColor(col, Graphics.COLOR_TRANSPARENT);        
                        dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                        //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
                    }
                //}
                /* else if (type == :orrery) {
                    
                    //var drawSmall = big_small==0  
                        //|| (radius > 4*b_size); //4*b_size is size of sun as drawn in orrery view
                    //|| (big_small==1 && (small_whh.indexOf(key)==-1 || orrZoomOption_values[$.Options_Dict["orrZoomOption"]] >= 4))
                    //|| (big_small==2 && ( small_whh.indexOf(key)==-1 || orrZoomOption_values[$.Options_Dict["orrZoomOption"]] >= 8));
                    
                    if (!key.equals("Sun") && !key.equals("Moon") )  {
                        sub = findSpotRect(x,y);
                        //mult = 2 + sub;
                        x2 = sub[0];
                        y2 = sub[1];
                        dc.setColor(col, Graphics.COLOR_TRANSPARENT);        
                        dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
                        //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
                    }
                */


            } 
        }
    }
    
    /*
    public function drawHorizon(dc, horizon_pm as Lang.float, noon_adj_dg as Lang.float, final_adj_deg as Lang.float, xct as Lang.float, yct as Lang.float, radius as Lang.float, drawCircle){

        //deBug("drawHorizon: ", [ dc, horizon_pm, noon_adj_dg, final_adj_deg, xct, yct, radius, drawCircle]);

        var eve_hor_start_deg = f.normalize  ( 270 - (horizon_pm)*15  - noon_adj_dg);
        //var eve_hor_start_deg = f.normalize  ( 270 - (horizon_pm)*15);
        var eve_hor_end_deg =f.normalize (- eve_hor_start_deg);
        var morn_hor_end_deg = f.normalize (eve_hor_end_deg + 180);'
        //var morn_hor_start_deg = f.normalize (eve_hor_start_deg + 180);'
        var hor_ang_deg = 0;
        
        var final_a2 = f.normalize(270 - final_adj_deg);
        //System.println("fainal: " + final_a2 + " evestart " + eve_hor_start_deg);
        //var sun_ang_deg =  -pp["Sun"][0] - final_a2;
        if (f.normalize(eve_hor_start_deg - final_a2) < f.normalize(eve_hor_start_deg-morn_hor_end_deg))
            { //night time
                if (eve_hor_start_deg < morn_hor_end_deg) {eve_hor_start_deg += 360;}
                if (final_a2 < morn_hor_end_deg) {final_a2 += 360;}
                
                var fact = (eve_hor_start_deg - final_a2 ) / (eve_hor_start_deg - morn_hor_end_deg );
                System.println("fainal: " + final_a2 + " evestart " + eve_hor_start_deg + " " + morn_hor_end_deg + " " + fact);
                hor_ang_deg =  (fact) * f.f.normalize180(eve_hor_start_deg - eve_hor_end_deg) + eve_hor_end_deg;
                

            }else { //daytime
                if (eve_hor_start_deg > morn_hor_end_deg) {eve_hor_start_deg -= 360;}
                if (final_a2 > morn_hor_end_deg) {final_a2 -= 360;}
                var fact = 0;
                if (morn_hor_end_deg - eve_hor_start_deg != 0 ) {
                  fact = (morn_hor_end_deg - final_a2) / (morn_hor_end_deg - eve_hor_start_deg);
                }
                System.println("fainal2: " + final_a2 + " evestart " + eve_hor_start_deg + " " + morn_hor_end_deg + " " + fact);
                hor_ang_deg =  (1-fact) *f.f.normalize180(eve_hor_start_deg - eve_hor_end_deg) + eve_hor_end_deg;

            }
            hor_ang_deg = f.normalize(hor_ang_deg);
            System.println("hor_ang_deg: " + hor_ang_deg);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            var hor_ang_rad = Math.toRadians(hor_ang_deg);
            var x_hor1 = radius* Math.cos(hor_ang_rad) + xct;
            var y_hor1 = radius* Math.sin(hor_ang_rad) + yct;
            var x_hor1a = .6*radius* Math.cos(hor_ang_rad) + xct;
            var y_hor1a = .6*radius* Math.sin(hor_ang_rad) + yct;
            var x_hor2 = -radius* Math.cos(hor_ang_rad) + xct;
            var y_hor2 = -radius* Math.sin(hor_ang_rad) + yct;
            var x_hor2a = -.6*radius* Math.cos(hor_ang_rad) + xct;
            var y_hor2a = -.6*radius* Math.sin(hor_ang_rad) + yct;
            dc.drawLine (x_hor1,y_hor1,x_hor1a,y_hor1a);
            dc.drawLine (x_hor2,y_hor2,x_hor2a,y_hor2a);
            
            dc.setPenWidth(2);
            //MERIDIAN
            var x_mer = radius* Math.cos(hor_ang_rad - Math.PI/2) + xct;
            var y_mer = radius* Math.sin(hor_ang_rad- Math.PI/2) + yct;
            var x_mera = .85*radius* Math.cos(hor_ang_rad- Math.PI/2) + xct;
            var y_mera = .85*radius* Math.sin(hor_ang_rad- Math.PI/2) + yct;            
            dc.drawLine (x_mer,y_mer,x_mera,y_mera);

        //drawARC (dc, sunrise_events[:NOON][0]-0.05+ noon_adj_hrs +  12, sunrise_events[:NOON][0]+0.05+ noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE);
    }
    */
    /*
    public function drawHorizon3(dc, horizon_pm as Lang.float, noon_adj_dg as Lang.float, final_a2, win_sol_eve_hr as Lang.float, sun_RA_deg as Lang.float, xct as Lang.float, yct as Lang.float, radius as Lang.float){

        //deBug("drawHorizon: ", [ dc, horizon_pm, noon_adj_dg, final_adj_deg, xct, yct, radius, drawCircle]);
        var tz_add = ($.now.timeZoneOffset/3600.0f) + $.now.dst;
        var eve_hor_start_deg = f.normalize  ( 270 - (horizon_pm)*15  - noon_adj_dg);
        //var eve_hor_start_deg = f.normalize  ( 270 - (horizon_pm)*15);
        var eve_hor_end_deg =f.normalize (- eve_hor_start_deg);
        var morn_hor_end_deg = f.normalize (eve_hor_end_deg + 180);'
        //var morn_hor_start_deg = f.normalize (eve_hor_start_deg + 180);'
        var hor_ang_deg = 0;

        //20.34 = max angle of the horizon in degrees for winter solstice @ this latitude
        win_sol_eve_hr -= tz_add;  //we added this in as we do with planets, so it can be plotted but for this purpose we need to subtract it back out so we have the time relative to 12:00 noon.
        var max_angle_deg = - (270 - win_sol_eve_hr * 15.0f).abs();
        //System.println("max_angle_deg: " + max_angle_deg + " win solstic eve sunset hr" + win_sol_eve_hr + " today hor_end " + eve_hor_end_deg + " today hor_start " + eve_hor_start_deg);

        
        final_a2 = f.normalize(270 - final_a2);
        //System.println("fainal: " + final_a2 + " evestart " + eve_hor_start_deg);
        //var sun_ang_deg =  -pp["Sun"][0] - final_a2;

        var fact_day=0; //goes from 0 to 1 from sunrise to sunset
        var fact_night=0; //goes from 0 to 1 from sunset to sunrise

        eve_hor_start_deg = f.f.normalize180(eve_hor_start_deg) + 360.0;
        morn_hor_end_deg = f.normalize(morn_hor_end_deg);
        final_a2 = f.normalize(final_a2);
        //if (final_a2 > morn_hor_end_deg) {final_a2 -= 360;}
        if (final_a2 < 90) { final_a2 += 360;}

        if (final_a2< eve_hor_start_deg && final_a2 > morn_hor_end_deg) 

        //f.normalize(eve_hor_start_deg - final_a2) < f.normalize(eve_hor_start_deg-morn_hor_end_deg))

            { //night time
                //if (eve_hor_start_deg < morn_hor_end_deg) {eve_hor_start_deg += 360;}

                
                

                
                //if (final_a2 < morn_hor_end_deg) {final_a2 += 360;}
                
                fact_night = (eve_hor_start_deg - final_a2 ) / (eve_hor_start_deg - morn_hor_end_deg );
                //System.println("fainal: " + final_a2 + " final_adj_deg" + hour_adj_deg + noon_adj_deg + " evestart " + eve_hor_start_deg + " " + morn_hor_end_deg + " " + fact_night);
                //hor_ang_deg =  (fact) * f.f.normalize180(eve_hor_start_deg - eve_hor_end_deg) + eve_hor_end_deg;
                

            }else { //daytime
                eve_hor_start_deg = f.f.normalize180(eve_hor_start_deg);
                morn_hor_end_deg = f.normalize(morn_hor_end_deg);
                final_a2 = f.normalize(final_a2);
                if (final_a2 > 270) {final_a2 -= 360;}
                fact_day = 0;
                if (morn_hor_end_deg - eve_hor_start_deg != 0 ) {
                  fact_day = (morn_hor_end_deg - final_a2) / (morn_hor_end_deg - eve_hor_start_deg);
                }
                //System.println("fainal2: " + final_a2 + " final_adj_deg" + hour_adj_deg + noon_adj_deg + " evestart " + eve_hor_start_deg + " " + morn_hor_end_deg + " " + fact_day);
                //hor_ang_deg =  (1-fact) *f.f.normalize180(eve_hor_start_deg - eve_hor_end_deg) + eve_hor_end_deg;

            }

            var fact = fact_day/2.0f + 0.5;
            if (fact_day == 0) {fact = fact_night/2.0f;}
            fact += 0.5;
            

            //var day_of_solar_year = 
            var sun_RA_day = constrain((sun_RA_deg -  270.0f)/360.0f);//this tells us how far along we are in the yr.... RA=0 is spring equinox. We want angle after winter solstic, RA=270.:__version
            //fact is the same for the DAY. 
            //We put them together & we have the "location" of the sun in the sky
            //for the year & date
            sun_RA_deg = f.normalize(sun_RA_deg);
            var sector = Math.floor(sun_RA_deg/90);
            var sun_RA_pct = f.mod(sun_RA_deg, 90)/90.0f; //how far off we are from the last solstice or equinox
            //if (sun_RA_deg <90){ }
            var today_horizon_pm_pct = 0;
            for (var rra_deg = 0; rra_deg<360;rra_deg += 90) {
                var si = sunrise_events2["Ecliptic"+rra_deg];
                var si2 = sunrise_events2["Ecliptic"+(f.normalize(rra_deg+90))];
                //kinda silly to add & subtract tz_add, but it keeps us from having to deal with mod 24issues... in subtracting, bec. all are relative to 12noon if tz_add is taken out
                if ( sun_RA_deg >= rra_deg && sun_RA_deg < rra_deg+90 ) {
                    
                    today_horizon_pm_pct = (horizon_pm - si[1] - tz_add).abs()/ ((si2[1] - tz_add) - (si[1] -  - tz_add)).abs();
                    //(sun_RA_deg - rra_deg)/90.0f;
                    //System.println("dayfact0 horizon_pm: " + horizon_pm + " si2: " + si2[1] + " si: " + si[1] + " today_horizon_pm_pct: " + today_horizon_pm_pct);
                    break;                    
                }
            }
            //var add_pct = (sector-3)*0.25 + today_horizon_pm_pct/4.0; 
            var add_pct = (sector-3)*0.25 + sun_RA_pct/4.0; 
            var operational_pct = fact + add_pct;
            //-0.25 because ecliptic degree 0 is spring equinox, not winter solstice, 
            //where our drawHorizon2 zero point is.  (sunrise @ winter solstice is point 0)


            //System.println("dayfact: " + fact + " sun_RA_pct: " + sun_RA_pct + " sun_RA_deg: " + sun_RA_deg + " sector: " + sector + " sunRApct: " + sun_RA_pct + " today_horizon_pm_pct: " + today_horizon_pm_pct + " add_pct: " + add_pct + " operational_pct: " + operational_pct);
            //fact - sun_RA_pct
            drawHorizon2(dc, max_angle_deg, operational_pct, xct, yct, radius);


        //drawARC (dc, sunrise_events[:NOON][0]-0.05+ noon_adj_hrs +  12, sunrise_events[:NOON][0]+0.05+ noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE);
    }
    */

    //var max_hor_ang = -1000000.0;
    //var min_hor_ang = 1000000.0;
    /*
    //This will go from -max_angle at 0 to max_angle at 0.5 back to -max angle at 1.emb_x_0
    //Will do mod 1 to repeat the same cycle every 1 unit
    public function drawHorizon2(dc, max_angle_deg, percent, xct as Lang.float, yct as Lang.float, radius as Lang.float){    

        //deBug("drawHorizon: ", [ dc, horizon_pm, noon_adj_dg, final_adj_deg, xct, yct, radius, drawCircle]);  
        percent = constrain(percent); //keep it between 0-1
        var fact;
        
        if (percent <0.5)  { fact = percent/0.5; }
        else { fact = 1.0 - (percent-.5)/0.5; }
        fact = sigmoid(fact); //sigmoid  works OK ... maybe circly will be perfect fit?
        //fact = circly(fact); //tried these, sigmoid is best
        //fact = circlypow(fact,1.52);
        var hor_ang_deg = fact * max_angle_deg * 2 - max_angle_deg;

            hor_ang_deg = f.normalize(hor_ang_deg);

            //var hor_ang_rad = sunrise_events2[:ECLIP_HORIZON][1] + sunrise_events2["Ecliptic0"][0];

            //Vernal equinox position 0,0 is just at 0 RA, 0 Decl, so to plot it's position
            //we only need to add the time factor, which is final adj.
            var hor_ang_rad = -Math.toRadians(sun_adj_deg - hour_adj_deg - noon_adj_deg) + sunrise_events2[:ECLIP_HORIZON][1];
            var temp = f.f.normalize180(Math.toDegrees(hor_ang_rad));

             //y0 = (90 - temp)/90.0 * 23.4 * mcob + 50 * msob;

            System.println("temp/hor_ang_rad: " + temp + " " + hor_ang_rad);
            //hor_ang_rad *= sidereal_to_solar; //convert to solar system frame of reference
            if (temp > max_hor_ang) {max_hor_ang = temp;}
            if (temp < min_hor_ang) {min_hor_ang = temp;}
            //if (hor_ang_deg > 1000) {deBug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!hor_ang" + [hor_ang_deg, sunrise_events2[:ECLIP_HORIZON][1]]); }
            //if (hor_ang_deg <-1000) {deBug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!hor_ang" + [hor_ang_deg, sunrise_events2[:ECLIP_HORIZON][1]]); }


            deBug("hor_ang_rad, final_adj, ECLIP_HOR, EH*sid, max_hor, min_hor, norm180: ", [Math.toDegrees(hor_ang_rad), final_adj_deg, Math.toDegrees(sunrise_events2[:ECLIP_HORIZON][1]),  Math.toDegrees(sunrise_events2[:ECLIP_HORIZON][1] * sidereal_to_solar), (max_hor_ang), (min_hor_ang), temp, temp]);

            //System.println("hor_ang_deg: " + hor_ang_deg);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            //var hor_ang_rad = Math.toRadians(hor_ang_deg);
            var x_hor1 = radius* Math.cos(hor_ang_rad) + xct;
            var y_hor1 = radius* Math.sin(hor_ang_rad) + yct;
            var x_hor1a = .6*radius* Math.cos(hor_ang_rad) + xct;
            var y_hor1a = .6*radius* Math.sin(hor_ang_rad) + yct;
            var x_hor2 = -radius* Math.cos(hor_ang_rad) + xct;
            var y_hor2 = -radius* Math.sin(hor_ang_rad) + yct;
            var x_hor2a = -.6*radius* Math.cos(hor_ang_rad) + xct;
            var y_hor2a = -.6*radius* Math.sin(hor_ang_rad) + yct;
            dc.drawLine (x_hor1,y_hor1,x_hor1a,y_hor1a);
            dc.drawLine (x_hor2,y_hor2,x_hor2a,y_hor2a);
            
            dc.setPenWidth(2);
            //MERIDIAN
            var x_mer = radius* Math.cos(hor_ang_rad - Math.PI/2) + xct;
            var y_mer = radius* Math.sin(hor_ang_rad- Math.PI/2) + yct;
            var x_mera = .85*radius* Math.cos(hor_ang_rad- Math.PI/2) + xct;
            var y_mera = .85*radius* Math.sin(hor_ang_rad- Math.PI/2) + yct;            
            dc.drawLine (x_mer,y_mer,x_mera,y_mera);

        //drawARC (dc, sunrise_events[:NOON][0]-0.05+ noon_adj_hrs +  12, sunrise_events[:NOON][0]+0.05+ noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE);
    }
    */
    //}

    public function drawHorizon4(dc, xct as Lang.float, yct as Lang.float, radius as Lang.float){

  
            var hor_ang_rad = -Math.toRadians(sun_adj_deg - hour_adj_deg - noon_adj_deg) + sunrise_events2[:ECLIP_HORIZON];

            //f.deBug("hor_ang", [f.normalize(Math.toDegrees(hor_ang_rad)), sun_adj_deg, hour_adj_deg, noon_adj_deg, Math.toDegrees(sunrise_events2[:ECLIP_HORIZON])]);
            //var temp = f.f.normalize180(Math.toDegrees(hor_ang_rad));

             //y0 = (90 - temp)/90.0 * 23.4 * mcob + 50 * msob;

            //System.println("temp/hor_ang_rad: " + temp + " " + hor_ang_rad + " " + constrain(temp/360.0) * 24.0 + " " + (hor_ang_rad - Math.PI/2.0) + " " + constrain((hor_ang_rad - Math.PI/2.0)/2.0/Math.PI)*24.0 );
            //hor_ang_rad *= sidereal_to_solar; //convert to solar system frame of reference
            //if (temp > max_hor_ang) {max_hor_ang = temp;}
            //if (temp < min_hor_ang) {min_hor_ang = temp;}
            //if (hor_ang_deg > 1000) {deBug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!hor_ang" + [hor_ang_deg, sunrise_events2[:ECLIP_HORIZON][1]]); }
            //if (hor_ang_deg <-1000) {deBug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!hor_ang" + [hor_ang_deg, sunrise_events2[:ECLIP_HORIZON][1]]); }


            //deBug("hor_ang_rad, final_adj, ECLIP_HOR, EH*sid, max_hor, min_hor, norm180: ", [Math.toDegrees(hor_ang_rad), final_adj_deg, Math.toDegrees(sunrise_events2[:ECLIP_HORIZON][1]),  Math.toDegrees(sunrise_events2[:ECLIP_HORIZON][1] * sidereal_to_solar), (max_hor_ang), (min_hor_ang), temp, temp]);
            var refract_add = -Math.toRadians(-.56667);// - Math.toRadians(sr.sunEventData[:SUNRISE]);//The horizon is set to -0.5667 degrees to account for refraction.  We';re setting :SUNRISE equal to :HORIZON (making sunrise at center of sun rather than very top as is customary)
            //So that is NOT accounted for in  sunrise_events2[:ECLIP_HORIZON][1] . . . but IS in the drawn ARC sun events.
            //Also, below is all in the garmin native graphics, 0,0 in top left corner, so 0 degree is 3 o'clock position but then positive degrees
            //is CW (downwards) from there, so the reverse direction of standard.

            var arb_add = Math.toRadians(1.15); //not sure why this is needed, maybe bec it happens to be 2xrefract_add...

            //System.println("hor_ang_deg: " + hor_ang_deg);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            //var hor_ang_rad = Math.toRadians(hor_ang_deg);
            var x_hor1 = radius* Math.cos(hor_ang_rad + refract_add + arb_add) + xct;
            var y_hor1 = radius* Math.sin(hor_ang_rad + refract_add + arb_add) + yct;
            var x_hor1a = .6*radius* Math.cos(hor_ang_rad + refract_add + arb_add) + xct;
            var y_hor1a = .6*radius* Math.sin(hor_ang_rad + refract_add + arb_add) + yct;
            var x_hor2 = -radius* Math.cos(hor_ang_rad - refract_add + arb_add) + xct;
            var y_hor2 = -radius* Math.sin(hor_ang_rad - refract_add + arb_add) + yct;
            var x_hor2a = -.6*radius* Math.cos(hor_ang_rad - refract_add + arb_add) + xct;
            var y_hor2a = -.6*radius* Math.sin(hor_ang_rad - refract_add + arb_add) + yct;
            dc.drawLine (x_hor1,y_hor1,x_hor1a,y_hor1a);
            dc.drawLine (x_hor2,y_hor2,x_hor2a,y_hor2a);
            
            dc.setPenWidth(2);
            //MERIDIAN
            var x_mer = radius* Math.cos(hor_ang_rad - Math.PI/2.0 + arb_add) + xct;
            var y_mer = radius* Math.sin(hor_ang_rad - Math.PI/2.0 + arb_add) + yct;
            var x_mera = .85*radius* Math.cos(hor_ang_rad  - Math.PI/2.0 + arb_add) + xct;
            var y_mera = .85*radius* Math.sin(hor_ang_rad  - Math.PI/2.0 + arb_add) + yct;            
            dc.drawLine (x_mer,y_mer,x_mera,y_mera);

        //drawARC (dc, sunrise_events[:NOON][0]-0.05+ noon_adj_hrs +  12, sunrise_events[:NOON][0]+0.05+ noon_adj_hrs  + 12, xc, yc, r, 10, Graphics.COLOR_WHITE);
    }

    /*
    //An S-shaped curve
    function sigmoid(x) {
        //return 1.0f / (1.0f + Math.pow(2.71828f,-10*(x-.5))); //too steep/flat
        //return 1.2f / (1.0f + Math.pow(1.6f,-10*(x-.5))) - 0.1f;
        return 1.106f / (1.0f + Math.pow(1.8f,-10*(x-.5))) - 0.0525f;
        //\frac{1}{\left(1+e^{-10\left(x-.5\right)}\right)}
    }
    */

    /*
    //half circle bottom displaced leftward for 0-0.5, top of circle displaced rightwards for 0.5-1.  So it makes a sort of a slanted S shape.  Similar to sigmoid, but more linear in the middle
    function circly(x) {
        
        if (x>0.5) { return 0.5f + 0.5f*Math.sqrt(1 - (2*x-2)*(2*x-2)); }
        else { return 0.5f - 0.5f*Math.sqrt(1 - (2*x)*(2*x)); }
    }   

    //not all pows work, neg sqrt neg 1 stuff if not careful.  1.52, 1.6, and pos. integer
    function circlypow(x,pow) {
        
        if (x>0.5) { return 0.5f + 0.5f*Math.sqrt(1 - Math.pow(2*x-2,pow)); }
        else { return 0.5f - 0.5f*Math.sqrt(1 - Math.pow(2*x,pow)); }
    }
    */

/*
    public function drawHorizon4(dc, now_info, timeZoneOffset_sec, dst, time_add_hrs, xct as Lang.float, yct as Lang.float, radius as Lang.float, drawCircle) {
    // Get the current Julian date
    var current_JD = f.julianDate(now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, timeZoneOffset_sec / 3600, dst);
    
    // Get the right ascension and declination of the Sun
    var sun_radec = planetCoord(now_info, timeZoneOffset_sec, dst, time_add_hrs, :ecliptic_latlon, ["Sun"]);
    var sun_RA_deg = sun_radec["Sun"][0];
    var sun_Dec_deg = sun_radec["Sun"][1];
    
    // Get the rise and set times of the Sun
    var sunrise_events = getRiseSetfromDate_hr(now_info, timeZoneOffset_sec, dst, time_add_hrs, lastLoc[0], lastLoc[1], sun_radec["Sun"]);
    var sunrise_time = sunrise_events[:SUNRISE][0];
    var sunset_time = sunrise_events[:SUNRISE][1];
    
    // Calculate the current time as a fraction of the day
    var current_time = now_info.hour + now_info.min / 60.0 + time_add_hrs;
    var day_fraction = current_time / 24.0;
    
    // Calculate the position of the horizon line
    var sun_RA_pct = constrain((sun_RA_deg - 270.0f) / 360.0f);
    var fact = day_fraction - sun_RA_pct;
    fact = constrain(fact);
    
    // Draw the horizon line
    drawHorizon2(dc, 21, fact, xct, yct, radius, drawCircle);
}
    
*/
    
    
//public function getMessage () {
        /*
        var x =  40000000000001l;
        var y =  -4000000000001l;
        _lines = [f.normalize (400.0).toString(),
        f.normalize (-400f),
        f.normalize (-170f),
        f.normalize (400f),
        f.normalize (170l),
        f.normalize(-570l),
        f.normalize(735f),];
        
        return;
        */
        /*
        // TEST CODE
        var x =  400000000000001.348258f;
        var y =  -400000000000001.944324f;
        _lines = [spherical2rectangular(x,y,1),
        spherical2rectangular(90,90,1),
        spherical2rectangular(180,180,1),
        spherical2rectangular(270,270,1),
        spherical2rectangular(270,90,1),
        spherical2rectangular(270000000.0,90f,1),
        ];
        var z = rectangular2spherical(1,0,0);
        _lines = [z,
        rectangular2spherical(0,-1,0),
        rectangular2spherical(0,0,1),
        rectangular2spherical(0,x,x),
        rectangular2spherical(270,-270,0),
        rectangular2spherical(90,0,-90),
        
        ];

        _lines = [z,
        ecliptic2equatorial(0,-1,0,1),
        ecliptic2equatorial(0,0,1,5),
        ecliptic2equatorial(0,x,x,-x),
        ecliptic2equatorial(270,-270,0,180),
        ecliptic2equatorial(90,0,-90,90),
        
        ];

        _lines = [z,
        equatorial2ecliptic(0,-1,0,1),
        equatorial2ecliptic(0,0,1,5),
        equatorial2ecliptic(0,x,x,-x),
        equatorial2ecliptic(270,-270,0,180),
        equatorial2ecliptic(90,0,-90,90),
        
        ];

        _lines = [z,
        spherical_ecliptic2equatorial(0,-1,0,1),
        spherical_ecliptic2equatorial(0,0,1,5),
        spherical_ecliptic2equatorial(0,x,x,-x),
        spherical_ecliptic2equatorial(270,-270,0,180),
        spherical_ecliptic2equatorial(90,0,-90,90),
        
        ];

        _lines = [decimal2clock(2.02504),
        decimal2clock(.502/60),
        decimal2clock(-12.090055555),
        decimal2clock(18.0505542345),
        decimal2clock(-2.025404654357),
        decimal2clock(-18.050543234),
        decimal2clock(-.033033333222341123),
        decimal2clock(-117.033003333355544532),
        
        ];


        _lines = [decimal2hms(279.02504),
        decimal2hms(-279.02504),
        decimal2hms(-12.090055555),
        decimal2hms(12.090055555),
        decimal2hms(302),
        decimal2hms(-302),
        decimal2hms(-507),
        decimal2hms(507),
        
        ];

        _lines = [Planet_Sun(48, .006, .72, 77, 54, 3.4),
        f.Planet_Sun(77,3.4, 54.9, .7, .006, 48),
        "247° 27'",
        

        
        
        ];
        */
        /*
        _lines = [sun2planet(2.02504),
        sun2planet(.502/60),
        sun2planet(-12.090055555),
        sun2planet(18.0505542345),
        sun2planet(-2.025404654357),
        sun2planet(-18.050543234),
        sun2planet(-.033033333222341123),
        sun2planet(-117.033003333355544532),
        
        ];
        */
        /*
                _lines = [z,
        decimal2arcs(60),
        decimal2arcs(60.25),
        decimal2arcs(-60),
        decimal2arcs(-60.25),
        decimal2arcs(-1.2),
        
        ];
        */

    //}

    //! Set the position
    //! @param info Position information
    /*
    public function setPosition(info as Info) as Void {
        _lines = [];

        var position = info.position;
        if (position != null) {
            _lines.add("lat = " + position.toDegrees()[0].toString());
            _lines.add("lon = " + position.toDegrees()[1].toString());
        }

        var speed = info.speed;
        if (speed != null) {
            _lines.add("speed = " + speed.toString());
        }

        var altitude = info.altitude;
        if (altitude != null) {
            _lines.add("alt = " + altitude.toString());
        }

        var heading = info.heading;
        if (heading != null) {
            _lines.add("heading = " + heading.toString());
        }

        WatchUi.requestUpdate();
    }
    */
    /*
    function setPositionFromManual() as Boolean {
        //deBug("SIP 2", null);
        if ($.Options_Dict[gpsOption_enum]) { return false;}
        if ($.latlonOption_value[0] < 0) {$.latlonOption_value[0] = 0;}
        if ($.latlonOption_value[0] > 180) {$.latlonOption_value[0] = 180;}
        if ($.latlonOption_value[1] < 0) {$.latlonOption_value[1] = 0;}
        if ($.latlonOption_value[1] > 360) {$.latlonOption_value[1] = 360;}
        //deBug("SIP 3", null);
        lastLoc= [$.latlonOption_value[0]-90, $.latlonOption_value[1]-180];
        //deBug("SIP 4", lastLoc);
        return true;       
    }
    */

    //Until setPosition gets a callback we will use SOME value for lastLoc
    //We call setInitPosition immeidately upon startup & then setPosition will fill in
    //later as correct data is available.
    function setInitPosition () {        
        //lastLoc = [-70.00894, -179.44008]; //for testing
        //lastLoc = [-60.00894, 179.44008]; //for testing
        //lastLoc = [39.00894, -94.44008]; //for testing
        //lastLoc = [59.00894, -94.44008]; //for testing
        //lastLoc = [0,0]; //for testing
        //lastLoc = [51.5, 0]; //for testing - Greenwich
        //deBug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TESTINGTESTINGTESTING LAT/LONG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", lastLoc);
        //return;

        //in case MANUAL POSITION set in settings
        //deBug("SIP 1", null);
        
        setPosition(null);

        /*

        //this is pretty much redundant with setPosition now, could be removed??
        if (lastLoc == null ) {
            if (lastLoc == null) {self.lastLoc = new Position.Location(            
                        { :latitude => 39.833333, :longitude => -94.583333, :format => :degrees }
                        ).toDegrees(); }
            if ($.Options_Dict.hasKey(lastLoc_enum)) {lastLoc = $.Options_Dict[lastLoc_enum];}
            
            var temp = Storage.getValue(lastLoc_enum);
            if (temp!=null) {lastLoc = temp;}
            Storage.setValue(lastLoc_enum, lastLoc);
            $.Options_Dict.put(lastLoc_enum, lastLoc);
        }
        //System.println("setINITPosition at " + animation_count + " to: "  + lastLoc);
        */
    }

    //fills in the variable lastLoc with current location and/or
    //several fallbacks
    function setPosition (pinfo as Info) {
        System.println ("setPosition");
        var curr_pos = null;
        

        //We only need this ONCE, not continuously, so . . . 
        //Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:setPosition));

        //lastLoc = [0,0]; //for testing
        //lastLoc = [51.5, 0]; //for testing - Greenwich
        //lastLoc = [39.00894, -94.44008]; //for testing
        //lastLoc = [-60.00894, 179.44008]; //for testing
        //lastLoc = [-70.00894, -179.44008]; //for testing
        //deBug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TESTINGTESTINGTESTING LAT/LONG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", lastLoc);        
        //return;

        //in case MANUAL POSITION set in settings
        //var man_set = setPositionFromManual(); //will be TRUE if the position is set manually
        var man_set = false;
        //We still go ahead & try to determine the actual GPS position & save it in options_dict & storage
        //for future use

        //if (info == null || info.position == null) { pinfo = Position.getInfo(); }
        //System.println ("sc1: Null? " + (pinfo==null));
        //if (pinfo != null ) {deBug ("setPosition getting position from OS:",  pinfo.position.toDegrees());}

        //From activity is the PREFERRED way for watch faces
        if (curr_pos == null) {
            var a_info = Activity.getActivityInfo();
            var a_pos = null;
            System.println ("sc1.2:Activity a_pos==Null3? " + (a_pos==null));
            
             if (a_info!=null && a_info has :currentLocation && a_info.currentLocation != null)
                { a_pos = a_info.currentLocation;}
            //System.println ("setPosition4");
            if (a_pos != null ) {
                System.println ("Position: Got from Activity.getActivityInfo() currentLocation" + a_pos + " " + a_pos.toDegrees());
                curr_pos = a_pos; 
            }
        }

        
        if (pinfo!= null && pinfo.position != null) { curr_pos = pinfo.position; }
        else { //if there is nothing in the pinfo passed to us we just try to grab it now (ie, at init)
            pinfo = Position.getInfo(); 
            if (pinfo!= null && pinfo.position != null) { curr_pos = pinfo.position; }
        }
        
        var temp = curr_pos.toDegrees()[0];
        if ( (temp - 180).abs() < 0.1 || temp.abs() < 0.1 ) {curr_pos = null;} //bad data
        

        /*
        //this is giving errors, IQ! screen on wathc???///???!!!!
        //so just removing for now  2024/12/11
        try {
            if (curr_pos == null && Toybox has :Weather) {

                if (Toybox has :Weather) {
            		var currentConditions = Weather.getCurrentConditions();
                    if (currentConditions != null && currentConditions.observationLocationPosition != null) {
                    curr_pos = currentConditions.observationLocationPosition;
                    }
	            }
                if (curr_pos != null && curr_pos has :toDegrees) {
                    temp = curr_pos.toDegrees()[0];
                    if ( temp == null || temp == 180 || temp == 0 ) {curr_pos = null;} //bad data
                }
            }
        } catch (e instanceof Lang.Exception) {
            System.println("This device does not have Toybox.Weather - skipping this method of obtaining position information. Error: " + e);
        }

        */

        /* //skipping for memory purposes
        if (curr_pos == null) {
            var a_info = Activity.getActivityInfo();
            var a_pos = null;
            //System.println ("sc1.2:Activity a_pos==Null3? " + (a_pos==null));
            
            if (a_info!=null && a_info has :position && a_info.position != null)
            { a_pos = a_info.position;}
            if (a_pos != null ) {
                //System.println ("sc1.2: a_pos " + a_pos.toDegrees());
                curr_pos = a_pos; 
            }
        }
        */
        

        //System.println ("sc1a:");
        //In case position info not available, we'll use either the previously obtained value OR the geog center of 48 US states as default.
        //|| info.accuracy == Pos.QUALITY_NOT_AVAILABLE 

        var new_lastLoc = null;
        if ($.Options_Dict.hasKey(lastLoc_saved))
           {
            new_lastLoc = $.Options_Dict[lastLoc_saved]; //:lastLoc ==99, for some reason it won't take the symbol directly
            
           }

        if (curr_pos == null ){
           if (new_lastLoc == null) { 
                var long = -98.583333; 

                //approximate longitude from time zone offset if no other option
                $.now = System.getClockTime();
                if ($.now != null && $.now.timeZoneOffset != null) { long = $.now.timeZoneOffset/3600*15;}

                new_lastLoc = new Position.Location(            
                    { :latitude => 39.833333, :longitude => long, :format => :degrees }
                    ).toDegrees();
                    //System.println ("sc1b: " + self.lastLoc);
           }
        } else {

            var loc = curr_pos.toDegrees();
            new_lastLoc = loc;
            //System.println ("sc1c:"+ curr_pos.toDegrees());
            //System.println ("sc1c");
        }        


        //System.println ("sc2");
        
        //$.Options_Dict["Location"] = [self.lastLoc, $.now.value()];
        //Storage.setValue("Location",$.Options_Dict["Location"]);
        //System.println ("sc3");
        /* For testing
           now = new Time.Moment(1483225200);
           self.lastLoc = new Pos.Location(
            { :latitude => 70.6632359, :longitude => 23.681726, :format => :degrees }
            ).toRadians();
        */
        //System.println ("lastLoc: " + new_lastLoc );

        if (new_lastLoc != null && new_lastLoc.size()>1) {
            $.Options_Dict.put(lastLoc_saved, new_lastLoc);            
            Storage.setValue(lastLoc_saved, new_lastLoc); //:lastLoc ==99, for some reason it won't take the symbol directly
        }
        
        if (!man_set) {self.lastLoc = new_lastLoc;} //if man_set is true, then we don't want to update self.lastLoc with the new value, we want to keep the value that was set by the user.

        System.println("setPosition (from GPS, final) at " + animation_count + " to: "  + new_lastLoc + " manual GPS mode?" + man_set + " final SET pos: " + self.lastLoc);
        return man_set;
    }

    /*
    //Not sure if this is really necessary for display of  ecliptic planets.  But it does very slightly alter proportions, and makes the 4 ecliptic points fit in as they should.
    private function flattenEclipticPP(obliq_deg){
        var obleq_rad = obliq_deg * Math.PI / 180;
        var mcob = Math.cos(obleq_rad);
        var msob = Math.sin(obleq_rad);
        var kys = pp.keys();
        
        for (var i = 0; i<kys.size(); i++) {
            key = kys[i];
            //deBug("flattenEclipticPP: ", [ key + " " + pp[key]]);
            
            z0 = pp[key][2] * mcob - pp[key][1] * msob;
            y0 = pp[key][1] * mcob + pp[key][2] * msob;

                         
            pp[key][1] = y0;// * pers_fact; // * pers_fact;
            pp[key][2] = z0;  
        }

    }
    */

    

}

