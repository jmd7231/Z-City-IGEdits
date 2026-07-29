local MODE = MODE

MODE.name = "kingkong"

-- Keep the opening seconds fair while clients are fading in and learning their role.
function MODE:HG_MovementCalc_2(_, _, cmd, mv)
	if (zb.ROUND_START or 0) + 8 <= CurTime() then return end

	if cmd then
		cmd:RemoveKey(IN_ATTACK)
		cmd:RemoveKey(IN_ATTACK2)
	end

	if mv then
		mv:RemoveKey(IN_ATTACK)
		mv:RemoveKey(IN_ATTACK2)
	end
end

function MODE:PlayerCanLegAttack()
	if (zb.ROUND_START or 0) + 8 > CurTime() then return false end
end
