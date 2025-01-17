import Toybox.Math;
import Toybox.System;
import Toybox.Lang; 


//var storRand = {};
//var storLastR = {};
/*
class VSOP87_cache{

    var g_cache;
    var indexes;
    var MAX_CACHE = 0;
    var lastFreeMemory = 100000000;
    var lastCount = 0;

    function initialize () {
        

        //planetoncenter = $.Geocentric.planetoncenter;
        //objectlist = $.Geocentric.objectlist;
        g_cache = {};
        indexes = [];
    }
function fetch (now_info, timeZoneOffset_sec, dst, timeAdd_hrs, type, req_array) {
    return planetCoord(now_info, timeZoneOffset_sec, dst, timeAdd_hrs, type, req_array);
}
*/
/*
    function fetch (now_info, timeZoneOffset_sec, dst, timeAdd_hrs, type) {
        //System.println("fetch... ");
                    
        //since we must incl lat & lon to get a sensible answer, might as well
        //includ UT & dst as well, as those are localized in the same way     
        var typ = "elip";
        if (type != :ecliptic_latlon) {typ = "xyz";}    



        var time_f.mod = Math.round(0.0f + timeAdd_hrs/24.0f + f.julianDate(now_info.year, now_info.month, now_info.day, 0, 0, timeZoneOffset_sec/3600.0f, dst)).toNumber();


        var index = time_mod + "|"+ typ;
        //System.println("CACHE: " + index);
        var ret;

        var myStats = System.getSystemStats();

        if ((myStats.freeMemory< lastFreeMemory && $.count > lastCount + 15) 
            || $.count%1000 == 0 ) {

               System.println("Memory/VSOP222: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory + " MAX_CACHE: " + MAX_CACHE + " count: "  + $.count + " animation_count: " + $.animation_count + " drawPlanetCount: " + $.drawPlanetCount + " buttonPresses: " + $.buttonPresses + " at " +  now.hour.format("%02d") + ":" +
            now.min.format("%02d") + ":" +
            now.sec.format("%02d") );

               lastFreeMemory = myStats.freeMemory;
               lastCount = $.count;

         }

        //myStats = null;

        if (g_cache.hasKey(index)) {
            ret = g_cache[index];
            //kys = ret.keys();
            } 
        else {
            //we always cache the info for midnight UTC & all objects
            
            if (myStats.freeMemory<5500) {
                MAX_CACHE = 0;
                self.empty();                                 
            
            } else if (myStats.freeMemory<9500) {
                MAX_CACHE -=1;
                if (MAX_CACHE < 1) { MAX_CACHE = 1; }
                if (indexes.size() > MAX_CACHE -1 && indexes.size() > 0) {
                    g_cache.remove(indexes[0]);
                    indexes.remove(indexes[0]);
                }
            }
            else if (myStats.freeMemory> 20000 && MAX_CACHE<60) {MAX_CACHE +=1;}

            if (indexes.size() > MAX_CACHE -1 && g_cache.size()>0) {
                g_cache.remove(indexes[0]);
                indexes.remove(indexes[0]);
            }
            //var vsop = new vsop87a_pico();
            ret = planetCoord(now_info, timeZoneOffset_sec, dst, timeAdd_hrs, type, null);
            //vsop = null;
            //kys = ret.keys();
            if ((MAX_CACHE > 0 && type == :ecliptic_latlon) ||  
                myStats.freeMemory>100000)  {
                    g_cache.put(index,ret);
                    indexes.add(index);
                }
        }                    

        return ret;
    }

    public function empty () {
        g_cache = null;
        indexes = null;
        g_cache = {};
        indexes = [];
    }
    */
/*} */


//VSOP87-Multilang http://www.celestialprogramming.com/
//Greg Miller (gmiller@gregmiller.net) 2021.  Released as Public Domain
//VSOP87a PICO - JAVASCRIPT version with minor tweaks
//https://github.com/gmiller123456/vsop87-multilang/blob/master/Languages/JavaScript/vsop87a_pico.js

//class vsop87a_pico{

class vs {


    public var j2000= 2451543.5f; //epoch used for some calculations (Pluto) from Ioannis

    // types are :ecliptic_latlon and :helio_xyz
    public function planetCoord (now_info, timeZoneOffset_sec, dst, timeAdd_hrs as Lang.double, type, req_array, context) {

        //var sml_days  = synodicMonthLength_days(now_info, timeZoneOffset_sec, dst );
        //var base_JD = f.julianDate (2025, 1, 29 , 12, 36, 0, 0);
        var JD1 = f.julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, timeZoneOffset_sec/3600d, dst);
        var JD = JD1 + timeAdd_hrs/24.0d;

        var t=(JD - 2451545.0d) / 365250.0d;

        //var j2000= 2451543.5f;
        //var d= JD ;

        var earth = getEarth(t);

        //change vantage point to earth & return lat/lon angles relative to ecliptic
        //Trick is to switch Earth & Sun, but -x, -y, -z that way  we have a
        //"sun position" even though it was all calculated with Sun  as the center
        
        var ret = {};
        //var vhh = $.planetsOption_values[planetsOption_value];
        var vhh = {};
        if (req_array != null) {vhh = req_array;}
        /*else {
          makePlanetsOpt(planetsOption_value);
          if (type != :helio_xyz) { vhh =makePlanetsOpt(1);}
        }*/

        

        //deBug("VSOP1: ", vhh);
        //deBug("VSOP2: ", req_array);
        /*deBug("VSOP3: ", $.planetsOption_values[planetsOption_value]);
        deBug("VSOP4: ", [$.planetsOption_value,$.planetsOption_values]);*/

        //if (planetsOption_value == 0 || planetsOption_value == 2 || type != :helio_xyz)

