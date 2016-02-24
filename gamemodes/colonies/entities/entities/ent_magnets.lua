
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Magnet"
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
		local c = team.GetColor( self.Owner:Team() )--Color(math.random(255),math.random(255),math.random(255),255)

		SetGlobalVector( "Color" .. tostring(self), Vector( c.r,c.g,c.b ) ) 
		--print(c)
		self.Hit = false
		self.LastShout = CurTime()
		self.CurrentPitch = 100
		self.SpawnDelay = CurTime() + 0.5
		self.DeathTime = CurTime() + 10
		self.Track = nil
		self.Stuck = false

		self:SetModel("models/XQM/Rails/trackball_1.mdl")
		self:PhysicsInitBox(Vector(-1,-1,-1),Vector(1,1,1))
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		--self:SetTrigger( true )
		self:SetMaterial("models/debug/debugwhite")
		self:DrawShadow(false)
		self:GetPhysicsObject():SetMass( 128 )
		self:SetColor(c)
		self:SetModelScale(self:GetModelScale()*0.1,0)
		--self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		
		local phys = self:GetPhysicsObject()  	
		if (phys:IsValid()) then 
			phys:Wake()
			--phys:EnableDrag(false)
			phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
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
		self:Explode(0,0)
		SafeRemoveEntity(self)
	end

	distance, self.Track = self:findTarget()
	
	self:GetPhysicsObject():EnableGravity( false )
	if self.Stuck == true then
		local vel = Vector(0,0,0)
		for i,ent in pairs(ents.GetAll()) do
			if IsValid( ent:GetParent() ) and ent:GetParent() ~= self:GetParent() and ent:GetClass() == "ent_magnets" then
				local v = (ent:GetPos()-self:GetPos()):GetNormalized()*100
				vel = vel+v
			end
		end
		self:GetParent():SetVelocity( vel )
	else
		if self.Track ~= nil then
			local v = self:GetPhysicsObject():GetVelocity()
			local mag = math.sqrt( v.x^2+v.y^2+v.z^2 )
			if mag > 500 then
				v = Vector( v.x-100,v.y-100,v.z-100 )
				self:GetPhysicsObject():AddVelocity( Vector(-v.x,-v.y,-v.z) )
			end
			dif = self.Track:OBBMaxs().z-self.Track:OBBMins().z
			local vEdit = self.Track:GetPos() + Vector(0,0,dif/2)
			local vec = vEdit - self:GetPos()
			local ang = vec:Angle()
			
			self:GetPhysicsObject():AddVelocity( vec:GetNormalized()*300 )
		end
	end
	if IsValid( self:GetParent() ) then
		self:GetParent():SetMoveType( MOVETYPE_WALK )
	end
end

function ENT:OnRemove()
	if self.WhirrSound then self.WhirrSound:Stop() end
	if IsValid(self.Fear) then self.Fear:Fire("kill") end
end

function ENT:Explode(dmg,rng)
	if IsValid(self.Owner) then
		if IsValid(self.Inflictor) then
			util.BlastDamage(self.Inflictor, self.Owner, self:GetPos(), rng, dmg)
		else
			util.BlastDamage(self, self.Owner, self:GetPos(), rng, dmg) 
		end
	end
	
	local fx = EffectData()
	fx:SetOrigin(self:GetPos())
	util.Effect("magnet_explode", fx)
	
	self:EmitSound("ambient/explosions/explode_"..math.random(7,9)..".wav",90,100)
	self:EmitSound("weapons/explode"..math.random(3,5)..".wav",90,85)

	self:SetModel("models/Roller.mdl")
end

function ENT:Touch(ent)
	if ent:IsPlayer() and ent:Team() ~= self.Owner:Team() and self.Stuck == false then
		self:SetMoveType(MOVETYPE_NONE)
		self.Stuck = true
		self:SetParent(ent)
		--self:Explode(0,0)
		--SafeRemoveEntity(self)
	end
end

function ENT:PhysicsCollide(data,phys)	
	if CLIENT then return end
	if self:IsValid() && !self.Hit then
		--self:SetMoveParent( Entity( 1 ) )
		--self:Explode(5,100)
		--SafeRemoveEntity(self)
	end	
end

if CLIENT then 
	c = GetGlobalVector( "Color" .. tostring(self) )
	
	
	-----------------------------------------------
	--------------------EXPLOSION------------------
	-----------------------------------------------
	local EFFECT = {}

	function EFFECT:Init(ed)

		local vOrig = ed:GetOrigin()
		self.Emitter = ParticleEmitter(vOrig)

		for i=1,10 do
		
			local sparks = self.Emitter:Add("effects/spark", vOrig)
			
			if (sparks) then

				sparks:SetColor(c.r,c.g,c.b)
				sparks:SetVelocity(VectorRand():GetNormal()*math.random(300, 500))
				sparks:SetRoll(math.Rand(0, 360))
				sparks:SetRollDelta(math.Rand(-2, 2))
				sparks:SetDieTime(2)
				sparks:SetLifeTime(0)
				sparks:SetStartSize(5)
				sparks:SetStartAlpha(255)
				sparks:SetStartLength(15)
				sparks:SetEndLength(30)
				sparks:SetEndSize(3)
				sparks:SetEndAlpha(255)
				sparks:SetGravity(Vector(0,0,-800))
				
			end
			
			local sparks2 = self.Emitter:Add("effects/spark", vOrig)
			
			if (sparks2) then

				sparks2:SetColor(c.r,c.g,c.b)
				sparks2:SetVelocity(VectorRand():GetNormal()*math.random(400, 800))
				sparks2:SetRoll(math.Rand(0, 360))
				sparks2:SetRollDelta(math.Rand(-2, 2))
				sparks2:SetDieTime(1)
				sparks2:SetLifeTime(0)
				sparks2:SetStartSize(5)
				sparks2:SetStartAlpha(255)
				sparks2:SetStartLength(80)
				sparks2:SetEndLength(0)
				sparks2:SetEndSize(2)
				sparks2:SetEndAlpha(0)
				sparks2:SetGravity(Vector(0,0,0))
				
			end
		
		end
		
		for i=1,1 do
		
			local flash = self.Emitter:Add("effects/combinemuzzle2_dark", vOrig)
			
			if (flash) then
			
				flash:SetColor(c.r,c.g,c.b)
				flash:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
				flash:SetRoll(math.Rand(0, 360))
				flash:SetDieTime(0.5)
				flash:SetLifeTime(0)
				flash:SetStartSize(15)
				flash:SetStartAlpha(255)
				flash:SetEndSize(24)
				flash:SetEndAlpha(0)
				flash:SetGravity(Vector(0,0,0))		
				
			end
		
		end
		
		
		for i=1,10 do

			local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)

			if (smoke) then

				smoke:SetColor(c.r,c.g,c.b)
				smoke:SetVelocity(VectorRand():GetNormal()*math.random(100, 300)/100)
				smoke:SetRoll(math.Rand(0, 360))
				smoke:SetRollDelta(math.Rand(-2, 2))
				smoke:SetDieTime(0.5)
				smoke:SetLifeTime(0)
				smoke:SetStartSize(0)
				smoke:SetStartAlpha(100)
				smoke:SetEndSize(50)
				smoke:SetEndAlpha(0)
				smoke:SetGravity(Vector(0,0,0))

			end
			
		end
		
	end

	function EFFECT:Think()
		return false
	end

	function EFFECT:Render()
	end

	effects.Register( EFFECT, "magnet_explode", true )
end