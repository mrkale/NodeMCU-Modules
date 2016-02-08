--[[
Compile all Lua scripts except excluded ones.
- Module defines usefull public constants debugging levels.
- Script "init.lua" is implicitly excluded from the compilation.
- At detail debug level the module prints out the configuration table with
  list of excluded scripts.
- After compilation the module releases itself, because it is not more needed.

License: http://opensource.org/licenses/MIT
Author : Libor Gabaj <libor.gabaj@gmail.com>
GitHub : https://github.com/mrkale/NodeMCU-Modules/tree/master/compileall
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
M.DEBUG_DETAIL = 2

--Configuration parameters
local conf = {
  debug = M.DEBUG_BASIC,  --Debug level determining detail of printouts
  excludes={"init.lua"},  --List of excluded scripts from compilation
}

--LOCAL FUNCTIONS--
local function extendTable(tblSource, tblExtend)
  --Concatenate tables
  for _, ve in ipairs(tblExtend)
  do
    local isUnique = true
    for _, vs in ipairs(tblSource)
    do
      if vs == ve
      then
        isUnique = false
        break
      end
    end
    if isUnique then table.insert(tblSource, ve) end
  end
  --Print extended source table
  if conf.debug >= M.DEBUG_DETAIL
  then
    print("extendTable:", table.concat(tblSource, ", "))
  end
  return tblSource
end
 
local function compileFile(luaFile)
  if file.open(luaFile)
  then
    file.close()
    --Check exclusion
    local isIncluded = true
    for _, excFile in ipairs(conf.excludes)
    do
      if excFile == luaFile
      then
        isIncluded = false
        break
      end
    end
    --Compilation
    local msg
    if isIncluded
    then
      node.compile(luaFile)
      file.remove(luaFile)
      collectgarbage()
      msg = "Compiled"
    else
      msg = "Excluded"
    end
    if conf.debug >= M.DEBUG_BASIC then print(msg..":", luaFile) end
  end
end

--Start module by input table setupTable with parameters in arbitrary order:
--debug    - debug level, defualt M.DEBUG_BASIC
--excludes - table with list of additional scripts excluded from compilation
function M.start(setupTable)
  if setupTable.debug ~= nil then conf.debug = setupTable.debug end
  if setupTable.excludes ~= nil then conf.excludes = extendTable(conf.excludes, setupTable.excludes) end
  --Compile files
  for fileName, fileSize in pairs(file.list())
  do
    if fileName:match("%.lua$")
    then
      compileFile(fileName)
    end
  end
  --Release module by itself
  _G[moduleName], package.loaded[moduleName] = nil, nil
  collectgarbage()
end

return M