#NodeMCU module<br>s2eta
The module converts elapsed or estimated amount of seconds to the time string with non-zero time components separated by one space, for in instance "*1d 7h 21m 6s*".


<a id="require"></a>
##Require
	require("s2eta")

<a id="release"></a>
## Release
	s2eta, package.loaded["s2eta"] = nil, nil

<a id="dependency"></a>
## Dependency
None

<a id="examples"></a>
## Examples
- **s2eta-ex00-version.lua**: Prints current version of the module.  
- **s2eta-ex01-eta.lua**: Prints illustrative time strings.  

<a id="interface"></a>
## Interface
- [version()](#version)
- [eta()](#eta)


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
require("s2eta")
print(s2eta.version())
```
	>1.2.3, 1, 2, 3

[Back to interface](#interface)


<a id="eta"></a>
## eta(seconds)
####Description
Returns the time string with non-zero time components separated by one space.

####Syntax
	eta(seconds)

####Parameters
- **seconds**: Positive integer of elapsed or estimated seconds.
	- If no, zero, or negative input seconds are provided, the module returns empty string.

####Returns
The output time string is composed of following time components in this order and marked with following suffixes
1. **days**: suffix **d**
1. **hours**: suffix **h**
1. **minutes**: suffix **m**
1. **seconds**: suffix **s**

####Example

```lua
require("s2eta")
print(s2eta.eta(12*86400 + 7*3600 + 18*60 + 23))
print(s2eta.eta(7*3600 + 18*60 + 23))
print(s2eta.eta(7*3600 + 0*60 + 23))
print(s2eta.eta(23))
print(s2eta.eta(120))
```
	>12d 7h 18m 23s
	>7h 18m 23s
	>7h 23s
	>23s
	>2m

[Back to interface](#interface)
