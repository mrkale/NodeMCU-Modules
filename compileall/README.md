#NodeMCU Module<br>compileall
- Module compiles all Lua scripts except excluded ones.
- Script "*init.lua*" is implicitly excluded from the compilation.
- At detail debug level the module prints out a list of excluded scripts.
- *Module implicitly compiles itself as well.*
- **After compilation the module releases itself, because it is not more needed.**


<a id="require"></a>
##Require
	require("compileall")

<a id="release"></a>
## Release
By itself

<a id="dependency"></a>
## Dependency
None

<a id="examples"></a>
## Examples
- **compileall-ex00-version.lua**: Print current version of the module.



<a id="interface"></a>
## Interface
- [Constants](#Constants)
- [version()](#version)
- [start{}](#start)


<a id="Constants"></a>
## Constants

####Debug level
The constants determine the detail of printed actions and relevance of module's values to the serial port during its run.
```
DEBUG_NONE   -- No debugging printouts
DEBUG_BASIC  -- Basic actions executed
DEBUG_DETAIL -- Overall list of excluded scripts
```


<a id="version"></a>
## version()
####Description
Returns the current semantic version string of the module alongside with the version component numbers.

####Syntax
	version()

####Parameters
none

####Returns
The function returns multiple values.
- **version**: Semantic version string in the schema *major.minor.patch*.
- **majorVersion**: Number of major version.
- **minorVersion**: Number of minor version.
- **patchVersion**: Number of patch version.

####Example

```lua
require("compileall")
print(compileall.version())
print((compileall.version()))
```
	>1.2.3, 1, 2, 3
	>1.2.3

[Back to interface](#interface)

<a id="start"></a>
##start{}
####Description
Starts the compilation with values of configuration parameters provided in the input table. The module uses default values for configuration parameters not present in the input table.

####Syntax
	compileall.start{
		debug = compileall.DEBUG_BASIC,
		excludes = {"init.lua"},
	}

- The parameter of the function is a Lua table with configuration parameters. Notice curly braces for inputing a table to a function.
- Above are depicted all of the configuration parameters with their default values wired directly in the module.
- Configuration parameters can be written in any order and only needed of them may be present in the table.
- Set only that configuration parameter, which another value you need for.

####Parameters
<a id="debug"></a>
- **debug**: [Constant](#Constants) determining level of debugging detail.
	- Valid values: positive integer
	- *Default value*: compileall.DEBUG_BASIC


<a id="excludes"></a>
- **excludes**: Table with list of explicitly excluded scipts from compilation.
	- Valid values: table of strings
	- *Default value*: "init.lua"

####Returns
nil

####Example

```lua
require("compileall")

compileall.setup{
	debug=compileall.DEBUG_DETAIL,
	excludes={"foo01.lua", "foo02.lua"},
}
```

[Back to interface](#interface)