        var allPlanets = f.toArray(WatchUi.loadResource($.Rez.Strings.planets_Options1) as String,  "|", 0);
         
            if (sin (allPlanets[1],vhh)) {ret.put (allPlanets[1], vspo_2_J2000(getMercury(t), earth, true, type));}
            if (sin (allPlanets[2],vhh)) {ret.put (allPlanets[2], vspo_2_J2000(getVenus(t), earth, true, type));} 
            //if (sin ("Mercury",vhh)) {"Earth" => vspo_2_J2000(getEarth(t), earth, true, type));}  */
            if (sin (allPlanets[5],vhh)) {ret.put (allPlanets[5], vspo_2_J2000(getMars(t), earth, true, type));} 
            if (sin (allPlanets[6],vhh)) {ret.put (allPlanets[6], vspo_2_J2000(getJupiter(t), earth, true, type));} 
            if (sin (allPlanets[7],vhh)) {ret.put (allPlanets[7], vspo_2_J2000(getSaturn(t), earth, true, type));}

            if (sin (allPlanets[0],vhh)) {ret.put (allPlanets[0], vspo_2_J2000([0,0,0], earth, true, type));} //SUN

            //if (context != :glance) {
               var v2 = new vs2(); 
               if (sin (allPlanets[8],vhh)) {ret.put (allPlanets[8], vspo_2_J2000(v2.getUranus(t), earth, true, type));} 
               if (sin (allPlanets[9],vhh)) {ret.put (allPlanets[9], vspo_2_J2000(v2.getNeptune(t), earth, true, type));}
               
               if (sin (allPlanets[10],vhh)) {ret.put (allPlanets[10], vspo_2_J2000(v2.getPluto(JD), earth, false, type));}

               //if (sin (allPlanets[11],vhh)) {ret.put (allPlanets[11], vspo_2_J2000(v2.getCeres(JD), earth, false, type));}

               v2 = null;
            //}
        
        

        //if ((planetsOption_value == 0 || planetsOption_value == 3 ) && type == :helio_xyz) {

            /* if (sin (allPlanets[15],vhh)) {ret.put (allPlanets[15], vspo_2_J2000(getEris(JD), earth, false, type));}
            if (sin (allPlanets[14],vhh)) {ret.put (allPlanets[14], vspo_2_J2000(getChiron(JD), earth, false, type));}
            
            if (sin (allPlanets[13],vhh)) {ret.put (allPlanets[11], vspo_2_J2000(getCeres(JD), earth, false, type));}
                        
            if (sin (allPlanets[16],vhh)) {ret.put (allPlanets[16], vspo_2_J2000(getGonggong(JD), earth, false, type));}
            if (sin (allPlanets[17],vhh)) {ret.put (allPlanets[17], vspo_2_J2000(getQuaoar(JD), earth, false, type));}
            if (sin (allPlanets[18],vhh)) {ret.put (allPlanets[18], vspo_2_J2000(getMakemake(JD), earth, false, type));}
            if (sin (allPlanets[19],vhh)) {ret.put (allPlanets[19], vspo_2_J2000(getHaumea(JD), earth, false, type));}
            */
        
        
         
        //keep vantage point as Sun and return XYZ coords
        //now we need Sun back at [0,0,0] and add earth as normal

        if (type == :helio_xyz) {
            ret ["allPlanets[0]"] = [0,0,0];
            ret.put(allPlanets[3], vspo_2_J2000(earth, earth, true, type));
        }
        
