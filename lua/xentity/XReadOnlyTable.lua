XReadOnlyTable = XReadOnlyTable or {}


XReadOnlyTable.Create = function(t)
    for x, y in pairs(t) do
        if type(x) == "table" then
            if type(y) == "table" then
                t[XReadOnlyTable.Create(x)] = XReadOnlyTable.Create(y)
            else
                t[XReadOnlyTable.Create(x)] = y
            end
        elseif type(y) == "table" then
            t[x] = XReadOnlyTable.Create(y)
        end
    end
    
    local mt = {
        __metatable = "readonly table",
        __index = t,
        __newindex = function (tab,k,v)
            XLog.Error("attempt to update a readonly table")
        end,
        __len = function (tab)
            return #t
        end,
        __pairs = function (tab)
            local function stateless_iter(tbl, k)
                local nk, nv = next(tbl, k)
                if nk then return nk, nv end
              end
              return stateless_iter, t, nil
        end
    }

    return setmetatable({}, mt)
end
