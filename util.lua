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

function lazy_debug(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 192, 0, 192, 0)
end
