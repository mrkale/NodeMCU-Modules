require("compileall")
print("Module version:", (compileall.version()))
compileall, package.loaded["compileall"]=nil,nil
