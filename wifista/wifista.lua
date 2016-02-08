--[[
Configure and connect to a Wifi router in the station mode.
- Module manages the routine actions at connecting to a Wifi network.
- After successful connection the module can be removed from memory
  in a callback function, if its constants and functions are not needed
  in an application anymore.
- Further Wifi management could be provided with help of the event monitor
  built-in in the framework.
- Module defines usefull public constants for Wifi states and
  debugging levels.

License: http://opensource.org/licenses/MIT
Author : Libor Gabaj <libor.gabaj@gmail.com>
GitHub : https://github.com/mrkale/NodeMCU-Modules/tree/master/wifista
--]]
local moduleName = ...
local M = {}
_G[moduleName] = M

function M.version()
  local major, minor, patch = 1, 0, 0
  return major.."."..minor.."."..patch, major, minor, patch
end

--Public constants
M.DEBUG_NONE = 0
M.DEBUG_BASIC = 1
--
M.STATION_IDLE = 0
M.STATION_CONNECTING = 1
M.STATION_WRONG_PASSWORD = 2
M.STATION_NO_AP_FOUND = 3
M.STATION_CONNECT_FAIL = 4
M.STATION_GOT_IP = 5
M.CONNECT_MANUAL = 0
M.CONNECT_AUTOMATIC = 1

--Configuration parameters
local conf = {
  debug = M.DEBUG_BASIC,  --Debug level determining detail of printouts
  timer = 6,              --Time number
  tries = 0,              --Number of tries to connect to Wifi
  credfile = nil,         --Credential file with Wifi credential and ipconfig table
  actioncb = nil,         --Call back function run after wifi connection
}

--LOCAL FUNCTIONS--
local fmt = string.format
local function isTimer(tn) return tn ~= nil and tn >= 0 and tn <= 6 end

local function wifiCheck()
  if wifi.sta.status() == M.STATION_GOT_IP
  then
    conf.tries = 0
    tmr.unregister(conf.timer)
    if conf.debug >= M.DEBUG_BASIC
    then
      print("\nMAC:", wifi.sta.getmac())
      print("Chip:", node.chipid())
      print("Heap:", node.heap())
      if wifi.sta.gethostname then print("Host:", wifi.sta.gethostname()) end
      print(wifi.sta.getip())
    end
    collectgarbage()
    if conf.actioncb then conf.actioncb() end
  else
    conf.tries = conf.tries + 1
    if conf.debug >= M.DEBUG_BASIC
    then
      print(fmt("Connecting to AP (%d)", conf.tries))
    end
  end
end

local function wifiStart()
  local t = dofile(conf.credfile)
  wifi.setmode(wifi.STATION)
  if t.ipconfig
  then
    wifi.sta.setip(t.ipconfig)
  end
  wifi.sta.config(t.SSID, t.PASSWORD, t.AUTO or M.CONNECT_AUTOMATIC, t.BSSID)
  if wifi.sta.sethostname then wifi.sta.sethostname(t.HOST) end
  wifi.sta.connect()
  tmr.unregister(conf.timer)
  tmr.alarm(conf.timer, 1000, tmr.ALARM_AUTO, wifiCheck)
end

--Start module by input table setupTable with parameters in arbitrary order:
--debug    - debug level, defualt M.DEBUG_BASIC
--timer    - number of timer (0 .. 6), default 6
--credfile - credential file name (.lua or .lc)
--actioncb - callback function launched after successful connection to the wifi
function M.start(setupTable)
  if setupTable.debug ~= nil then conf.debug = setupTable.debug end
  if isTimer(setupTable.timer) then conf.timer = setupTable.timer end
  if setupTable.credfile ~= nil then conf.credfile = setupTable.credfile end
  if setupTable.actioncb ~= nil then conf.actioncb = setupTable.actioncb end

  wifiStart()
end

return M