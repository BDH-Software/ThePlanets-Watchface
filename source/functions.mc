/*************************************************************
*
* Adapted directly from:
* SolarSystem by Ioannis Nasios 
* https://github.com/IoannisNasios/solarsystem
*
* LICENSE & COPYRIGHT:
* The MIT License, Copyright (c) 2020, Ioannis Nasios
*
***************************************************************/

import Toybox.Math;
import Toybox.System;
import Toybox.Lang;    
//degree_sign= u'\N{DEGREE SIGN}';



    const sidereal_to_solar = 1.00273790935; //sidereal to solar time ratio 86400/86164.0905

    var fc = 0.0000001; //correction for Math.floor to avoid like 49.999999999

    var FN_obliq_deg as Lang.float = 23.4392911;
    var FN_obliq_save_time_add_hrs = null;

    var J2000_0= 2451543.5d; // 2000 Jan 0.0 TDT, which is the same as 1999 Dec 31.0 TDT, i.e. precisely at midnight TDT  (Jan 0.0 is not the first day of January but rather the LAST day of December, so a full day before Jan 1.0)
    //This is actually NOT the same as J2000, which is 1 Jan 2000 at noon, Julian Date 2451545, or 2000 Jan 1.5.
    //This MIGHT be a mistake by someone who was trying to use J2000 but missed by a little?  In obliquity of ecliptic calc below the difference will be negligible.

    var J2000 = 2451545d; //start of J2000 epoch

(:glance)
module f {

    function normalize(degrees) {  
        /*
        set degrees always between 0 - 360
        
        Args:
            degrees (float): degrees to be adjusted
            
        Returns:
            float: degrees between 0-360
            
        */
        switch (degrees) {
            case instanceof Number:
            case instanceof Long:
                if (degrees >= 0) { return degrees%360;}
                else {return degrees%360 + 360;}
            //case instanceof Long:
            //    return degrees%360;
            default:
                return ((degrees/360.0 - Math.floor(degrees/360.0 + fc)) *360.0).toFloat();
        }        

    }

    function normalize180(degrees) {  
        /*
        set degrees always between -180 to 180
        
        Args:
            degrees (float): degrees to be adjusted
            
        Returns:
            float: degrees between -180 and 180
            
        */
        var d = normalize(degrees);
        if (d > 180) {return d - 360;}
        return d;
        
        /*
        var ret;
        switch (degrees) {
            case instanceof Number:
            case instanceof Long:
                if (degrees >= 0) { ret = degrees%360 - 180;}
                else {ret = degrees%360 + 180;}
                
            //case instanceof Long:
            //    return degrees%360;
            default:
                ret = ((degrees/360.0 - Math.floor(degrees/360.0 + fc)) *360.0).toFloat();
        }  

        if (ret > 180 ) { return ret - 360;}
        return ret;    
        */  
    }
    //modular division for floats/doubles
    //a mod b
    //Has a little correction to avoid issues with fp&double numbers like
    // 1.99999999 (rounds to 2 instead of 1)
    function mod (a ,b) {
        if (b ==0) { return 0; }
        return ((a/b - Math.floor(a/b + fc)) *b).toFloat();
    }

    /*
    //QUADRANT FUNCTIONS all work find but we're not using them now
    function quadrant_deg(ang_deg){
        //returns the quadrant of the angle in degrees
        //0 = 0-90, 1 = 90-180, 2 =
        //3 = 180-270, 4 = 270-360
        ang_deg = normalize (ang_deg);
        if (ang_deg < 90) {return 0;}
        if (ang_deg < 180) {return 1;}
        if (ang_deg < 270) {return 2;}
        return 3;
    }

    function quadrant_rad(ang_rad){
        //returns the quadrant of the angle in radians
        return quadrant_deg(Math.toDegrees(ang_rad));
    }

    function sameQuadrant_rad(ang1_rad, ang2_rad){
        //returns true if two angles are in the same quadrant
        var diff_rad = ang1_rad-ang2_rad;
        diff_rad = mod(diff_rad,Math.PI*2.0);
        return (diff_rad < Math.PI);
    }
    */


        