        return ret;
    }

    public function sin ( name,arry) {
      if (arry.indexOf(name) >=0) {return true;}
      else {return false;}
    }

    // types are :ecliptic_latlon and :helio_xyz
    public function vspo_2_J2000(input, earth, vsop, type) {
       
        var x = input[0];
        var y = input [1];
        var z = input [2];
       if (type == :ecliptic_latlon) { 
         x = input[0] - earth[0];
         y = input [1]- earth[1];
         z = input [2]- earth[2];
       }

       var tx = x;
       var ty = y;
       var tz = z;

    if (vsop) {
     //Rotate from VSOP coordinates to J2000
      tx = (x + y * 0.000000440360f + z * -0.000000190919f);
      ty = (x * -0.000000479966f + y * 0.917482137087f + z * -0.397776982902f);
      tz = (y * 0.397776982902f + z * 0.917482137087f);
    }

    if (type == :helio_xyz) {return [(tx).toFloat(),(ty).toFloat(),(tz).toFloat()];}

    //System.println("XYZ: " + tx + " " + ty + " " + tz);
    //Convert from Cartesian to polar coordinates 
    var r = Math.sqrt(tx * tx + ty * ty + tz * tz);
    var l = Math.atan2(ty, tx);
    var t2 = 0;
    if (r != 0 ) { t2 = Math.acos(tz / r); }

    //System.println("LTr: " + l + " " + t2 + " " + r);


    //Make sure RA is positive, and Dec is in range +/-90
    if (l < 0) { l += 2 * Math.PI; }
    t2 = .5 * Math.PI - t2;

    //Uncomment to return results in hours and degrees rather than radians
    //return {ra: l*180/Math.PI/15, dec: t2*180/Math.PI, r: r};
    //return {ra: l, dec: t2, r: r};
    //return {:lat=> Math.toDegrees(l), :lon => Math.toDegrees(t2), :r => r};
    return [(Math.toDegrees(l)).toFloat(), (Math.toDegrees(t2)).toFloat(), (r).toFloat()];//lat, lon, r
    }

    
   function getMercury(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=mercury_x(t);
      temp[1]=mercury_y(t);
      temp[2]=mercury_z(t);

      return temp;
   }

   function getVenus(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=venus_x(t);
      temp[1]=venus_y(t);
      temp[2]=venus_z(t);

      return temp;
   }

   function getEarth(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=earth_x(t);
      temp[1]=earth_y(t);
      temp[2]=earth_z(t);

      return temp;
   }

   function getMars(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=mars_x(t);
      temp[1]=mars_y(t);
      temp[2]=mars_z(t);

      return temp;
   }

   function getJupiter(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=jupiter_x(t);
      temp[1]=jupiter_y(t);
      temp[2]=jupiter_z(t);

      return temp;
   }

   function getSaturn(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=saturn_x(t);
      temp[1]=saturn_y(t);
      temp[2]=saturn_z(t);

      return temp;
   }

  
   /*

   function getEmb(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=emb_x(t);
      temp[1]=emb_y(t);
      temp[2]=emb_z(t);

      return temp;
   }
   */

   function getMoon(earth, emb){
      var temp=[0.0f, 0.0f, 0,0];

      temp[0]=(emb[0]-earth[0])*(1 + 1 / 0.01230073677f);
      temp[1]=(emb[1]-earth[1])*(1 + 1 / 0.01230073677f);
      temp[2]=(emb[2]-earth[2])*(1 + 1 / 0.01230073677f);
      temp[0]=temp[0]+earth[0];
      temp[1]=temp[1]+earth[1];
      temp[2]=temp[2]+earth[2];

      return temp;
   }

   function venus_z(t){
      var venus_z_0 = 0.0f;

      venus_z_0 += 0.04282990302f * Math.cos(0.26703856476f + 10213.28554621100f*t);
      return venus_z_0;
   }

   function venus_y(t){
      var venus_y_0 = 0.0f;

      venus_y_0 += 0.72324820731f * Math.cos(1.60573808356f + 10213.28554621100f*t);
      return venus_y_0;
   }

   function venus_x(t){
      var venus_x_0 = 0.0f;

      venus_x_0 += 0.72211281391f * Math.cos(3.17575836361f + 10213.28554621100f*t);
      return venus_x_0;
   }

   
   function saturn_z(t){
      var saturn_z_1 = 0.0f;

      saturn_z_1 += 0.01906503283f * Math.cos(4.94544746116f + 213.29909543800f*t);
      saturn_z_1=saturn_z_1*t;

      var saturn_z_0 = 0.0f;

      saturn_z_0 += 0.01214249867f * Math.cos(0.00000000000f + 0.00000000000f*t);
      saturn_z_0 += 0.01148283576f * Math.cos(2.85128367469f + 426.59819087600f*t);
      saturn_z_0 += 0.41356950940f * Math.cos(3.60234142982f + 213.29909543800f*t);
      return saturn_z_1+saturn_z_0;
   }

   function saturn_y(t){
      var saturn_y_1 = 0.0f;

      saturn_y_1 += 0.02647489677f * Math.cos(3.76132298889f + 220.41264243880f*t);
      saturn_y_1 += 0.02741594312f * Math.cos(4.26667636015f + 206.18554843720f*t);
      saturn_y_1 += 0.03090575152f * Math.cos(2.70346890906f + 426.59819087600f*t);
      saturn_y_1 += 0.05373889135f * Math.cos(0.00000000000f + 0.00000000000f*t);
      saturn_y_1=saturn_y_1*t;

      var saturn_y_0 = 0.0f;

      saturn_y_0 += 0.01098751131f * Math.cos(4.08608782813f + 639.89728631400f*t);
      saturn_y_0 += 0.01245790434f * Math.cos(0.60367177975f + 110.20632121940f*t);
      saturn_y_0 += 0.01183874652f * Math.cos(1.34638298371f + 419.48464387520f*t);
      saturn_y_0 += 0.02345609742f * Math.cos(0.44652132519f + 7.11354700080f*t);
      saturn_y_0 += 0.06633570703f * Math.cos(5.46258848288f + 220.41264243880f*t);
      saturn_y_0 += 0.06916653915f * Math.cos(2.55279408706f + 206.18554843720f*t);
      saturn_y_0 += 0.26441781302f * Math.cos(4.83528061849f + 426.59819087600f*t);
      saturn_y_0 += 0.79387988806f * Math.cos(3.14159265359f + 0.00000000000f*t);
      saturn_y_0 += 9.52986882699f * Math.cos(5.58600556665f + 213.29909543800f*t);
      return saturn_y_1+saturn_y_0;
   }

   function saturn_x(t){
      var saturn_x_1 = 0.0f;

      saturn_x_1 += 0.02643100909f * Math.cos(5.33291950584f + 220.41264243880f*t);
      saturn_x_1 += 0.02714918399f * Math.cos(5.85229412397f + 206.18554843720f*t);
      saturn_x_1 += 0.03085041716f * Math.cos(4.27565749128f + 426.59819087600f*t);
      saturn_x_1 += 0.07575103962f * Math.cos(0.00000000000f + 0.00000000000f*t);
      saturn_x_1=saturn_x_1*t;

      var saturn_x_0 = 0.0f;

      saturn_x_0 += 0.01097683232f * Math.cos(5.65753337256f + 639.89728631400f*t);
      saturn_x_0 += 0.01115684467f * Math.cos(3.15686878377f + 419.48464387520f*t);
      saturn_x_0 += 0.01255372247f * Math.cos(2.17338917731f + 110.20632121940f*t);
      saturn_x_0 += 0.02336340488f * Math.cos(2.02227784673f + 7.11354700080f*t);
      saturn_x_0 += 0.04244797817f * Math.cos(0.00000000000f + 0.00000000000f*t);
      saturn_x_0 += 0.06624260115f * Math.cos(0.75094737780f + 220.41264243880f*t);
      saturn_x_0 += 0.06760430339f * Math.cos(4.16767145778f + 206.18554843720f*t);
      saturn_x_0 += 0.26412374238f * Math.cos(0.12390892620f + 426.59819087600f*t);
      saturn_x_0 += 9.51638335797f * Math.cos(0.87441380794f + 213.29909543800f*t);
      return saturn_x_1+saturn_x_0;
   }

   
   function mercury_z(t){
      var mercury_z_0 = 0.0f;

      mercury_z_0 += 0.04607665326f * Math.cos(1.99295081967f + 26087.90314157420f*t);
      return mercury_z_0;
   }

   function mercury_y(t){
      var mercury_y_0 = 0.0f;

      mercury_y_0 += 0.03854668215f * Math.cos(5.88780608966f + 52175.80628314840f*t);
      mercury_y_0 += 0.11626131831f * Math.cos(3.14159265359f + 0.00000000000f*t);
      mercury_y_0 += 0.37953642888f * Math.cos(2.83780617820f + 26087.90314157420f*t);
      return mercury_y_0;
   }

   function mercury_x(t){
      var mercury_x_0 = 0.0f;

      mercury_x_0 += 0.02625615963f * Math.cos(3.14159265359f + 0.00000000000f*t);
      mercury_x_0 += 0.03825746672f * Math.cos(1.16485604339f + 52175.80628314840f*t);
      mercury_x_0 += 0.37546291728f * Math.cos(4.39651506942f + 26087.90314157420f*t);
      return mercury_x_0;
   }

   function mars_z(t){
      var mars_z_0 = 0.0f;

      mars_z_0 += 0.04901207220f * Math.cos(3.76712324286f + 3340.61242669980f*t);
      return mars_z_0;
   }

   function mars_y(t){
      var mars_y_1 = 0.0f;

      mars_y_1 += 0.01427324210f * Math.cos(3.14159265359f + 0.00000000000f*t);
      mars_y_1=mars_y_1*t;

      var mars_y_0 = 0.0f;

      mars_y_0 += 0.08655481102f * Math.cos(0.00000000000f + 0.00000000000f*t);
      mars_y_0 += 0.07064550239f * Math.cos(4.97051892902f + 6681.22485339960f*t);
      mars_y_0 += 1.51558976277f * Math.cos(4.63212206588f + 3340.61242669980f*t);
      return mars_y_1+mars_y_0;
   }

   function mars_x(t){
      var mars_x_0 = 0.0f;

      mars_x_0 += 0.07070919655f * Math.cos(0.25870338558f + 6681.22485339960f*t);
      mars_x_0 += 0.19502945246f * Math.cos(3.14159265359f + 0.00000000000f*t);
      mars_x_0 += 1.51769936383f * Math.cos(6.20403346548f + 3340.61242669980f*t);
      return mars_x_0;
   }

   function jupiter_z(t){
      var jupiter_z_0 = 0.0f;

      jupiter_z_0 += 0.11823100489f * Math.cos(3.55844646343f + 529.69096509460f*t);
      return jupiter_z_0;
   }

   function jupiter_y(t){
      var jupiter_y_1 = 0.0f;

      jupiter_y_1 += 0.01694798253f * Math.cos(3.14159265359f + 0.00000000000f*t);
      jupiter_y_1=jupiter_y_1*t;

      var jupiter_y_0 = 0.0f;

      jupiter_y_0 += 0.01475809370f * Math.cos(2.04679566495f + 536.80451209540f*t);
      jupiter_y_0 += 0.01508275299f * Math.cos(5.43934968102f + 522.57741809380f*t);
      jupiter_y_0 += 0.09363670616f * Math.cos(3.14159265359f + 0.00000000000f*t);
      jupiter_y_0 += 0.12592862602f * Math.cos(5.66160227728f + 1059.38193018920f*t);
      jupiter_y_0 += 5.19520046589f * Math.cos(5.31203162731f + 529.69096509460f*t);
      return jupiter_y_1+jupiter_y_0;
   }

   function jupiter_x(t){
      var jupiter_x_0 = 0.0f;

      jupiter_x_0 += 0.01476224578f * Math.cos(3.61736921122f + 536.80451209540f*t);
      jupiter_x_0 += 0.01500672056f * Math.cos(0.73175134610f + 522.57741809380f*t);
      jupiter_x_0 += 0.12593937922f * Math.cos(0.94911583701f + 1059.38193018920f*t);
      jupiter_x_0 += 0.36662642320f * Math.cos(3.14159265359f + 0.00000000000f*t);
      jupiter_x_0 += 5.19663470114f * Math.cos(0.59945082355f + 529.69096509460f*t);
      return jupiter_x_0;
   }

