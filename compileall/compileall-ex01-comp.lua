require("compileall")
compileall.start{
  debug = compileall.DEBUG_DETAIL,
  excludes = {"init_test.lua", "test.lua"}, --ini.lua excluded implicitly
}