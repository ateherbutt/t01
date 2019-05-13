if myHero.charName ~= "Fiora" then return end

-- [ update ]
do
    
    local Version = 1
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "Fiora.lua",
            Url = "https://raw.githubusercontent.com/miragessee/GoSFiora/master/Fiora.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "miragesfiora.version",
            Url = "https://raw.githubusercontent.com/miragessee/GoSFiora/master/miragesfiora.version"
        }
    }
    
    local function AutoUpdate()
        
        local function DownloadFile(url, path, fileName)
            DownloadFileAsync(url, path .. fileName, function() end)
            while not FileExist(path .. fileName) do end
        end
        
        local function ReadFile(path, fileName)
            local file = io.open(path .. fileName, "r")
            local result = file:read()
            file:close()
            return result
        end
        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print(Files.Version.Name .. ": Updated to " .. tostring(NewVersion) .. ". Please Reload with 2x F6")
        else
            print(Files.Version.Name .. ": No Updates Found")
        end
    
    end
    
    AutoUpdate()

end

local _atan = math.atan2
local _min = math.min
local _abs = math.abs
local _sqrt = math.sqrt
local _floor = math.floor
local _max = math.max
local _pow = math.pow
local _huge = math.huge
local _pi = math.pi
local _insert = table.insert
local _contains = table.contains
local _sort = table.sort
local _pairs = pairs
local _find = string.find
local _sub = string.sub
local _len = string.len

local LocalControlIsKeyDown = Control.IsKeyDown;
local LocalControlMouseEvent = Control.mouse_event;
local LocalControlSetCursorPos = Control.SetCursorPos;
local LocalControlCastSpell = Control.CastSpell;
local LocalControlKeyUp = Control.KeyUp;
local LocalControlKeyDown = Control.KeyDown;
local LocalControlMove = Control.Move;
local LocalGamecursorPos = Game.cursorPos;
local LocalGameCanUseSpell = Game.CanUseSpell;
local LocalGameLatency = Game.Latency;
local LocalGameTimer = Game.Timer;
local LocalGameHeroCount = Game.HeroCount;
local LocalGameHero = Game.Hero;
local LocalGameMinionCount = Game.MinionCount;
local LocalGameMinion = Game.Minion;
local LocalGameTurretCount = Game.TurretCount;
local LocalGameTurret = Game.Turret;
local LocalGameWardCount = Game.WardCount;
local LocalGameWard = Game.Ward;
local LocalGameObjectCount = Game.ObjectCount;
local LocalGameObject = Game.Object;
local LocalGameMissileCount = Game.MissileCount;
local LocalGameMissile = Game.Missile;
local LocalGameParticleCount = Game.ParticleCount;
local LocalGameParticle = Game.Particle;
local LocalGameIsChatOpen = Game.IsChatOpen;
local LocalGameIsOnTop = Game.IsOnTop;

function GetMode()
    if _G.SDK then
        if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
            return "Combo"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
            return "Harass"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
            return "Clear"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
            return "Flee"
        end
    else
        return GOS.GetMode()
    end
end

local distance = 200
local passtiveList = {
	["Fiora_Base_Passive_NE.troy"] = { x = 0, y = distance},
	["Fiora_Base_Passive_NW.troy"] = { x = distance, y = 0},
	["Fiora_Base_Passive_SE.troy"] = { x = -1 * distance, y = 0},
	["Fiora_Base_Passive_SW.troy"] = { x = 0, y = -1 * distance},
	["Fiora_Base_R_Mark_NE_FioraOnly.troy"] = { x = 0, y = distance},
	["Fiora_Base_R_Mark_NW_FioraOnly.troy"] = { x = distance, y = 0},
	["Fiora_Base_R_Mark_SE_FioraOnly.troy"] = { x = -1 * distance, y = 0},
	["Fiora_Base_R_Mark_SW_FioraOnly.troy"] = { x = 0, y = -1 * distance}
}

local objectList = {}
local buffList = {}

local function getNearestPos()
	local result = nil
	local distanceTemp = math.huge
	for _,obj in pairs(buffList) do
		local origin = GetOrigin(obj)
		if origin then
			local distance = passtiveList[GetObjectBaseName(obj)]
			local buff_pos = {
				x = origin.x+distance.x,
				y = origin.y+distance.y,
				z = origin.z
			}
			local buff_pos_distance = GetDistance(buff_pos)
			if not result or buff_pos_distance < distanceTemp then
				result = buff_pos
				distanceTemp = buff_pos_distance
			end
		end
	end

	return result, distanceTemp
end

local function processObjectList()
	local tempObjectList = {}
	for _,object in ipairs(objectList) do
		local id = GetNetworkID(object)
		if id then
			buffList[id] = object
		else
			table.insert(tempObjectList, object)
		end
	end
	objectList = tempObjectList
end

OnProcessSpellComplete(function(unit, spell)
  if unit == myHero and spell.name == "FioraE" then
		resetAA()
  end
end)

OnCreateObj(function(object)
	if passtiveList[GetObjectBaseName(object)] then
		table.insert(objectList, object)
	end

	if debug and GetObjectBaseName(object):find("Fiora_Base") and not GetObjectBaseName(object):lower():find("speed")then
		PrintChat(
			""..GetObjectBaseName(object).."  "..
			"IsVisible : "..tostring(IsVisible(object)).."  "..
			"GetTeam : "..GetTeam(object).."  "..
			"IsTargetable : "..tostring(IsTargetable(object)).."  "
			)
	end
end)

OnDeleteObj(function(object)
	if passtiveList[GetObjectBaseName(object)] then
		buffList[GetNetworkID(object)] = nil
	end
end)

PrintChat("simple fiora loaded")