/*
   function emb_z(t){
      return 0;
   }

   function emb_y(t){
      var emb_y_0 = 0.0f;

      emb_y_0 += 0.02442698841f * Math.cos(3.14159265359f + 0.00000000000f*t);
      emb_y_0 += 0.99989209645f * Math.cos(0.18265890456f + 6283.07584999140f*t);
      return emb_y_0;
   }

   function emb_x(t){
      var emb_x_0 = 0.0f;

      emb_x_0 += 0.99982927460f * Math.cos(1.75348568475f + 6283.07584999140f*t);
      return emb_x_0;
   }
   */

   /// ORIGINAL PICO
   /*
   function earth_z(t){
      return 0;
   }

   function earth_y(t){
      var earth_y_0 = 0.0f;

      earth_y_0 += 0.02442699036f * Math.cos(3.14159265359f + 0.00000000000f*t);
      earth_y_0 += 0.99989211030f * Math.cos(0.18265890456f + 6283.07584999140f*t);
      return earth_y_0;
   }

   function earth_x(t){
      var earth_x_0 = 0.0f;

      earth_x_0 += 0.99982928844f * Math.cos(1.75348568475f + 6283.07584999140f*t);
      return earth_x_0;
   }
   */

   function earth_z(t){
      return 0.00227822442f * Math.cos(3.41372504278f + 6283.07584999140f*t)*t;
   }

   function earth_y(t){
        var y = 0.0f;
        y = 0.00010466965f * Math.cos(0.09641690558f + 18849.22754997420f*t);
        y += 0.00835292314f * Math.cos(0.13952878991f + 12566.15169998280f*t) -0.02442699036f;
        y += 0.99989211030f * Math.cos(0.18265890456f + 6283.07584999140f*t);
        y += (0.00093046324f + 0.00051506609f * Math.cos(4.43180499286f + 12566.15169998280f*t))*t;
      return y;
   }

   function earth_x(t){
       
       var x = 0.00561144206f + 0.00010466628f * Math.cos(1.66722645223f + 18849.22754997420f*t);
        x += 0.00835257300f * Math.cos(1.71034539450f + 12566.15169998280f*t);
        x += 0.99982928844f * Math.cos(1.75348568475f + 6283.07584999140f*t);
        x += (0.00123403056f + 0.00051500156f * Math.cos(6.00266267204f + 12566.15169998280f*t))*t;
      return x;
   }


}


