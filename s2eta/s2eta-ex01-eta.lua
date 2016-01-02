require("s2eta")
local seconds

seconds = 12*86400 + 7*3600 + 18*60 + 23
print("ETA "..seconds.." sec. => "..s2eta.eta(seconds))

seconds = 7*3600 + 18*60 + 23
print("ETA "..seconds.." sec. => "..s2eta.eta(seconds))

seconds = 7*3600 + 0*60 + 23
print("ETA "..seconds.." sec. => "..s2eta.eta(seconds))

seconds = 23
print("ETA "..seconds.." sec. => "..s2eta.eta(seconds))

seconds = 120
print("ETA "..seconds.." sec. => "..s2eta.eta(seconds))

s2eta, package.loaded["s2eta"] = nil, nil
