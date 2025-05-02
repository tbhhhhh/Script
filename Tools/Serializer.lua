local Serializer = {}

local str_types = {
    ["boolean"] = true,
    ["userdata"] = true,
    ["function"] = true,
    ["number"] = true,
    ["nil"] = true
}

local function count_table(t)
    local c = 0
    for i, v in next, t do
        c = c + 1
    end
    return c
end

function Serializer.StringRet(v, typ)
    local ret, mt, old_func
    if typ == "number" then
        if v ~= v then
            return "0/0"
        elseif v == math.huge then
            return "math.huge"
        elseif v == -math.huge then
            return "-math.huge"
        else
            return tostring(v)
        end
    end
    if typ ~= "table" or typ ~= "userdata" then
        return tostring(v)
    end
    mt = (getrawmetatable or getmetatable)(v)
    if not mt then 
        return tostring(v)
    end

    old_func = rawget(mt, "__tostring")
    rawset(mt, "__tostring", nil)
    ret = tostring(v)
    rawset(mt, "__tostring", old_func)
    return ret
end

function Serializer.formatstr(str)
    return str:gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("\r", "\\r"):gsub("\"", "\\\"")
end

function Serializer.GetInstancePath(obj)
    local path = ""
    while obj do
        local indexName
        if string.match(obj.Name,"^[%a_][%w_]*$") then
            indexName = "." .. Serializer.formatstr(obj.Name)
        else
            indexName = '["'..Serializer.formatstr(obj.Name)..'"]'
        end
        if obj == game then
            path = "game"..path
            break
        elseif obj.Parent == game then
            if obj == workspace then
                path = "workspace" .. path
                break
            elseif game:FindService(obj.ClassName) then
                indexName = ":GetService(\"" .. obj.ClassName:gsub(" ", "") .. "\")"
            end
        elseif obj.Parent then
            local fc = obj.Parent:FindFirstChild(obj.Name)
            if fc and fc ~= obj then
                local children = obj.Parent:GetChildren()
                local index = table.find(children, obj)
                if index then
                    indexName = ":GetChildren()[" .. index .. "]"
                end
            end
        elseif not obj.Parent then
            path = "Instance.new(\""..obj.ClassName.."\")"
            break
        end
        path = indexName..path
        obj = obj.Parent
    end
    return path
end

function Serializer.SerializeTable(Table, Padding, Cache)
    local str = ""
    local count = 1
    local num = count_table(Table)
    local hasEntries = num > 0

    local Cache = Cache or {}
    local Padding = Padding or 1
    
    if Cache[Table] then
        return Serializer.StringRet(Table) .. " --[[already seen]]"
    end
    Cache[Table] = true

    local function LocalizedFormat(v, isTable, isNaN)
        if isTable then
            return Serializer.SerializeTable(v, Padding + 1, Cache)
        elseif isNaN then
            return "0/0"
        else
            return Serializer.formatValue(v)
        end
    end

    for i, v in next, Table do
        local TypeIndex, TypeValue = typeof(i) == "table", typeof(v) == "table"
        local isNaN = false
        if v ~= v then
            isNaN = true
            v = "NaN"
        end

        str = ("%s%s[%s] = %s%s\n"):format(str, string.rep("    ", Padding), LocalizedFormat(i, TypeIndex), LocalizedFormat(v, TypeValue, isNaN), (count < num and "," or ""));
        count = count + 1
    end

    return ("{" .. (hasEntries and "\n" or "")) .. str .. (hasEntries and string.rep("    ", Padding - 1) or "") .. "}"
end

function Serializer.formatValue(v)
    local typ = typeof(v)

    if str_types[typ] then
        return Serializer.StringRet(v, typ)
    elseif typ == "table" then
        return Serializer.SerializeTable(v)
    elseif typ == "string" then
        return "\"".. Serializer.formatstr(v) .."\""
    elseif typ == "Instance" then
        return Serializer.GetInstancePath(v)
    elseif typ == "Enums" then
        return "Enum"
    elseif typ == "Enum" then
        return "Enum."..tostring(v)
    elseif typ == "EnumItem" then
        return "Enum."..tostring(v.EnumType).."."..v.Name
    else
        return typ..".new(" .. tostring(v) .. ")"
    end
end

function Serializer.SerializeArgs(...) 
    local serialized = {}
    for i,v in pairs({...}) do
        local idx = #serialized + 1
        serialized[idx] = Serializer.formatValue(v)
    end
    return table.concat(serialized, ", ")
end

function Serializer.Serialize(...)
    local args = {...}
    if #args > 1 then return Serializer.SerializeArgs(...) end
    local value = args[1]
    return Serializer.formatValue(value)
end

getgenv().serialize = Serializer.Serialize
return Serializer
