AddCSLuaFile("cl_init.lua")--:SetCollisionGroup(COLLISION_GROUP_PLAYER)
AddCSLuaFile("shared.lua")
AddCSLuaFile("hud.lua")

include("shared.lua")
include("player.lua")
include("falldamage.lua")
include("maps/maps.lua")

util.AddNetworkString("TeamChanged")
util.AddNetworkString("SetPlayerValue")
util.AddNetworkString("ChatPrint")
util.AddNetworkString("TeamColorSync")
util.AddNetworkString("round")
util.AddNetworkString("power")
util.AddNetworkString("graph")

--prop_physics_create "props_borealis/bluebarrel001.mdl"

started = false

function SyncAllTeams(ply)
	for i=1,#team.GetAllTeams() do
		net.Start( "TeamColorSync" )
			net.WriteString( tostring(i) )
			net.WriteColor( team.GetColor( i ) )
		net.Send(ply)
	end
end

function TeamChanged(ply,TEAM)
	net.Start( "TeamChanged" )
		net.WriteString( tostring(TEAM) )
	net.Send( ply )
end

function SetPlayerValue( ply, name, value )
	net.Start( "SetPlayerValue" )
		net.WriteString(name)
		net.WriteTable(value)
	net.Send( ply )
	if #value == 1 then
		ply[name] = value[1]
	else
		ply[name] = value
	end
end

function GM:PlayerDeathThink( ply )
end

function GM:Initialize()
end

function SpawnRandomPosition()
	local maps = getMaps()
	local map = game.GetMap()
	local map_index = maps[map]
	if map_index ~= nil then
		return table.Random( map_index )
	else
		return false
	end
end

function GM:PlayerConnect( name, ip )
	addDataPoint()
	print( name .. ", has joined the game.")
end

function GM:ShouldCollide( ent1,ent2 )
	if ent1:IsPlayer() and ent2:IsPlayer() then
		if ent1:Team() == ent2:Team() then
			return false
		end
	end
	return true
end

function setRandomTeam(ply) 
	TEAMS = {1}
	AMOUNT = 10000
	for i=1,#team.GetAllTeams() do
		local players = #team.GetPlayers( i )

		if players < AMOUNT then
			TEAMS = {i}
			AMOUNT = players
		elseif players == AMOUNT then
			table.insert(TEAMS,i)
		end
	end
	ply:SetTeam( table.Random( TEAMS ) )
end

function GM:PlayerInitialSpawn( ply )
	ply:SetCustomCollisionCheck( true )
	
	local roundNum = GetGlobalInt( "roundNum", 0 )
	if roundnum ~= -1 then
		setRandomTeam(ply) 
	else
		for i=1,#team.GetAllTeams() do
			if team.NumPlayers( i ) > 0 then
				ply:SetTeam(i)
				break;
			end
		end
	end
	ply:SetNWString("Primary","weapon_smg")
	ply:SetNWString("Secondary","weapon_cpistol")
	ply:SetNWString("Power","power_ammogen")
	ply:SetNWInt("MaxHealth",10)
	ply:SetNWInt("PowerWait",0)
end

function GM:PlayerSpawn( ply )
	ply:AllowFlashlight( true )
	ply:SetGModeTeam( ply:Team() )
	if ply:GetNWString("PlyModel") == nil or ply:GetNWString("PlyModel") == "" then
		ply:SetGModeModel()
	end
	ply:SetModel(ply:GetNWString("PlyModel"))
	
	ply:RemoveAllAmmo() 
	
	local roundNum = GetGlobalInt( "roundNum", 0 )
	if roundNum ~= -1 then
		ply:GiveGModeWeps()
		ply:RemoveAllAmmo() 
		
		ply:GiveAmmo( 1, "slam", true )
		ply:GiveAmmo( 3, "grenade", true )
		ply:GiveAmmo( 80, "pistol", true )
		ply:GiveAmmo( 250, "smg1", true )
		ply:GiveAmmo( 2, "RPG_round", true )
	else
		ply:GiveBreakWeps()
	end
	
	ply:SetHealth( 10 )
	
	local pos = ply:GetNWVector("pos",nil)
	local ang = ply:GetNWAngle("ang",nil)
	if pos ~= Vector(0,0,0) and ang ~= Vector(0,0,0) then
		ply:SetPos(pos)
		ply:SetEyeAngles( ang )
		
		ply:SetNWVector("pos",nil)
		ply:SetNWAngle("ang",nil)
	else
		local POS = SpawnRandomPosition(ply)
		if POS ~= false then
			ply:SetPos(POS)
		end
	end
end


----------------------------------------------------------------------
-------------------------No team killing------------------------------
----------------------------------------------------------------------

function GM:PlayerShouldTakeDamage( ply, attacker )
	if ply ~= attacker and ply:IsPlayer() then
		if attacker:IsPlayer() then
			if ply:Team() == attacker:Team() then
				return false
			else return true
			end
		elseif attacker:IsNPC() and attacker["Team"] ~= nil then
			if ply:Team() == attacker["Team"] then
				return false
			else return true
			end
		end
	else return true
	end
	
	return true
