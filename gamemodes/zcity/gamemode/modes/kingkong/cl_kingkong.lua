local MODE = MODE

MODE.name = "kingkong"

local king
local roleShownAt = 0

net.Receive("kingkong_start", function()
	king = net.ReadEntity()
	roleShownAt = CurTime()
	zb.RemoveFade()

	if IsValid(king) then
		chat.AddText(Color(225, 175, 75), king:Nick(), color_white, " is King Kong!")
	end
end)

net.Receive("kingkong_end", function()
	local winner = net.ReadUInt(1)
	local text = winner == 1 and "King Kong wins!" or "The hunters defeated King Kong!"
	chat.AddText(Color(225, 175, 75), text)
end)

function MODE:RenderScreenspaceEffects()
	if roleShownAt + 1.5 < CurTime() then return end

	local alpha = 255 * math.Clamp(roleShownAt + 1.5 - CurTime(), 0, 1)
	surface.SetDrawColor(0, 0, 0, alpha)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function MODE:HUDPaint()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	if roleShownAt + 8 > CurTime() and ply:Alive() then
		local fade = math.Clamp(roleShownAt + 8 - CurTime(), 0, 1)
		local isKing = ply:GetNWBool("ZCityKingKong", false)
		local title = isKing and "You are King Kong" or "You are a Kong Hunter"
		local objective = isKing and "Crush every hunter." or "Work together and bring down King Kong."
		local color = isKing and Color(200, 80, 35, 255 * fade) or Color(60, 155, 235, 255 * fade)

		draw.SimpleText("King Kong", "ZB_HomicideMediumLarge", ScrW() * 0.5, ScrH() * 0.12,
			color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(title, "ZB_HomicideMediumLarge", ScrW() * 0.5, ScrH() * 0.5,
			color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(objective, "ZB_HomicideMedium", ScrW() * 0.5, ScrH() * 0.88,
			color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if not ply:Alive() or not IsValid(king) or king == ply or not king:Alive() then return end

	local healthFraction = math.Clamp(king:Health() / math.max(king:GetMaxHealth(), 1), 0, 1)
	local width = math.min(ScrW() * 0.45, 600)
	local x = (ScrW() - width) * 0.5
	local y = ScrH() * 0.04

	draw.SimpleText("KING KONG", "ZB_HomicideMedium", ScrW() * 0.5, y - 2,
		Color(235, 220, 190), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	surface.SetDrawColor(35, 25, 20, 230)
	surface.DrawRect(x, y, width, 14)
	surface.SetDrawColor(190, 55, 30, 240)
	surface.DrawRect(x + 2, y + 2, (width - 4) * healthFraction, 10)
end
