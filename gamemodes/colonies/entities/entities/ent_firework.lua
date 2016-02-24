
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Firework"
ENT.Author			= "Ryan Reed"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.Editable			= false

function ENT:Initialize()
	if SERVER then
		local c = Color(math.random(255),math.random(255),math.random(255),255)

		SetGlobalVector( "Color" .. tostring(self), Vector( c.r,c.g,c.b ) ) 
		--print(c)
		self.Hit = false
		self.LastShout = CurTime()
		self.CurrentPitch = 100
		self.SpawnDelay = CurTime() + 0.5
		self.DeathTime = CurTime() + 2 - math.random(1,10)/10
		self.Track = nil

		self:SetModel("models/weapons/w_bazooka_rocket.mdl")
		self:PhysicsInitBox(Vector(-1,-1,-10),Vector(1,1,10))
		self:SetCollisionGroup( 11 )
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetModelScale(self:GetModelScale()*1.4,0)
		self:SetMaterial("models/debug/debugwhite")
		self:DrawShadow(false)
		self:GetPhysicsObject():SetMass( 128 )
		self:SetColor(c)
		
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

function ENT:Think()
	if SERVER then
	
		if self.DeathTime <= CurTime() then
			self:Explode(0,0)
			SafeRemoveEntity(self)
		end

		self:GetPhysicsObject():EnableGravity( false )
		local a = self:GetAngles()
		local ba = 0.9
		local bb = 1-ba
		self:SetAngles( (Angle( a.p*ba-90*bb,a.y,a.r )) )
		local angle = self:GetAngles()
		--self:GetPhysicsObject():AddVelocity( angle:Forward()*100 )
		self:GetPhysicsObject():SetVelocityInstantaneous( angle:Forward()*1000 )
		
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		util.Effect("firework_smoke", fx)
	end
	if CLIENT then 
		local c = GetGlobalVector( "Color" .. tostring(self) )
		
		
		-----------------------------------------------
		--------------------EXPLOSION------------------
		-----------------------------------------------
		local EFFECT = {}

		function EFFECT:Init(ed)

			local vOrig = ed:GetOrigin()
			self.Emitter = ParticleEmitter(vOrig)

			for i=1,72 do
			
				local sparks = self.Emitter:Add("effects/spark", vOrig)
				
				if (sparks) then

					sparks:SetColor(c.r,c.g,c.b)
					sparks:SetVelocity(VectorRand():GetNormal()*math.random(300, 500))
					sparks:SetRoll(math.Rand(0, 360))
					sparks:SetRollDelta(math.Rand(-2, 2))
					sparks:SetDieTime(2)
					sparks:SetLifeTime(0)
					sparks:SetStartSize(30)
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
					sparks2:SetStartSize(50)
					sparks2:SetStartAlpha(255)
					sparks2:SetStartLength(80)
					sparks2:SetEndLength(0)
					sparks2:SetEndSize(5)
					sparks2:SetEndAlpha(0)
					sparks2:SetGravity(Vector(0,0,0))
					
				end
			
			end
			
			for i=1,8 do
			
				local flash = self.Emitter:Add("effects/combinemuzzle2_dark", vOrig)
				
				if (flash) then
				
					flash:SetColor(c.r,c.g,c.b)
					flash:SetVelocity(VectorRand():GetNormal()*math.random(10, 30))
					flash:SetRoll(math.Rand(0, 360))
					flash:SetDieTime(0.5)
					flash:SetLifeTime(0)
					flash:SetStartSize(150)
					flash:SetStartAlpha(255)
					flash:SetEndSize(240)
					flash:SetEndAlpha(0)
					flash:SetGravity(Vector(0,0,0))		
					
				end
			
			end
			
		end

		function EFFECT:Think()
			return false
		end

		function EFFECT:Render()
		end

		effects.Register( EFFECT, "firework_explode", true )
		
		-----------------------------------------------
		----------------------SMOKE--------------------
		-----------------------------------------------
		local EFFECT = {}

		function EFFECT:Init(ed)

			local vOrig = ed:GetOrigin()
			self.Emitter = ParticleEmitter(vOrig)
			
			for i=1,10 do

				local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)

				if (smoke) then

					smoke:SetColor(255,255,255)
					smoke:SetVelocity(VectorRand():GetNormal()*math.random(100, 300)/100)
					smoke:SetRoll(math.Rand(0, 360))
					smoke:SetRollDelta(math.Rand(-2, 2))
					smoke:SetDieTime(0.5)
					smoke:SetLifeTime(0)
					smoke:SetStartSize(0)
					smoke:SetStartAlpha(100)
					smoke:SetEndSize(10)
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

		effects.Register( EFFECT, "firework_smoke", true )
	end
end

function ENT:OnRemove()
	if CLIENT then 
		hook.Run( "RemoveBabies" .. tostring(self) );
		hook.Remove( "RemoveBabies" .. tostring(self), "RemoveBabies" )
		return 
	end
	
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
	util.Effect("firework_explode", fx)
	
	self:EmitSound("ambient/explosions/explode_"..math.random(7,9)..".wav",90,100)
	self:EmitSound("weapons/explode"..math.random(3,5)..".wav",90,85)
end