-- Aero mod template by creo. --

------------------------------------------
-- Do not write here, write in main.lua --
------------------------------------------

local aero = {}
local BeatEvents = { { 9999999, function() end } }
local modsfile = loadfile(GAMESTATE:GetCurrentSong():GetSongDir() .. "/lua/main.lua")()

_G.Notefield = nil
aero.FrameEvents = {}

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

_G.frame = ActorFrame { -- IMPORTANT, DO NOT TOUCH!!
    InitCommand = function(self)
        self:queuecommand("Update")
        self:SetDrawByZPosition(false)
    end,
    OnCommand = function(self)
        for i, v in pairs(SCREENMAN:GetTopScreen():GetChildren()) do
            if i ~= "PlayerP1" and v ~= self:GetParent() then
                v:diffuse(1, 1, 1, 0)
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
    --"Bounce",
    "Brake",
    "Bumpy",
    "Centered",
    "Confusion",
    "Cross",
    "Dark",
    --"Digital",
    "Hidden",
    --"DrawSize",
    "Expand",
    "Flip",
    "Hallway",
    "Hidden",
    "Incoming",
    "Invert",
    "Split",
    "Reverse",
    "Blacksphere"
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



local po_known_states = {} -- for keeping track of what effects are currently at
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
    pcall(function()
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

local TweenInitialValues = {}

_G.ease = function(when, time_in_beats, easingstyle, value, player_effect) -- eases a player effect within an amount of beats
    CreateFrameEvent(function()
        local return_val = false
        if CurrentSongBeat >= when then
            local Initval = nil

            if TweenInitialValues[player_effect] then
                Initval = TweenInitialValues[player_effect]
            else
                TweenInitialValues[player_effect] = po_known_states[player_effect]
                Initval = TweenInitialValues[player_effect]
            end

            local percent = (1 / time_in_beats) * (CurrentSongBeat - when)
            if percent >= 1 then
                percent = 1
                TweenInitialValues[player_effect] = nil
                return_val = true
            end
            SetPlayerOption(player_effect, Lerp(Initval, value, percent))
        else
            Initval = po_known_states[player_effect]
        end
        return return_val
    end)
end

InsertActor = function(actor)
    frame[#frame + 1] = actor
end

-- End fuckery --
return frame
