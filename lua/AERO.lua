-- Aero mod template by creo. --
------------------------------------------
-- https://github.com/Vezxe/Aero-Mod-Template
------------------------------------------

------------------------------------------
-- Do not write here, write in main.lua --
------------------------------------------

local aero = {}
local BeatEvents = { { 9999999, function() end } }
local modsfile = loadfile(GAMESTATE:GetCurrentSong():GetSongDir() .. "/lua/main.lua")()
local xml = loadfile(GAMESTATE:GetCurrentSong():GetSongDir() .. "/lua/xmlSimple.lua")().newParser() -- https://github.com/Cluain/Lua-Simple-XML-Parser

local file = RageFileUtil.CreateRageFile()
file:Open(GAMESTATE:GetCurrentSong():GetSongDir() .. "/lua/Actors.xml", 1)
local ActorsXML = file:Read()

local acxml = xml:ParseXmlText(ActorsXML)

_G.Actors = {}

_G.Notefield = nil
aero.FrameEvents = {}
aero.easingevents = {}

_G.PlayerOptions = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions('ModsLevel_Song')

_G.GetCurrentBeat = function()
    return GAMESTATE:GetSongPosition():GetSongBeat()
end

_G.GetSongBeatsPerSecond = function()
    return GAMESTATE:GetSongPosition():GetCurBPS()
end

_G.GetSongBeatsPerMinute = function()
    return GetSongBeatsPerSecond() * 60
end

_G.BeatsToSeconds = function(Beats)
    return Beats / GetSongBeatsPerSecond()
end

_G.Lerp = function(a, b, t)
    return a + (b - a) * t
end

_G.ActorFrame = Def["ActorFrame"]
local initactor = nil

_G.frame = ActorFrame { -- IMPORTANT, DO NOT TOUCH!!
    InitCommand = function(self)
        self:queuecommand("Update")
        self:SetDrawByZPosition(false)
    end,
    OnCommand = function(self)
        for i, v in pairs(SCREENMAN:GetTopScreen():GetChildren()) do
            if i ~= "PlayerP1" and v ~= self:GetParent() then
                --v:diffuse(1, 1, 1, 0)
            end
        end
    end,
    UpdateCommand = function(self)
        self:sleep(1 / 120)
        self:queuecommand("Update")

        _G.CurrentSongTime = GAMESTATE:GetSongPosition():GetMusicSeconds()
        _G.CurrentSongBeat = GetCurrentBeat()
        if BeatEvents[1][1] <= CurrentSongBeat then
            BeatEvents[1][2](BeatEvents[1][1])
            table.remove(BeatEvents, 1)
        end
        for i, func in pairs(aero.FrameEvents) do
            local x = func()
            if x then
                table.remove(aero.FrameEvents, i)
            end
        end

        local index = 1
        for i, v in pairs(aero.easingevents) do
            if v[2](v[1]) then
                aero.easingevents[i] = nil
            end
        end
    end,
    Def.ActorProxy {
        OnCommand = function(self)
            _G.Notefield = SCREENMAN:GetTopScreen():GetChild('PlayerP1'):GetChild('NoteField')
            modsfile(_G) -- run the user's code
        end
    },
    Def.Actor {
        Name = "preserver",
        InitCommand = function(self)
            self.sleep(self, 999999999)
        end
    },
}

