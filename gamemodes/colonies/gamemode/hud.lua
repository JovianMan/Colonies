HL2_WEAPONS_TABLE = {
    weapon_physcannon   = { MaxAmmo = 0;    AmmoType = "PhysCannon" };
    weapon_physgun      = { MaxAmmo = 0;    AmmoType = "PhysGun" };
    gmod_tool           = { MaxAmmo = 0;    AmmoType = "Tool" };

    weapon_crowbar      = { MaxAmmo = 0;    AmmoType = "Melee" };
    weapon_pistol       = { MaxAmmo = 18;   AmmoType = "Pistol" };
    weapon_357          = { MaxAmmo = 6;    AmmoType = "Pistol" };
    weapon_smg1         = { MaxAmmo = 45;   AmmoType = "SMG1", SecondaryAmmoType = "SMG1_Grenade" };
    weapon_ar2          = { MaxAmmo = 30;   AmmoType = "Rifle", SecondaryAmmoType = "CombineBall" };
    weapon_crossbow     = { MaxAmmo = 1;    AmmoType = "Bolts" };
    weapon_frag         = { MaxAmmo = 1;    AmmoType = "Grenade" };
    weapon_rpg          = { MaxAmmo = 1;    AmmoType = "RPG" };
    weapon_shotgun      = { MaxAmmo = 6;    AmmoType = "Shotgun" };
}

function HideHUD( hud )
	for k,v in pairs{"CHudAmmo","CHudHealth"} do
		if hud == v then
			return false;
		end
	end
end
hook.Add("HUDShouldDraw","HideHUD",HideHUD)

local strands = {}
for i=1,5 do
	local strand = {}
	table.insert(strand,{
		x1 = math.random(50),
		y1 = ScrH()-math.random(50),
		x2 = math.random(50),
		y2 = ScrH()-math.random(50),
	})
	local past_theta = math.atan( (strand[1].y2-strand[1].y1)/(strand[1].x2-strand[1].x1) )*57.2957795
	for n=2,5 do
		local h = math.random(30,100)
	
		local a = {}
		a.x1 = strand[n-1].x2
		a.y1 = strand[n-1].y2
		
		local theta = past_theta+math.random(-10,10)
		
		a.x2 = strand[n-1].x2+math.cos( theta/57.2957795 )*h
		a.x2 = math.max(a.x2,0)
		
		a.y2 = strand[n-1].y2+math.sin( theta/57.2957795 )*h
		a.y2 = math.min(a.y2,ScrH())
		
		local dist = math.sqrt( (a.x2-20)^2 + (a.y2-(ScrH()-20))^2 )
		local m = 30
		if dist > m then
			local THETA = math.atan(((ScrH()-20)-a.y2)/(20-a.x2))*57.2957795
			
			a.x2 = 20+math.cos(THETA/57.2957795)*m
			a.y2 = (ScrH()-20)+math.sin(THETA/57.2957795)*m
		end
		
		table.insert(strand,a)
		
		past_theta = theta
	end
	table.insert(strands,strand)
end

