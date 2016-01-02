require("nistclock")

--Rewrite default module parameters if needed. Mind the default timer no. 0.
--Set time zone delay for CET.
--If UTC time zone is needed, comment or delete next line to use default 0 delay.
nistclock.setup{tzdelay = 3600}

--Wait for NIST server connection by another timer
nistclock.request()
tmr.alarm(1, 500, 1, 
  function()
    second, minute, hour, weekday, day, month, year = nistclock.getTime()
    if second ~= nil
    then
      tmr.stop(1)
      --Format date and time for configuration time zone delay
      print(string.format("CET: %02d.%02d.%4d %02d:%02d:%02d", day, month, year, hour, minute, second))
      --Format date and time for UTC
      second, minute, hour, weekday, day, month, year = nistclock.getTime(0)
      print(string.format("UTC: %02d.%02d.%4d %02d:%02d:%02d", day, month, year, hour, minute, second))
      --Release it after use
      nistclock, package.loaded["nistclock"] = nil, nil
    end
  end
)
