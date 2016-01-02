--[[
Seconds to elapsed or estimated time conversion for NODEMCU
- Module converts amount of seconds to time string with components:
  days (d), hours (h), minutes (m), seconds (s)
- Zero components are not included into the time string.
- If no, zero, or negative input seconds are provided, the module returns empty string.

License: http://opensource.org/licenses/MIT
Author : Libor Gabaj <libor.gabaj@gmail.com>
GitHub : https://github.com/mrkale/NodeMCU-Modules.git
--]]
local moduleName = ...
local M = {}
_G[moduleName] = M

local floor = math.floor
local format = string.format

function M.version()
  local major, minor, patch = 1, 0, 0
  return major.."."..minor.."."..patch, major, minor, patch
end

--Convert to ETA
function M.eta(seconds)
  if (seconds or 0) <= 0 then return "" end
  local config = {
  [1] = {value = seconds,
        coef = 60,
        sfx = "s",
        },
  [2] = {value = 0,
        coef = 60,
        sfx = "m",
        },
  [3] = {value = 0,
        coef = 24,
        sfx = "h",
        },
  [4] = {value = 0,
        sfx = "d",
        },
  }
  --Calculation
  for i = 1,4
  do
    --Calculate value
    if (config[i].coef or 0) ~= 0 
    then
      config[i+1].value = floor(config[i].value / config[i].coef)
      config[i].value = config[i].value % config[i].coef
    end
  end
  --Formatting
  local result = ""
  for i = 4,1,-1
  do
    if config[i].value ~= 0
    then
      if #result > 0 then result = result .. " " end
      result = result .. format("%d"..config[i].sfx, config[i].value)
    end
  end
  return result
end

return M