    //Julians MUST be double or they have accuracy of only .25 day even in 2024 already.
    function julianDate (year as Lang.double, month as Lang.double, day as Lang.double, hour as Lang.double, min as Lang.double, UT as Lang.double, dst as Lang.double) as Lang.double {


        var pr=0d;
        if (dst==1) {pr=1/24.0d;}
        //note SUBTRACTION of UT which is correct for this direction of the conversion
        var JDN= ((367l*(year) - Math.floor(7l*(year + Math.floor((month+9l )/12l))/4l)) + Math.floor(275l*(month)/9l) + (day + 1721013.5d - UT/24.0d ) );
        var JD= (JDN + (hour)/24.0d + min/1440.0d - pr); //(hour)/24 + (min)/1440; in this case  noon (hr12, min0)
        return JD;

    }

/****************** note different version below which  accounts for date prior to 1582...
/*
    function gregorianDateToJulianDate(year, month, day, hour, min, sec)as Lang.double {

	var isGregorian=true;
	if(year<1582 || (year == 1582 && (month < 10 || (month==10 && day < 5)))){
		isGregorian=false;
	}

	if (month < 3){
		year = year - 1;
		month = month + 12;
	}

	var b = 0;
	if (isGregorian){
	var a = INT(year / 100.0d);
		b = 2 - a + INT(a / 4.0d);
        deBug("JD: a,b: ", [a,b]);
	}
    var jd = 0.0d;    
	jd=INT(365.25d * (year + 4716d)) + INT(30.6001d * (month + 1)) + day + b - 1524.5d;
    deBug("JD: jd: ", [jd, 365.25d * (year + 4716d),INT(365.25d * (year + 4716d)), 30.6001d * (month + 1),INT(30.6001d * (month + 1)), day, b]);
    jd = jd.toDouble();

    deBug("JD2: jd: ", [jd]);

	jd+=hour/24.0d;
	jd+=min/24.0d/60.0d;
	jd+=sec/24.0d/60.0d/60.0d;
    deBug("JD3: jd: ", [jd, hour, min, sec]);
	return jd;
} */

    function j2000_0Date  (year, month, day, hour, min, UT, dst) as Lang.double {

        var JD = julianDate(year, month, day, hour, min, UT, dst);
        
        return JD - J2000_0;


    }

    function j2000Date (year, month, day, hour, min, UT, dst) as Lang.double {

        var JD = julianDate(year, month, day, hour, min, UT, dst);
        
        return JD - J2000;


    }

    function obliquityEcliptic_deg (year, month, day, hour, min, UT, dst) {

        var d = j2000_0Date(year, month, day, hour, min, UT, dst);
        
        return 23.4393f - 3.563E-7f * d; //obliquity of the ecliptic, i.e. the "tilt" of the Earth's axis of rotation (currently 23.4 degrees and slowly decreasing)
        
    }

    function obliquityEcliptic_rad (year, month, day, hour, min, UT, dst) {

        return Math.toRadians (obliquityEcliptic_deg(year, month, day, hour, min, UT, dst));
        
    }

    //CACHED versions of the obliquity, that only change every 500 yrs.  Bec Obliquity changes so slowly
    function calc_obliq_deg(nw_info, nw)  as Lang.float {

            return calc_obliq1_deg(nw_info, time_add_hrs, nw.timeZoneOffset, nw.dst);

            /*var ret_deg as Lang.float = 23.4392911;
            if (FN_obliq_deg == null || FN_obliq_save_time_add_hrs == null || FN_obliq_deg == 0 || (FN_obliq_save_time_add_hrs - time_add_hrs).abs() > 4380000 ) // = 500 yrs, the value of obliq barely changes year per year
                { ret_deg= obliquityEcliptic_deg (nw_info.year, nw_info.month, nw_info.day + time_add_hrs, nw_info.hour, nw_info.min, nw.timeZoneOffset/3600.0, nw.dst);
            else {
                ret_deg = curr_val_deg;
            }
            FN_obliq_deg = ret_deg;
            FN_obliq_save_time_add_hrs = time_add_hrs;
            return ret_deg;
            */

    }

