#NodeMCU Module<br>nistclock
- The module reads current UTC time from a NIST time server contacted by TCP at port 13 through server pool at address *time.nist.gov*.
- The module requires the internet connection in order to work properly.
- The module acts as a clock and can be used as the substitution to a hardware RTC (real time clock).
- The module uses limited level of input values sanitizing due to keep it as much efficient and small as possible.
- The module honors leap years.
- For culculating day of week for particular date the *Tomohiko Sakamoto algorithm* is used.


<a id="require"></a>
##Require
	require("nistclock")

<a id="release"></a>
## Release
	nistclock, package.loaded["nistclock"] = nil, nil

<a id="dependency"></a>
## Dependency
None

<a id="examples"></a>
## Examples
- **nistclock-ex00-version.lua**: Prints current version of the module.  
- **nistclock-ex01-time.lua**: Getting one-time formatted current date and time in CET and UTC with waiting for a NIST server with help another system timer than default one.  
- **nistclock-ex02-web.lua**: Web server with simple HTML page refreshed every 15 seconds displaying current date and time in CET format and other system parameters. The HTTP header `Date` contains the current date and time in GMT format. Months and weekdays are translated to their names.

<a id="interface"></a>
## Interface
- [version()](#version)
- [setup{}](#setup)
- [start()](#start)
- [stop()](#stop)
- [request()](#request)
- [getTime()](#getTime)
- [getStartTime()](#getStartTime)
- [correctStartTime()](#correctStartTime)
- [getElapsedSecs()](#getElapsedSecs)


<a id="version"></a>
## version()
####Description
Returns the current semantic version string of the module alongside with the version component numbers.

####Syntax
	version()

####Parameters
none

####Returns
The function returns multiple values. 
- **version**: Semantic version string in the schema *major.minor.patch*.
- **majorVersion**: Number of major version.
- **minorVersion**: Number of minor version.
- **patchVersion**: Number of patch version.

####Example

```lua
require("nistclock")
print(nistclock.version())
print((nistclock.version()))
```
	>1.2.3, 1, 2, 3
	>1.2.3

[Back to interface](#interface)

<a id="setup"></a>
##setup{}
####Description
Sets up configuration parameters of the module by rewriting default ones.

####Syntax
	nistclock.setup{
		timer = 0,
		tzdelay = 0,
		refresh = 60,
		debug = true,
		tickcb = nil
	}

- The parameter of the setup function is a Lua table with configuration parameters. Notice curly braces for inputing a table to a function.
- Above are depicted all of the configuration parameters with their default values wired directly in the module.
- Configuration parameters can be written in any order and only needed of them may be present in the table.
- Set only that configuration parameter, which another value you need for.

####Parameters
<a id="timer"></a>
- **timer**: Number of system timer for intenal clock.
	- Valid values: positive integer 0 ~ 6
	- *Default value*: 0


<a id="tzdelay"></a>
- **tzdelay**: Desired time zone difference from UTC in seconds. Positive for East, Negative value for West to meridian. Zero value for UTC. Setting the non-zero value avoids putting the time zone delay at each reading the date and time.
	- Valid values: integer
	- *Default value*: 0


<a id="refresh"></a>
- **refresh**: Time interval in seconds for rereading (updating) the internally kept date and time from a NIST server. Between readings the module updates time by its timer ticking every second.
	- Valid values: positive integer >= 5
	- *Default value*: 60


<a id="debug"></a>
- **debug**: Boolean flag determining whether the module should output debug text. It is useful for observing read NIST records in the serial monitor.
	- Valid values: boolean
	- *Default value*: true


<a id="tickcb"></a>
- **tickcb**: Callback function running by internal clock at every clock tick, i.e., at every second. It can be used for periodic actions in a program. 
	- Valid values: function
	- *Default value*: nil

####Returns
nil

####Example

```lua
require("nistclock")
nistclock.setup{tzdelay = 3600}
nistclock.setup{refresh = 300, timer = 1}
```

####See also
- [getTime()](#getTime)

[Back to interface](#interface)

<a id="start"></a>
## start()
####Description
Starts the internal clock controlled by the system timer with [timer](#timer) number.

- If the timer with [timer](#timer) number is running already, it is stopped before setting it for the module purposes. The coordination of system timer is in responsibility of you.
- The clock ticks in seconds and rereads the date and time from a NIST server after every [refresh](#refresh) number of seconds.
- The clock runs the callback function every second if it is defined in the configuration parameter [tickcb](#tickcb).
- The module stores the first date and time read from a NIST server since launching this function as the NIST clock start time.

####Syntax
	start()

####Parameters
none

####Returns
- **true**: If nist clock started successfully.
- **false**: If nist clock start fails. Check if [timer](#timer) number is correct in [setup{}](#setup).

####Example

```lua
require("nistclock")
nistclock.start()
```
	>true

####See also
- [stop()](#stop)
- [setup{}](#setup)

[Back to interface](#interface)


<a id="stop"></a>
## stop()
####Description
Stops the internal clock and resets the internal date and time.
- Stopping internal clock means stopping the system timer of [timer](#timer) configuration number.
- After stopping the module does not return the date and time anymore. The new [start()](#start) or [request()](#request) is needed.
- The internal time is reset even if the timer has not been stopped or running before, e.g., after previous [request()](#request) reading instant date and time.

####Syntax
	stop()

####Parameters
none

####Returns
nil

####Example

```lua
require("nistclock")
nistclock.start()
nistclock.stop()
```

####See also
- [start()](#start)
- [request()](#request)

[Back to interface](#interface)


<a id="request"></a>
## request()
####Description
Reads the current date and time from a NIST server.
- The module parses the NIST date and time record to the internal date and time.
- If [debug](#debug) configuration flag is set, then the module prints the entire NIST record to the serial monitor. 
- The internal clock runs this function periodically by the system timer, if the clock has been started.
- This function is suitable for debuging and tuning of the module in some more complex program.
- The function can be used for a clock controlled outside the module.
- This function does not store the start time as mentioned in [start()](#start).

####Syntax
	request()

####Parameters
none

####Returns

- **NIST record**: String printed to the serial output if [debug](#debug) flag is true. 

####Example

```lua
require("nistclock")
nistclock.setup{debug = true}
nistclock.request()
```
	>
	57383 15-12-27 20:33:00 00 0 0  30.5 UTC(NIST) *

####See also
- [setup{}](#setup)

[Back to interface](#interface)


<a id="getTime"></a>
## getTime()
####Description
Returns the current date and time.
- If internal clock is running, it is the current calendar date and time kept by the system [timer](#timer) and refreshed every [refresh](#refresh) number of seconds from a NIST server.
- If internal clock is not running but the [request()](#request) has been called, the function returns recently read NIST date and time.
- The function returns nil time until the first time since system reset a NIST server has been contancted or after internal clock has been stopped. So that it is useful some delay after system reset and internal clock starting to wait for internet connection and NIST server reading.

####Syntax
	getTime(secondsDelay, flagAdd)

####Parameters
<a id="secondsDelay"></a>
- **secondsDelay**: Integer number of seconds from UTC time for desired time zone.
	- If the parameter is nil or not put into the function, the default value 0 is used.
	- The value of the parameter is added to the value of [tzdelay](#tzdelay) configuration parameter or used instead of it according to the value of the second parameter [flagAdd](#flagAdd).
	- If the parameter is exactly 0 and [flagAdd](#flagAdd) is false or not present, the function returns UTC time. It is useful in a web server, when some time zone is set by [tzdelay](#tzdelay) configuration parameter, but for the HTTP header `Date` the GMT time is needed.
	- If the parameter is positive integer, the function returns time from *eastern time zones* of meridian.  
	- If the parameter is negative integer, the function returns time from *western time zones* of meridian.
	- The parameters can span multiple days, months, or years, if appropriate number of seconds is put to the function.  


<a id="flagAdd"></a>
- **flagAdd**: Boolean flag determining whether [secondsDelay](#secondsDelay) parameter has to be added to the [tzdelay](#tzdelay) configuration parameter or just replace it.
	- If the parameter is true, the [secondsDelay](#secondsDelay) value is added to [tzdelay](#tzdelay) configuration parameter, but not persistently just temporarily for the time of calculation.
	- If the parameter is false, nil, or not put into the function, the [secondsDelay](#secondsDelay) value is used instead of the [tzdelay](#tzdelay) configuration parameter, but not persistently just temporarily for the time of calculation.

####Returns
The output format is compatible with the same function of the official NodeMCU module *DS3231* just with additional modified Julian day. If internal clock has not been started by [start()](#start) or one time [request()](#request) called yet, the function returns nil value.

- **second**: Nil or non-negative integer of seconds (0~59) in a minute of time.  
- **minute**: Non-negative integer of minutes (0~59) in a hour of time.
- **hour**: Non-negative integer of hours (0~23) in a day of date.  
- **weekday**: Positive integer of a week day (1~7) of date, where 1=Sunday to 7=Saturday. For proper calculation just the Gregorian calendar era (since 1752) should be used.  
- **day**: Positive integer of days (1~31) in a month of date.  
- **month**: Positive integer of months (1~12) in a year of date.  
- **year**: Integer of years (-9999~9999) of date including the century.
- **mjd**: Integer of modified Julian day (0 - 99999) of date.

####Example

```lua
require("nistclock")
nistclock.start()
second, minute, hour, weekday, day, month, year, mjd = nistclock.getTime()
if second ~= nil
then
	print(string.format("%02d.%02d.%04d %02d:%02d:%02d", day, month, year, hour, minute, second))
end
--Exact UTC time
second, minute, hour, weekday, day, month, year = nistclock.getTime(0)
--One hour western from meridian
second, minute, hour, weekday, day, month, year = nistclock.getTime(-3600)
--30 days ago and one hour eastern from meridian
second, minute, hour, weekday, day, month, year = nistclock.getTime(-30*86400+3600)
```
	>27.12.2015 20:33:00

####See also
- [getStartTime()](#getStartTime)
- [start()](#start)
- [request()](#request)

[Back to interface](#interface)


<a id="getStartTime"></a>
## getStartTime()
####Description
Returns the starting date and time of the NIST clock. It is the first gained date and time after starting the clock by function [start()](#start).
- The behaviour and interface of the function is the same as the function [getTime()](#getTime) has.

####Syntax
	getStartTime(secondsDelay, flagAdd)

####See
- [getTime()](#getTime)

[Back to interface](#interface)


<a id="correctStartTime"></a>
## correctStartTime()
####Description
Permanently increases or decreases the start date and time by input number of seconds.
- The correction is useful for relevant long initial sequence in a program in order to set the more precise start time of the program instead to have the start time of the NIST clock.
- If the initial sequence is relevant, it should be measured and by its time period in seconds should be deducted from the start time after the first reading from a NIST server.

####Syntax
	correctStartTime(secondsDelay)

####Parameters
<a id="secondsDelay"></a>
- **secondsDelay**: Integer number of seconds that should be added or deducted from stored start date and time.
	- If the parameter is nil or not put into the function, nothing happens.
	- The parameters can span multiple days, months, or years, if reasonable and appropriate number of seconds is put to the function.  

####Returns
nil

####Example

```lua
initTime = tmr.now()
...
require("nistclock")
nistclock.start()
...
second, minute, hour, weekday, day, month, year, mjd = nistclock.getStartTime()
print(string.format("%02d.%02d.%04d %02d:%02d:%02d", day, month, year, hour, minute, second))
--Correct initial sequence
nistclock.correctStartTime((initTime - tmr.now())/1000000)
second, minute, hour, weekday, day, month, year, mjd = nistclock.getStartTime()
print(string.format("%02d.%02d.%04d %02d:%02d:%02d", day, month, year, hour, minute, second))
```
	>24.01.2016 20:28:30
	>24.01.2016 20:28:27

####See also
- [getStartTime()](#getStartTime)

[Back to interface](#interface)


<a id="getElapsedSecs"></a>
## getElapsedSecs()
####Description
Calculates elapsed seconds (difference) between current date and time and start date and time.


####Syntax
	getElapsedSecs()

####Parameters
None

####Returns
Difference in seconds between the current time returned by the function [getTime()](#getTime) without input parameters and the start time returned by the function [getStartTime()](#getStartTime) without input parameters as well (eventually corrected by [correctStartTime()](#correctStartTime)).

- **seconds**: Non-negative integer number of seconds elapsed since the corrected start date and time until the current date and time. It can be considered as the uptime of the system or NIST clock at least.

####Example

```lua
require("nistclock")
nistclock.start()
...
print(string.format("Elapsed %d secs", nistclock.getElapsedSecs()))
```
	>Elapsed 12 secs

####See also
- [getTime()](#getTime)
- [getStartTime()](#getStartTime)
- [correctStartTime()](#correctStartTime)

[Back to interface](#interface)
