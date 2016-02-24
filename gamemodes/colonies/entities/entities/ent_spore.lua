
AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Spore"
ENT.Author			= "Ryan Reed"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.Editable			= false

function ENT:Initialize()
	if SERVER then
		local c = team.GetColor( self.Owner:Team() ) 

		SetGlobalVector( "Color" .. tostring(self), Vector( c.r,c.g,c.b ) ) 
		--print(c)
		self.Hit = false
		self.LastShout = CurTime()
		self.CurrentPitch = 100
		self.SpawnDelay = CurTime() + 0.5
		self.DeathTime = CurTime() + 15 - math.random(1,10)/5
		self.Track = nil

		self:SetModel("models/XQM/Rails/gumball_1.mdl")
		self:PhysicsInitBox(Vector(-1,-1,-1),Vector(1,1,1))
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetTrigger(true)
		self:SetMaterial("models/debug/debugwhite")
		self:SetModelScale(self:GetModelScale()*0.05,0)
		self:SetColor( Color( 100, 100, 100, 255 ) )
		self:DrawShadow(false)
		
		local phys = self:GetPhysicsObject()  	
		if (phys:IsValid()) then 
			phys:Wake()
			--phys:EnableDrag(false)
			--phys:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			--phys:SetBuoyancyRatio(0)
		end
		

		self:Fire("kill", 1, 60)
	end
	if CLIENT then
		local color = GetGlobalVector( "Color" .. tostring(self) )
	
		if color ~= nil then
			--print(color)
			local K = {}
			local l = ClientsideModel( "models/XQM/Rails/gumball_1.mdl", RENDERGROUP_TRANSLUCENT )
			l:SetPos(self:GetPos())
			l:FollowBone( self, 0 )
			l:SetParent( self )
			l:SetColor( Color( color.x, color.y, color.z, 255 ) )
			l:SetRenderMode( RENDERMODE_TRANSALPHA )
			
			local matrix = Matrix()
			matrix:Scale( Vector(1,1,1)*0.2 )
			l:EnableMatrix( "RenderMultiply", matrix )
			
			l:Spawn()
			l:Activate()
			
			table.insert(K,l)
			
			hook.Add( "RemoveBabies" .. tostring(self), "RemoveBabies", function()
				for i,l in pairs(K) do
					l:SetNoDraw( true )
					SafeRemoveEntity( l )
				end
			end)
		end
	end
end

function ENT:findTarget()
	local pos = self:GetPos()
	local d = 175
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

if CLIENT then
	A = false
end
function ENT:Think()
	if SERVER then
		net.Start( "ExplodeColor" )
			net.WriteEntity( self )
			net.WriteEntity( self.Owner )
		net.Broadcast()
	
		if self.DeathTime <= CurTime() then
			self:Explode(0,0)
			SafeRemoveEntity(self)
		end

		distance, self.Track = self:findTarget()
		
		self:GetPhysicsObject():EnableGravity( false )
		if self.Track == nil then
			local v = self:GetPhysicsObject():GetVelocity()
			self:GetPhysicsObject():AddVelocity( Vector(-v.x/3,-v.y/3,-v.z/3) )
		else
			dif = self.Track:OBBMaxs().z-self.Track:OBBMins().z
			local vEdit = self.Track:GetPos() + Vector(0,0,dif/2)
			local vec = vEdit - self:GetPos()
			local ang = vec:Angle()
			
			self:GetPhysicsObject():AddVelocity( vec:GetNormalized()*300 )
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
						smoke:SetVelocity(VectorRand():GetNormal()*math.random(100, 300)/100)
						smoke:SetRoll(math.Rand(0, 360))
						smoke:SetRollDelta(math.Rand(-2, 2))
						smoke:SetDieTime(1)
						smoke:SetLifeTime(0)
						smoke:SetStartSize(50)
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

			effects.Register( EFFECT, "midget_swarm_explode", true )
		end)
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
	util.Effect("midget_swarm_explode", fx)
	
	self:EmitSound("ambient/explosions/explode_"..math.random(7,9)..".wav",90,100)
	self:EmitSound("weapons/explode"..math.random(3,5)..".wav",90,85)
end

function ENT:Touch(ent)
	if CLIENT then return end
	if string.match(ent:GetClass(),"npc") ~= nil or ent:GetClass() == "player" then
		self:Explode(1,100)
		
		SafeRemoveEntity(self)
	end
end