local o = 0
function HealthBar()
	o = o+1

	local maxHealth = LocalPlayer():GetNWInt("MaxHealth")
	local health = LocalPlayer():Health()/maxHealth*100
	local c = Color(255*( (-health+100)/100 ),255*(health/100),0,255)
	local tc = team.GetColor( LocalPlayer():Team() )
	
	
	local amount = 4
	local layers = {}
	
	for i=1,amount do
		table.insert(layers,{})
	end

	local circle_background = {}
	local circle2 = { {x=20,y=ScrH()-20} }
	
	local triangles = 30
	local anglePerTri = 360/triangles
	local h = 70
	local d = (h/amount)^(2/3)
	for f=1,amount do
		for i=0,triangles do
			local theta = i*anglePerTri-90
			local x1 = math.cos(theta/57.2957792)*(h-10+math.sin(o/(f*20))*2+math.sin(o/(f*20+(health/10)))*math.random(-10,10)/(1+(health/5))-d*f)
			local y1 = math.sin(theta/57.2957792)*(h-10+math.sin(o/(f*20))*2+math.sin(o/(f*20+(health/10)))*math.random(-10,10)/(1+(health/5))-d*f)
			
			table.insert(layers[f], {x=x1+20,y=y1+ScrH()-20} )
		end
	end
	
	local h = 60
	anglePerTri = anglePerTri*0.37
	for i=0,triangles do
		local theta = -(130*(health/100)-20)+i*anglePerTri

		local x1 = math.cos(theta/57.2957792)*(h+10)
		local y1 = math.sin(theta/57.2957792)*(h+10)
		
		table.insert(circle2, {x=x1+20,y=y1+ScrH()-20} )
	end
	
	triangles = 40
	local anglePerTri2 = 360/triangles+4
	for i=0,triangles do
		if i < triangles/2 then
			local theta = i*anglePerTri2-110

			local x1 = math.cos(theta/57.2957792)*(h+10)
			local y1 = math.sin(theta/57.2957792)*(h+10)
			
			table.insert(circle_background, {x=x1+20,y=y1+ScrH()-20} )
		else
			local theta = (i-triangles/2)*anglePerTri2-110

			local x1 = math.cos(theta/57.2957792)*(h)
			local y1 = math.sin(theta/57.2957792)*(h)
			
			table.insert(circle_background, {x=x1+20,y=y1+ScrH()-20} )
		end
	end
	
	
	for i=1,triangles/2 do
		local p1 = circle_background[i]
		local p2 = circle_background[i+1]
		local p3 = circle_background[i+triangles/2]
		local p4 = circle_background[i+triangles/2+1]

		surface.SetDrawColor( 70,70,70, 255 )
		draw.NoTexture()
		surface.DrawPoly( {p2,p3,p1} )
		surface.DrawPoly( {p2,p4,p3} )
	end
	
	for i=11-health/10,triangles/2 do
		local p1 = circle_background[i]
		local p2 = circle_background[i+1]
		local p3 = circle_background[i+triangles/2]
		local p4 = circle_background[i+triangles/2+1]

		local a = 0.9
		local b = 0.1
		c = Color( c.r*a + tc.r*b, c.g*a + tc.g*b, c.b*a + tc.b*b )
		
		surface.SetDrawColor( c.r, c.g, c.b, 255 )
		draw.NoTexture()
		surface.DrawPoly( {p2,p3,p1} )
		surface.DrawPoly( {p2,p4,p3} )
	end
	
	local k = 255/amount
	for i,v in pairs(layers) do
		local f = 80/amount+(math.sin(o/(i*20))-1)*2
		surface.SetDrawColor( tc.r-f*(i-1), tc.g-f*(i-1), tc.b-f*(i-1), 255-k*(i-1) )
		draw.NoTexture()
		surface.DrawPoly( v )
		if i==#layers-1 then
			for i,v in pairs(strands) do
				for n,f in pairs(v) do
					f.x2 = f.x2+math.random(-10,10)/10-math.sin(o/(1+health))*math.random(-10,10)/10*(8-(health/100)*8)
					f.y2 = f.y2+math.random(-10,10)/10-math.sin(o/(1+health))*math.random(-10,10)/10*(8-(health/100)*8)
					if n+1 <= #v then
						v[n+1].x1 = f.x2
						v[n+1].y1 = f.y2
					end
				
					local dist = math.sqrt( (f.x2-20)^2 + (f.y2-(ScrH()-20))^2 )
					local m = 30
					if dist > m then
						local THETA = math.atan(((ScrH()-20)-f.y2)/(20-f.x2))*57.2957795
						
						f.x2 = 20+math.cos(THETA/57.2957795)*m
						f.y2 = (ScrH()-20)+math.sin(THETA/57.2957795)*m
					end
				
					surface.SetDrawColor( tc.r*0.25+255*0.75,tc.g*0.25+255*0.75,tc.b*0.25+255*0.75,175+(math.sin(o/100)-1)*50 - n*20 )
					surface.DrawLine( f.x1, f.y1, f.x2, f.y2 )
				end
			end
		end
	end
end
hook.Add("HUDPaint","HealthBar",HealthBar)

