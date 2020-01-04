function Class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k, v in pairs(super) do
                cls[k] = v
            end
            cls.__create = super.__create
            cls.super = super
        else
            cls.__create = super
            cls.Ctor = function()
            end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.New(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k, v in pairs(cls) do
                instance[k] = v
            end
            instance.class = cls
            instance:Ctor(...)
            --MemLeakChecker[#MemLeakChecker + 1] = instance
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, { __index = super })
            cls.super = super
        else
            cls = { Ctor = function()
            end }
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.New(...)
            local instance = setmetatable({}, cls)
            instance:Ctor(...)
            return instance
        end
    end

    return cls
end
