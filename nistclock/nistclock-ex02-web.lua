require('nistclock')

days = {
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
}

months = {
  "January",
  "Febuary",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
}

--Set desired time zone delay.
nistclock.setup{tzdelay = 3600}
nistclock.start()

--Create web server
srv=net.createServer(net.TCP)
srv:listen(80,
    function(conn)
        --Local time for HTML body
        second, minute, hour, weekday, day, month, year = nistclock.getTime()
        if second == nil
        then
          prettyTime = "n.a."
        else
          prettyTime = string.format("%s, %d. %s %d %02d:%02d:%02d", days[weekday], day, months[month], year, hour, minute, second)
        end
        --UTC time for HTTP header
        second, minute, hour, weekday, day, month, year = nistclock.getTime(0)
        if second == nil
        then
          headerTime = nil
        else
          headerTime = string.format("%s, %d %s %d %02d:%02d:%02d GMT", days[weekday]:sub(1,3), day, months[month]:sub(1,3), year, hour, minute, second)
        end
        
        htmlBody = "<!DOCTYPE HTML><html><body>"
          .. "<b>NodeMCU-ESP8266</b></br>"
          .. "Time and Date: " .. prettyTime .. "<br>"
          .. "Node ChipID: " .. node.chipid() .. "<br>"
          .. "Node MAC: " .. wifi.sta.getmac() .. "<br>"
          .. "Node Heap: " .. node.heap() .. "<br>"
          .. "Timer Ticks: " .. tmr.now() .. "<br>"
          .. "</html></body>"

         htmlHeader = "HTTP/1.1 200 OK\n"
          .. "Content-Type: text/html\n"
          .. "Content-Length: " .. tostring(#htmlBody) .. "\n"
          .. "Server: NodeMCU-NISTclock\n"
          .. "Refresh: 15\n"
        if headerTime ~= nil
        then
          htmlHeader = htmlHeader .. "Date: " .. headerTime .. "\n"
        end

        conn:send(htmlHeader .. "\n" .. htmlBody)
        conn:on("sent",function(conn) conn:close() end)
    end
)
