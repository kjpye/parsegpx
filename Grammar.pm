use v6;

#use Grammar::Tracer;

grammar Gpx {
    token float {
	| <[+-]>? (\d+) '.' (\d*)
	| <[+-]>? '.' (\d)+
    }
    token nonnegative { (\d+) }
    token datetime { (\d\d\d\d) '-'
	 	     (\d\d) <?{ 1 <= $1 <= 12 }> '-'
                     (\d\d) <?{ 1 <= $2 <= 31 }> 'T' # Fix to disallow 31st September and friends
	 	     (\d\d) <?{ $3 < 24 }> ':'
	 	     (\d\d) <?{ $4 < 60 }> ':'
	 	     (\d\d) <?{ $5 <= 60 }> 'Z' # allow for leap seconds
		   }
    token fix { 'none' | '2d' | '3d' | 'dgps' | 'pps' }
    rule dgpsStation { ( \d+ ) <?{ $0 < 1024 }> }
    rule degrees { (<float>) <?{ 0.0 <= $0 <= 360.0 }> }
    rule longitude { (<float>) <?{ -180.0 <= $0 <= 180.0 }> }
    rule latitude { (<float>) <?{ -90.0 <= $0 <= 90.0 }> }
    rule bounds { [
			| 'minlat' '=' '"' <latitude>  '"'
			| 'minlon' '=' '"' <longitude> '"'
			| 'maxlat' '=' '"' <latitude>  '"'
			| 'maxlon' '=' '"' <longitude> '"'
		    ]
		}
    rule ptseg { '<' 'pt' '>' <pt> '<' '/' 'pt' '>' }
    rule pt { [
		    | 'lat' '=' '"' <latitude> '"'
		    | 'lon' '=' '"' <longitude> '"'
		    | <ele>
		    | <time>
		]+
	    }
    token string { (<-[<]>*)}
    rule person { [
			| '<' 'name' '>' <string> '<' '/' 'name' '>'
			| '<' 'email' '>' <email> '<' '/' 'email' ''
			| <link>
		    ]*
		}
    rule email { [
		       | 'id' '=' <string> '"'
		       | 'domain' '=' '"' <string> '"'
		   ]*
	       }
    token uri { (<-["]>+) }
    rule link { '<' 'link'
                           'href' '=' '"' <uri> '"'
[
                [ '/' '>' ]
                |
                [
                  '>'
		  [ '<' 'text' '>' <string> '<' '/' 'text' '>' ]?
		  [ '<' 'type' '>' <string> '<' '/' 'type' '>' ]?
                  '<' '/' 'link' '>'
                ]
]
	      }
    rule copyright { [
			   | 'author' '=' '"' <string> '"'
			   | '<' 'year' '>' <year> '<' '/' 'year' '>'
			   | '<' 'license' '>' <uri> '<' '/' 'license' '>'
		       ]+
		   }
    rule trkseg { [
			| '<' 'trkpt'          <wpt> '<' '/' 'trkpt' '>'
			| '<' 'extensions' '>' <extensions> '<' '/' 'extesions' '>'
		    ]*
		}
    rule extensions {
# ???
{ fail "not implemented"; }
    }
    rule trk { [
		     | '<' 'name'       '>' <string>      '<' '/' 'name'       '>'
		     | '<' 'cmt'        '>' <string>      '<' '/' 'cmt'        '>'
		     | '<' 'desc'       '>' <string>      '<' '/' 'desc'       '>'
		     | '<' 'src'        '>' <string>      '<' '/' 'src'        '>'
		     | <link>
		     | '<' 'number'     '>' <nonnegative> '<' '/' 'number'     '>'
		     | '<' 'type'       '>' <string>      '<' '/' 'type'       '>'
		     | '<' 'extensions' '>' <extensions>  '<' '/' 'extensions' '>'
		     | '<' 'trkseg'     '>' <trkseg>      '<' '/' 'trkseg'     '>'
		     ]*
	     }
    rule rte { [
		     | '<' 'name'       '>' <string>      '<' '/' 'name'       '>'
		     | '<' 'cmt'        '>' <string>      '<' '/' 'cmt'        '>'
		     | '<' 'desc'       '>' <string>      '<' '/' 'desc'       '>'
		     | '<' 'src'        '>' <string>      '<' '/' 'src'        '>'
		     | <link>
		     | '<' 'number'     '>' <nonnegative> '<' '/' 'number'     '>'
		     | '<' 'type'       '>' <string>      '<' '/' 'type'       '>'
		     | '<' 'extensions' '>' <extensions>  '<' '/' 'extensions' '>'
		     | '<' 'rtept'      '>' <wpt>         '<' '/' 'rtept'      '>'
		     ]*
	     }
    rule wpt {
		     'lat' '=' '"' <latitude>  '"'
		     'lon' '=' '"' <longitude> '"'
                     '>'
		     [
		     | '<' 'ele'           '>' <float>       '<' '/' 'ele'           '>'
		     | '<' 'time'          '>' <datetime>    '<' '/' 'time'          '>'
		     | '<' 'magvar'        '>' <degrees>     '<' '/' 'magvar'        '>'
		     | '<' 'geoidheight'   '>' <float>       '<' '/' 'geoidheight'   '>'
		     | '<' 'name'          '>' <string>      '<' '/' 'name'          '>'
		     | '<' 'cmt'           '>' <string>      '<' '/' 'cmt'           '>'
		     | '<' 'desc'          '>' <string>      '<' '/' 'desc'          '>'
		     | '<' 'src'           '>' <string>      '<' '/' 'src'           '>'
		     | <link>
		     | '<' 'sym'           '>' <string>      '<' '/' 'sym'           '>'
		     | '<' 'type'          '>' <string>      '<' '/' 'type'          '>'
		     | '<' 'fix'           '>' <fix>         '<' '/' 'fix'           '>'
		     | '<' 'sat'           '>' <nonnegative> '<' '/' 'sat'           '>'
		     | '<' 'hdop'          '>' <float>       '<' '/' 'hdop'          '>'
		     | '<' 'vdop'          '>' <float>       '<' '/' 'vdop'          '>'
		     | '<' 'pdop'          '>' <float>       '<' '/' 'pdop'          '>'
		     | '<' 'ageofdgpsdata' '>' <float>       '<' '/' 'ageofdgpsdata' '>'
		     | '<' 'dgpsid'        '>' <dgps>        '<' '/' 'dgpsid'        '>'
		     | '<' 'extensions'    '>' <extensions>  '<' '/' 'extensions'    '>'
		 ]+
	     }
    rule metadata { [
			  | '<' 'name'       '>' <string>     '<' '/' 'name'       '>'
			  | '<' 'desc'       '>' <string>     '<' '/' 'desc'       '>'
			  | '<' 'author'     '>' <person>     '<' '/' 'author'     '>'
			  | '<' 'copyright'  '>' <copyright>  '<' '/' 'copyright'  '>'
			  | <link>
			  | '<' 'time'       '>' <datetime>   '<' '/' 'time'       '>'
			  | '<' 'keywords'   '>' <string>     '<' '/' 'keywords'   '>'
			  | '<' 'bounds'     '>' <bounds>     '<' '/' 'bounds'     '>'
			  | '<' 'extensions' '>' <extensions> '<' '/' 'extensions' '>'
		      ]*
		  }
    rule gpx { [
		     | 'version' '=' '"' '1.1'    '"'
		     | 'creator' '=' '"' <string> '"'
		     | '<' 'metadata'   '>' <metadata>   '<' '/' 'metadata'   '>'
		     | '<' 'wpt'            <wpt>        '<' '/' 'wpt'        '>'
		     | '<' 'rte'        '>' <rte>        '<' '/' 'rte'        '>'
		     | '<' 'trk'        '>' <trk>        '<' '/' 'trk'        '>'
		     | '<' 'extensions' '>' <extensions> '<' '/' 'extensions' '>'
		 ]+
	     }
    rule TOP {
	'<' 'gpx' '>' <gpx> '<' '/' 'gpx' '>'
}
		   }
my $teststring;

$teststring = Q:to/EOS/;
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>

<gpx xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1" creator="Oregon 400t" version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd">
  <metadata>
    <link href="http://www.garmin.com">
      <text>Garmin International</text>
    </link>
    <time>2009-10-17T22:58:43Z</time>
  </metadata>
  <trk>
    <name>Example GPX Document</name>
    <trkseg>
      <trkpt lat="47.644548" lon="-122.326897">
        <ele>4.46</ele>
        <time>2009-10-17T18:37:26Z</time>
      </trkpt>
      <trkpt lat="47.644548" lon="-122.326897">
        <ele>4.94</ele>
        <time>2009-10-17T18:37:31Z</time>
      </trkpt>
      <trkpt lat="47.644548" lon="-122.326897">
        <ele>6.87</ele>
        <time>2009-10-17T18:37:34Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
EOS

$teststring = Q:to/EOS/;
<gpx>
  <metadata>
    <link href="http://www.garmin.com">
      <text>Garmin International</text>
    </link>
    <time>2009-10-17T22:58:43Z</time>
  </metadata>
  <trk>
    <name>Example GPX Document</name>
    <trkseg>
      <trkpt lat="47.644548" lon="-122.326897">
        <ele>4.46</ele>
        <time>2009-10-17T18:37:26Z</time>
      </trkpt>
      <trkpt lat="47.644548" lon="-122.326897">
        <ele>4.94</ele>
        <time>2009-10-17T18:37:31Z</time>
      </trkpt>
      <trkpt lat="47.644548" lon="-122.326897">
        <ele>6.87</ele>
        <time>2009-10-17T18:37:34Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
EOS

dd Gpx.parse($teststring);
		     
