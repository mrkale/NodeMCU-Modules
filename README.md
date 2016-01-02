# NodeMCU-Modules
Lua modules for running in NodeMCU framework within ESP8266. Each module is located in a separate folder with some example scripts and its own *README.md* file.

**It is recommended to compile modules used in a program in order to reduce the file system and heap space.**

<a id="nistclock"></a>
##nistclock
The module reads current UTC time from a NIST time server contacted by TCP at port 13 through server pool at address *time.nist.gov*. Then parses and outputs read date and time to their parts including weekday number. The module provides internal clock ticking at every seconds with posibility to define a callback function running at every clock tick for periodical actions in a program.

<a id="s2eta"></a>
##s2eta
The module converts elapsed or estimated amount of seconds to the time string with non-zero time components separated by one space, for in instance "*1d 7h 21m 6s*".
