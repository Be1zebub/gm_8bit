-- it was difficult to test this through the console so i made a menu

if CLIENT then
	local menu = vgui.Create("DFrame")
	menu:SetSize(350, 400)
	menu:Center()
	menu:MakePopup()

	local lbl = menu:Add("DLabel")
	lbl:SetText("Effect")
	lbl:SizeToContents()
	lbl:Dock(TOP)

	local effect = menu:Add("EditablePanel")
	effect:Dock(TOP)
	effect:DockMargin(0, 6, 0, 16)

	local names = {
		[0] = "NONE",
		[1] = "BITCRUSH",
		[2] = "DESAMPLE"
	}

	for i = 0, 2 do
		local btn = effect:Add("DButton")
		btn:Dock(LEFT)
		btn:SetText(names[i])
		btn:SizeToContents()
		btn.DoClick = function()
			net.Start("gm8bit")
				net.WriteString("EnableEffect")
				net.WriteTable({
					LocalPlayer():UserID(),
					i
				})
			net.SendToServer()
		end
		btn.PaintOver = function(me, w, h)
			if GetGlobalInt("8BitEffect", -1) == i then
				surface.SetDrawColor(0, 255, 0, 60)
				surface.DrawRect(0, 0, w, h)
			end
		end
	end

	for _, data in ipairs({
		{func = "SetGainFactor", effect = "BITCRUSH", decimals = 2},
		{func = "SetCrushFactor", effect = "BITCRUSH", decimals = 2},
		{func = "SetDesampleRate", effect = "DESAMPLE", min = 1, max = 50, default = 2}
	}) do
		local slider = menu:Add("DNumSlider")
		slider:Dock(TOP)
		slider:SetTall(32)
		slider:SetText(data.effect .." ".. data.func:sub(4))
		slider:SetMin(data.min or 0)
		slider:SetMax(data.max or 1)
		slider:SetValue(GetGlobalFloat(data.func, data.default or 0))
		slider:SetDecimals(data.decimals or 0)
		slider.OnValueChanged = function(_, val)
			timer.Create("gm8bit", 0.25, 1, function()
				net.Start("gm8bit")
					net.WriteString(data.func)
					net.WriteTable({
						val
					})
					net.WriteBool(true)
				net.SendToServer()
			end)
		end
	end
else
	require("eightbit")

	util.AddNetworkString("gm8bit")

	net.Receive("gm8bit", function(len, ply)
		if ply:IsSuperAdmin() then
			local func = net.ReadString()
			local data = net.ReadTable()

			if net.ReadBool() then
				eightbit[func](data[1])
				SetGlobalFloat(func, data[1])
			else
				eightbit[func](data[1], data[2])
				SetGlobalInt("8BitEffect", data[2])
			end
		end
	end)
end
