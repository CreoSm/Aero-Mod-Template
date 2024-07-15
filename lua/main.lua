local mod = function()
    --Put your code here --
end

-- DO NOT TOUCH --
return function(env)
    setfenv(1, env)
    mod()
end