class vs2 {


 function getUranus(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=uranus_x(t);
      temp[1]=uranus_y(t);
      temp[2]=uranus_z(t);

      return temp;
   }

   function getNeptune(t){
      var temp=[0.0f, 0.0f, 0.0f];
      temp[0]=neptune_x(t);
      temp[1]=neptune_y(t);
      temp[2]=neptune_z(t);

      return temp;
   }

   function neptune_z(t){
      var neptune_z_0 = 0.0f;

      neptune_z_0 += 0.01245978462f * Math.cos(0.00000000000f + 0.00000000000f*t);
      neptune_z_0 += 0.92866054405f * Math.cos(1.44103930278f + 38.13303563780f*t);
      return neptune_z_0;
   }

   function neptune_y(t){
      var neptune_y_0 = 0.0f;

      neptune_y_0 += 0.01073739772f * Math.cos(3.81371728533f + 74.78159856730f*t);
      neptune_y_0 += 0.02584250749f * Math.cos(0.42549700754f + 1.48447270830f*t);
      neptune_y_0 += 0.14936165806f * Math.cos(5.79694900665f + 39.61750834610f*t);
      neptune_y_0 += 0.15706589373f * Math.cos(4.82539970129f + 36.64856292950f*t);
      neptune_y_0 += 0.13506391797f * Math.cos(1.92953034883f + 76.26607127560f*t);
      neptune_y_0 += 0.30205857683f * Math.cos(3.14159265359f + 0.00000000000f*t);
      neptune_y_0 += 30.06056351665f * Math.cos(3.74086294714f + 38.13303563780f*t);
      return neptune_y_0;
   }

   function neptune_x(t){
      var neptune_x_0 = 0.0f;

      neptune_x_0 += 0.01074040708f * Math.cos(5.38502938672f + 74.78159856730f*t);
      neptune_x_0 += 0.02597313814f * Math.cos(1.99590301412f + 1.48447270830f*t);
      neptune_x_0 += 0.14935120126f * Math.cos(1.08499403018f + 39.61750834610f*t);
      neptune_x_0 += 0.15726094556f * Math.cos(0.11319072675f + 36.64856292950f*t);
      neptune_x_0 += 0.13505661755f * Math.cos(3.50078975634f + 76.26607127560f*t);
      neptune_x_0 += 0.27080164222f * Math.cos(3.14159265359f + 0.00000000000f*t);
      neptune_x_0 += 30.05890004476f * Math.cos(5.31211340029f + 38.13303563780f*t);
      return neptune_x_0;
   }



function uranus_z(t){
      var uranus_z_0 = 0.0f;

      uranus_z_0 += 0.01774318778f * Math.cos(3.14159265359f + 0.00000000000f*t);
      uranus_z_0 += 0.25878127698f * Math.cos(2.61861272578f + 74.78159856730f*t);
      return uranus_z_0;
   }

   function uranus_y(t){
      var uranus_y_1 = 0.0f;

      uranus_y_1 += 0.02157896385f * Math.cos(0.00000000000f + 0.00000000000f*t);
      uranus_y_1=uranus_y_1*t;

      var uranus_y_0 = 0.0f;

      uranus_y_0 += 0.01442356575f * Math.cos(1.08004542712f + 148.07872442630f*t);
      uranus_y_0 += 0.01542668264f * Math.cos(2.55040539213f + 224.34479570190f*t);
      uranus_y_0 += 0.06250078231f * Math.cos(3.56960243857f + 1.48447270830f*t);
      uranus_y_0 += 0.14123958128f * Math.cos(2.82486076549f + 76.26607127560f*t);
      uranus_y_0 += 0.14755940186f * Math.cos(1.85423280679f + 73.29712585900f*t);
      uranus_y_0 += 0.16256125476f * Math.cos(3.14159265359f + 0.00000000000f*t);
      uranus_y_0 += 0.44390465203f * Math.cos(0.08884111329f + 149.56319713460f*t);
      uranus_y_0 += 19.16518231584f * Math.cos(3.91045677002f + 74.78159856730f*t);
      return uranus_y_1+uranus_y_0;
   }

   function uranus_x(t){
      var uranus_x_0 = 0.0f;

      uranus_x_0 += 0.01444216660f * Math.cos(2.65117115201f + 148.07872442630f*t);
      uranus_x_0 += 0.01542951343f * Math.cos(4.12121838072f + 224.34479570190f*t);
      uranus_x_0 += 0.06201106178f * Math.cos(5.14043574125f + 1.48447270830f*t);
      uranus_x_0 += 0.14130269479f * Math.cos(4.39572927934f + 76.26607127560f*t);
      uranus_x_0 += 0.14668209481f * Math.cos(3.42395862804f + 73.29712585900f*t);
      uranus_x_0 += 0.44402496796f * Math.cos(1.65967519586f + 149.56319713460f*t);
      uranus_x_0 += 1.32272523872f * Math.cos(0.00000000000f + 0.00000000000f*t);
      uranus_x_0 += 19.17370730359f * Math.cos(5.48133416489f + 74.78159856730f*t);
      return uranus_x_0;
   }


