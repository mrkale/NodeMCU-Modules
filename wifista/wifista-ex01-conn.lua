require("wifista")
print("wifista version:", (wifista.version()))

function mainAction()
  print("Started main activity...")
end

function wifiConnected()
  print("Successfully connected to:", (wifi.sta.getip()))
  wifista, package.loaded["wifista"] = nil, nil
  print("Module wifista has been released!")
  mainAction()
end

wifista.start{
	credfile = "creds_wifi.lua",
	actioncb = wifiConnected
}
