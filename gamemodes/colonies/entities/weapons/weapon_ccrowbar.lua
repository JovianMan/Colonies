if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 5;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;
   --resource.AddFile( "materials/aimbot/killico.png" )
end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Crowbar";
   SWEP.Slot = 1;
   SWEP.SlotPos = 1;
   SWEP.DrawAmmo = true;
   SWEP.DrawCrosshair = true;
 
end

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;
SWEP.AdminOnly		= false
SWEP.Category 		= "ARGGGGG"
SWEP.IconLetter    	= "D"
SWEP.Author         = "Ryan Reed"
SWEP.Contact        = ""
SWEP.Purpose        = "Helps shooting at enemies"
SWEP.Instructions   = "Fire to unleash hell on your enemies."

SWEP.ViewModel			= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"

SWEP.HoldType			= "melee"
SWEP.ViewModelFlip            = false -- I don't like left-side SWEPs either.

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Delay            = 0.4
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "none"

SWEP.Primary.Recoil            = 500
SWEP.Primary.Damage            = 0.5
SWEP.Primary.NumShots        = 1
SWEP.Primary.Cone            = 0.03

SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo            = "none"

SWEP.MissSound = Sound( "Weapon_Crowbar.Single" )
SWEP.WallSound = Sound( "Weapon_Crowbar.Melee_Hit" )

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
	
    killicon.Add( "weapon_ccrowbar", "", color_white ) --aimbot/killico
    end
	self:SetWeaponHoldType( self.HoldType )
end
----------------------------------------------------------------------------------------------------
-- The rest of the code I don't have to really bother with as the following is aimbot code.
----------------------------------------------------------------------------------------------------


function SWEP:Think()

end

function SWEP:PrimaryAttack()

	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if ( trace.Hit ) then
	
		if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self:fireBullet()
			self.Owner:FireBullets(bullet) 
		else
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			self:fireBullet()
			self.Weapon:EmitSound( self.WallSound )		
		end
	else
		self.Weapon:EmitSound(self.MissSound) 
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER) 
	end
end

function SWEP:fireBullet()
	bullet = {}
	bullet.Num    = 1
	bullet.Src    = self.Owner:GetShootPos()
	bullet.Dir    = self.Owner:GetAimVector()
	bullet.Spread = Vector(0, 0, 0)
	bullet.Tracer = 0
	bullet.Force  = 1
	bullet.Damage = self.Primary.Damage
	self.Owner:FireBullets(bullet) 
end

function SWEP:SecondaryAttack()    
end

function SWEP:ShouldDropOnDie()
    return true
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
    draw.SimpleText("Crowbar","Arial",x + wide/2,y + tall*0.35,team.GetColor( LocalPlayer():Team() ),TEXT_ALIGN_CENTER) -- is this right?
end