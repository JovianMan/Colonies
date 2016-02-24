if SERVER then
	AddCSLuaFile()
end

SWEP.Base				= "weapon_base"

SWEP.PrintName			= "Barricade Grenade"	
SWEP.ClassName			= "grenade_scatter"			
SWEP.Author				= "Ryan Reed"
SWEP.Category			= "ARGGGGG"
SWEP.Instructions		= "Left click to throw, right click to toss."
SWEP.Slot				= 2
SWEP.SlotPos			= 2
		
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.ViewModelFOV		= 55
SWEP.ViewModelFlip		= false

SWEP.HoldType			= "grenade"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false

SWEP.ViewModel			= "models/weapons/v_Grenade.mdl"
SWEP.WorldModel			= "models/weapons/W_grenade.mdl"

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Delay				= 0.75

SWEP.Primary.ClipSize			= 1
SWEP.Primary.DefaultClip		= 32
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				= "grenade"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo				= "none"

SWEP.NextThrow = CurTime()
SWEP.NextAnimation = CurTime()
SWEP.Throwing = false
SWEP.StartThrow = false
SWEP.ResetThrow = false
SWEP.Tossed = false
SWEP.ThrowVel = 50

if CLIENT then
	function SWEP:PreDrawViewModel( vm, ply )
		vm:SetMaterial("models/debug/debugwhite")
		vm:SetColor( team.GetColor( LocalPlayer():Team() ) )
		vm:SetRenderMode( RENDERMODE_TRANSALPHA )
	end

	function SWEP:PostDrawViewModel( vm, ply )
		vm:SetMaterial("")
	end
end

function SWEP:Initialize()
    if CLIENT then
	surface.CreateFont( "Arial",
	{
	font = "Arial",
	size = ScreenScale(10),
	weight = 400
	})   
	
    killicon.Add( "weapon_barricade", "", color_white ) --aimbot/killico
    end
	self:SetWeaponHoldType(self.HoldType)
end

if CLIENT then
	
	local function ShrinkHands(self)
		local grenade = self:LookupBone("ValveBiped.Grenade_body")
		local matr = self:GetBoneMatrix(grenade)
		if matr then
			matr:Scale(vector_origin)
			self:SetBoneMatrix(grenade, matr)
		end
	end
	
	local function ResetHands(self)
		local grenade = self:LookupBone("ValveBiped.Grenade_body")
		local matr = self:GetBoneMatrix(grenade)
		if matr then
			matr:Scale(Vector(1,1,1))
			self:SetBoneMatrix(grenade,matr)
		end
	end

	function SWEP:ShrinkViewModel(cmodel)
		if IsValid(cmodel) then
			cmodel:SetupBones()
			cmodel.BuildBonePositions = ShrinkHands
		end
	end
	
	function SWEP:ResetViewModel(cmodel)
		if IsValid(cmodel) then
			cmodel:SetupBones()
			cmodel.BuildBonePositions = ResetHands
		end
	end
	
	function SWEP:CreateViewProp()
		self.CSModel = ClientsideModel("models/dav0r/hoverball.mdl", RENDER_GROUP_VIEW_MODEL_OPAQUE)
		if IsValid(self.CSModel) then
			self.CSModel:SetPos(self:GetPos())
			self.CSModel:SetAngles(self:GetAngles())
			self.CSModel:SetParent(self)
			self.CSModel:SetNoDraw(true)
		end
	end
	
	function SWEP:ResetWeapon()
		if IsValid(self.CSModel) then self.CSModel:Remove() end
		if IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()) then
			self:ResetViewModel(self.Owner:GetViewModel())
		end
	end
	
end

/*

function SWEP:ViewModelDrawn()

	local vm = self.Owner:GetViewModel()
	
	if IsValid(self.Owner) && IsValid(vm) then
	
		local mdl = self.CSModel
		local bone = vm:LookupBone("ValveBiped.Grenade_body")
		
		if IsValid(mdl) then
		
			local vmang = Angle(120,30,90)
			local vmpos = Vector(-0.75,-0.70,1.25)

			local pos = vm:GetBonePosition(bone)
			local ang = vm:GetAngles()
			
			mdl:SetPos(pos + ang:Forward() * vmpos.x + ang:Right() * vmpos.y + ang:Up() * vmpos.z)
			
			ang:RotateAroundAxis(ang:Up(), vmang.y)
			ang:RotateAroundAxis(ang:Right(), vmang.p)
			ang:RotateAroundAxis(ang:Forward(), vmang.r)
			
			mdl:SetAngles(ang)
			mdl:SetModelScale(self:GetModelScale()*0.35,0)
			mdl:SetMaterial("models/weapons/v_grenade/grenade body")
			
			render.SetColorModulation(0/255, 200/255, 1)
			render.SetBlend(1)
			mdl:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)
			
			else
			
			self:ShrinkViewModel(vm)
			self:CreateViewProp(self)
		
		end
	
	end
	
end

*/

function SWEP:Deploy()

	if game.SinglePlayer() then
		self:CallOnClient("Deploy", "")
	end

	self.StartThrow = false
	self.Throwing = false
	self.ResetThrow = false

	if !self.Throwing then
	
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		if IsValid(self.Owner:GetViewModel()) then
			self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			self.NextThrow = CurTime() + self.Owner:GetViewModel():SequenceDuration()
		end
		
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 && self:Clip1() <= 0 then
			self.Owner:RemoveAmmo(1, self.Primary.Ammo)
			self:SetClip1(self:Clip1()+1)
		end
		
	end
	
	return true	
	
end

