GM.Name = "Colonies"
GM.Author = "Ryan Reed"
GM.Email = ""
GM.Website = ""

SetGlobalBool( "c", false )
for i=1,game.MaxPlayers() do
	if SERVER then
		print(i,"TEAMS")
		local c = Color(math.random(255), math.random(255), math.random(255),255)
		SetGlobalVector( tostring(i), Vector(c.r,c.g,c.b) ) 
		team.SetUp( i, "", c )
	end
end

data_points = {}
function addDataPoint()
	local tab = {}
	for i=1,#team.GetAllTeams() do
		tab[i] = #team.GetPlayers( i )
	end
	table.insert(data_points,tab)
end

GAMEMODE_NAME = GM.Name

sound.Add( {
	name = "horn01",
	channel = CHAN_VOICE2,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "horns/horn01.wav"
} )
sound.Add( {
	name = "horn02",
	channel = CHAN_VOICE2,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "horns/horn02.wav"
} )
sound.Add( {
	name = "horn03",
	channel = CHAN_VOICE2,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "horns/horn03.wav"
} )
sound.Add( {
	name = "horn04",
	channel = CHAN_VOICE2,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "horns/horn04.wav"
} )
sound.Add( {
	name = "horn05",
	channel = CHAN_VOICE2,
	volume = 1.0,
	level = 80,
	pitch = { 95, 110 },
	sound = "horns/horn05.wav"
} )

options_3 = {
	"power_healthgen",
	"power_ammogen",
	"power_explode",
	"power_manhack",
	--"power_mine",
	--"power_tether",
	"power_trackers",
	"power_groupheal",
	"power_damagestealer",
	"power_magnets",
}
names = {}
names["power_healthgen"] = "Health Regen"
names["power_ammogen"] = "Ammo Regen"
names["power_explode"] = "Kamikaze"
names["power_celebrate"] = "CELEBRATE!"
names["power_manhack"] = "Manhack"
--names["power_mine"] = "Mine"
--names["power_tether"] = "Tether"
names["power_trackers"] = "Trackers"
names["power_groupheal"] = "Group Heal"
names["power_damagestealer"] = "Damage Stealer"
names["power_magnets"] = "Magnets"

labels = {}
labels["power_healthgen"] = "Regen Health"
labels["power_ammogen"] = "Regen Ammo"
labels["power_explode"] = "Kamikaze"
labels["power_celebrate"] = "CELEBRATE!"
labels["power_manhack"] = "throw Manhack"
--labels["power_mine"] = "place Mine"
--labels["power_tether"] = "shoot Tether"
labels["power_trackers"] = "launch Trackers"
labels["power_groupheal"] = "Heal Group"
labels["power_damagestealer"] = "launch Sponges"
labels["power_magnets"] = "fire Magnets"

times = {}
times["power_healthgen"] = 20
times["power_ammogen"] = 60
times["power_explode"] = 100
times["power_celebrate"] = 3
times["power_manhack"] = 60
--times["power_mine"] = 1
--times["power_tether"] = 1
times["power_trackers"] = 45
times["power_groupheal"] = 100
times["power_damagestealer"] = 50
times["power_magnets"] = 30


function Think()
	net.Receive( "SetPlayerValue", function( length, ply )	
		local name = net.ReadString()
		local value = net.ReadTable()
		if #value == 1 then
			ply[name] = value[1]
			ply:SetNWString(name,value[1])
		else
			ply[name] = value
		end
	end)
end
hook.Add( "Think", "", Think() )


function GM:Initialize()
	self.BaseClass.Initialize( self )
end

function GM:SpawnMenuEnabled()
	return false;
end





round = {}

-- Variables
round.Break	= 30		-- 30 second breaks
round.RoundsPlayed = 0

SetGlobalInt( "roundNum", 0 )

hook.Add( "Think", "Some unique name", onThink )
function round.SetValue(name,value,ply)
	ply:SetNWInt(name,value)
end


function round.Broadcast(Text)
	for k, v in pairs(player.GetAll()) do
		net.Start( "ChatPrint" )
			net.WriteString(Text)
		net.Send( v )
	end
end

function round.RecolorTeams()
	for i=1,game.MaxPlayers() do
		local c = Color(math.random(255), math.random(255), math.random(255),255)
		SetGlobalVector( tostring(i), Vector(c.r,c.g,c.b) ) 
		team.SetColor(i,c)
	end
	SetGlobalBool( "c", false )
end



function round.SetUp()
	if #player.GetAll() >= 2 then
		data_points = {}
		game.CleanUpMap( false, {} )
		round.RoundsPlayed = round.RoundsPlayed+1
		timer.Remove("end_time")
		for _,a in pairs(player.GetAll()) do
			setRandomTeam(a) 
			a:KillSilent()
			a:Spawn()
			a:SetNWInt("PowerWait",times[a:GetNWString("Power")])
		end
		
		addDataPoint()
		round.Begin()
	else
		round.Broadcast("This Gamemode needs at least 2 people to play. Invite some buddies to play with you! And remember, the more the merrier! :)")
	end
end

function round.Begin()
	round.Broadcast("The round has begun, may the best team win!")
	SetGlobalInt( "roundNum", 1 )
	for _,b in pairs(player.GetAll()) do
		net.Start( "round" )
			net.WriteString("1")
		net.Send(b)
	end
end

function round.check()
	local TEAM = 0
	for i=1, #team.GetAllTeams() do
		if #team.GetPlayers( TEAM ) <= #team.GetPlayers( i ) then
			TEAM = i
		end
	end
	
	if #team.GetPlayers( TEAM ) == #player.GetAll() then
		round.End(TEAM)
	end
end

function round.End(winner)
	round.Broadcast("The round has ended! You have " .. round.Break .. " seconds to screw around")
	
	net.Start( "graph" )
		net.WriteTable( data_points )
	net.Broadcast()
	
	SetGlobalInt( "roundNum", -1 )
	for i,v in pairs(player.GetAll()) do
		net.Start( "round" )
			net.WriteString("-1")
		net.Send( v )
		v:StripWeapons()
		v:RemoveAllAmmo() 
		v:GiveBreakWeps()
	end

	timer.Create("end_time",round.Break,1,function()
		SetGlobalInt( "roundNum", 0 )
		for i,v in pairs(player.GetAll()) do
			net.Start( "round" )
				net.WriteString("0")
			net.Send( v )
		end
		
		game.CleanUpMap( false, {} )
		round.SetUp()
	end)
end
