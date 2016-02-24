
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Fungus"
ENT.Author			= "Ryan Reed"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.Editable			= false

function ENT:Initialize()

	if ( CLIENT ) then return end

	self.Hit = false
	self.LastShout = CurTime()
	self.CurrentPitch = 100
	self.SpawnDelay = CurTime() + 0.5

	self:SetModel("models/Items/grenadeAmmo.mdl")
	self:PhysicsInitBox(Vector(-1,-5,-1),Vector(1,5,1))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger(true)
	self:SetMaterial("models/debug/debugwhite")
	self:SetModelScale(self:GetModelScale()*1,0)
	self:SetColor( team.GetColor( self.Owner:Team() ) )
	self:DrawShadow(false)
	
	local phys = self:GetPhysicsObject()  	
	if (phys:IsValid()) then 
		phys:Wake()
		phys:EnableDrag(false)
		phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
		phys:SetBuoyancyRatio(0)
	end
	
	self.Fear = ents.Create("ai_sound")
	self.Fear:SetPos(self:GetPos())
	self.Fear:SetParent(self)
	self.Fear:SetKeyValue("SoundType", "8|1")
	self.Fear:SetKeyValue("Volume", "500")
	self.Fear:SetKeyValue("Duration", "1")
	self.Fear:Spawn()
	
	self:Fire("kill", 1, 60)

end

function ENT:Think()

	if SERVER then
		net.Start( "ExplodeColor" )
			net.WriteEntity( self )
			net.WriteEntity( self.Owner )
		net.Broadcast()
		if self.LastShout < CurTime() then
			if IsValid(self.Fear) then
				self.Fear:Fire("EmitAISound")
			end
			self.LastShout = CurTime() + 0.25
		end
		
		if self.Hit then
			self.CurrentPitch = self.CurrentPitch + 5
			if self.WhirrSound then self.WhirrSound:ChangePitch(math.Clamp(self.CurrentPitch,100,255),0) end
		end

		if self.Hit && self.Splodetimer && self.Splodetimer < CurTime() then
			local scatters = 3
			local h = 5
			for x=1, 3 do
				for y=1, 2 do
					local yAngle = 360/scatters*y
					local y_A = math.cos(yAngle/57.2957795)*h
					local y_O = math.sin(yAngle/57.2957795)*h
					
					local xAngle = 360/scatters*x
					local x_A = math.cos(xAngle/57.2957795)*y_A
					local x_O = math.sin(xAngle/57.2957795)*y_A

					local scatter = ents.Create("ent_spore")
					scatter.Owner = self.Owner
					scatter:SetPos(self:GetPos() + Vector(x_A,x_O,y_O+200) )
					scatter:Activate()
					scatter:Spawn()
					scatter:GetPhysicsObject():SetVelocityInstantaneous( Vector(x_A,x_O,y_O*y/4)*30 )
				end
			end
			util.ScreenShake( self:GetPos(), 50, 50, 1, 250 )
			
			local fx = EffectData()
			fx:SetOrigin(self:GetPos())
			util.Effect("fungusExplode", fx)
			
			self:EmitSound("ambient/explosions/explode_"..math.random(7,9)..".wav",90,100)
			self:EmitSound("weapons/explode"..math.random(3,5)..".wav",90,85)
			
			self:Remove()
			
		end
	end
	
	if CLIENT then 
		net.Receive( "ExplodeColor", function()
			local ent = net.ReadEntity()
			if ent ~= self then return end
			local owner = net.ReadEntity()
			
			local c = team.GetColor( owner:Team() )
			
			local EFFECT = {}

			function EFFECT:Init(ed)

				local vOrig = ed:GetOrigin()
				self.Emitter = ParticleEmitter(vOrig)
				
				for i=1,24 do

					local smoke = self.Emitter:Add("particle/particle_smokegrenade", vOrig)

					if (smoke) then

						smoke:SetColor(c.r,c.g,c.b)
						smoke:SetVelocity(VectorRand():GetNormal()*math.random(100, 300))
						smoke:SetRoll(math.Rand(0, 360))
						smoke:SetRollDelta(math.Rand(-2, 2))
						smoke:SetDieTime(0.5)
						smoke:SetLifeTime(0)
						smoke:SetStartSize(50)
						smoke:SetStartAlpha(255)
						smoke:SetEndSize(100)
						smoke:SetEndAlpha(0)
						smoke:SetGravity(Vector(0,0,0))

					end
					
					local smoke2 = self.Emitter:Add("particle/particle_smokegrenade", vOrig)
					
					if (smoke2) then

						smoke2:SetColor(c.r,c.g,c.b)
						smoke2:SetVelocity(VectorRand():GetNormal()*math.random(50, 100))
						smoke2:SetRoll(math.Rand(0, 360))
						smoke2:SetRollDelta(math.Rand(-2, 2))
						smoke2:SetDieTime(1)
						smoke2:SetLifeTime(0)
						smoke2:SetStartSize(50)
						smoke2:SetStartAlpha(255)
						smoke2:SetEndSize(100)
						smoke2:SetEndAlpha(0)
						smoke2:SetGravity(Vector(0,0,0))

					end
					
					local smoke3 = self.Emitter:Add("particle/particle_smokegrenade", vOrig+Vector(math.random(-150,150),math.random(-150,150),0))
					
					if (smoke3) then

						smoke3:SetColor(c.r,c.g,c.b)
						smoke3:SetVelocity(VectorRand():GetNormal()*math.random(50, 100))
						smoke3:SetRoll(math.Rand(0, 360))
						smoke3:SetRollDelta(math.Rand(-2, 2))
						smoke3:SetDieTime(1)
						smoke3:SetLifeTime(0)
						smoke3:SetStartSize(50)
						smoke3:SetStartAlpha(255)
						smoke3:SetEndSize(100)
						smoke3:SetEndAlpha(0)
						smoke3:SetGravity(Vector(0,0,0))

					end
					
				end
				
			end

			function EFFECT:Think()
				return false
			end

			function EFFECT:Render()
			end

			effects.Register( EFFECT, "fungusExplode", true )
		end)
	end
end

function ENT:OnRemove()
	if CLIENT then return end
	
	if self.WhirrSound then self.WhirrSound:Stop() end
	if IsValid(self.Fear) then self.Fear:Fire("kill") end
end

function ENT:PhysicsUpdate(phys)
	if CLIENT then return end
	
	if !self.Hit then
		self:SetLocalAngles(phys:GetVelocity():Angle())
	else
		phys:SetVelocity(Vector(phys:GetVelocity().x*0.95,phys:GetVelocity().y*0.95,phys:GetVelocity().z))
	end
end

function ENT:Touch(ent)
	if CLIENT then return end
	
	if IsValid(ent) && !self.Stuck then
		if ent:IsNPC() || (ent:IsPlayer() && ent != self:GetOwner()) || (ent == self:GetOwner() && self.SpawnDelay < CurTime() ) || ent:IsVehicle() then
			self:SetSolid(SOLID_NONE)
			self:SetMoveType(MOVETYPE_NONE)
			self:SetParent(ent)
			if !self.Splodetimer then
				self.Splodetimer = CurTime()
			end
			self.Stuck = true
			self.Hit = true
		end
	end
end

function ENT:PhysicsCollide(data,phys)	
	if CLIENT then return end
	
	if self:IsValid() && !self.Hit then
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		if !self.Splodetimer then
			self.Splodetimer = CurTime()
		end
		self.Hit = true
	end	
end

