# Exoplanets as Table
Turn the data from the [open exoplanet catalog](https://github.com/OpenExoplanetCatalogue/open_exoplanet_catalogue) into a lua table.

## Why though
Lua is pretty neat (or, in my opinion better to use than python) but working with XML directly in it is not pretty neat.  Being able to use the data as a table should make it much easier to do whatever you want with it.  If you also want a library to help with using the data, there's [torch](https://github.com/torch/torch7), [scilua](https://github.com/stepelu/lua-sci), and I'm sure plenty more.  

## Dependencies
 * [xml](https://luarocks.org/modules/gaspard/xml)
 * [lfs](https://keplerproject.github.io/luafilesystem/)
 * [serpent](https://luarocks.org/modules/paulclinger/serpent)

## Using
Assuming lua and all this programs dependencies are installed you only need to run ```lua build.lua```. However, I didn't like how the catalog's XML translated into a table, so you can also run it with the ```-f``` or ```--fix``` argument to change varaiable names to camelCase and have all arrays of objects (stars, binaries, and planets) become direct children of their system.  Here's a list of the allowed arguments  
 * ```-i ./path/to/data/folder``` or ```--input ./path/to/data/folder``` sets the data input directory  
 * ```-o ./path/to/output/file.lua``` or ```--output ./path/to/output/file.lua``` sets the table output directory  
 * ```-f``` or ```--fix``` cleans up, reparents data, and removes some fields like videolink and description  
 * ```-m``` or ```--minify``` makes the ouput table smaller, but also less readable  

### Where do I get the data from?
The [open exoplanet catalog](https://github.com/OpenExoplanetCatalogue/open_exoplanet_catalogue).  Put the two folders "systems" and "systems_kepler" into a directory and point build.lua to that directory with the ```-i``` argument.

## Data Structure
Assuming you don't use the ```-f``` argument, this will be the exact same as what's listed [here](https://github.com/OpenExoplanetCatalogue/open_exoplanet_catalogue#data-structure), otherwise it'll follow this slightly modified version.

| Key      | Can be child of | Description | Unit |
| -------- | --------------- | ----------- | ---- |
| ` planets` | `system` | This is an array for all the planets in a system. A planet is a free floating (orphan) planet if there are no other stars, binaries, or planets in this system. | 
| `stars`  | `system` | This is an array for all the stars in a system. A star can be host to one or more planets (circum-stellar planets). | 
| `binaries` 		| `system` | This is an array of binaries. A binary consists of either two stars, one star and one binary or two binaries. In addition a binary can be host to one or more planets (circum-binary planets).| |
| | | | |
| `declination`	| `system` | Declination | +/- dd mm ss   |
| `rightAscension`	| `system` | Right ascension | hh mm ss   |
| `distance`		| `system` | Distance from the Sun | parsec   |
| `name`		| `system`, `binary`, `star`, `planet` | Name of this object. This tag can be used multiple times if the object has multiple Names. |   |
| `semimajorAis` 	| `binary`, `planet` | Semi-major axis of a planet (heliocentric coordinates) if child of `planet`. Semi-major axis of the binary if child of `binary`. |  AU |
| `separation`	 	| `binary`, `planet` | Projected separation of planet from its host, or if child of `binary` the projected separation from one component to the other. This tag can occur multiple times with different units. It is different from the tag `semimajoraxis` as it does not imply a specific orbital configuration. |  AU, arcsec |
| `positionAngle` | `binary` | Position angle | degree |
| `eccentricity` 	| `binary`, `planet` | Eccentricity  | |
| `periastron` 	| `binary`, `planet` | Longitude of periastron | degree  |
| `longitude` 	| `binary`, `planet` | Mean longitude at a given Epoch (same for all planets in one system) | degree  |
| `meanAnomaly`	| `binary`, `planet` | Mean anomaly at a given Epoch (same for all planets in one system) | degree  |
| `ascendingNode` 	| `binary`, `planet` | Longitude of the ascending node | degree  |
| `inclination` 	| `binary`, `planet` | Inclination of the orbit | degree  |
| `impactParameter`	| `planet` | Impact parameter of transit | |
| `epoch` | `system` | Epoch for the orbital elements | BJD |
| `period`	 	| `binary`, `planet` | Orbital period   | day  |
| `transitTime` | `binary`, `planet` | Time of the center of a transit | BJD |
| `periastronTime` | `binary`, `planet` | Time of periastron | BJD |
| `maximumRVTime` | `binary`, `planet` | Time of maximum radial velocity | BJD |
| `mass`		| `planet`, `star` |Mass (or m sin(i) for radial velocity planets) | Jupiter masses (`planet`), Solar masses (`star`)  |
| `radius`		| `planet`, `star` |Physical radius | Jupiter radii (`planet`), Solar radii (`star`)  |
| `temperature`	| `planet`, `star` |Temperature (surface or equilibrium) | Kelvin  |
| `age`		| `planet`, `star` |Age | Gyr  |
| `metallicity`	| `star` | Stellar metallicity  | log, relative to solar  |
| `spectralType`	| `star`, `planet` | Spectral type  |   |
| `magB`		| `binary`, `star`, `planet` | B magnitude |   |
| `magV`		| `binary`, `star`, `planet` | Visual magnitude |   |
| `magR`		| `binary`, `star`, `planet` | R magnitude |   |
| `magI`		| `binary`, `star`, `planet` | I magnitude |   |
| `magJ`		| `binary`, `star`, `planet` | J magnitude |   |
| `magH`		| `binary`, `star`, `planet` | H magnitude |   |
| `magK`		| `binary`, `star`, `planet` | K magnitude |   |
| | | | |
| `discoveryMethod` 	| `planet` | Discovery method of the planet. For example: timing, RV, transit, imaging.  |   |
| `isTransiting` 	| `planet` | Whether the planet is transiting (1) or not (0).  |   |
| `discoveryYear`	| `planet` | Year of the planet's discovery | yyyy  |
| `lastUpdate`	| `planet` | Date of the last (non-trivial) update | yy/mm/dd   |
| `spinOrbitAlignment` | `planet` | Rossiter-McLaughlin Effect. | degree |

## TODO
 * One object can have multiple names, so that should be an array instead of just one value
 * Make sure all file's being parsed are XML (have .xml extension at the least)