    function calc_obliq1_deg(nw_info, ta_hrs, tZO_sec, dst)  as Lang.float {

            var ret_deg= 23.439291;
            if (FN_obliq_deg == null || FN_obliq_save_time_add_hrs == null || FN_obliq_deg == 0 || (FN_obliq_save_time_add_hrs - ta_hrs).abs() > 4380000 ) // = 500 yrs, the value of obliq barely changes year per year
                { ret_deg= obliquityEcliptic_deg (nw_info.year, nw_info.month, nw_info.day + time_add_hrs, nw_info.hour, nw_info.min, tZO_sec/3600.0, dst);
            } else {
                ret_deg = FN_obliq_deg;
            }
            FN_obliq_deg = ret_deg;
            FN_obliq_save_time_add_hrs = time_add_hrs;
            return ret_deg;

    }

    /*

     //Works great, just not using it
     function rectangular2spherical(x, y, z) {
        /*Transform rectangular to spherical projection.
        
        From rectangular(x,y,z) coordinates system to spherical (RA,Decl, r) or 
        by replacing x with azimuth and y with altitude we can tranform 
        horizontal coordinates to ecliptic (longitude, latitude).
        
        Args:
            x: value on x axis of a rectangular projection.
            y: value on y axis of a rectangular projection.
            z: value on z axis of a rectangular projection.
    
        Returns:
            tuple: RA, Decl, r spherical coordinate system. 
            
        */
        /*
        var r    = Math.sqrt( x*x + y*y + z*z );
        var RA   = Math.atan2( y, x );
        //    var Decl = Math.asin( z / r ) ;
        var Decl = Math.atan2( z, Math.sqrt( x*x + y*y ) );

        //System.println( "rRADecl: " + r + " " + RA + " " + Decl);
        
        RA = normalize(Math.toDegrees(RA));
        Decl = (Math.toDegrees(Decl));
        return [RA, Decl, r]    ;

    }

    */
    
    
    function sind (deg)  {
        return Math.sin(Math.toRadians(deg));
    }
    
    function cosd (deg)  {
        return Math.cos(Math.toRadians(deg));
    }
    