function AmmoCounter()
	local c = team.GetColor( LocalPlayer():Team() )

	current_weapon = LocalPlayer():GetActiveWeapon()
	
	if !current_weapon:IsValid() then return; end
	
	weapon_currentclip1 = current_weapon:Clip1()
	weapon_currentclip2 = current_weapon:Clip2()
	
	local i = "a"
	local ammo = 0
	local f = false
	local a = false
	if current_weapon:GetPrintName()  == "Crowbar" then
		i = "6"
		a = true
		f = true
	elseif current_weapon:GetPrintName()  == "Pistol" then
		i = "-"
		ammo = LocalPlayer():GetAmmoCount( "pistol" )
	elseif current_weapon:GetPrintName()  == "Revolver" then
		i = "."
		ammo = LocalPlayer():GetAmmoCount( "pistol" )
	elseif current_weapon:GetPrintName()  == "SMG" then
		i = "/"
		ammo = LocalPlayer():GetAmmoCount( "smg1" )
	elseif current_weapon:GetPrintName()  == "Burst Rifle" then
		i = "2"
		ammo = LocalPlayer():GetAmmoCount( "smg1" )
	elseif current_weapon:GetPrintName()  == "Rocket Launcher" then
		i = "3"
		ammo = LocalPlayer():GetAmmoCount( "RPG_Round" )
	elseif current_weapon:GetPrintName()  == "Spore Grenade" or current_weapon:GetPrintName()  == "Barricade Grenade" then
		i = "4"
		f = true
		if current_weapon:GetPrintName()  == "Spore Grenade" then
			ammo = LocalPlayer():GetAmmoCount( "slam" )
		else
			ammo = LocalPlayer():GetAmmoCount( "grenade" )
		end
	elseif current_weapon:GetPrintName() == "Fireworks Gun" then
		i = "/"
		a = true
		f = true
	elseif current_weapon:GetPrintName() == "Confetti Blaster" then
		i = "0"
		a = true
		f = true
	end
	
	local base = {}
	base.size = {
		x = 105,
		y = 50,
	}
	base.position = {
		x = ScrW()-105, 
		y = ScrH()-80,
	}
	
	draw.RoundedBox( 0, base.position.x,base.position.y, base.size.x,base.size.y, Color(0,0,0,128) ) 
	
	draw.RoundedBox( 8, ScrW()-100, base.position.y+5, 100, 40, Color(c.r,c.g,c.b,255) ) 
	
	draw.SimpleText( i, "HL2MPTypeDeath", ScrW()-100+50, base.position.y+40, Color(255,255,255,255), 1, 1 ) 
	
	if a == false then
		draw.RoundedBox( 0, base.position.x-85-10, base.position.y, 95, 50, Color(0,0,0,128) ) 
	
		draw.RoundedBox( 8, base.position.x-85-5, base.position.y+5, 85, 40, Color(c.r,c.g,c.b,255) ) 
		
		draw.SimpleText( ammo, "CloseCaption_Bold", base.position.x-47, base.position.y+23, Color(255,255,255,255), 1, 1 )
	end
	
	local bullet = {}
	bullet.size = {
		x = 5,
		y = 15,
	}
	local border = 5
	if f == false then
		local clip = weapon_currentclip1
		local filled_clip = current_weapon.Primary.ClipSize
		
		local size = (bullet.size.x+border)*filled_clip+border
		
		draw.RoundedBox( 8, ScrW()-size-border, ScrH()-30, size+border+10, 30+10, Color(0,0,0,128) ) 
		
		draw.RoundedBox( 0, ScrW()-size, ScrH()-25, size, 25, Color(c.r,c.g,c.b,255) ) 
		
		for i=1,clip do
			draw.RoundedBox( 0, ScrW()-(bullet.size.x+border)*i, ScrH()-bullet.size.y-border, bullet.size.x, bullet.size.y, Color(255,255,255,255) ) 
		end
	end
end
hook.Add("HUDPaint","AmmoCounter",AmmoCounter)


