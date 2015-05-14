local seen={}
dofile("scripts/keys.lua")
dofile("scripts/utils.lua")
function dump(t,i)
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		--local file = io.open("funcs.txt", "a")
		
		print(i,v)
		v=t[v]
		if type(v)=="table" and not seen[v] then
			dump(v,i.."\t")
		end
	end
end

function splitString(inputstr,sep)
  if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

Libs = {}
local addIns = {}
function loadAddIns() 
	print("Loading Addins")
	for index, mod in pairs(addIns) do
		if (mod ~= false) then
			if (mod.unload ~= nil) then
				mod:unload()
			end			
			addIns[index] = nil
			if (package.loaded[index] ~=nil) then
				print("Unload Addin "..index)
				package.loaded[index] = nil
			end
		end
	end
	
	for mod in lfs.dir("scripts/addins/") do
	   if mod ~= "." and mod ~= ".." and mod:find(".lua") ~=nil  then
			print("load Addin "..mod)
			modName = string.gsub(mod,".lua","")
			local mod = require(modName)
			if (mod ~= false) then
				addIns[modName] = mod
				if (addIns[modName].init ~= nil) then
					addIns[modName]:init()
				end
			end
		end
	end
	print("Addins Loaded")
end
function loadLibs() 
	print("Loading Libs")
	for index, mod in pairs(Libs) do
		if (mod ~= false) then
			if (mod.unload ~= nil) then
				mod:unload()
			end		
			print("Unload Lib outerscope"..index)			
			Libs[index] = nil
			if (package.loaded[index] ~=nil) then
				print("Unload Lib "..index)
				package.loaded[index] = nil
			end
		end
	end
	
	for mod in lfs.dir("scripts/libs/") do
	   if mod ~= "." and mod ~= ".." and mod:find(".lua") ~=nil  then
			modName = string.gsub(mod,".lua","")
			print("load "..modName)
			
			local mod = require(modName)
			if (mod ~= false) then
				Libs[modName] = mod
				if (Libs[modName].init ~= nil) then
					Libs[modName]:init()
				end
			end
		end
	end
	print("Libs Loaded")
end
function init()
	--dump(_G,"")
	-- Update the search path
	local module_folder = "scripts/"
	package.path = module_folder .. "?.lua;" .. package.path
	local addins_folder = "scripts/addins/"
	package.path = addins_folder .. "?.lua;" .. package.path
	local addins_folder = "scripts/libs/"
	package.path = addins_folder .. "?.lua;" .. package.path
	loadLibs() 
	loadAddIns() 

	
end
function unload()
	for index, mod in pairs(Libs) do
		if (mod ~= false) then
			if (mod.unload ~= nil) then
				mod:unload()
			end				
			Libs[index] = nil
			if (package.loaded[index] ~=nil) then
				print("Unload Lib "..index)
				package.loaded[index] = nil
			end
		end
	end
	print("Unloaded Libs")
	for index, mod in pairs(addIns) do
		if (mod ~= false) then
			if (mod.unload ~= nil) then
				mod:unload()
			end			
			addIns[index] = nil
			if (package.loaded[index] ~=nil) then
				print("Unload Addin "..index)
				package.loaded[index] = nil
			end
		end
	end
	print("Unloaded Addins")
end
function tick()
	--print("test")

	for index, mod in pairs(addIns) do
		if (mod.tick ~= nil) then
				mod:tick()
		end
	end
	
end