    function Planet_Sun(M, e, a, N, w, i) {
        /*
        Helper Function. From planet's trajectory elements to position around sun
        Used extensively in VSOP87A calcs
            
        Returns:
            tuple: position elements
            
        */

        var M2=Math.toRadians(M);
        var E0=M + (180/Math.PI)*e*Math.sin(M2)*(1+e*Math.cos(M2));
        E0=normalize(E0) ;
        var E02=Math.toRadians(E0);
        var E1=E0 - (E0 - (180/Math.PI)*e*Math.sin(E02)-M)/(1-e*Math.cos(E02));
        E1=normalize(E1) ;
        var E=Math.toRadians(E1);
        var x=a*(Math.cos(E)-e);
        var y=a*(Math.sqrt(1 - e*e))*Math.sin(E);

        var r=Math.sqrt(x*x+y*y);
        var v=Math.atan2(y, x);
        v=normalize(Math.toDegrees(v));

        var xeclip=r*(Math.cos(Math.toRadians(N))*Math.cos(Math.toRadians(v+w)) - Math.sin(Math.toRadians(N))*Math.sin(Math.toRadians(v+w))*Math.cos(Math.toRadians(i)));
        var yeclip=r*(Math.sin(Math.toRadians(N))*Math.cos(Math.toRadians(v+w)) + Math.cos(Math.toRadians(N))*Math.sin(Math.toRadians(v+w))*Math.cos(Math.toRadians(i)));
        var zeclip=r*Math.sin(Math.toRadians(v+w))*Math.sin(Math.toRadians(i)) ;
        var long2 = Math.atan2( yeclip, xeclip );
        long2=normalize(Math.toDegrees(long2));
        var lat2 = Math.atan2( zeclip, Math.sqrt( xeclip*xeclip +yeclip*yeclip ) );
        lat2=Math.toDegrees(lat2);
        //return {:xeclip => xeclip,:yeclip => yeclip, :zeclip => zeclip, :long2 => long2, :lat2=>lat2, :r => r};
        return [xeclip,yeclip,zeclip,long2,lat2,r];

    }

/*

    //This works fine, we're just no using it now
    function sun2planet(xeclip, yeclip, zeclip, x, y, z) {
        /*
        Helper Function. From Heliocentric to Geocentric position
            
        Returns:
            tuple: geocentric view of object.
            
        */
        /*
        var x_geoc=(x+xeclip);
        var y_geoc=(y+yeclip);
        var z_geoc=(z+zeclip);
        //System.println("sun2peclip: " + xeclip +" " + yeclip +" " + zeclip +" ");
        //System.println("sun2pxyz: " + x +" " + y +" " + z +" ");
        //System.println("sun2p: " + x_geoc +" " + y_geoc +" " + z_geoc +" ");
        return rectangular2spherical(x_geoc, y_geoc, z_geoc);
        //    t = ecliptic2equatorial(x_geoc, y_geoc, z_geoc, 23.4);
        //    return rectangular2spherical(t[0],t[1],t[2]);
    }
*/


//}

/*
////insertionSort works fine but we're not using it right now. Quicksort is (maybe) a tad quickers.
//given a dict with keys =kyss & values an array [1,2,3,4,5...]
//and separate send the keys kys (or perhaps they are a separate array...)
//will return an array with the keys sorted ascending on the nth value of the array
function insertionSort(kys, dict, n) {
    //var kys = dict.getKeys();
    for (var i = 1; i < kys.size(); i++) {
        var kkey = kys[i];
        var sorton = dict[kkey][n];
        
        var j = i - 1;

        // Move elements of dict[0..i-1], that are greater than key,
        // to one position ahead of their current position
        while (j >= 0 && dict[kys[j]][n] > sorton) {
            kys[j + 1] = kys[j];
            j = j - 1;
        }
        kys[j + 1] = kkey;
    }


    return kys;
}
*/

/*
// Given a dict with keys = kys & values an array [1,2,3,4,5...]
// and separate send the keys kys (or perhaps they are a separate array...)
// will return an array with the keys sorted ascending on the nth value of the array
function countingSort(kys, dict, n, min_z, max_z) {
    // Calculate the range of the Z values
    var range = max_z - min_z + 1;
    
    // Create a count array to store the count of each Z value
    var count = [];
    for (var i = 0; i < range; i++) {
        count.add(0); // Initialize count array
    }

    // Create an output array to store the sorted keys
    var output = [];
    output.addAll(count);

    // Count occurrences of each Z value
    for (var i = 0; i < kys.size(); i++) {
        var kkey = kys[i];
        var zValue = dict[kkey][n];
        count[zValue - min_z]++; // Increment the count for the corresponding Z value
    }

    // Change count[i] so that it contains the actual position of this Z value in output
    for (var i = 1; i < range; i++) {
        count[i] += count[i - 1];
    }

    // Build the output array
    for (var i = kys.size() - 1; i >= 0; i--) {
        var kkey = kys[i];
        var zValue = dict[kkey][n];
        output[count[zValue - min_z] - 1] = kkey; // Place the key in the output array
        count[zValue - min_z] = count[zValue - min_z] -1; // Decrease the count for this Z value
    }

    return output; // Return the sorted keys
}
*/

/*
// Given a dict with keys = kys & values an array [1,2,3,4,5...]
// and separate send the keys kys (or perhaps they are a separate array...)
// will return an array with the keys sorted ascending on the nth value of the array
var dict_qs, kys_qs;

    // Helper function to perform the partitioning
    function partition(low, high, n) {
        var pivotKey = kys_qs[high]; // Choose the last element as the pivot
        var pivotValue = dict_qs[pivotKey][n];
        var i = low - 1; // Pointer for the smaller element

        for (var j = low; j < high; j++) {
            // If the current element is less than or equal to the pivot
            if (dict_qs[kys_qs[j]][n] <= pivotValue) {
                i++; // Increment the pointer for the smaller element
                // Swap the elements
                var temp = kys_qs[i];
                kys_qs[i] = kys_qs[j];
                kys_qs[j] = temp;
            }
        }
        // Swap the pivot element with the element at i + 1
        var temp = kys_qs[i + 1];
        kys_qs[i + 1] = kys_qs[high];
        kys_qs[high] = temp;

        return i + 1; // Return the partitioning index
    }

    // Recursive quicksort function
    function quickSortRecursive(low, high,n) {
        if (low < high) {
            // Partition the array and get the pivot index
            var pivotIndex = partition(low, high,n);
            // Recursively sort elements before and after partition
            quickSortRecursive(low, pivotIndex - 1,n);
            quickSortRecursive(pivotIndex + 1, high,n);
        }
    }
function quickSort(kys, dict, n) {
    // Start the quicksort process
    kys_qs = kys;
    dict_qs = dict;
    
    quickSortRecursive(0, kys.size() - 1, n);
    dict_qs = null;
    var ret = kys_qs;
    kys_qs = null;
    return ret; // Return the sorted keys
    //kys_qs = null;
    
}
*/

//isNumber: 0 string, 1 Number, 2 Float
function toArray(text, delimiter, isNumber)
{
    var arr = [];
    var delLen = delimiter.length();

    //System.println("TXT: " + text + " df " + delimiter + " isn " + isNumber);
    while (text.length() > 0)
    {
        //System.println ("TXT " + delLen + " txt: " + text);
        var iend = text.find(delimiter);
        if (iend == null) // If delimiter is not found
        {
            iend = text.length(); // Take the rest of the string

        }

        // Extract the substring and convert to number if applicable
        var value = text.substring(0, iend);
        if (isNumber==1) {value = value.toNumber();}
        else if (isNumber==2) {value = value.toFloat();}
        arr.add(value); // Convert to number if needed
        
        if (iend==null) {break;}
        //System.println ("TXT" + iend + " d: " + delLen + "val: " + value + " txt: " + text);
        // Update text to remove the processed part
        //So FR 245 SIMULATOR (not real thing, only simulator) croaks when last
        //field is NULL even though documentations says that is OK
        text = text.substring(iend + delLen, text.length());
    }

    return arr; // Return the array of values
}

/*
const FLT_MAX = 3.4028235e38f;

function isnan(x as Float) as Boolean {
    return x != x;
}

function isinf(x as Float) as Boolean {
    return (x < -FLT_MAX || FLT_MAX < x);
}

function isUnSafeFloat(x as Float) as Boolean {
    return isnan (x) || isinf(x);
}

*/

/*

//this seems to work better than the above two funcs
public function isSafeValue(x as Number or Long or Float or Double) as Boolean {
  return !x.equals(NaN) && !x.equals(Math.acos(45));
}

*/




/*
function intersect_array (a, b) {
    var result = [];
    for (var i = 0; i < a.size(); i++) {
        if (b.indexOf(a[i]) != -1) {
            result.add(a[i]);
            }
        }
    return result;            

}
*/
function deBug(label, ary) {
    System.println (label + ": " + ary);
    //if (ary == null) {System.println(" NULL!"); return;}

    /*if (ary instanceof Lang.Array) {
        for (var i = 0; i< ary.size(); i++) {
        System.print(ary[i] + " : ");
        } 
    }else {
        System.print(ary);
    }
    System.println("");*/
}
}

function deBug(label, ary) {
    System.println (label + ": " + ary);
    //if (ary == null) {System.println(" NULL!"); return;}

    /*if (ary instanceof Lang.Array) {
        for (var i = 0; i< ary.size(); i++) {
        System.print(ary[i] + " : ");
        } 
    }else {
        System.print(ary);
    }
    System.println("");*/
}