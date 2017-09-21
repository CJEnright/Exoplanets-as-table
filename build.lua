-- Recursion's pretty cool, so there's a lot of that going on
-- Github: https://github.com/CJEnright/Exoplanets-as-table
-- This is supposed to be used with data from the open exoplanet catalog
-- open exoplanet catalog: https://github.com/OpenExoplanetCatalogue/open_exoplanet_catalogue
-- Big ups to them for the data, and the agencies that sourced the data
-- All the modules below you should be able to get from luarocks.org

local xml = require('xml')
local lfs = require('lfs')
local serpent = require('serpent')

local allowedFields = {'system', 'star', 'binary', 'declination', 'rightAscension', 'distance', 'name', 'semimajorAxis', 'positionAngle', 'eccentricity', 'periastron', 'longitude', 'meanAnomaly', 'ascendingNode', 'inclination', 'impactParameter', 'epoch', 'period', 'transitTime', 'periastronTime', 'maximumRVTime', 'mass', 'radius', 'temperature', 'age', 'metallicity', 'spectralType', 'magB', 'magV', 'magR', 'magI', 'magJ', 'magH', 'magK', 'discoveryMethod', 'isTransiting', 'discoveryYear', 'lastUpdate', 'spinOrbitAlignment'}

function load(path)
	local exoplanets = {}

	for file in lfs.dir(path) do
		if lfs.attributes(path..file).mode == 'directory' and file ~= '.' and file ~= '..' then
			local data = load(path..file..'/')
			-- data will be different per directory in the ./data directory, so we have to combine them
			for i,v in ipairs(data) do
				table.insert(exoplanets, v)
			end
		elseif file ~= '.' and file ~= '..' then
			table.insert(exoplanets, parse(xml.loadpath(path..file)))
		end
	end

	return exoplanets
end 

function parse(data)
	local object = {}

	if data.xml == 'system' or data.xml == 'star' or data.xml == 'binary' or data.xml == 'planet' then
		for k,v in pairs(data) do
			if v.xml == 'star' or v.xml == 'binary' or v.xml == 'planet' then
				if object[v.xml] == nil then
					object[v.xml] = {}
				end
				table.insert(object[v.xml], parse(data[#data]))
			elseif v.xml ~= nil then
				object[v.xml] = parse(v)
			end
		end
	else
		return data[#data]
	end

	return object
end

-- Change to camelCase, remove fields we don't need (video links, descriptions), change singulars to plurals (star->stars)
function clean(data)
	for k,v in pairs(data) do
		if type(v) == 'table' then
			v = clean(v)
			if k == 'star' then
				data['stars'] = data[k]
				data[k] = nil
			elseif k == 'binary' then
				data['binaries'] = data[k]
				data[k] = nil
			elseif k == 'planet' then
				data['planets'] = data[k]
				data[k] = nil
			end
		else 
			for i,field in ipairs(allowedFields) do
				if k == string.lower(field) and field ~= string.lower(field) then
					data[field] = data[k]
					data[k] = nil
				end
			end
		end
	end

	return data
end

-- Makes all stars, binaries, and planets direct children of a system (system.stars = {...}, etc)
-- No recursion here for simplicity
function reparent(data)
	for systemKey,system in pairs(data) do
		local binaries, stars, planets = {}, {}, {}

		if system.binaries ~= nil then
			for binaryKey,binary in pairs(system.binaries) do
				if binary.stars ~= nil then
					for starKey,star in pairs(binary.stars) do
						if star.planets ~= nil then
							for planetKey,planet in pairs(star.planets) do
					 			table.insert(planets, planet)
					 			planet = nil -- We don't technically need this but why not tho
							end
							star.planets = nil
							table.insert(stars, star)
					 	end
					end
					binary.stars = nil
					table.insert(binaries, binary)
				end
			end
			system.binaries = nil
		end
		if system.stars ~= nil then
			for starKey,star in pairs(system.stars) do
				if star.planets ~= nil then
					for planetKey,planet in pairs(star.planets) do
			 			table.insert(planets, planet)
					end
					star.planets = nil
					table.insert(stars, star)
			 	end
			end
			system.stars = nil
		end
		if system.planets ~= nil then
			for planetKey,planet in pairs(system.planets) do
	 			table.insert(planets, planet)
			end
			system.planets = nil
	 	end

		if #binaries ~= 0 then
			system.binaries = binaries
		end
		if #stars ~= 0 then
			system.stars = stars
		end
		if #planets ~= 0 then
			system.planets = planets
		end
	end

	return data
end

-- Command line argument handling
local startingPath = lfs.currentdir()
local inputPath = lfs.currentdir()..'/data/'
local outputPath = lfs.currentdir()..'/output.lua'
local shouldFix = false
local shouldMinify = false

for i=1,#arg do
	if arg[i] == '-i' or arg[i] == '--input' then
		assert(arg[i+1], 'No input path given')
		assert(lfs.chdir(arg[i+1]), 'Unknown input path '..arg[i+1])
		inputPath = lfs.currentdir()..'/'
		i=i+1
	elseif arg[i] == '-o' or arg[i] == '--output' then
		lfs.chdir(startingPath)
		assert(arg[i+1], 'No output path given')
		local file = assert(io.open(arg[i+1], 'w'), 'meme')
		file:close()
		outputPath = arg[i+1]
		i=i+1
	elseif arg[i] == '-f' or arg[i] == '--fix' then
		shouldFix = true
	elseif arg[i] == '-m' or arg[i] == '--minify' then
		shouldMinify = true
	end
end

print('Loading and parsing data from '..inputPath)
local exoplanets = load(inputPath)

if shouldFix then
	print('Fixing data formatting')
	exoplanets = reparent(clean(exoplanets))
end

lfs.chdir(startingPath)
local file = io.open(outputPath, 'w')
file:write('return ')

print('Writing table to file')
if shouldMinify then
	file:write(serpent.line(exoplanets,  {comment = false}))
else
	file:write(serpent.block(exoplanets,  {comment = false}))	
end

file:close()
print('Done, output written to '..outputPath)