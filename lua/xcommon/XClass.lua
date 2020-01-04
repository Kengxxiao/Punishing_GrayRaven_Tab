local _class = {}

function XClass(super)
    local class = {}
    class.Ctor = false
    class.Super = super
    class.New = function(...)
        local obj = {}
        setmetatable(obj, {__index = _class[class]})
        do
            local create
            create = function(c, ...)
                if c.Super then
                    create(c.Super, ...)
                end
                
                if c.Ctor then
                    c.Ctor(obj, ...)
                end
            end
            create(class, ...)
        end
        return obj
    end
    
    local vtbl = {}
    _class[class] = vtbl
    
    setmetatable(class, {
        __newindex = function(t, k, v)
            vtbl[k] = v
        end,
        __index = function(t, k)
            return vtbl[k]
        end
    })
    
    if super then
        setmetatable(vtbl, {
            __index = function(t, k)
                local ret = _class[super][k]
                vtbl[k] = ret
                return ret
            end
        })
    end
    
    return class
end 