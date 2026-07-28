local MODE = MODE

MODE.name = "kingkong"
MODE.PrintName = "King Kong"
MODE.LootSpawn = false
MODE.GuiltDisabled = true
MODE.randomSpawns = true
MODE.noBoxes = true
MODE.ForBigMaps = false
MODE.ROUND_TIME = 300
MODE.Chance = 0.025

local KING_TEAM = 1
local HUNTER_TEAM = 0
local KING_HEALTH_PER_HUNTER = 125

util.AddNetworkString("kingkong_start")
util.AddNetworkString("kingkong_end")

local function IsActivePlayer(ply)
	return IsValid(ply) and ply:Team() ~= TEAM_SPECTATOR
end

local function IsLiving(ply)
	return IsActivePlayer(ply) and ply:Alive()
		and not (ply.organism and ply.organism.incapacitated)
end

local function ResetKing(ply)
	if not IsValid(ply) then return end

	ply:SetNWBool("ZCityKingKong", false)
	ply:SetModelScale(1, 0)
	ply:SetMaxHealth(100)
end

function MODE:CanLaunch()
	local count = 0
	for _, ply in player.Iterator() do
		if IsActivePlayer(ply) then count = count + 1 end
	end

	return count >= 3
end

function MODE:Intermission()
	game.CleanUpMap()
	self.saved.king = nil
	self.saved.winner = nil

	for _, ply in player.Iterator() do
		ResetKing(ply)
		if IsActivePlayer(ply) then ply:SetupTeam(HUNTER_TEAM) end
	end
end

function MODE:GiveEquipment()
	local players = {}
	for _, ply in player.Iterator() do
		if IsActivePlayer(ply) then players[#players + 1] = ply end
	end

	if #players == 0 then return end

	local king = table.Random(players)
	self.saved.king = king

	for _, ply in ipairs(players) do
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		ply:Give("weapon_hands_sh")

		if ply == king then
			ply:SetupTeam(KING_TEAM)
			ply:SetNWBool("ZCityKingKong", true)
			ply:SetModelScale(1.2, 0)

			local health = math.max(350, (#players - 1) * KING_HEALTH_PER_HUNTER)
			ply:SetMaxHealth(health)
			ply:SetHealth(health)
			ply:Give("weapon_hg_axe")
			ply:Give("weapon_hg_shovel")
			zb.GiveRole(ply, "King Kong", Color(150, 55, 20))

			if ply.organism then
				ply.organism.recoilmul = 0.15
				ply.organism.pain = 0
				ply.organism.painadd = -25
				ply.organism.stamina.max = math.max(ply.organism.stamina.max or 0, 300)
				ply.organism.stamina.range = math.max(ply.organism.stamina.range or 0, 300)
			end
		else
			ply:SetupTeam(HUNTER_TEAM)
			ply:Give("weapon_m4a1")
			ply:Give("weapon_hk_usp")
			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
			ply:GiveAmmo(90, "AR2", true)
			ply:GiveAmmo(34, "Pistol", true)
			zb.GiveRole(ply, "Kong Hunter", Color(40, 125, 200))
		end

		ply:SelectWeapon("weapon_hands_sh")
		ply:SetSuppressPickupNotices(false)
		timer.Simple(0.1, function()
			if IsValid(ply) then ply.noSound = false end
		end)
	end

	net.Start("kingkong_start")
		net.WriteEntity(king)
	net.Broadcast()
end

function MODE:RoundStart()
end

function MODE:GiveWeapons()
end

function MODE:CheckAlivePlayers()
	local kingAlive = IsLiving(self.saved.king)
	local huntersAlive = false

	for _, ply in player.Iterator() do
		if ply ~= self.saved.king and IsLiving(ply) then
			huntersAlive = true
			break
		end
	end

	return kingAlive, huntersAlive
end

function MODE:ShouldRoundEnd()
	local kingAlive, huntersAlive = self:CheckAlivePlayers()
	if kingAlive and huntersAlive then return false end

	self.saved.winner = kingAlive and KING_TEAM or HUNTER_TEAM
	return true
end

function MODE:BoringRoundFunction()
	-- Hunters win if Kong cannot finish them before the round timer expires.
	self.saved.winner = HUNTER_TEAM
end

function MODE:EntityTakeDamage(target, damageInfo)
	local attacker = damageInfo:GetAttacker()
	if not target:IsPlayer() or not attacker:IsPlayer() then return end

	if target:GetNWBool("ZCityKingKong", false) then
		damageInfo:ScaleDamage(0.65)
	elseif attacker:GetNWBool("ZCityKingKong", false) then
		damageInfo:ScaleDamage(1.8)
	end
end

function MODE:EndRound()
	local winner = self.saved.winner
	if winner == nil then
		local kingAlive = self:CheckAlivePlayers()
		winner = kingAlive and KING_TEAM or HUNTER_TEAM
	end

	net.Start("kingkong_end")
		net.WriteUInt(winner, 1)
	net.Broadcast()

	for _, ply in player.Iterator() do ResetKing(ply) end
end

function MODE:PlayerDeath()
end