 /*  
   public function getPluto (d) {

           //ploutonas - Pluto
        d = d - vs.j2000;

        var S_pl  = Math.toRadians(  50.03f  +  0.033459652f *  d);
        var P_pl  = Math.toRadians( 238.95f  +  0.003968789f *  d);
        
        var long2_pl = (238.9508f  +  0.00400703f * d - 19.799f * Math.sin(P_pl)
                     + 19.848f * Math.cos(P_pl) + 0.897f * Math.sin(2*P_pl)
               - 4.956f * Math.cos(2*P_pl) + 0.610f * Math.sin(3*P_pl)
               + 1.211f * Math.cos(3*P_pl) - 0.341f * Math.sin(4*P_pl)
               - 0.190f * Math.cos(4*P_pl) + 0.128f * Math.sin(5*P_pl)
               - 0.034f * Math.cos(5*P_pl) - 0.038f * Math.sin(6*P_pl)
               + 0.031f * Math.cos(6*P_pl) + 0.020f * Math.sin(S_pl - P_pl) 
               - 0.010f * Math.cos(S_pl - P_pl) );
        var lat2_pl = ( -3.9082f - 5.453f * Math.sin(P_pl) - 14.975f * Math.cos(P_pl)
                      + 3.527f * Math.sin(2*P_pl) + 1.673f * Math.cos(2*P_pl)
                      - 1.051f * Math.sin(3*P_pl) + 0.328f * Math.cos(3*P_pl)
                      + 0.179f * Math.sin(4*P_pl) - 0.292f * Math.cos(4*P_pl)
                      + 0.019f * Math.sin(5*P_pl) + 0.100f * Math.cos(5*P_pl)
                      - 0.031f * Math.sin(6*P_pl) - 0.026f * Math.cos(6*P_pl)
                      + 0.011f * Math.cos(S_pl - P_pl) );
        var r_pl = ( 40.72f + 6.68f * Math.sin(P_pl) + 6.90f * Math.cos(P_pl)
                      - 1.18f * Math.sin(2*P_pl) - 0.03f * Math.cos(2*P_pl)
                      + 0.15f * Math.sin(3*P_pl) - 0.14f * Math.cos(3*P_pl));
        
        long2_pl=Math.toRadians(long2_pl);
        lat2_pl=Math.toRadians(lat2_pl);
        var x = r_pl * Math.cos(long2_pl) * Math.cos(lat2_pl); //eclip
        var y = r_pl * Math.sin(long2_pl) * Math.cos(lat2_pl);
        var z = r_pl * Math.sin(lat2_pl);
        return [x, y, z];
   }*/

   
   //THIS IS FROM GREG MILLER CELESTIALPROGRAMMING.COM and
   //gives the RIGHT ANSWER for PLUTO
   //https://www.celestialprogramming.com/planets_with_keplers_equation.html

   //3000BC to 3000AD elements are used below for PLUTO

   /*This is an implementation of the algorithm described in Chapter 8 of the Explanatory Supplement to the Astronomical Almanac 3rd ed P340. Two sets of elements are provided, and they are accurate for different intervals. The first set is valid for 1800-2050, and the worst case accuracy is for Saturn at about 10 arc minutes. Most others are under 1 arcmin. The second set is valid for 3000BC to 3000AD, and has a worst case accuracy (for Uranus) of about half a degree. Most others are on the order of 1 arc minute. See table 8.10 in the Explanatory Supplement for full accuracy details.

   You'll notice that each planet has 12 elements rather than the nomral 6 Kelperian elements. A pure Kelperian element solve looses accuracy rather quickly due to purturation effects from other planets. So the authors of this routine have provided an additional 6 elements which are corrections to the Kelperian elements based on time since Jan 1 2000. The corrections were specifically fit to the specified time periods, so they are considered invalid outside of that time period.*/

   var pluto_elements = [39.48686035,      0.24885238,     17.14104260,      238.96535011,    224.09702598,    110.30167986];
   var pluto_rates =   [ 0.00449751,      0.00006016,      0.00000501,      145.18042903,     -0.00968827,     -0.00809981];
   var pluto_extraterms = [-0.01262724,    0,             0,             0,] ;