end











function GM:PlayerSetHandsModel( ply, ent )

	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end

end

function GM:PlayerAuthed( ply, steamID, uniqueID )
end

function GM:Think()
	net.Receive( "power", function( len, ply )
		local p = ply:GetNWString("Power")
		local t = ply:GetNWInt("PowerWait")
		local roundNum = GetGlobalInt( "roundNum", 0 )
		if roundNum == -1 then
			p = "power_celebrate"
		end
		if t <= 0 then
			if p == "power_healthgen" then
				if ply:Health() < 10 then
					ply:SetHealth( ply:Health()+1 )
				end
			elseif p == "power_ammogen" then
				ply:GiveAmmo( 1, "slam", true )
				ply:GiveAmmo( 3, "grenade", true )
				ply:GiveAmmo( 80, "pistol", true )
				ply:GiveAmmo( 250, "smg1", true )
				ply:GiveAmmo( 2, "RPG_round", true )
			elseif p == "power_explode" then
				util.BlastDamage(ply, ply, ply:GetPos(), 300, 50)
				local fx = EffectData()
				fx:SetOrigin(ply:GetPos())
				util.Effect("Explosion", fx)
			elseif p == "power_celebrate" then
				ply:EmitSound( Sound("horn0" .. math.random(1,5)) )
				local fx = EffectData()
				fx:SetOrigin(ply:GetPos()+Vector(0,0,32))
				util.Effect("confetti", fx)
			elseif p == "power_manhack" then
				local manhack = ents.Create("npc_manhack")
				manhack:Spawn()
				manhack:SetPos(ply:GetShootPos()+ply:GetAimVector()*50)
				manhack:SetSubMaterial(1,"models/debug/debugwhite")
				manhack:SetColor( team.GetColor( ply:Team() ) )
				manhack:SetHealth(5)
				manhack:Activate()
				manhack["Team"] = ply:Team()
				manhack:SetAngles( ply:GetAimVector():Angle() )
				timer.Create("manhack_break" .. tostring(manhack), 30,1,function() 
					hook.Remove( "PlayerDeath", tostring(manhack) )
					manhack:TakeDamage( 1000 )
				end)
				for i,v in pairs(player.GetAll()) do
					if v:Team() == ply:Team() then
						manhack:AddEntityRelationship( v, D_LI, 99 )
					else
						manhack:AddEntityRelationship( v, D_HT, 99 )
					end
				end
				hook.Add( "PlayerDeath", tostring(manhack), function()
					for i,v in pairs(player.GetAll()) do
						if v:Team() == ply:Team() then
							manhack:AddEntityRelationship( v, D_LI, 99 )
						else
							manhack:AddEntityRelationship( v, D_HT, 99 )
						end
					end
				end)
			elseif p == "power_mine" then
				local mine = ents.Create("combine_mine")
				mine:Spawn()
				mine:SetPos(ply:GetShootPos()+ply:GetAimVector()*50)
				mine:SetAngles( ply:GetAimVector():Angle() )
				mine:SetMaterial("models/debug/debugwhite")
				mine:SetColor( team.GetColor( ply:Team() ) )
				mine:Activate()
				mine.Owner = ply
				mine["Team"] = ply:Team()
				timer.Create("12323", 10,1,function() 
					PrintTable(mine:GetSaveTable())
					PrintTable(mine:GetMaterials())
				end)
				--m_hNearestNPC	=	Player [1][Christmas Cactus]
				--m_iTeamNum	=	0
				--m_bPlacedByPlayer	=	false
				--m_vecAbsVelocity	=	0.000000 0.000000 0.000000
				mine:SetSaveValue( "m_iTeamNum", ply:Team() )
				local angle = mine:GetAngles()
				mine:SetSaveValue( "m_vecAbsVelocity", angle:Forward()*1000 )
				local function onThink()
					if  IsValid(mine) then
						local nearest = mine:GetSaveTable()["m_hNearestNPC"]
						if nearest:IsPlayer() then
							if nearest:Team() ~= mine:GetSaveTable()["m_iTeamNum"] then
								mine:SetSaveValue( "m_bFoeNearest", true )
								mine:SetSaveValue( "m_iMineState", 4 )
							else
								mine:SetSaveValue( "m_bFoeNearest", false )
							end
						end
						if mine:GetSaveTable()["m_iMineState"] == 4 then
							hook.Remove( "Think", tostring(mine) )
						end
					end
				end
				
				hook.Add( "Think", tostring(mine), onThink )
			elseif p == "power_trackers" then
				for i=1,5 do
					local ang = ply:GetAngles()
					ang:RotateAroundAxis( ang:Up(), 360/5*i )
					local tracker = ents.Create("ent_flyer")
					tracker.Owner = ply
					tracker:Spawn()
					constraint.NoCollide( tracker, ply, 0, 0 )
					tracker:SetAngles( ang )
					tracker:SetPos( ply:GetPos() + Vector(0,0,64) + tracker:GetAngles():Forward()*10 )
					tracker:GetPhysicsObject():AddVelocity( ang:Forward()*500 )
				end
			elseif p == "power_tether" then
				local ang = ply:EyeAngles()
				ang:RotateAroundAxis( ply:EyeAngles():Right(), 90 )
				local ang2 = ply:EyeAngles()
				
				local tracker = ents.Create("ent_arrow")
				tracker.Owner = ply
				tracker:Spawn()
				constraint.NoCollide( tracker, ply, 0, 0 )
				tracker:SetAngles( ang )
				tracker:SetPos( ply:GetPos() + Vector(0,0,32) + tracker:GetAngles():Forward()*10 )
				tracker:GetPhysicsObject():AddVelocity( ang2:Forward()*500 )
			elseif p == "power_magnets" then
				for i=1,5 do
					local ang = ply:GetAngles()
					ang:RotateAroundAxis( ang:Up(), 90/5*i-45 )
					local magnet = ents.Create("ent_magnets")
					magnet.Owner = ply
					magnet:Spawn()
					constraint.NoCollide( magnet, ply, 0, 0 )
					magnet:SetAngles( ang )
					magnet:SetPos( ply:GetPos() + Vector(0,0,64) + magnet:GetAngles():Forward()*10 )
					magnet:GetPhysicsObject():AddVelocity( magnet:GetAngles():Forward()*800 )
				end
			elseif p == "power_groupheal" then
				local ang = ply:EyeAngles()
				local magnet = ents.Create("ent_healthbox")
				magnet.Owner = ply
				magnet:Spawn()
				magnet:SetAngles( ang )
				magnet:SetPos( ply:GetPos() + Vector(0,0,55) + magnet:GetAngles():Forward()*10 )
				magnet:GetPhysicsObject():AddVelocity( magnet:GetAngles():Forward()*400 )
			elseif p == "power_damagestealer" then
				for i=1,5 do
					local ang = ply:GetAngles()
					ang:RotateAroundAxis( ang:Up(), 90/5*i-45 )
					local magnet = ents.Create("ent_sponge")
					magnet.Owner = ply
					magnet:Spawn()
					constraint.NoCollide( magnet, ply, 0, 0 )
					magnet:SetAngles( ang )
					magnet:SetPos( ply:GetPos() + Vector(0,0,64) + magnet:GetAngles():Forward()*10 )
					magnet:GetPhysicsObject():AddVelocity( magnet:GetAngles():Forward()*800 )
				end
			end
			ply:SetNWInt("PowerWait",times[p])
		end
	end)
	local roundNum = GetGlobalInt( "roundNum", 0 )
	if roundNum == 0 then
		round.SetUp()
	elseif roundNum == 1 then
		round.check()
	elseif roundNum == -1 then
		for i,v in pairs(player.GetAll()) do
			local t = v:GetNWInt("PowerWait")
			if t > times["power_celebrate"] then
				v:SetNWInt("PowerWait",times["power_celebrate"])
			end
		end
	end
