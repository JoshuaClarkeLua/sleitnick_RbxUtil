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

	-- Create init promise
	comp[ComponentInitWaitExt.INIT_PROMISE] = Promise
		.defer(function(resolve, _, onCancel)
			if onCancel() then
				return
			end
			-- Call Init functions
			local mainFn = rawget(comp, 'Init')
			if typeof(mainFn) == 'function' then
				mainFn(comp)
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
	warn("Added MemDebug to", tag)
	return comp
end

export type Component = Component.Component
export type ComponentInstance = Component.ComponentInstance
return Util
