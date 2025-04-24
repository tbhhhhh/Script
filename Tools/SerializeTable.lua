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

local function format_value(v)
    local typ = typeof(v)

    if str_types[typ] then
        return string_ret(v, typ)
    elseif typ == "string" then
        return '"' .. v:gsub('(["\n])', {['"'] = '\\"', ['\n'] = '\\n'}) .. '"'
    elseif typ == "Instance" then
        return v.Parent and "game."..v:GetFullName() or string.format('Instance.new("%s")', v.ClassName)
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
        c[i], c[v] = (not c[i] and typ_i) and {i, p} or c[i], (not c[v] and typ_v) and {v, p} or c[v]
        str = str .. s("    ", p) .. "[" .. localized_format(i, typ_i) .. "] = "  .. localized_format(v, typ_v, isNaN) .. (ti < n and "," or "") .. "\n"
        ti = ti + 1
    end

    return ("{" .. (e and "\n" or "")) .. str .. (e and s("  ", p - 1) or "") .. "}"
end

getgenv().serialize=serialize_table
return serialize_table