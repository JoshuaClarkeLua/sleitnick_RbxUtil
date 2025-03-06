local Ext = {}

function Ext.ShouldConstruct(self)
	local comp = getmetatable(self)
	local mainFn = rawget(comp, 'ShouldConstruct')
	if typeof(mainFn) == 'function' then
		if not mainFn(self) then
			return false
		end
	end
	return true
end

function Ext.Constructing(self)
	local comp = getmetatable(self)
	local mainFn = rawget(comp, 'Constructing')
	if typeof(mainFn) == 'function' then
		mainFn(self)
	end
end

function Ext.Constructed(self)
	local comp = getmetatable(self)
	local mainFn = rawget(comp, 'Constructed')
	if typeof(mainFn) == 'function' then
		mainFn(self)
	end
end

function Ext.Starting(self)
	local comp = getmetatable(self)
	local mainFn = rawget(comp, 'Starting')
	if typeof(mainFn) == 'function' then
		mainFn(self)
	end
end

function Ext.Started(self)
	local comp = getmetatable(self)
	local mainFn = rawget(comp, 'Started')
	if typeof(mainFn) == 'function' then
		mainFn(self)
	end
end

function Ext.Stopping(self)
	local comp = getmetatable(self)
	local mainFn = rawget(comp, 'Stopping')
	if typeof(mainFn) == 'function' then
		mainFn(self)
	end
end

function Ext.Stopped(self)
	local comp = getmetatable(self)
	local mainFn = rawget(comp, 'Stopped')
	if typeof(mainFn) == 'function' then
		mainFn(self)
	end
end

return Ext