function SWEP:Holster()

	if game.SinglePlayer() then
		self:CallOnClient("Holster", "")
	end

	self.StartThrow = false
	self.Throwing = false
	self.ResetThrow = false
	
	if CLIENT then
		self:ResetWeapon()
	end
	
	return true
	
end

function SWEP:OnRemove()
	if game.SinglePlayer() then
		self:CallOnClient("OnRemove", "")
	end
	
	if CLIENT then
		self:ResetWeapon()
	end
end

function SWEP:OnDrop()
	if game.SinglePlayer() then
		self:CallOnClient("OnDrop", "")
	end
	
	if IsValid(self.Weapon) then
		self.Weapon:Remove()
	end
end

function SWEP:CreateGrenade()

	if IsValid(self.Owner) && IsValid(self.Weapon) then

		if (SERVER) then
		
			local ent = ents.Create("ent_barricade")
			if !ent then return end
			ent.Owner = self.Owner
			ent.Inflictor = self.Weapon
			ent:SetOwner(self.Owner)		
			local eyeang = self.Owner:GetAimVector():Angle()
			local right = eyeang:Right()
			local up = eyeang:Up()
			if self.Tossed then
				ent:SetPos(self.Owner:GetShootPos()+right*4-up*4)
			else
				ent:SetPos(self.Owner:GetShootPos()+right*4+up*4)
			end
			ent:SetAngles(self.Owner:GetAngles())
			ent:SetPhysicsAttacker(self.Owner)
			ent:Spawn()
			ent:GetPhysicsObject():AddAngleVelocity( Vector(1,1,1) )
			
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocity(self.Owner:GetAimVector() * self.ThrowVel + (self.Owner:GetVelocity() * 0.75))
			end
			
		end
	
	end
	
end

function SWEP:Think()
	if self.Owner:KeyDown(IN_ATTACK2) then
		self.ThrowVel = 700
		self.Tossed = true
	elseif self.Owner:KeyDown(IN_ATTACK) then
		self.ThrowVel = 1500
		self.Tossed = false
	end

	if self.StartThrow && !self.Owner:KeyDown(IN_ATTACK) && !self.Owner:KeyDown(IN_ATTACK2) && self.NextThrow < CurTime() then
	
		self.StartThrow = false
		self.Throwing = true
		if self.Tossed then
			self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
		else
			self.Weapon:SendWeaponAnim(ACT_VM_THROW)
		end
		self.Owner:SetAnimation(PLAYER_ATTACK1)		
		self:CreateGrenade(self.Owner, self.Weapon)
		self:TakePrimaryAmmo(1)
		self.NextAnimation = CurTime() + self.Primary.Delay
		self.ResetThrow = true
		
	end
	
	if self.Throwing && self.ResetThrow && self.NextAnimation < CurTime() then
	
		if self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 && self:Clip1() <= 0 then
		
			self.Owner:RemoveAmmo(1, self.Primary.Ammo)
			self:SetClip1(self:Clip1()+1)
			self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
			if IsValid(self.Owner:GetViewModel()) then
				self.NextThrow = CurTime() + self.Owner:GetViewModel():SequenceDuration()
				self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
				self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			end
			
		else
			self.Owner:ConCommand("lastinv")
		end
		
		self.ResetThrow = false
		self.Throwing = false
		
	end
	
	if SERVER then
		if self.Owner:GetAmmoCount( "grenade" ) <= 0 then
			self.Owner:StripWeapon( "grenade_barricade" ) 
		end
	end
end

function SWEP:CanPrimaryAttack()
	if self.Throwing || ( self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 && self:Clip1() <= 0 ) then
		return false
	end
	
	return true
end

function SWEP:PrimaryAttack()
	if (!self:CanPrimaryAttack()) then return end
	if !self.Throwing && !self.StartThrow then
		self.StartThrow = true
		self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
		if IsValid(self.Owner:GetViewModel()) then
			self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			self.NextThrow = CurTime() + self.Owner:GetViewModel():SequenceDuration()
		end
	end
end

function SWEP:SecondaryAttack()
	if (!self:CanPrimaryAttack()) then return end
	if !self.Throwing && !self.StartThrow then
		self.StartThrow = true
		self.Weapon:SendWeaponAnim(ACT_VM_PULLBACK_LOW)
		if IsValid(self.Owner:GetViewModel()) then
			self.Weapon:SetNextPrimaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			self.Weapon:SetNextSecondaryFire(CurTime() + self.Owner:GetViewModel():SequenceDuration())
			self.NextThrow = CurTime() + self.Owner:GetViewModel():SequenceDuration()
		end
	end
end

function SWEP:Reload()
end

function SWEP:ShouldDropOnDie()
	return false
end

local ENT = {}

ENT.Type = "anim"  
ENT.Base = "base_anim"

if CLIENT then
	ENT.Mat = Material("sprites/light_glow02_add")
	ENT.Scaled = false

	function ENT:Draw()
		self:DrawModel()
		render.SetMaterial(self.Mat)
		render.DrawSprite(self:GetPos(), 72+(16*math.sin(CurTime()*5)), 72+(16*math.sin(CurTime()*5)), Color(50,150,255,255))
		render.DrawSprite(self:GetPos(), 64+(16*math.sin(CurTime()*5)), 64+(16*math.sin(CurTime()*5)), Color(50,255,255,255))
	end
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
    draw.SimpleText("Barricade Grenade","Arial",x + wide/2,y + tall*0.35,team.GetColor( LocalPlayer():Team() ),TEXT_ALIGN_CENTER) -- is this right?
end