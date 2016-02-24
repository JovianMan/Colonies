include("shared.lua")
include("hud.lua")

ePressed = false
clock_frame = nil
clock_timeleft = 0
clock_label = ""
TextLabel = nil

function GM:PostDrawViewModel( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end
		
	end
	vm:SetMaterial("")
end

function SetPlayerValue(name,value)
	net.Start( "SetPlayerValue" )
		net.WriteString(name)
		net.WriteTable(value)
	net.SendToServer()
	if #value == 1 then
		LocalPlayer()[name] = value[1]
	else
		LocalPlayer()[name] = value
	end
end

local cur = nil
timer.Create( "PowerCooldown", 1, 0, function() 
	local t = LocalPlayer():GetNWInt("PowerWait")
	if t > 0 then
		SetPlayerValue( "PowerWait",{t-1} )
	end
end)
function GM:Think()	
	if input.IsKeyDown( 17 ) == true then
		local p = LocalPlayer():GetNWString("Power")
		local t = LocalPlayer():GetNWInt("PowerWait")
		if t == 0 then
			net.Start( "power" )
			net.SendToServer()
			SetPlayerValue( "PowerWait",{times[p]} )
		end
	end
	if GetGlobalBool("c") == false then
		local failed = false
		for i=1,game.MaxPlayers() do
			local c = GetGlobalVector( tostring(i), Vector(-1,-1,-1) ) 
			if c ~= Vector(-1,-1,-1) then
				team.SetUp( i, "", Color( c.x,c.y,c.z,255 ) )
				team.SetColor( i, Color( c.x,c.y,c.z,255 ) )
			else
				failed = true
			end
		end
		if failed == false then
			SetGlobalBool( "c", true )
		end
	end
	net.Receive( "TeamColorSync", function( length, ply )
		local t = tonumber(net.ReadString())
		local color = net.ReadColor()
		
		team.SetColor( t, color ) 
	end)
	net.Receive( "TeamChanged", function(length, ply)
	
		local t = tonumber(net.ReadString())
		local c = team.GetColor( t ) 
		
		local DPanel = vgui.Create( "DPanel" )
		local DLabel = vgui.Create( "DLabel", DPanel )
		DLabel:SetFont( "DermaLarge" )
		DLabel:SetText( "Team Changed" ) -- Set the text of the label
		DLabel:SizeToContents() -- Size the label to fit the text in it
		DLabel:SetBright( true )
		DLabel:SetContentAlignment( 5 ) 
		cur = DPanel
		local a = 0
		function DPanel:Think()
			if a <= ScrW() then
				DPanel:SetSize( math.min(a,ScrW()), 200 )
				DPanel:SetPos( ScrW()/2-DPanel:GetWide()/2,ScrH()/2-DPanel:GetTall()/2 )
				
				DLabel:SetPos( DPanel:GetWide()/2-DLabel:GetWide()/2, DPanel:GetTall()/2-DLabel:GetTall()/2 )
			elseif a >= 4800 then
				local p1 = vgui.Create( "DPanel" )
				p1:SetSize(ScrW()/2,200)
				p1:SetPos( ScrW()/4-p1:GetWide()/2,ScrH()/2-p1:GetTall()/2 )
				if cur ~= DPanel then
					p1:MoveToBack() 
				end
				function p1:Paint( w, h )
					draw.RoundedBox( 8, 0, 0, w, h, Color( c.r, c.g, c.b ) )
				end
				local l1 = vgui.Create( "DLabel", p1 )
				l1:SetFont( "DermaLarge" )
				l1:SetText( "Team Changed" ) -- Set the text of the label
				l1:SizeToContents() -- Size the label to fit the text in it
				l1:SetBright( true )
				l1:SetContentAlignment( 5 ) 
				l1:SetPos( p1:GetWide()-l1:GetWide()/2, p1:GetTall()/2-l1:GetTall()/2 )
		
		
				
				local p2 = vgui.Create( "DPanel" )
				p2:SetSize(ScrW()/2,200)
				p2:SetPos( ScrW()/4*3-p2:GetWide()/2,ScrH()/2-p2:GetTall()/2 )
				if cur ~= DPanel then
					p2:MoveToBack() 
				end
				function p2:Paint( w, h )
					draw.RoundedBox( 8, 0, 0, w, h, Color( c.r, c.g, c.b ) )
				end
				local l2 = vgui.Create( "DLabel", p2 )
				l2:SetFont( "DermaLarge" )
				l2:SetText( "Team Changed" ) -- Set the text of the label
				l2:SizeToContents() -- Size the label to fit the text in it
				l2:SetBright( true )
				l2:SetContentAlignment( 5 ) 
				l2:SetPos( -l2:GetWide()/2, p2:GetTall()/2-l2:GetTall()/2 )
				
				local b = 0
				function p1:Think()
					b = b+1
					p1:SetSize( p1:GetWide()-b,p1:GetTall() )
					l1:SetPos( p1:GetWide()-l1:GetWide()/2, p1:GetTall()/2-l1:GetTall()/2 )
					if p1:GetWide()-b <= 0 then
						p1:Remove()
					end
					p2:SetSize( p2:GetWide()-b,p2:GetTall() )
					p2:SetPos( ScrW()-p2:GetWide(),ScrH()/2-p2:GetTall()/2 )
					if p2:GetWide()-b <= 0 then
						p2:Remove()
					end
				end
				
				DPanel:Remove()
			end
			a = a+100
			
		end
		
		function DPanel:Paint( w, h )
			draw.RoundedBox( 8, 0, 0, w, h, Color( c.r, c.g, c.b ) )
		end
	end)

	net.Receive( "ChatPrint", function(length, ply)
		local text = net.ReadString()
		
		if TextLabel == nil then
			
			TextLabel = vgui.Create( "DLabel" )
			TextLabel:SetFont("DermaLarge")
			TextLabel:SetText( text )
			TextLabel:SizeToContents()
			TextLabel:SetPos( ScrW()/2-TextLabel:GetWide()/2,ScrH()/2-TextLabel:GetTall()/2 )
			timer.Simple( 5, function()
				if TextLabel ~= nil then
					TextLabel:Remove()
					TextLabel = nil
				end
			end)
		end
	end)
	net.Receive( "SetPlayerValue", function(length, ply)
	
		local name = net.ReadString()
		local value = net.ReadTable()
		
		if #value == 1 then
			LocalPlayer()[name] = value[1]
		else
			LocalPlayer()[name] = value
		end
	end)
	net.Receive( "graph", function(length, ply)
		local points = net.ReadTable()
	
		local frame = vgui.Create( "DPanel" )
		frame:SetSize( 1000, 400 )
		frame:SetPos( ScrW()/2-frame:GetWide()/2, ScrH()/2-frame:GetTall()/2 )
		frame:MakePopup()
		frame:SetMouseInputEnabled( true )
		frame:SetKeyboardInputEnabled( false )
		function frame:Paint(w,h)
			draw.RoundedBox( 8, 0, 0, w, h, Color(0,0,0,128) )
		end
		
		local button = vgui.Create( "DButton",frame )
		button:SetSize( 40, 20 )
		button:SetPos( frame:GetWide()-button:GetWide(), 0 )
		button:SetText( "X" )
		button:SetDark()
		button:SetFont("Trebuchet24")
		function button:Paint(w,h)
			local C = Color( 245, 20, 20, 255 )
			draw.RoundedBox( 8, 0, 0, w, h, C )
		end
		button.DoClick = function()
			frame:Remove()
		end
		
		local C = team.GetColor( LocalPlayer():Team() )
		local border = 5
		
		local color_box = vgui.Create( "DPanel",frame )
		color_box:SetSize( 100,100 )
		color_box:SetPos( 300,10 )
		function color_box:Paint(w,h)
			draw.RoundedBox( 8, 0, 0, w, h, Color(0,0,0,127) )
			draw.RoundedBox( 8, border, border, w-border*2, h-border*2, C )
		end
		
		local DLabel = vgui.Create( "DLabel", frame )
		DLabel:SetPos( color_box:GetWide()+300+10, 50 )
		DLabel:SetFont("DermaLarge")
		DLabel:SetText( "team is the winner!" )
		DLabel:SizeToContents()
		
		local grid = vgui.Create( "DPanel",frame )
		grid:SetSize( frame:GetWide()-10,275 )
		grid:SetPos( frame:GetWide()/2-grid:GetWide()/2,frame:GetTall()-grid:GetTall()-10 )
		function grid:Paint(w,h)
			draw.RoundedBox( 8, 0, 0, w, h, Color(255,255,255,128) )
			
			local transTable = {}
			local p_size = (w-border*2)/#points
			local p_size2 = (w-border*2)/(#points+#points-1)
			for i,v in pairs(points) do
				local max_players = 0
				for teamNum,players in pairs(v) do
					max_players = max_players+players
				end
				
				local y_offset = 0
				local sizePerPlayer = (h-border*2)/max_players
				for teamNum,players in pairs(v) do
					local tc = team.GetColor( teamNum )
					draw.RoundedBox( 0, p_size*(i-1)+border, y_offset+border, p_size2, players*sizePerPlayer, tc )
					y_offset = y_offset+players*sizePerPlayer
					
					if transTable[teamNum] == nil then transTable[teamNum] = {} end
					table.insert(transTable[teamNum],{ {p_size*(i-1)+border, y_offset+border}, {p_size*(i-1)+border, y_offset+border-players*sizePerPlayer}, {p_size*(i-1)+border+p_size2, y_offset+border}, {p_size*(i-1)+border+p_size2,y_offset+border-players*sizePerPlayer} })
				end
			end
			
			for i,v in pairs(transTable) do
				for n,f in pairs(v) do
					if n ~= #v then
						local vertices = {
							{x=f[4][1], y=f[4][2]},
							{x=v[n+1][2][1], y=v[n+1][2][2]},
							{x=v[n+1][1][1], y=v[n+1][1][2]},
							{x=f[3][1], y=f[3][2]},
						}
					
						local tc = team.GetColor( i )
						surface.SetDrawColor( tc )
						draw.NoTexture()
						surface.DrawPoly( vertices )
					end
				end
			end
		end
	end)
end

concommand.Add( "Pos", function( ply )
	local pos = ply:GetPos()
	print("Vector(" .. pos.x .. "," .. pos.y .. "," .. pos.z .. ")")
end)