initactor = function(acxml, parent)
    for i, v in pairs(acxml:children()) do -- Initiate xml actors
        local dothings = {}
        local ActorType = v:name()
        local new_actor = Def[ActorType] { -- Create a new actor of type v:name()
            InitCommand = function(self)
                pcall(function()
                    if v["@Name"] then
                        _G.Actors[v["@Name"]] = self
                    end
                end)

                for x, Func in pairs(dothings) do
                    if Func == "FullScreen" then -- Doing this rather than fullscreen in reality to stop ActorFrames from freaking the fuck out
                        self:SetWidth(SCREEN_WIDTH):SetHeight(SCREEN_HEIGHT)
                    else
                        self[Func](self)
                    end
                end
            end
        }

        for i, v in pairs(v) do                -- Fill in the actors properties
            if string.sub(i, 1, 1) == "@" then -- Is a set property
                local propertyname = string.sub(i, 2, string.len(i))

                local lowv = string.lower(v)

                if propertyname == "Texture" or propertyname == "Frag" then
                    v = GAMESTATE:GetCurrentSong():GetSongDir() .. v
                end

                if propertyname == "FullScreen" or propertyname == "Center" then
                    if lowv == "true" then
                        table.insert(dothings, propertyname)
                    end
                else
                    new_actor[propertyname] = v
                end
            end
        end
        parent[#parent + 1] = new_actor
        initactor(v, new_actor)
    end
end
initactor(acxml, frame) -- Initiate actors from xml



_G.beatevent = function(Beat, Function) -- Runs function on specified beat. With the beat it should be initialized on as a parameter.
    table.insert(BeatEvents, { Beat, Function })
    local new_beat_events = {}
    while #BeatEvents ~= 0 do
        local smallest_beat = BeatEvents[1][1]
        local index = 1
        for i, v in pairs(BeatEvents) do
            if v[1] < smallest_beat then
                smallest_beat = v[1]
                index = i
            end
        end
        table.insert(new_beat_events, BeatEvents[index])
        table.remove(BeatEvents, index)
    end
    BeatEvents = new_beat_events
end
_G.be = _G.beatevent

_G.beateventcount = function(BeatStart, BeatEnd, nth, func)
    for i = BeatStart, BeatEnd - 1 do
        for v = 0, nth - 1 do
            be(i + ((1 / nth) * v), func)
        end
    end
end

_G.CreateFrameEvent = function(func) -- Call a function on every frame, if you want to stop the function return 1 or true.
    table.insert(aero.FrameEvents, func)
end

-- Easing / Tweening fuckery --
_G.easing_styles = loadfile(GAMESTATE:GetCurrentSong():GetSongDir() .. "/lua/easing.lua")()

for i, v in pairs(_G.easing_styles) do
    _G[i] = v
end

local po_list = {
    "Alternate",
    "CMod",
    "MMod",
    "Distant",
    "Drunk",
    "Tipsy",
    "Dizzy",
    "Beat",
    "Blind",
    "Blink",
    "Boomerang",
    "Boost",
    "Bounce",
    "Brake",
    "Bumpy",
    "Centered",
    "Confusion",
    "Cross",
    "Dark",
    "Digital",
    "Hidden",
    "DrawSize",
    "Expand",
    "Flip",
    "Hallway",
    "Hidden",
    "Incoming",
    "Invert",
    "Split",
    "Reverse",
    "Blacksphere",
    "NotePath",
    "Mini",
}
function addcolvar(option)
    for i = 1, 16 do
        po_list[#po_list + 1] = option .. tostring(i)
    end
    po_list[#po_list + 1] = option
end

addcolvar("ConfusionOffset")
addcolvar("Tiny")

addcolvar("MoveX")
addcolvar("MoveY")
addcolvar("MoveZ")



_G.po_known_states = {} -- for keeping track of what effects are currently at
for i, po in pairs(po_list) do
    po_known_states[po] = 0
end

local NewPlayerOptions = { -- Allow adding "fake" player options, add functions in with their names in this dictionary
}

function CreatePlayerOption(Name, func) -- Use to define custom player effects
    NewPlayerOptions[Name] = func
    po_known_states[Name] = 0
end

function lv(v) -- "Looping value" used to standardize values that go between 0 - 1 and loop back when going over or below
    return (math.pi / 2 * v)
end

function vl(v) -- opposite of lv
    return v * (math.pi / 2)
end

CreatePlayerOption("OutInvert", function(v)
    v = lv(v)
    SetPlayerOption("Flip", -0.5 * math.sin(v))
    SetPlayerOption("Invert", 1.5 * math.sin(v))
end)

CreatePlayerOption("BounceCenter", function(v)
    SetPlayerOption("Split", -0.25 * v)
    SetPlayerOption("Alternate", 0.25 * v)
end)

CreatePlayerOption("Blacksphere", function(rot) -- From mod chart "blacksphere", who woulda guessed :P
    local alt = math.sin(rot * 2 * math.pi) * 0.2
    local rev = math.sin(rot * 2 * math.pi) * -0.1
    local inv = -math.cos(rot * 2 * math.pi) * 0.5 + 0.5
    SetPlayerOption("Invert", inv)
    SetPlayerOption("Reverse", rev)
    SetPlayerOption("Alternate", alt)
end)

function SetPlayerOption(Option, value) -- Does exactly as it says
    pcall(function()                    -- Some player effects are not available between all stepmania versions, so just ignore the errors to keep going.
        po_known_states[Option] = value
        if not NewPlayerOptions[Option] then
            PlayerOptions[Option](PlayerOptions, value, 9999)
        else
            NewPlayerOptions[Option](value)
        end
    end)
end

function SetDefaultPlayerOptions() -- Set all "known" player options to their default 0, unless they are CMod or MMod
    for i, po in pairs(po_list) do
        if po ~= "CMod" and po ~= "MMod" then
            SetPlayerOption(po, 0)
        end
    end
    SetPlayerOption("MMod", 550)
    SetPlayerOption("CMod", 550)
end

SetDefaultPlayerOptions()

local CurrentEasingData = {}

_G.ease = function(when, time_in_beats, easingstyle, value, player_effect) -- eases a player effect within an amount of beats
    local easf = nil
    easf = function(Initval)
        local return_val = false
        if CurrentSongBeat >= when then
            local percent = (1 / time_in_beats) * (CurrentSongBeat - when)
            if percent >= 1 then
                percent = 1
                return_val = true
            end
            SetPlayerOption(player_effect, Lerp(Initval, value, easingstyle(percent)))
        end
        return return_val
    end
    beatevent(when, function(b)
        aero.easingevents[player_effect] = { po_known_states[player_effect], easf }
    end)
end

InsertActor = function(actor)
    frame[#frame + 1] = actor
end

-- End fuckery --
return frame
