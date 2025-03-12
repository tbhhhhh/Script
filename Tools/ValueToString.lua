--Credits to FaithfulAC(https://github.com/FaithfulAC), Modded by Xingtaiduan

local settings = (...) or {
        maxTableDepth = 25,
        maxFunctionDepth = 25,
        maxStringLength = 5000,
        maxBufferStringLength = 10000,
        maxRepresentedBufferStringLength = 50,
	maxUpvalues = 20,
	maxConstants = 50,
	maxTableCount = 100,
        Yield = 100, -- no yield = -1
}

local CrazyCharacters = {
	["0"] = "\0",
	["n"] = "\n",
	["t"] = "\t",
	["s"] = "\s",
	["r"] = "\r",
	["f"] = "\f"
}

local StoredUpvals = {}

local debounce = 0

local function ReturnSafeString(str)
	local safe = ""

	for i = 1, #str do
		if i > settings.maxStringLength then safe ..= "... (Exceeded max string length)" break end
		local subchar = string.sub(str, i, i)
		local byteint = string.byte(subchar)

		if byteint > 32 and byteint < 127 and byteint ~= 34 and byteint ~= 92 then
			safe ..= subchar
		elseif byteint == 34 then
			safe ..= "\\\""
		elseif byteint == 92 then
			safe ..= "\\\\"
		else
			local stop = false

			for key, value in pairs(CrazyCharacters) do
				if value == subchar then
					safe ..= "\\" .. key
					stop = true
					break
				end
			end

			if stop then continue end
			safe ..= "\\" .. byteint
		end
	end

	return safe
end

local function GetPath(ins)
	if ins == game then return "game" end
	
	local path = ""
	
	if ins.Parent == nil then
		return ins.Name
	end

	local ancestry = {}
	repeat
		table.insert(ancestry, (ancestry[#ancestry] or ins).Parent)
	until ancestry[#ancestry] == game;

	for i = (#ancestry), 1, -1 do
		if ancestry[i] == game then
			path = path .. "game"
		elseif ancestry[i+1] == game then
			path = path .. ":FindFirstChildOfClass(\"" .. ancestry[i].ClassName .. "\")"
		else
			path = path .. ":FindFirstChild(\"" .. ReturnSafeString(ancestry[i].Name) .. "\")"
		end
	end

	path = path .. ":FindFirstChild(\"" .. ReturnSafeString(ins.Name) .. "\")"
	return path
end

local function makeParams(num, isVararg)
	local params = ""
	for i = 1, num do
		params ..= "v" .. tostring(i) .. ", "
	end
	if isVararg then
		params ..= "..."
	else
		params = string.sub(params, 1, #params-2)
	end
	return params
end

local opentable, openfunction;
local recursivetblcount, recursivefnccount = 1, 1

-- function ripped from simplespy
local function u2s(u)
	debounce += 1
        if settings.Yield ~= -1 and debounce % settings.Yield == 0 then task.wait() end
	
	if typeof(u) == "TweenInfo" then
		-- TweenInfo
		return "TweenInfo.new("
			.. tostring(u.Time)
			.. ", Enum.EasingStyle."
			.. tostring(u.EasingStyle)
			.. ", Enum.EasingDirection."
			.. tostring(u.EasingDirection)
			.. ", "
			.. tostring(u.RepeatCount)
			.. ", "
			.. tostring(u.Reverses)
			.. ", "
			.. tostring(u.DelayTime)
			.. ")"
	elseif typeof(u) == "Ray" then
		-- Ray
		return "Ray.new(" .. u2s(u.Origin) .. ", " .. u2s(u.Direction) .. ")"
	elseif typeof(u) == "NumberSequence" then
		-- NumberSequence
		local ret = "NumberSequence.new("
		for i, v in pairs(u.KeyPoints) do
			ret = ret .. tostring(v)
			if i < #u.Keypoints then
				ret = ret .. ", "
			end
		end
		return ret .. ")"
	elseif typeof(u) == "DockWidgetPluginGuiInfo" then
		-- DockWidgetPluginGuiInfo
		local stringedArgs = tostring(u)
		stringedArgs = string.gsub(stringedArgs, " ", ", ")
		stringedArgs = string.gsub(stringedArgs, "InitialDockState:", "Enum.InitialDockState.")
		stringedArgs = string.gsub(stringedArgs, "InitialEnabled:", "")
		stringedArgs = string.gsub(stringedArgs, "InitialEnabledShouldOverrideRestore:", "")
		stringedArgs = string.gsub(stringedArgs, ", 1", ", true")
		stringedArgs = string.gsub(stringedArgs, ", 0", ", false")
		for i, v in pairs({"FloatingXSize:", "FloatingYSize:", "MinWidth:", "MinHeight:"}) do
			stringedArgs = string.gsub(stringedArgs, v, "")
		end

		return "DockWidgetPluginGuiInfo.new(" .. stringedArgs .. ")"
	elseif typeof(u) == "ColorSequence" then
		-- ColorSequence
		local ret = "ColorSequence.new("
		for i, v in pairs(u.KeyPoints) do
			ret = ret .. "Color3.new(" .. tostring(v) .. ")"
			if i < #u.Keypoints then
				ret = ret .. ", "
			end
		end
		return ret .. ")"
	elseif typeof(u) == "BrickColor" then
		-- BrickColor
		return "BrickColor.new(" .. tostring(u.Number) .. ")"
	elseif typeof(u) == "NumberRange" then
		-- NumberRange
		return "NumberRange.new(" .. tostring(u.Min) .. ", " .. tostring(u.Max) .. ")"
	elseif typeof(u) == "Region3" then
		-- Region3
		local center = u.CFrame.Position
		local size = u.CFrame.Size
		local vector1 = center - size / 2
		local vector2 = center + size / 2
		return "Region3.new(" .. u2s(vector1) .. ", " .. u2s(vector2) .. ")"
	elseif typeof(u) == "Faces" then
		-- Faces
		local faces = {}
		if u.Top then
			table.insert(faces, "Enum.NormalId.Top")
		end
		if u.Bottom then
			table.insert(faces, "Enum.NormalId.Bottom")
		end
		if u.Left then
			table.insert(faces, "Enum.NormalId.Left")
		end
		if u.Right then
			table.insert(faces, "Enum.NormalId.Right")
		end
		if u.Back then
			table.insert(faces, "Enum.NormalId.Back")
		end
		if u.Front then
			table.insert(faces, "Enum.NormalId.Front")
		end
		return "Faces.new(" .. table.concat(faces, ", ") .. ")"
	elseif typeof(u) == "RBXScriptSignal" then
		return string.gsub(tostring(u), "Signal ", "") .. " --[[RBXScriptSignal]]"
	elseif typeof(u) == "PathWaypoint" then
		return string.format("PathWaypoint.new(%s, %s)", "Vector3.new(" .. tostring(u.Position) .. ")", tostring(u.Action))
	end
	if getrenv()[typeof(u)] and getrenv()[typeof(u)].new then
		return typeof(u) .. ".new(" .. tostring(u) .. ") --[[warning: not reliable]]"
	end
	return typeof(u) .. " --[[actual value is a userdata]]"
end

local list = {
	Axes = Axes,
	buffer = buffer,
	bit32 = bit32,
	BrickColor = BrickColor,
	coroutine = coroutine,
	CFrame = CFrame,
	Color3 = Color3,
	ColorSequenceKeypoint = ColorSequenceKeypoint,
	ColorSequence = ColorSequence,
	Content = Content,
	CatalogSearchParams = CatalogSearchParams,
	debug = debug,
	DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo,
	DateTime = DateTime,
	Faces = Faces,
	FloatCurveKey = FloatCurveKey,
	Font = Font,
	Instance = Instance,
	math = math,
	NumberRange = NumberRange,
	NumberSequenceKeypoint = NumberSequenceKeypoint,
	NumberSequence = NumberSequence,
	OverlapParams = OverlapParams,
	os = os,
	PathWaypoint = PathWaypoint,
	PhysicalProperties = PhysicalProperties,
	Path2DControlPoint = Path2DControlPoint,
	Random = Random,
	Ray = Ray,
	RotationCurveKey = RotationCurveKey,
	Region3 = Region3,
	Region3int16 = Region3int16,
	Rect = Rect,
	RaycastParams = RaycastParams,
	string = string,
	SharedTable = SharedTable,
	SecurityCapabilities = SecurityCapabilities,
	task = task,
	table = table,
	TweenInfo = TweenInfo,
	UDim2 = UDim2,
	utf8 = utf8,
	UDim = UDim,
	Vector2 = Vector2,
	Vector3 = Vector3,
	Vector2int16 = Vector2int16,
	Vector3int16 = Vector3int16,
}

local function isInRobloxEnvTable(func)
	for i, v in pairs(list) do
		for i2, v2 in pairs(v) do
			if v2 == func then
				return i .. "."
			end
		end
	end
	return false
end

local function Safetostring(obj)
	debounce += 1
        if settings.Yield ~= -1 and debounce % settings.Yield == 0 then task.wait() end

	if debug.info(100, "f") ~= nil then
		return "--[[DEPTH OF SAFETOSTRING EXCEEDED 100]]"
	end
	
	if typeof(obj) == "nil" or typeof(obj) == "boolean" then
		return tostring(obj)
	end

	if typeof(obj) == "string" then
		return '"' .. ReturnSafeString(obj) .. '"' --[[gsub " bait later?]]
	end

	if typeof(obj) == "function" then
		-- TO RESOLVE AND DO OTHER STUFF WITH
		if iscclosure(obj) and (getrenv()[debug.info(obj, "n")] or isInRobloxEnvTable(obj)) then
			return isInRobloxEnvTable(obj) and isInRobloxEnvTable(obj) .. debug.info(obj, "n") or debug.info(obj, "n")
		elseif iscclosure(obj) then
			return "function()end --[[is a cclosure: " .. tostring(obj) .. "]]"
		end
		if recursivefnccount > settings.maxFunctionDepth then
			return "--[[Recursive function depth exceeded max of " .. tostring(settings.maxFunctionDepth) .. "]]"
		end
		return openfunction(obj, recursivefnccount)
	end

	if typeof(obj) == "thread" then
		return "coroutine.create(function()end) --[[" .. tostring(obj) .. "]]"
	end

	if typeof(obj) == "number" then
		if tostring(obj) == "nan" then return "0/0 --[[nan]]" end
		return tostring(obj)
	end

	if typeof(obj) == "userdata" then
		if getmetatable(obj) then return "newproxy(true)" end
		return "newproxy()"
	end

	if typeof(obj) == "Instance" then
		return GetPath(obj) --[[if in nil, say: nil instance]]
	end

	if typeof(obj) == "table" then
		for i, v in pairs(list) do
			if v == obj then
				return i
			end
		end

		if recursivetblcount > settings.maxTableDepth then
			return "--[[Table depth exceeded max of " .. tostring(settings.maxTableDepth) .. "]]"
		end
		return opentable(obj, recursivetblcount)
	end

	if typeof(obj) == "Enums" then
		return "Enum"
	end

	if typeof(obj) == "Enum" then
		return "Enum." .. tostring(obj)
	end

	if typeof(obj) == "EnumItem" then
		return tostring(obj)
	end

	if typeof(obj) == "buffer" then
		local thing = buffer.tostring(obj)
		local len = buffer.len(obj)

		if len < settings.maxBufferStringLength and string.gsub(thing, "\0", "") ~= "" then
			return "buffer.fromstring(\"" .. ReturnSafeString(thing) .. "\")"
		elseif len >= settings.maxBufferStringLength and string.gsub(thing, "\0", "") ~= "" then
			return "buffer.fromstring(\"" .. ReturnSafeString(string.sub(thing, 1, settings.maxRepresentedBufferStringLength)) .. " (...)\") --[[Exceeded max of " .. tostring(maxRepresentedBufferStringLength) .. " characters]]"
		end

		return "buffer.create(" .. len .. ")"
	end

	if type(obj) == "userdata" then --[[already looped thru other ud's]]
		return u2s(obj)
	end

	return "??? (type: " .. type(obj) .. ", typeof: " .. typeof(obj) .. ")"
end

opentable = function(tbl, tabcount)
	local tabcount = string.rep("\t", tabcount or 1)
	recursivetblcount += 1;
	local orgR;

	if #tabcount >= recursivetblcount then
		orgR = recursivetblcount
		recursivetblcount = #tabcount + 1
	end

	local str = "{\n"
	local temp = 0
	for i, v in pairs(tbl) do
                debounce += 1
		temp += 1
                if settings.Yield ~= -1 and debounce % settings.Yield == 0 then task.wait() end
                
		str ..= tabcount
		str ..= "[" .. (Safetostring(i) or "???") .. "] = " .. (Safetostring(v) or "nil --[[?]]") .. ",\n"

		if temp > settings.maxTableCount then str ..= "--[[HIT MAX TBL # LIMIT]]\n" break end
	end
	str ..= string.rep("\t", recursivetblcount - 2) .. "}"

	if orgR then
		recursivetblcount = orgR
	else
		recursivetblcount -= 1;
	end

        debounce = 0
	return str
end

openfunction = function(func, tabcount)
    if not islclosure(func) then return Safetostring(func) end
    local tabcount = string.rep("\t", tabcount or 1)
    recursivefnccount += 1
    local orgR

    if #tabcount >= recursivefnccount then
        orgR = recursivefnccount
        recursivefnccount = #tabcount + 1
    end

    -- Function definition
    local name = (function()
        local name = debug.info(func, "n")
        return ((name~="") and " "..name) or ""
    end)()
    local str = "function"..name.."(" .. makeParams(debug.info(func, "a")) .. ")"

    -- Constants
    local constantsStr = " --Constants:"
    for i, v in pairs(getconstants(func)) do
        debounce += 1
        if settings.Yield ~= -1 and debounce % settings.Yield == 0 then task.wait() end

        constantsStr ..= " " .. tostring(i) .. ": " .. (Safetostring(v) or "nil")
        if i > settings.maxConstants then constantsStr ..= " --[[HIT MAX CNS LIMIT]]" break end
    end

    -- Upvalues
    local upvaluesStr = " Upvalues:"
    for i, v in pairs(getupvalues(func)) do
        debounce += 1
        if settings.Yield ~= -1 and debounce % settings.Yield == 0 then task.wait() end

        local wasStored = false
        if typeof(v) == "table" then
            for ts, _v in pairs(StoredUpvals) do
                if rawequal(v, _v) then
                    upvaluesStr ..= " " .. tostring(i) .. ": (shared with " .. ts .. ")"
                    wasStored = true
                end
            end
        end
        if wasStored then continue end

        upvaluesStr ..= " " .. tostring(i) .. ": " .. (Safetostring(v) or "nil")

        if i > settings.maxUpvalues then upvaluesStr ..= " --[[HIT MAX UPVAL LIMIT]]" break end
    end

    -- Combine everything into a single line
    str = str .. constantsStr .. upvaluesStr

    if orgR then
        recursivefnccount = orgR
    else
        recursivefnccount -= 1
    end

    debounce = 0
    return str
end

return Safetostring
