function Handler(target , func)
    return function(...)
        return func(target, ...)
    end
end

handler = Handler