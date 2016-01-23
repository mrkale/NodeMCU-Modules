--[[
NIST clock module for NODEMCU
- Module retrieves network time from a NIST server by Daytime Protocol (RFC-867).
- Only date and time parts of the response are used for the output.

License: http://opensource.org/licenses/MIT
Author : Libor Gabaj <libor.gabaj@gmail.com>
GitHub : https://github.com/mrkale/NodeMCU-Modules.git
--]]
local moduleName = ...
local M = {}
_G[moduleName] = M

function M.version()
  local major, minor, patch = 1, 0, 2
  return major.."."..minor.."."..patch, major, minor, patch
end

--Configuration parameters
local conf = {
  timer = 0,            --Number of clock timer
  tzdelay = 0,          --Time zone difference from UTC in seconds
  refresh = 60,         --Refresh time period in seconds from NIST time server
  tickcb = nil,         --Call back function run at every clock tick
  connecting = false,   --Flag determining pending connection to a NIST server
  debug = true,         --Flag determining module print outputs provided
}

--Calendar parameters
local monthDays = {31,28,31,30,31,30,31,31,30,31,30,31}
local monthCorr = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4}
local timeCoef = {24, 60, 60} --Hours, Minutes, Seconds
local dateTable = {0,0,0,0,0,0} --1=Year, 2=Month, 3=Day, 4=Hour, 5=Minute, 6=Second

--LOCAL FUNCTIONS--
local floor = math.floor
local max = math.max
local fmt = string.format

local function isTimer(tn) return tn ~= nil and tn >= 0 and tn <= 6 end
local function daySeconds() return 60*(60*dateTable[4]+dateTable[5])+dateTable[6] end

local function isLeapYear(y)
  y = y + 0
  return (y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0))
end

local function getMonthDays(m, y)
  local d = monthDays[m]
  if m == 2 and isLeapYear(y)
  then
    d = d + 1
  end
  return d
end

local function parseNistRecord(nistRecord)
  local timeString = "20"..nistRecord:sub(8, 24)
  local i = 0
  for v in timeString:gmatch("%d+")
  do
    i = i + 1
    dateTable[i] = v + 0
  end
end

--Add seconds to date table
local function plusTimeTable(t, s)
  if s <= 0 or t[2] == 0 then return t end
  t[6] = t[6] + s
  --Time portion
  for i = 6, 4, -1
  do
    local c = timeCoef[i-3]
    if t[i] >= c
    then
      t[i-1] = t[i-1] + floor(t[i]/c)
      t[i] = t[i]%c
    end
  end
  --Date portion
  local monthDays = getMonthDays(t[2], t[1])
  while t[3] > monthDays
  do
    t[2] = t[2] + 1
    if t[2] == 13
    then
      t[2] = 1
      t[1] = t[1] + 1
    end
    t[3] = t[3] - monthDays
    monthDays = getMonthDays(t[2], t[1])
  end
  return t
end

--Substract seconds from date table
local function minusTimeTable(t, s)
  if s >= 0 or t[2] == 0 then return t end
  t[6] = t[6] + s
  --Time portion
  for i = 6, 4, -1
  do
    local c = timeCoef[i-3]
    if t[i] < 0
    then
      t[i-1] = t[i-1] + floor(t[i]/c)
      t[i] = t[i]%c
    end
  end
  --Date portion
  while t[3] <= 0
  do
    t[2] = t[2] - 1
    if t[2] == 0
    then
      t[2] = 12
      t[1] = t[1] - 1
    end
    t[3] = t[3] + getMonthDays(t[2], t[1])
  end
  return t
end

--Tomohiko Sakamoto algorithm (1 = Sunday, 2 = Monday .. 7 = Saturday)
local function dayOfWeek(y, m, d)
  if m < 3 then y = y - 1 end
  return (y + floor(y/4) - floor(y/100) + floor(y/400) + monthCorr[m] + d) % 7 + 1
end

--PUBLIC FUNCTIONS--

--Read date time record from a NIST server
function M.request()
  local conn = net.createConnection(net.TCP, 0)
  conn:on("receive",
    function(conn, payload)
      if conf.debug then print(payload) end
      if payload:find("UTC") ~= nil
      then
        parseNistRecord(payload)
      end
      conn:close()
    end
  )
  conn:on("disconnection",
    function(conn)
      conf.connecting = false
    end
  )
  conf.connecting = true
  conn:connect(13, "time.nist.gov")
end

--Stop clock timer if it is running
function M.stop()
  if isTimer(conf.timer) then tmr.unregister(conf.timer) end
  for k,v in ipairs(dateTable)
  do
    dateTable[k] = 0
  end
end

--Start clock timer if it is set correctly and return result flag
function M.start()
  if isTimer(conf.timer) then M.stop() else return false end
  tmr.alarm(conf.timer, 1000, tmr.ALARM_AUTO,
    function()
      plusTimeTable(dateTable, 1)
      if conf.tickcb then conf.tickcb() end
      if not conf.connecting and daySeconds() % conf.refresh == 0
      then
        M.request()
      end
    end
  )
  return true
end

--Return current time parts in compatibility with DS3231 module
--Second, Minute, Hour, WeekDay, Day, Month, Year
--If secondsDelay not used, the configuration tzdelay is used instead
function M.getTime(secondsDelay)
  if dateTable[2] == 0 then return nil end
  secondsDelay = (secondsDelay or conf.tzdelay)
  local tt = {}
  if secondsDelay == 0
  then
    tt = dateTable
  else
    for k,v in ipairs(dateTable)
    do
      tt[k] = v
    end
    tt = minusTimeTable(plusTimeTable(tt, secondsDelay), secondsDelay)
  end
  return
    tt[6],
    tt[5],
    tt[4],
    dayOfWeek(tt[1], tt[2], tt[3]),
    tt[3],
    tt[2],
    tt[1]
end

--Setup module by input table setupTable with parameters in arbitrary order:
--timer   - number of clock timer (0 - 6)
--tzdelay - time zone difference from UTC in seconds (+ for East, - for West)
--refresh - time period for refreshing time table from a NIST server
--debug   - flag determining the module print output
--tickcb  - callback function run at every clock tick (every second)
function M.setup(setupTable)
  if isTimer(setupTable.timer) then conf.timer = setupTable.timer end
  if setupTable.tzdelay ~= nil then conf.tzdelay = setupTable.tzdelay end
  if setupTable.refresh ~= nil then conf.refresh = max(setupTable.refresh, 5) end
  if setupTable.debug ~= nil then conf.debug = setupTable.debug end
  if setupTable.tickcb ~= nil then conf.tickcb = setupTable.tickcb end
end


return M