   function getPluto(jd){
    var toRad=Math.PI/180.0;
    //Algorithm from Explanatory Supplement to the Astronomical Almanac ch8 P340
    //Step 1:
    var T=(jd-2451545.0)/36525.0;
    var a=pluto_elements[0]+pluto_rates[0]*T;
    var e=pluto_elements[1]+pluto_rates[1]*T;
    var I=pluto_elements[2]+pluto_rates[2]*T;
    var L=pluto_elements[3]+pluto_rates[3]*T;
    var w=pluto_elements[4]+pluto_rates[4]*T;
    var O=pluto_elements[5]+pluto_rates[5]*T;

    //Step 2:
    var ww=w-O;
    var M=L - w;
    if(pluto_extraterms.size() > 0){
        var b=pluto_extraterms[0];
        var c=pluto_extraterms[1];
        var s=pluto_extraterms[2];
        var f=pluto_extraterms[3];
        M=L - w + b*T*T + c*Math.cos(f*T*toRad) + s*Math.sin(f*T*toRad);
    }

    while(M>180){M-=360;}

    var E=M+57.29578*e*Math.sin(M*toRad);
    var dE=1;
    var n=0;
    while(dE.abs()>1e-7 && n<10){
        dE=SolveKepler(M,e,E);
        E+=dE;
        n++;
    }

    //Step 4:
    var xp=a*(Math.cos(E*toRad)-e);
    var yp=a*Math.sqrt(1-e*e)*Math.sin(E*toRad);
    var zp=0;

    //Step 5:
    a*=toRad; e*=toRad; I*=toRad; L*=toRad; ww*=toRad; O*=toRad;
    var xecl=(Math.cos(ww)*Math.cos(O)-Math.sin(ww)*Math.sin(O)*Math.cos(I))*xp + (-Math.sin(ww)*Math.cos(O)-Math.cos(ww)*Math.sin(O)*Math.cos(I))*yp;
    var yecl=(Math.cos(ww)*Math.sin(O)+Math.sin(ww)*Math.cos(O)*Math.cos(I))*xp + (-Math.sin(ww)*Math.sin(O)+Math.cos(ww)*Math.cos(O)*Math.cos(I))*yp;
    var zecl=(Math.sin(ww)*Math.sin(I))*xp + (Math.cos(ww)*Math.sin(I))*yp;

    //Step 6:
    var eps=23.43928*toRad;

    var x=xecl;
    var y=Math.cos(eps)*yecl - Math.sin(eps)*zecl;
    var z=Math.sin(eps)*yecl + Math.cos(eps)*zecl;

    return [x,y,z];

}

function SolveKepler(M,e,E){
    var toRad=Math.PI/180;

    var dM=M - (E-e/toRad*Math.sin(E*toRad));
    var dE=dM/(1-e*Math.cos(E*toRad));
    return dE;

}



   /*
   public function getEris (d){
        /*
           //A ERIS epoch  2456400.5f 2013-apr-18.0f   j2000= 2451543.5f;
        var epoch = 2456400.5f   
        var d_new= d + 2451543.5f - epoch;
        
        var N=36.0308972598494f  ; //QR
        var i=43.88534676566927f ; //IN
        var w=150.8002573158863f ; //W
        var a=67.95784302407351f ;  //A
        var e=0.4370835020505101f ; //EC
        var M=203.2157808586589f +  0.001759319413340421f * d_new;
        */
        /*

        var EPOCH=  2457996.5f;
        var EC= .441713222152167f;
        var QR= 37.76778537485207f;   
        //var TP= 2545579.0049365791f;      
        //var OM= 35.87796152910861f;   
        var W=  151.5251501002852f;   
        var IN= 44.2037909086797f;  
        var  A= 67.6494355113423f;  
        var  MA= 204.8595058015323f;  
        var  N= .001771364f;

        var newE = randomizeOrbit ("Eris", EC, QR, W, IN, A, MA, d);

        var d_new= d - EPOCH;
        var M = MA + N * d_new;
        
        M=f.normalize(M);

        var ret = f.Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Eris"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;

   }
   */
   
