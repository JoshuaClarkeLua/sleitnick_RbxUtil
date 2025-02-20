local RunService = game:GetService("RunService")
local ComponentInitWaitExt = require(script.ComponentInitWaitExt)
local DefaultComponentExt = require(script.DefaultComponentExt)
local Component = require(script.Component)
local Promise = require(script.Parent.Promise)

local Util = {}

local function mergeConfigs(a, b): ()
	if b.Extensions then
		if a.Extensions then
			table.move(a.Extensions, 1, #a.Extensions, #b.Extensions + 1, b.Extensions)
		end
		a.Extensions = b.Extensions
	end
	if b.Ancestors then
		if a.Ancestors then
			table.move(a.Ancestors, 1, #a.Ancestors, #b.Ancestors + 1, b.Ancestors)
		end
		a.Ancestors = b.Ancestors
	end
end

function Util.new(config): Component
	-- Put ComponentInitWaitExt before config
	mergeConfigs(config, {
		Extensions = { ComponentInitWaitExt },
	})
	-- Put DefaultComponentExt after config
	mergeConfigs({
		Extensions = { DefaultComponentExt },
	}, config)
	local comp = Component.new(config)
	comp.Server = {}
	comp.Client = {}
	-- Setup Server and Client functions
	comp.__index = function(t, k)
		if k == "Server" or k == "Client" then
			error("Cannot access Component.Server or Component.Client directly", 2)
		end
		local fn
		if RunService:IsServer() then
			if typeof(comp.Server[k]) == "function" then
				fn = comp.Server[k]
			end
		else
			if typeof(comp.Client[k]) == "function" then
				fn = comp.Client[k]
			end
		end
		return fn or comp[k]
	end

	-- Create init promise
	comp[ComponentInitWaitExt.INIT_PROMISE] = Promise
		.defer(function(resolve, _, onCancel)
			if onCancel() then
				return
			end
			-- Call Init functions
			local mainFn = rawget(comp, 'Init')
			if typeof(mainFn) == 'function' then
				mainFn()
			end
			if RunService:IsServer() then
				if typeof(comp.Server.Init) == 'function' then
					comp.Server.Init()
				end
			else
				if typeof(comp.Client.Init) == 'function' then
					comp.Client.Init()
				end
			end
			-- Set to true to indicate the component has been initialized
			comp[ComponentInitWaitExt.INIT_PROMISE] = true
			resolve()
		end)
	--
	return comp
end

local function __unset(old: string, ...: any): ...any
	debug.setmemorycategory(old)
	return ...
end
function Util.MemDebug(tag: string, comp: Component): Component
	for k,v in pairs(comp) do
		if typeof(v) == "function" then
			comp[k] = function(...)
				local old = debug.getmemorycategory()
				debug.setmemorycategory(`{tag}.{k}()`)
				return __unset(old, v(...))
			end
		end
	end
	local _server = rawget(comp, "Server")
	if _server then
		for k,v in pairs(_server) do
			if typeof(v) == "function" then
				_server[k] = function(...)
					local old = debug.getmemorycategory()
					debug.setmemorycategory(`{tag}.Server.{k}()`)
					return __unset(old, v(...))
				end
			end
		end
	end
	local _client = rawget(comp, "Client")
	if _client then
		for k,v in pairs(_client) do
			if typeof(v) == "function" then
				_client[k] = function(...)
					local old = debug.getmemorycategory()
					debug.setmemorycategory(`{tag}.Client.{k}()`)
					return __unset(old, v(...))
				end
			end
		end
	end
	warn("Added MemDebug to", tag)
	return comp
end

export type Component = Component.Component
export type ComponentInstance = Component.ComponentInstance
return Util
