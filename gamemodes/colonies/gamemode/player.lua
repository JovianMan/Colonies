local ply = FindMetaTable("Player")


plyWeapons = {
	"grenade_barricade",
	"grenade_spores",
}
brkWeapons = {
	"weapon_fireworks",
	"weapon_confetti",
}
plyModels = {
	"models/player/group01/female_01.mdl",
	"models/player/group01/female_02.mdl",
	"models/player/group01/female_03.mdl",
	"models/player/group01/female_04.mdl",
	"models/player/group01/female_05.mdl",
	"models/player/group01/female_06.mdl",
	"models/player/group01/male_01.mdl",
	"models/player/group01/male_02.mdl",
	"models/player/group01/male_03.mdl",
	"models/player/group01/male_04.mdl",
	"models/player/group01/male_05.mdl",
	"models/player/group01/male_06.mdl",
	"models/player/group01/male_07.mdl",
	"models/player/group01/male_08.mdl",
	"models/player/group01/male_09.mdl",
}

function ply:SetGModeTeam( n )
	
	self:SetTeam( n )
	
	local c = team.GetColor( self:Team() )
	
	self:SetPlayerColor( Vector( c.r, c.g, c.b )/255 )

end

function ply:GiveGModeWeps()
	local primary = self:GetNWString("Primary")
	if primary ~= nil then
		self:Give( primary )
	end
	local secondary = self:GetNWString("Secondary")
	if secondary ~= nil then
		self:Give( secondary )
	end
	for i,wep in pairs(plyWeapons) do
		self:Give( wep )
	end
end

function ply:GiveBreakWeps()
	for i,wep in pairs(brkWeapons) do
		self:Give( wep )
	end
end

function ply:SetGModeModel()
	self:SetNWString( "PlyModel",table.Random( plyModels ) )
end