#NodeMCU Module<br>wifista
- Module manages the routine actions at the connecting to a Wifi network.
- After successful connection the module can be removed from memory
  in a callback function, if its constants and functions are not needed in an application altogether.
- The callback function can start subsequent activities of an application.
- Further Wifi management could be provided with help of the [event monitor](http://nodemcu.readthedocs.org/en/newdocs/en/modules/wifi/#wifistaeventmonreg) and the (wifi module](http://nodemcu.readthedocs.org/en/newdocs/en/modules/wifi/) built-in in the NodeMCU framework.
- Module contains just minimum code sanitization in order to keep it as small as possible.


<a id="require"></a>
##Require
	require("wifista")

<a id="release"></a>
## Release
	wifista, package.loaded["wifista"] = nil, nil

<a id="dependency"></a>
## Dependency
None

<a id="examples"></a>
## Examples
- **wifista-ex00-version.lua**: Print current version of the module.  
- **wifista-ex01-conn.lua**: Connecting to a Wifi network and release the module.  


<a id="interface"></a>
## Interface
- [Constants](#Constants)
- [version()](#version)
- [start{}](#start)
- [Credential file](#credscript)

<a id="Constants"></a>
## Constants

####Debug level
The constants determine the detail of printed actions and values of the module to the serial port during its run.  
```
DEBUG_NONE   -- No debugging printouts
DEBUG_BASIC  -- Basic actions executed 
```

###Wifi status
The constants define [status values](http://nodemcu.readthedocs.org/en/newdocs/en/modules/wifi/#wifistastatus) of the *wifi* module from the NodeMCU framework.
```
-- For wifi.sta.status()
STATION_IDLE
STATION_CONNECTING
STATION_WRONG_PASSWORD
STATION_NO_AP_FOUND
STATION_CONNECT_FAIL
STATION_GOT_IP
-- For wifi.sta.config()
CONNECT_MANUAL
CONNECT_AUTOMATIC
```


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
require("wifista")
print(wifista.version())
print((wifista.version()))
```
	>1.2.3, 1, 2, 3
	>1.2.3

[Back to interface](#interface)

<a id="start"></a>
##start{}
####Description
Starts the connection to a Wifi network with values of configuration parameters provided in the input table. The module uses default values for configuration parameters not present in the input table 

####Syntax
	wifista.start{
		debug = wifista.DEBUG_BASIC,
		timer = 6,
		credfile = nil,
		actioncb = nil,
	}

- The parameter of the function is a Lua table with configuration parameters. Notice curly braces for inputing a table to a function.
- Above are depicted all of the configuration parameters with their default values wired directly in the module.
- Configuration parameters can be written in any order and only needed of them may be present in the table.
- Set only that configuration parameter, which another value you need for.

####Parameters
<a id="debug"></a>
- **debug**: [Constant](#Constants) determining level of debugging detail.
	- Valid values: positive integer
	- *Default value*: wifista.DEBUG_BASIC


<a id="timer"></a>
- **timer**: Number of a system timer used for waiting for the wifi connection. After successful connection to a Wifi network the module [unregisters](http://nodemcu.readthedocs.org/en/newdocs/en/modules/tmr/#tmrunregister) this timer.
	- Valid values: positive integer 0 ~ 6
	- *Default value*: 6


<a id="credfile"></a>
- **credfile**: Name and extension of a script file defining the table with Wifi credentials and configuration of the IP address. Mind to provide correct file's extension if you plan to use compiled scripts.  
	- Valid values: string
	- *Default value*: nil


<a id="actioncb"></a>
- **actioncb**: Callback function launched right after successful connecting to a Wifi network. It can be used for starting subsequent actions requiring wifi connection as well as for potential [releasing](#release) the module from the memory.
	- Valid values: function
	- *Default value*: nil

####Returns
nil

####Example

```lua
require("wifista")

function wifiConnected()
  wifista, package.loaded["wifista"] = nil, nil
end

wifista.setup{
	timer = 0,
	credfile = "creds_wifi.lua",
	actioncb = wifiConnected
}
```

####See also
- [Release](#release)

[Back to interface](#interface)


<a id="credscript"></a>
## Credential file
It is a lua script returning just a table with Wifi and IP configuration parameters.

```lua
return {
  SSID="MySSID",
  PASSWORD="MyPASW",
  -- AUTO=1,
  -- BSSID="MyMAC",
  -- HOST="MyHOST",
  -- ipconfig={
    -- ip="192.168.0.x",
    -- netmask="255.255.255.0",
    -- gateway="192.168.0.1",
    -- },
}
``` 


<a id="wifiparams"></a>
*Wifi credential parameters* are used for the framework function [wifi.sta.config](http://nodemcu.readthedocs.org/en/newdocs/en/modules/wifi/#wifistaconfig). 
- **SSID**, **PASSWORD**: Name of a Wifi network and access password, which you want to connect to.
- **AUTO**, **BSSID**: Optional parameters, while default value for *AUTO* is [wifistat.CONNECT_AUTOMATIC](#Constants) and for *BSSID* is *nil*.
- **HOST**: Optional name of a station (your wifi router) you want to connect to and name it on your own in your application. It is applied only if framework functions [wifi.sta.sethostname()](http://nodemcu.readthedocs.org/en/newdocs/en/modules/wifi/#wifistasethostname) and [wifi.sta.gethostname()](http://nodemcu.readthedocs.org/en/newdocs/en/modules/wifi/#wifistagethostname) are implemented. 


*IP config parameter* is a table used for the framework function [wifi.sta.setip()](http://nodemcu.readthedocs.org/en/newdocs/en/modules/wifi/#wifistasetip) setting up static IP address of the ESP8266. If the table is not defined, the ESP8266 gets dynamic IP address from a DHCP server.  
- **ipconfig**: Configuration table with static IP address parameters.
- **ip**: Desired static IP address of the ESP8266.
- **netmask**: Mask of your LAN network defined in your wifi router.
- **gateway**: IP address of your wifi router.