end






-----------------------------------------
------------SYSTEM EVENTS----------------
-----------------------------------------

function GM:PlayerDeath( victim, inflictor, attacker )
	if (attacker:IsPlayer() == true or (attacker:IsNPC() == true and attacker["Team"] ~= nil)) and attacker ~= victim then
		local pos = victim:GetPos()
		local ang = victim:EyeAngles()
		
		if attacker:IsPlayer() == true then
			victim:SetTeam( attacker:Team() )
		else
			victim:SetTeam( attacker["Team"] )
			for i,v in pairs(player.GetAll()) do
				if v:Team() == attacker["Team"] then
					attacker:AddEntityRelationship( v, D_LI, 99 )
				else
					attacker:AddEntityRelationship( v, D_HT, 99 )
				end
			end
		end
		
		victim:SetNWVector("pos",pos)
		victim:SetNWAngle("ang",ang)
		
		if IsValid(victim.sponge) then
			victim:SetTeam( victim.sponge.Team )
			SafeRemoveEntity(victim.sponge)
			victim.sponge = nil
		end
		
		timer.Simple( 0.00001, function()
			victim:Spawn()
			TeamChanged(victim,victim:Team())
		end)
		addDataPoint()
	else
		timer.Simple( 3, function()
			victim:Spawn()
		end)
	end
end

function GM:OnNPCKilled( npc, attacker, inflictor )
end

function GM:PlayerDisconnected( ply )
	addDataPoint()
end

function GM:ShowSpare2( ply )
	ply:ConCommand( "shop" )
end

concommand.Add( "AddPos", function( ply, cmd, args )
	if ply:IsAdmin() then
		local map = args[1]
		local pos = Vector( args[2],args[3],args[4] )
		local MAPS = getMaps()
		if MAPS[map] == nil then
			MAPS[map] = {}
		end
		table.insert(MAPS[map],pos)
		print(args[1],args[2],args[3])
	end
end)