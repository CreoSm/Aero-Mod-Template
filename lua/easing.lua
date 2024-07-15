-- file from mirin template


local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local pow = math.pow
local exp = math.exp
local pi = math.pi
local abs = math.abs

local ease_styles = {}

function ease_styles.flip(fn)
    return function(x) return 1 - fn(x) end
end

function ease_styles.bounce(t) return 4 * t * (1 - t) end

function ease_styles.tri(t) return 1 - abs(2 * t - 1) end

function ease_styles.pop(t) return 3.5 * (1 - t) * (1 - t) * sqrt(t) end

function ease_styles.tap(t) return 3.5 * t * t * sqrt(1 - t) end

function ease_styles.pulse(t) return t < .5 and ease_styles.tap(t * 2) or -ease_styles.pop(t * 2 - 1) end

function ease_styles.spike(t) return exp(-10 * abs(2 * t - 1)) end

function ease_styles.inverse(t) return t * t * (1 - t) * (1 - t) / (0.5 - t) end

function ease_styles.instant() return 1 end

function ease_styles.linear(t) return t end

function ease_styles.inQuad(t) return t * t end

function ease_styles.outQuad(t) return -t * (t - 2) end

function ease_styles.inOutQuad(t)
    t = t * 2
    if t < 1 then
        return 0.5 * t ^ 2
    else
        return 1 - 0.5 * (2 - t) ^ 2
    end
end

function ease_styles.inCubic(t) return t * t * t end

function ease_styles.outCubic(t) return 1 - (1 - t) ^ 3 end

function ease_styles.inOutCubic(t)
    t = t * 2
    if t < 1 then
        return 0.5 * t ^ 3
    else
        return 1 - 0.5 * (2 - t) ^ 3
    end
end

function ease_styles.inQuart(t) return t * t * t * t end

function ease_styles.outQuart(t) return 1 - (1 - t) ^ 4 end

function ease_styles.inOutQuart(t)
    t = t * 2
    if t < 1 then
        return 0.5 * t ^ 4
    else
        return 1 - 0.5 * (2 - t) ^ 4
    end
end

function ease_styles.inQuint(t) return t ^ 5 end

function ease_styles.outQuint(t) return 1 - (1 - t) ^ 5 end

function ease_styles.inOutQuint(t)
    t = t * 2
    if t < 1 then
        return 0.5 * t ^ 5
    else
        return 1 - 0.5 * (2 - t) ^ 5
    end
end

function ease_styles.inExpo(t) return 1000 ^ (t - 1) - 0.001 end

function ease_styles.outExpo(t) return 0.999 - 1000 ^ -t end

function ease_styles.inOutExpo(t)
    t = t * 2
    if t < 1 then
        return 0.5 * 1000 ^ (t - 1) - 0.0005
    else
        return 0.9995 - 0.5 * 1000 ^ (1 - t)
    end
end

function ease_styles.inCirc(t) return 1 - sqrt(1 - t * t) end

function ease_styles.outCirc(t) return sqrt(-t * t + 2 * t) end

function ease_styles.inOutCirc(t)
    t = t * 2
    if t < 1 then
        return 0.5 - 0.5 * sqrt(1 - t * t)
    else
        t = t - 2
        return 0.5 + 0.5 * sqrt(1 - t * t)
    end
end

function ease_styles.inElastic(t)
    t = t - 1
    return -(pow(2, 10 * t) * sin((t - 0.075) * (2 * pi) / 0.3))
end

function ease_styles.outElastic(t)
    return pow(2, -10 * t) * sin((t - 0.075) * (2 * pi) / 0.3) + 1
end

function ease_styles.inOutElastic(t)
    t = t * 2 - 1
    if t < 0 then
        return -0.5 * pow(2, 10 * t) * sin((t - 0.1125) * 2 * pi / 0.45)
    else
        return pow(2, -10 * t) * sin((t - 0.1125) * 2 * pi / 0.45) * 0.5 + 1
    end
end

function ease_styles.inBack(t) return t * t * (2.70158 * t - 1.70158) end

function ease_styles.outBack(t)
    t = t - 1
    return (t * t * (2.70158 * t + 1.70158)) + 1
end

function ease_styles.inOutBack(t)
    t = t * 2
    if t < 1 then
        return 0.5 * (t * t * (3.5864016 * t - 2.5864016))
    else
        t = t - 2
        return 0.5 * (t * t * (3.5864016 * t + 2.5864016) + 2)
    end
end

function ease_styles.outBounce(t)
    if t < 1 / 2.75 then
        return 7.5625 * t * t
    elseif t < 2 / 2.75 then
        t = t - 1.5 / 2.75
        return 7.5625 * t * t + 0.75
    elseif t < 2.5 / 2.75 then
        t = t - 2.25 / 2.75
        return 7.5625 * t * t + 0.9375
    else
        t = t - 2.625 / 2.75
        return 7.5625 * t * t + 0.984375
    end
end

function ease_styles.inBounce(t) return 1 - ease_styles.outBounce(1 - t) end

function ease_styles.vinOutBounce(t)
    if t < 0.5 then
        return ease_styles.inBounce(t * 2) * 0.5
    else
        return ease_styles.outBounce(t * 2 - 1) * 0.5 + 0.5
    end
end

function ease_styles.inSine(x)
    return 1 - cos(x * (pi * 0.5))
end

function ease_styles.outSine(x)
    return sin(x * (pi * 0.5))
end

function ease_styles.inOutSine(x)
    return 0.5 - 0.5 * cos(x * pi)
end

return ease_styles
