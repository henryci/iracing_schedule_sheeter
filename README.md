# iracing_schedule_sheeter

Converts the iRacing schedule into a TSV file that can be used with Google Sheets / Excel / etc.
It works by parsing out the tables in the PDF which iRacing supplies. It's kind of gross but
I couldn't find the data in a less messy format. I'm not sure I want to know if it exists
somewhere else. :)

## Installation
It's just a Ruby script so it should just work. (Tested on OSX and Linux). The only challenge may be 
installing the `iguvium` gem because it requires building a native extension and if you are on OSX 
this may require updating your Xcode / build environment. 

## Usage
./iracing_Schedule_sheeter.rb <iRacingPDF.pdf>

## Track File
This script is straight forward with this one exception. The iRacing PDF lists the track for
a given week in a single cell, with entries such as:
* Charlotte Motor Speedway - Legends Oval - 2018 (2022-04-01 08:50 1x)
* South Boston Speedway (2022-04-16 19:50 1x)
* [Legacy] Daytona International Speedway - 2008 - Oval (2022-05-17 15:35 1x)

From these strings we need to get the track and the configuration. This is complicated by the fact
that iRacing adds new tracks and configurations every season.

To accomplish this we split this string on "(" and provide a JSON file mapping the first value to a
defined track and configuration. The entries for the above look like:
```
{
   "Charlotte Motor Speedway - Legends Oval - 2018":{
      "name":"Charlotte Motor Speedway",
      "config":"Legends Oval - 2018"
   },
      "South Boston Speedway":{
      "name":"South Boston Speedway",
      "config":"South Boston Speedway"
   },
   "[Legacy] Daytona International Speedway - 2008 Constant weather, Dynamic sky, Qual - Oval":{
      "name":"[Legacy] Daytona International Speedway",
      "config":"2008 - Oval"
   },
}
```

If you looked at that third entry and said "hey, that's not right!" then you have a good eye. This is the result of the way the PDF parser handles run-on cells. Part of the next cell over is being pulled into the track cell and this is the result. Fortunately, the script dumps all of this at the end and this is pretty straight forward to handle.

When the script is done, you may see output like this:
```
Last page: 117 tables read: 111
There are unknown tracks:
{"LA Coliseum Raceway":{"name":"","config":""},"Las Vegas Motor Speedway - Infield Legends Oval":{"name":"","config":""},"Charlotte Motor Speedway - Legends RC Long - Dynamic weather, Dynamic sky, Qual 2018":{"name":"","config":""},"Oulton Park Circuit - Island":{"name":"","config":""},"Knockhill Racing Circuit - International Reverse":{"name":"","config":""},"Red Bull Ring - National":{"name":"","config":""},"Winton Motor Raceway - National Circuit":{"name":"","config":""},"Winton Motor Raceway - Club Circuit":{"name":"","config":""},"Knockhill Racing Circuit - International":{"name":"","config":""},"Knockhill Racing Circuit - National Reverse":{"name":"","config":""},"Road America - Bend":{"name":"","config":""},"Lime Rock Park - West Bend Chicane":{"name":"","config":""},"Sonoma Raceway - IndyCar 2012-2018":{"name":"","config":""},"Summit Point Raceway - Summit Point Raceway Dynamic weather, Dynamic sky, Grid":{"name":"","config":""},"Suzuka International Racing Course - Grand Prix Dynamic weather, Dynamic sky,":{"name":"","config":""},"Federated Auto Parts Raceway at I-55":{"name":"","config":""},"Knockhill Racing Circuit - Rallycross":{"name":"","config":""},"iRacing Superspeedway":{"name":"","config":""}}
```
This means tracks were encountered that didn't have a matching entry in the JSON file. This output is in the same format as the tracks file and can usually be updated with little work. For example, above the second entry is:
`"Las Vegas Motor Speedway - Infield Legends Oval":{"name":"","config":""}`
Which would be come:
```
"Las Vegas Motor Speedway - Infield Legends Oval":{
  "name":"Las Vegas Motor Speedway",
  "config":"Infield Legends Oval"
}
```
