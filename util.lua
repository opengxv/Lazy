function lazy_clone(object, deep)
    local copy = {}
    for k, v in pairs(object) do
		if deep and type(v) == "table" then
            v = lazy_clone(v, deep)
        end
        copy[k] = v
    end
    return setmetatable(copy, getmetatable(object))
end