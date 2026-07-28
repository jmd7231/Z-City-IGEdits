if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_melee"
SWEP.PrintName = "King Kong"
SWEP.Instructions = "LMB to smash.\nRMB to shove."
SWEP.Category = "Z-City"
SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.Spawnable = false
SWEP.AdminOnly = false
SWEP.NoDrop = true
SWEP.NoHolster = true

SWEP.ViewModel = ""
SWEP.WorldModel = "models/z_city/nmrih/weapons/fists/v_me_fists.mdl"
SWEP.WorldModelReal = "models/z_city/nmrih/weapons/fists/v_me_fists.mdl"
SWEP.WorldModelExchange = false

SWEP.HoldType = "fist"
SWEP.HoldPos = Vector(0, 0, 0)
SWEP.HoldAng = Angle(0, 0, 0)
SWEP.weaponPos = Vector(0, 0, 0)
SWEP.weaponAng = Angle(0, 0, 0)
SWEP.AttackPos = Vector(0, 0, 0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 55
SWEP.DamageSecondary = 20
SWEP.PainMultiplier = 1.5
SWEP.ShockMultiplier = 1.5
SWEP.BreakBoneMul = 1.5

SWEP.PenetrationPrimary = 8
SWEP.PenetrationSecondary = 3
SWEP.PenetrationSizePrimary = 6
SWEP.PenetrationSizeSecondary = 3
SWEP.MaxPenLen = 8

SWEP.AttackLen1 = 85
SWEP.AttackLen2 = 70
SWEP.AttackRads = 110
SWEP.AttackRads2 = 80
SWEP.MultiDmg1 = true
SWEP.MultiDmg2 = true

SWEP.AttackTime = 0.45
SWEP.AnimTime1 = 1.2
SWEP.WaitTime1 = 1.5
SWEP.AttackTimeLength = 0.12
SWEP.ViewPunch1 = Angle(3, 0, 0)

SWEP.Attack2Time = 0.35
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 1.75
SWEP.Attack2TimeLength = 0.08
SWEP.ViewPunch2 = Angle(2, 0, -2)

SWEP.StaminaPrimary = 5
SWEP.StaminaSecondary = 4
SWEP.SwingAng = -20
SWEP.SwingAng2 = 10
SWEP.MinSensivity = 0.4

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AnimList = {
	["idle"] = "Idle",
	["deploy"] = "Draw",
	["attack"] = "Attack_Quick",
	["attack2"] = "Shove"
}

SWEP.AttackHit = "physics/concrete/concrete_break2.wav"
SWEP.Attack2Hit = "physics/body/body_medium_impact_hard3.wav"
SWEP.AttackHitFlesh = "physics/flesh/flesh_impact_hard6.wav"
SWEP.Attack2HitFlesh = "physics/flesh/flesh_impact_hard3.wav"
SWEP.DeploySnd = "npc/antlion_guard/angry1.wav"

function SWEP:CanPrimaryAttack()
	return IsValid(self:GetOwner()) and self:GetOwner():GetNWBool("ZCityKingKong", false)
end

function SWEP:CanSecondaryAttack()
	return IsValid(self:GetOwner()) and self:GetOwner():GetNWBool("ZCityKingKong", false)
end

local function ThrowHitEntity(owner, ent, trace, force)
	if not IsValid(ent) then return end

	local direction = owner:GetAimVector()
	if ent:IsPlayer() or ent:IsNPC() then
		ent:SetVelocity(direction * force + Vector(0, 0, force * 0.25))
	end

	local phys = ent:GetPhysicsObjectNum(trace.PhysicsBone or 0)
	if IsValid(phys) then
		phys:ApplyForceOffset(direction * force * phys:GetMass(), trace.HitPos)
	end
end

function SWEP:PrimaryAttackAdd(ent, trace)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	ThrowHitEntity(owner, ent, trace, 450)
	if SERVER and hgIsDoor(ent) then
		hgBlastThatDoor(ent, owner:GetAimVector() * 350 + owner:GetVelocity())
	end
end

function SWEP:SecondaryAttackAdd(ent, trace)
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	ThrowHitEntity(owner, ent, trace, 700)
end

function SWEP:ShouldDropOnDie()
	return false
end

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/hmcd_knuckles")
	SWEP.IconOverride = "vgui/hud/hmcd_knuckles"
	SWEP.BounceWeaponIcon = false
end