   /*
   public function getCeres (d){
     /*
           var ddd = d + 2451543.5 - 2455400.5;
        
        var N_ce=80.39319901972638  + 1.1593E-5 *ddd;
        var i_ce=10.58682160714853 - 2.2048E-6*ddd;
        var w_ce=72.58981198193074  + 1.84E-5*ddd;
        var a_ce=2.765348506018043 ;
        var e_ce=0.07913825487621974 + 1.8987E-8*ddd;
        var M_ce=113.4104433863731   + 0.21408169952325  * ddd ;
        */
        /*
        
 
        var EPOCH=  2458849.5f;
     
        var EC= .07687465013145245f;  
        var QR= 2.556401146697176f;   
        //var TP= 2458240.1791309435f;
        //var OM= 80.3011901917491f;    
        var W=  73.80896808746482f;   
        var IN= 10.59127767086216f;
        var A= 2.769289292143484f;    
        var MA= 130.3159688200986f;   
        //var ADIST= 2.982177437589792f;
        //var  PER= 4.60851f;
        var N= .213870844f;

        //var newE = randomizeOrbit ("Ceres", EC, QR, W, IN, A, MA, d);



        var d_new= d - EPOCH;
        var M = MA + N * d_new;
        
        M=f.normalize(M);

        var ret = f.Planet_Sun(M, EC, A, QR, W, IN);

        //var ret = f.Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        //$.storLastR ["Ceres"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;

   }
   */
   /*

   public function getChiron (d){

      //https://ssd.jpl.nasa.gov/horizons/app.html#/
      var EPOCH=  2457535.5f; // ! 2016-May-27.00 (TDB)         Residual RMS= .19998
      var EC= .3827260124508142f;   
      var QR= 8.418796919952825f;   
      //var TP= 2450138.5315822391f;
      //var OM= 209.2210850370517f;   
      var W=  339.5128645055728f;   
      var IN= 6.946297035265285f;
      var A= 13.63867114079872f;
      var MA= 144.7437272459811f;   
      //var ADIST= 18.85854536164461f;
      //var PER= 50.36934f; 
      var N= .01956798f;

      var newE = randomizeOrbit ("Chiron", EC, QR, W, IN, A, MA, d);



        var d_new= d - EPOCH;
        var M = MA + N * d_new;
        
        M=f.normalize(M);

        //return f.Planet_Sun(M, EC, A, QR, W, IN);

        var ret = f.Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Chiron"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;

   }
  public function getGonggong(d){

    //225088 Gonggong (2007 OR10)

     var EPOCH=  2457964.5f; // ! 2017-Jul-30.00 (TDB)         Residual RMS= .10926
     var EC= .505928166740521f;
     var     QR= 33.17018711494477f;
     //var   TP= 2399628.8293997725f;
     //var   OM= 336.8249678431149f;
     var    W=  207.173549840275f;
     var     IN= 30.87334176604489f;
     var    A= 67.1363653663784f;
     var      MA= 104.5205123804387f;
     //       ADIST= 101.102543617812   PER= 550.10417          
     var N= .001791708f;

     var newE = randomizeOrbit ("Gonggong", EC, QR, W, IN, A, MA, d);

        var d_new= d - EPOCH;
        var M = newE[:MA] + N * d_new;
        
        M=f.normalize(M);

        var ret = f.Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Gonggong"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;
  } 

  //Quaoar
  public function getQuaoar(d){

      //225088 Gonggong (2007 OR10)
      var name = "Quaoar";

      var EPOCH=  2459800.5f; // ! 2022-Aug-09.00 (TDB)         Residual RMS= .21356
      var EC= .04098702510897952f;
      var QR= 41.69021570747672f; 
      //var TP= 2478347.5347988536f;
      //var OM= 189.0902949942479f; 
      var W=  155.214428533145f;  
      var IN= 7.991232171849933f;
      var A= 43.47200381956696f;
      var MA= 296.2230021720905f;
      //var ADIST= 45.25379193165721
      //var PER= 286.63069          
      var N= .003438663f;

      var newE = randomizeOrbit (name, EC, QR, W, IN, A, MA, d);

      var d_new= d - EPOCH;
      var M = newE[:MA] + N * d_new;
            
         M=f.normalize(M);

         var ret = f.Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
         $.storLastR [name] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
         //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
         return ret;
  } 

  public function getMakemake(d){

    //225088 Gonggong (2007 OR10)

     var EPOCH=  2458086.5f; // ! 2017-Nov-29.00 (TDB)         Residual RMS= .15511
   
     var EC= .1549341371192079f;
     var QR= 38.62074545461233f; 
     //var TP= 2407473.3048103042f;
     //var OM= 79.60071323640928f;   
     var W=  295.8277253622994f;  
     var IN= 28.98514685760906f;
     var A= 45.70146204102473f;    
     var MA= 161.4628775532161f;

      
     var N= .003190134f;

     var newE = randomizeOrbit ("Makemake", EC, QR, W, IN, A, MA, d);

        var d_new= d - EPOCH;
        var M = newE[:MA] + N * d_new;
        
        M=f.normalize(M);

        var ret = f.Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Makemake"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;
  } 

    public function getHaumea(d){

         var EPOCH=  2457665.5f; // ! 2016-Oct-04.00 (TDB)         Residual RMS= .16606
         var EC= .1890800327846289f; 
         var QR= 35.14667962719495f;  
         //var TP= 2500383.7360014333f;
        //var OM= 121.8932402833152f ;  
        var W=  239.2598062405985f;   
        var IN= 28.1988605373753f;
        var A= 43.34173660550696f;   
        var MA= 212.4436438927888f;   
        //var ADIST= 51.53679358381897;
        var N= .003454177f;


     var newE = randomizeOrbit ("Haumea", EC, QR, W, IN, A, MA, d);

        var d_new= d - EPOCH;
        var M = newE[:MA] + N * d_new;
        
        M=f.normalize(M);

        var ret = f.Planet_Sun(M, newE[:EC], newE[:A], newE[:QR], newE[:W], newE[:IN]);
        $.storLastR ["Haumea"] = Math.sqrt(ret[0]*ret[0] + ret[1]*ret[1] + ret[2]*ret[2]);
        //System.println("XYZ: " + ret[0] + " " + ret[1] + " " + ret[2]);
        return ret;
  } 

  //Next to add probably Sedna & Orcus

  //slightly scramble  up all the params
  
  function randomizeOrbit (name, EC, QR, W, IN, A, MA, d){
        
        var ret = {};
        var pRet =  {:EC => EC,
                        :QR => QR,
                        :W => W,
                        :IN => IN,
                        :A => A,
                        :MA => MA,
                        :lastD => d,
                    };
        if ($.animSinceModeChange <= 1 ) {
            $.storRand.put(name, pRet);
            return pRet;    
        }                    

        if ($.storRand != null && storRand.hasKey(name)) {
            
            pRet = storRand[name];
            //System.println("pRet from STOR: " + pRet);
        }
        var lastR = QR;
        if ($.storLastR != null && storLastR.hasKey(name)) {            
            lastR = storLastR[name];
            //System.println("lastR from STOR: " + lastR);
        }

        //lastR = QR;
        
        var eTime = d - pRet[:lastD];
        var rFact = 2000;
        var div = 10000000; //was 10000000 but seemed too big, 100000000f but seemed too small
                           // now 20000000 seems too small so putting to 8000000
                           //putting back to 10000000 - just a slight tweak back
        
        //ret.put(:EC, pRet[:EC] + (Math.rand()%(2*rFact)-rFact) * QR);

        
        ret.put(:EC, (pRet[:EC] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650 * QR/lastR)*A/div/100).toFloat());
        ret.put(:QR, (pRet[:QR] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650 * QR/lastR)*A/div).toFloat());
        ret.put(:W, (pRet[:W] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650 *A)/div).toFloat());
        ret.put(:IN, (pRet[:IN] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650 * QR/lastR*A)/div).toFloat());
        ret.put(:A, (pRet[:A] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650 * QR/lastR*A)/div).toFloat());
        ret.put(:MA, (pRet[:MA] + ((Math.rand()%(2*rFact)-rFact) * QR * eTime/3650 * QR/lastR*A)/div).toFloat());
        ret.put(:lastD, (d).toFloat());

        if (ret[:EC] > 1) {ret[:EC]=1;}
        if (ret[:EC] < 0) {ret[:EC]=0;}

        //System.println("ret: " + ret);
        //System.println("ret: " + ret);
        
        

        $.storRand.put(name, ret);
        return ret;

  }
  */
   

//}

}