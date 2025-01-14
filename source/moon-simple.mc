/***************************************************************************************
* SIMPLIFIED Small & Fast Moon Position & Phase Calculator
*
***************************************************************************************/

//The average duration in modern times is 29.53059 days with up to seven hours variation about the mean in any given year.[7] (which gives a mean synodic month as 29.53059 days or 29 d 12 h 44 min 3 s)[a] A more precise figure of the average duration may be derived for a specific date using the lunar theory of Chapront-Touzé and Chapront (1988):
//29.5305888531 + 0.00000021621T − 3.64×10−10T2 where T = (JD − 2451545.0)/36525 and JD is the Julian day number (and JD = 2451545 corresponds to 1 January AD 2000 at Noon.)
//Source: https://en.wikipedia.org/wiki/Lunar_month#Synodic_month
//
//This is an approximation and any phase/full moon may be off by as much as +/- 7 hours. The moon moves about 0.5 degrees per hour against the background stars, so the difference may be about +/- 3.5 degrees visually or +/- 12 minutes.  This is large enough to be seen visually on i.e. even a small
//24-hour clock dial but considering we are only showing a approx. sky positions & rough moon quarter this probably good enough for many applications.

import Toybox.Math;
import Toybox.System;
import Toybox.Lang;

(:glance)
class simpleMoon {

//class simpleMoon {
   /*
    //  can use Time.Gregorian.info() output for now_info &
    // now = System.getClockTime(); output for now.timeZoneOffset and now.dst
    //Note timeZoneOffset_sec is SECONDS not hours
    public function synodicMonthLength_days(now_info, timeZoneOffset_sec, dst ) {
        if (timeZoneOffset_sec == null) {timeZoneOffset_sec = 0;}
        if (dst == null) {dst = 0;}


        var JD = f.julianDate (now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, timeZoneOffset_sec/3600, dst);

        var T = (JD - 2451545.0)/36525f;

        return 29.5305888531f + 0.00000021621f* T - 3.64E-10 * T*T;
    }

    //Using above month length, you can calculate new moon etc starting with any
    //known new moon date/time
    //We will use: 2025 Jan 29  12:36 UTC
    // JD = 2460705 ; 2460705.025000
    //This will return the current % of lunar phase as a number ranging 0 to 1
    // 0 & 1 are new moon, 0.5 full moon, etc.
    //returns a triplet: [lunar phase(0-1), current lunar day, synodic month length in days]

    public function lunarPhase (now_info, timeZoneOffset_sec, dst) {

        var sml_days  = synodicMonthLength_days(now_info, timeZoneOffset_sec, dst );
        var base_JD = f.julianDate (2025, 1, 29 , 12, 36, 0, 0);
        var current_JD = f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, timeZoneOffset_sec/3600, dst);

        var difference = current_JD - base_JD;

        var lunar_day = f.mod (difference, sml_days);

        var lunar_phase = lunar_day/sml_days;

        return [lunar_phase, lunar_day, sml_days];

    }
    */

    public function eclipticPos_moon (now_info, timeZoneOffset_sec, dst,  addTime_hrs) {

        //deBug("moonret: ", [now_info, timeZoneOffset_sec, dst, addTime_hrs]);
        //var sml_days  = synodicMonthLength_days(now_info, timeZoneOffset_sec, dst );
        //var base_JD = f.julianDate (2025, 1, 29 , 12, 36, 0, 0);
        var current_JD = f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, timeZoneOffset_sec/3600, dst);
        current_JD += addTime_hrs/24.0;
        var ret = getGeocentricMoonPos(current_JD);
        return ret;
    }

    // Low Precision Moon Position
    //Accurate to .5 deg over period 1900-2100
    // Source
    // https://celestialprogramming.com/lowprecisionmoonposition.html
    //Input: Julian Date
    //Output: Ecliptical Long, Lat in degrees
    // (rem-ed out portion converts this to geocentric RA & Decl)

    
    public function getGeocentricMoonPos(jd){
	var T = ((jd-2451545)/36525).toFloat();
	var L = 218.32f + 481267.881f*T + 6.29f*f.sind(135.0f + 477198.87f*T) - 1.27f*f.sind(259.3 - 413335.36f*T) + 0.66f*f.sind(235.7f + 890534.22f*T) + 0.21f*f.sind(269.9f + 954397.74f*T) - 0.19f*f.sind(357.5f + 35999.05f*T) - 0.11f*f.sind(186.5f + 966404.03f*T);
	var B = 5.13f*f.sind( 93.3f + 483202.02f*T) + 0.28f*f.sind(228.2f + 960400.89f*T) - 0.28f*f.sind(318.3f + 6003.15f*T) - 0.17f*f.sind(217.6f - 407332.21f*T);
    //P is the parallax factor, radius (in earth radii?) r= 1/sin(P)

	//var P = 0.9508 + 0.0518*cosd(135.0 + 477198.87*T) + 0.0095*cosd(259.3 - 413335.36*T) + 0.0078*cosd(235.7 + 890534.22*T) + 0.0028*cosd(269.9 + 954397.74*T);

    //This would return ECLIPTICAL LAT & LONG in degrees
    //var ret = [(f.normalize(L)).toFloat(),(f.normalize(B)).toFloat()];
    //deBug("moonret: ", [jd]);
    //return ret;

    
    //convert to geocentric ra & decl
	//var SD=0.2724*P;
	//var r=1/f.sind(P);

	var l = f.cosd(B) * f.cosd(L);
	var m = 0.9175*f.cosd(B)*f.sind(L) - 0.3978*f.sind(B);
	var n = 0.3978*f.cosd(B)*f.sind(L) + 0.9175*f.sind(B);

	var ra=Math.atan2(m,l);
	if(ra<0){ra+=2*Math.PI;}
	var dec=Math.asin(n);
	return [Math.toDegrees(ra).toFloat(),Math.toDegrees(dec).toFloat()];
    
    }

//}
}