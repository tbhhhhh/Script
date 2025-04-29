local str_types = {
    ["boolean"] = true,
    ["table"] = true,
    ["userdata"] = true,
    ["table"] = true,
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

local function string_ret(v, typ)
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
    if not (typ == "table" or typ == "userdata") then
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

local function formatstr(str)
    return str:gsub("\n", "\\n"):gsub("\t", "\\t"):gsub("\r", "\\r"):gsub("\"", "\\\"")
end

local function getInstancePath(obj)
    local path = ""
    while obj do
        local indexName
        if string.match(obj.Name,"^[%a_][%w_]*$") then
            indexName = "." .. formatstr(obj.Name)
        else
            indexName = '["'..formatstr(obj.Name)..'"]'
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
                indexName = ":GetChildren()[" .. index .. "]"
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

local function format_value(v)
    local typ = typeof(v)

    if str_types[typ] then
        return string_ret(v, typ)
    elseif typ == "string" then
        return "\"".. formatstr(v) .."\""
    elseif typ == "Instance" then
        return getInstancePath(v)
    else
        return typ..".new(" .. tostring(v) .. ")"
    end
end

local function serialize_table(t, p, c, s)
    local str = ""
    local n = count_table(t)
    local ti = 1
    local e = n > 0

    c = c or {}
    p = p or 1
    s = s or string.rep

    local function localized_format(v, is_table, isNaN)
        return is_table and (c[v][2] >= p) and serialize_table(v, p + 1, c, s) or (isNaN and "0/0") or format_value(v)
    end

    c[t] = {t, 0}

    for i, v in next, t do
        local typ_i, typ_v = typeof(i) == "table", typeof(v) == "table"
        local isNaN = false
        if v ~= v then
            isNaN = true
            v = "NaN"
        end
        c[i] = (not c[i] and typ_i) and {i, p} or c[i]
        c[v] = (not c[v] and typ_v) and {v, p} or c[v]
        str = str .. s("    ", p) .. "[" .. localized_format(i, typ_i) .. "] = "  .. localized_format(v, typ_v, isNaN) .. (ti < n and "," or "") .. "\n"
        ti = ti + 1
    end

    return ("{" .. (e and "\n" or "")) .. str .. (e and s("  ", p - 1) or "") .. "}"
end

local function serializeArgs(...) 
    local serialized = {}
    for i,v in pairs({...}) do
        local typ = typeof(v)
        local idx = #serialized + 1
        if typ == "table" then
            serialized[idx] = serialize_table(v)
        else
            serialized[idx] = format_value(v)
        end
    end
    return table.concat(serialized, ", ")
end

local function serialize(...)
    local args = {...}
    if #args > 1 then return serializeArgs(...) end
    local value = args[1]
    local typ = typeof(value)
    if typ == "table" then
        return serialize_table(value)
    else
        return format_value(value)
    end
end

getgenv().serialize=serialize
return serialize
