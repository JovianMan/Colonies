
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Healthbox"
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
		self.LastShout = CurTime()
		self.CurrentPitch = 100
		self.SpawnDelay = CurTime()
		self.DeathTime = CurTime() + 20
		self.Team = self.Owner:Team()

		self:SetModel("models/props_junk/wood_crate001a.mdl")
		self:PhysicsInitBox(Vector(-9,-9,-9),Vector(9,9,9))
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		--self:SetTrigger( true )
		self:SetMaterial("models/debug/debugwhite")
		self:DrawShadow(false)
		self:GetPhysicsObject():SetMass( 128 )
		self:SetColor(Color(0,255,0))
		self:SetModelScale(self:GetModelScale()*0.4,0)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		
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

lastShot = CurTime()
function ENT:Think()
	if SERVER then
	
		if self.DeathTime <= CurTime() then
			self:Explode(0,0)
			SafeRemoveEntity(self)
		end
		
		local fx = EffectData()
		fx:SetOrigin(self:GetPos())
		util.Effect("health_smoke", fx)
		
		if CurTime() > lastShot+6 then
			for i,ply in pairs(player.GetAll()) do
				local d = self:GetPos():Distance( ply:GetPos() )
				if ply:Health() < 10 and ply:Team() == self.Team and d < 200 then
					ply:SetHealth(ply:Health()+1)
				end
			end
			lastShot = CurTime()
		end
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

			for i=1,10 do
			
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
			
			for i=1,100 do
				local a = 360/100*i
				local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)

				if (smoke) then
					
					smoke:SetColor(c.r,c.g,c.b)
					smoke:SetVelocity(Vector(math.sin(a/57.2957795),math.cos(a/57.2957795),0)*300)
					smoke:SetRoll(math.Rand(0, 360))
					smoke:SetRollDelta(math.Rand(-2, 2))
					smoke:SetDieTime(2)
					smoke:SetLifeTime(0)
					smoke:SetStartSize(0)
					smoke:SetStartAlpha(100)
					smoke:SetEndSize(100)
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

		effects.Register( EFFECT, "health_explode", true )
		
		-----------------------------------------------
		----------------------SMOKE--------------------
		-----------------------------------------------
		local EFFECT = {}

		function EFFECT:Init(ed)

			local vOrig = ed:GetOrigin()
			self.Emitter = ParticleEmitter(vOrig)
			
			for i=1,2 do
				vOrig = vOrig+Vector(math.random(-100,100),math.random(-100,100),0)
				local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)

				if (smoke) then
					local S = 255*0.6
					smoke:SetColor(S+c.r*0.4,S+c.g*0.4,S+c.b*0.4)
					smoke:SetVelocity(VectorRand():GetNormal()*math.random(100, 300)/100+Vector(0,0,math.random(50)))
					smoke:SetRoll(math.Rand(0, 360))
					smoke:SetRollDelta(math.Rand(-2, 2))
					smoke:SetDieTime(4)
					smoke:SetLifeTime(0)
					smoke:SetStartSize(50)
					smoke:SetStartAlpha(250)
					smoke:SetEndSize(math.random(100,300))
					smoke:SetEndAlpha(0)
					smoke:SetGravity(Vector(0,0,0))

				end
				
			end
			
			for i=1,1 do
				vOrig = vOrig+Vector(math.random(-100,100),math.random(-100,100),0)
				local plus = self.Emitter:Add("vgui/colonies/health_plus", vOrig)

				if (plus) then
					plus:SetColor(c.r,c.g,c.b)
					plus:SetVelocity(VectorRand():GetNormal()*math.random(100, 300)/100+Vector(0,0,math.random(150)))
					plus:SetRoll(math.Rand(0, 360))
					plus:SetRollDelta(math.Rand(-2, 2))
					plus:SetDieTime(4)
					plus:SetLifeTime(0)
					plus:SetStartSize(math.random(10,20))
					plus:SetStartAlpha(250)
					plus:SetEndSize(math.random(4))
					plus:SetEndAlpha(0)
					plus:SetGravity(Vector(0,0,0))

				end
				
			end
			
		end

		function EFFECT:Think()
			return false
		end

		function EFFECT:Render()
		end

		effects.Register( EFFECT, "health_smoke", true )
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
	util.Effect("health_explode", fx)
	
	self:EmitSound("ambient/explosions/explode_"..math.random(7,9)..".wav",90,100)
	self:EmitSound("weapons/explode"..math.random(3,5)..".wav",90,85)

	self:SetModel("models/Roller.mdl")
end