local tab = nil
function GM:ScoreboardShow()
	tab = vgui.Create( "DPanel" )
	tab:SetPos( ScrW()/4, ScrH()/4 )
	tab:SetSize( ScrW()/2, ScrH()/2 )
	tab:MakePopup()
	tab:SetMouseInputEnabled( true )
	tab:SetKeyboardInputEnabled( false )
	function tab:Paint(w,h)
		draw.RoundedBox( 8, 0, 0, w, h, Color(0,0,0,128) )
	end
	
	local DScrollPanel = vgui.Create( "DScrollPanel",tab )
	DScrollPanel:SetSize( tab:GetWide(),tab:GetTall() )
	DScrollPanel:SetPos( 0, 0 )

	local c = team.GetColor( LocalPlayer():Team() )--Color( 200,100,0,255 )
	local rc = Color( 255-c.r,255-c.g,255-c.b,255 )
	
	local sbar = DScrollPanel:GetVBar()
	sbar:SetSize(10,sbar:GetTall())
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, rc )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, rc )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 4, 0, 0, w, h, c )
	end
	
	local y = 0
	for i=1,#team.GetAllTeams() do
		if #team.GetPlayers( i ) > 0 then
			local TEAM = vgui.Create( "DPanel",DScrollPanel )
			TEAM:SetSize( DScrollPanel:GetWide(),24*math.max(1,#team.GetPlayers( i ))+20 )
			TEAM:SetPos( 0, y )
			function TEAM:Paint(w,h)
				draw.RoundedBox( 8, 0, 0, w, h, team.GetColor(i) )
			end

			for i,v in pairs(team.GetPlayers( i )) do
				local PlyLabel = vgui.Create( "DLabel", TEAM )
				PlyLabel:SetFont("Trebuchet24")
				PlyLabel:SetText( v:Nick() )
				PlyLabel:SizeToContents()
				PlyLabel:SetPos( 10, PlyLabel:GetTall()*(i-1)+10 )
				
				local C = team.GetColor( v:Team() )
				local RC = Color( 255-C.r,255-C.g,255-C.b,255 )
				
				local h1 = 0.6
				local h2 = 0.4
				local Hybrid = Color( C.r*h1+RC.r*h2,C.g*h1+RC.g*h2,C.b*h1+RC.b*h2 )
				
				PlyLabel:SetColor( Hybrid )
			end
			
			local DProgress = vgui.Create( "DProgress",TEAM )
			DProgress:SetSize( TEAM:GetWide()/4, 20 )
			DProgress:SetPos( TEAM:GetWide()/4*3-DProgress:GetWide()/2, TEAM:GetTall()/2-10 )
			DProgress:SetFraction( #team.GetPlayers( i )/#player.GetAll() )

			y = y+TEAM:GetTall()
			DScrollPanel:AddItem( TEAM )
		end
	end
end

function GM:ScoreboardHide()
	tab:SetMouseInputEnabled( false )
	tab:Remove()
	tab = nil
end

local frame = nil
local options_1 = {
	"weapon_smg",
	"weapon_burst",
	"weapon_rocket",
}
local options_2 = {
	"weapon_cpistol",
	"weapon_ccrowbar",
	"weapon_revolver",
}

local ta = 165
local ma = 10
function Power()
	local p = LocalPlayer():GetNWString("Power")
	local t = LocalPlayer():GetNWInt("PowerWait")
	local c = team.GetColor( LocalPlayer():Team() )
	local roundNum = GetGlobalInt( "roundNum", 0 )
	if roundNum == -1 then
		p = "power_celebrate"
	end
	
	if ta > 0 and t <= 0 then
		ta = ta-ma
		if ta <= 0 then
			ta = 0
		end
	elseif ta < 165 and t > 0 then
		ta = ta+ma
		if ta >= 165 then
			ta = 165
		end
	end
	
	local size = Vector(210,75,0)
	local pos = Vector(ScrW()-200+ta,ScrH()-165,0)
	
	draw.RoundedBox( 0, pos.x, pos.y, size.x, size.y, Color(0,0,0,127) )
	draw.RoundedBox( 8, pos.x+5+30, pos.y+5, size.x-10-30, size.y-10, c )
	draw.RoundedBox( 8, pos.x+5, pos.y+5, size.x-10-175, size.y-10, c )
	draw.SimpleText( "[G] to ", "HudHintTextLarge", pos.x+120, pos.y+20, Color(255,255,255,255), 1, 1 )
	draw.SimpleText( labels[p], "CloseCaption_Bold", pos.x+120, pos.y+45, Color(255,255,255,255), 1, 1 )

	draw.SimpleText( math.floor(t/100), "CloseCaption_Bold", pos.x+17, pos.y+17, Color(255,255,255,255), 1, 1 )
	draw.SimpleText( (math.floor(t/10)*10-math.floor(t/100)*100)/10, "CloseCaption_Bold", pos.x+17, pos.y+36, Color(255,255,255,255), 1, 1 )
	draw.SimpleText( t-math.floor(t/10)*10, "CloseCaption_Bold", pos.x+17, pos.y+55, Color(255,255,255,255), 1, 1 )
end
hook.Add("HUDPaint","Power",Power)


function createShop()
	frame = vgui.Create( "DPanel" )
	frame:SetSize( 50+250*3, 200 )
	frame:SetPos( ScrW()/2-frame:GetWide()/2, ScrH()/2-frame:GetTall()/2 )
	frame:MakePopup()
	frame:SetMouseInputEnabled( true )
	frame:SetKeyboardInputEnabled( false )
	function frame:Paint(w,h)
		draw.RoundedBox( 8, 0, 0, w, h, Color(0,0,0,128) )
	end
	
	for n=1,3 do
		local options = options_1
		if n==2 then
			options = options_2
		elseif n == 3 then
			options = options_3
		end
		local DScrollPanel = vgui.Create( "DScrollPanel",frame )
		DScrollPanel:SetSize( 200,frame:GetTall()-100 )
		DScrollPanel:SetPos( 50+250*(n-1), 50 )

		local c = Color( 245, 70, 70 ,255 )
		
		local sbar = DScrollPanel:GetVBar()
		sbar:SetSize(10,sbar:GetTall())
		function sbar:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
		end
		function sbar.btnUp:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, c )
		end
		function sbar.btnDown:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, c )
		end
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 4, 0, 0, w, h, c )
		end
		local panel = vgui.Create( "DPanel",DScrollPanel )
		panel:SetPos( 0, 0 )
		panel:SetSize( 200, DScrollPanel:GetTall() )
		function panel:Paint(w,h)
			draw.RoundedBox( 8, 0, 0, w, h, Color(0,0,0,128) )
		end
		
		for i,v in pairs(options) do
			local button = vgui.Create( "DButton",panel )
			button:SetPos( 0, 100*(i-1) )
			button:SetSize( DScrollPanel:GetWide(), 100 )
			
			
			local i = "_"
			if v  == "weapon_ccrowbar" then
				i = "6"
			elseif v  == "weapon_cpistol" then
				i = "-"
			elseif v  == "weapon_smg" then
				i = "/"
			elseif v == "weapon_rocket" then
				i = "3"
			elseif v == "weapon_burst" then
				i = "2"
			elseif v == "weapon_revolver" then
				i = "."
			elseif v  == "grenade_spores" or v  == "grenade_barricade" then
				i = "4"
			elseif n == 3 then
				i = "8"
			end
			
			button:SetText( "" )
			function button:Paint(w,h)
				local C = Color( 20, 150, 245 ,255 )
				local i = "Primary"
				if n==2 then
					i = "Secondary"
				elseif n==3 then
					i = "Power"
				end
				if v == LocalPlayer():GetNWString(i) then
					C = Color( 245, 170, 40 ,255 )
				end
				draw.RoundedBox( 8, 0, 0, w, h, C )
				if n==3 then
					draw.SimpleText( names[v], "Trebuchet24", 100, 75, Color(255,255,255,255), 1, 1 ) 
				end
			end
			button.DoClick = function()
				if n == 1 then
					SetPlayerValue("Primary",{v})
				elseif n == 2 then
					SetPlayerValue("Secondary",{v})
				elseif n == 3 then
					SetPlayerValue("Power",{v})
					SetPlayerValue( "PowerWait",{times[v]} )
				end
			end
			
			local DLabel = vgui.Create( "DLabel", button )
			DLabel:SetPos( 60, 30 )
			DLabel:SetFont("HL2MPTypeDeath")
			DLabel:SetText( i )
			DLabel:SizeToContents()
			DLabel:SetBright()
			
			DScrollPanel:AddItem( button )
		end
	end
end

function OpenShop()
	if frame ~= nil then
		if frame:IsValid() == true then
			frame:Remove()--frame:Close()
			frame = nil
		else
			createShop()
		end
	else
		createShop()
	end
end

concommand.Add("shop", OpenShop)