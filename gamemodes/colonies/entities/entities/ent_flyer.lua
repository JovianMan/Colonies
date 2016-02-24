
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= ""
ENT.Author			= "Ryan Reed"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.Editable			= false

if CLIENT then
	c = Color(255,255,255)
end

function ENT:Initialize()
	if SERVER then
		local c = team.GetColor( self.Owner:Team() ) 
		SetGlobalVector( "Color" .. tostring(self), Vector( c.r,c.g,c.b ) ) 
		--SetGlobalVector( "Color" .. tostring(self), Vector( c.r,c.g,c.b ) ) 
		self.Trail = util.SpriteTrail(self, 0, c, false, 10, 0, 2, 0.01, "trails/plasma.vmt")

		self.Hit = false
		self.LastShout = CurTime()
		self.CurrentPitch = 100
		self.SpawnDelay = CurTime() + 0.5
		self.DeathTime = CurTime() + 8
		self.Track = nil

		self:SetModel("models/props_combine/headcrabcannister01a.mdl")
		self:PhysicsInitBox(Vector(-1,-1,-1),Vector(1,1,1))
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetTrigger(true)
		self:SetMaterial("models/debug/debugwhite")
		self:SetModelScale(self:GetModelScale()*1,0)
		self:SetColor( c )
		self:DrawShadow(false)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetModelScale(self:GetModelScale()*0.1,0)
		
		local phys = self:GetPhysicsObject()  	
		if (phys:IsValid()) then 
			phys:Wake()
			--phys:EnableDrag(false)
			--phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			--phys:SetBuoyancyRatio(0)
		end
		

		self:Fire("kill", 1, 60)
	end
end

function ENT:findTarget()
	local pos = self:GetPos()
	local d = 1000
	local ent = nil
	for i,v in pairs( ents.FindByClass( "npc_*" ) ) do
		if v ~= self.Owner and IsFriendEntityName( v:GetClass() ) == false then
			local dist = pos:Distance( v:GetPos() )
			if dist <= d then d = dist ent = v end
		end
	end
	for n,f in pairs( player.GetAll() ) do
		if f:Team() ~= self.Owner:Team() then
			local dist = pos:Distance( f:GetPos() )
			if dist <= d then d = dist ent = f end
		end
	end
	return d,ent
end

function ENT:Think()
	if CLIENT then
		local v = GetGlobalVector( "Color" .. tostring(self) )
		c = Color( v.x,v.y,v.z )
		return 
	end
	if self:GetPhysicsObject() == nil then return end
	
	if self.DeathTime <= CurTime() then
		self:Explode()
		SafeRemoveEntity(self)
	end

	distance, self.Track = self:findTarget()
	
	self:GetPhysicsObject():EnableGravity( false )
	if self.Track == nil then
		local v = self:GetPhysicsObject():GetVelocity()
		--self:GetPhysicsObject():AddVelocity( Vector(-v.x/3,-v.y/3,-v.z/3) )
	else
		dif = self.Track:OBBMaxs().z-self.Track:OBBMins().z
		local vEdit = self.Track:GetPos() + Vector(0,0,dif/2)
		local vec = vEdit - self:GetPos()
		local ang = vec:Angle()
		
		self:GetPhysicsObject():AddVelocity( vec:GetNormalized()*300 )
		self:SetAngles( ang )
	end
end

function ENT:OnRemove()
	if self.WhirrSound then self.WhirrSound:Stop() end
	if IsValid(self.Fear) then self.Fear:Fire("kill") end
end

function ENT:Explode()
	if IsValid(self.Owner) then
		if IsValid(self.Inflictor) then
			util.BlastDamage(self.Inflictor, self.Owner, self:GetPos(), 1, math.random(40,50)/10)
		else
			util.BlastDamage(self, self.Owner, self:GetPos(), 1, math.random(40,50)/10) 
		end
	end
	
	local fx = EffectData()
	fx:SetOrigin(self:GetPos())
	util.Effect("midget_swarm_explode", fx)
	
	self:EmitSound("ambient/explosions/explode_"..math.random(7,9)..".wav",90,100)
	self:EmitSound("weapons/explode"..math.random(3,5)..".wav",90,85)
end

function ENT:Touch(ent)
	if CLIENT then return end
	if (string.match(ent:GetClass(),"npc") ~= nil and ( ent["Team"] ~= nil or ent["Team"] == self.Owner:Team() ) ) or (ent:GetClass() == "player" and ent:Team() ~= self.Owner:Team()) then
		self:Explode()
		
		SafeRemoveEntity(self)
	end
end

if CLIENT then

	local EFFECT = {}

	function EFFECT:Init(ed)

		local vOrig = ed:GetOrigin()
		self.Emitter = ParticleEmitter(vOrig)
		
		for i=1,70 do

			local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)

			if (smoke) then

				smoke:SetColor(c.r,c.g,c.b)
				smoke:SetVelocity(VectorRand():GetNormal()*math.random(100, 300)/100)
				smoke:SetRoll(math.Rand(0, 360))
				smoke:SetRollDelta(math.Rand(-2, 2))
				smoke:SetDieTime(math.random(100)/30)
				smoke:SetLifeTime(0)
				smoke:SetStartSize(50)
				smoke:SetStartAlpha(100)
				smoke:SetEndSize(10)
				smoke:SetEndAlpha(0)
				smoke:SetGravity(Vector(0,0,0))

			end
			
		end
		
		for i=1,20 do
		
			local sparks = self.Emitter:Add("effects/spark", vOrig)
			
			if (sparks) then

				sparks:SetColor(c.r,c.g,c.b)
				sparks:SetVelocity(VectorRand():GetNormal()*math.random(300, 350)/10)
				sparks:SetRoll(math.Rand(0, 360))
				sparks:SetRollDelta(math.Rand(-2, 2))
				sparks:SetDieTime(2)
				sparks:SetLifeTime(0)
				sparks:SetStartSize(3)
				sparks:SetStartAlpha(255)
				sparks:SetStartLength(15)
				sparks:SetEndLength(3)
				sparks:SetEndSize(3)
				sparks:SetEndAlpha(255)
				sparks:SetGravity(Vector(0,0,-200))
				
			end
			
			local sparks2 = self.Emitter:Add("effects/spark", vOrig)
			
			if (sparks2) then

				sparks2:SetColor(c.r,c.g,c.b)
				sparks2:SetVelocity(VectorRand():GetNormal()*math.random(400, 800)/100)
				sparks2:SetRoll(math.Rand(0, 360))
				sparks2:SetRollDelta(math.Rand(-2, 2))
				sparks2:SetDieTime(0.4)
				sparks2:SetLifeTime(0)
				sparks2:SetStartSize(5)
				sparks2:SetStartAlpha(255)
				sparks2:SetStartLength(80)
				sparks2:SetEndLength(0)
				sparks2:SetEndSize(5)
				sparks2:SetEndAlpha(0)
				sparks2:SetGravity(Vector(0,0,0))
				
			end
		
		end
		
	end

	function EFFECT:Think()
		return false
	end

	function EFFECT:Render()
	end

	effects.Register( EFFECT, "midget_explode", true )

end
