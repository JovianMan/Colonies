if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 500;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;
   --resource.AddFile( "materials/aimbot/killico.png" )
end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Burst Rifle";
   SWEP.Slot = 0;
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

SWEP.ViewModel                = "models/weapons/v_irifle.mdl"
SWEP.WorldModel                = "models/weapons/w_irifle.mdl"

SWEP.HoldType                = "ar2"
SWEP.ViewModelFlip            = false -- I don't like left-side SWEPs either.

SWEP.Primary.ClipSize        = 12
SWEP.Primary.DefaultClip    = 90
SWEP.Primary.Delay            = 0.5
SWEP.Primary.Automatic        = false
SWEP.Primary.Ammo            = "smg1"

SWEP.Primary.Sound = 		Sound( "weapons/ar2/fire1.wav" )
SWEP.Primary.Recoil            = 500
SWEP.Primary.Damage            = 2
SWEP.Primary.NumShots        = 1
SWEP.Primary.Cone            = 0.03

SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo            = "none"

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
	
    killicon.Add( "weapon_smg", "", color_white ) --aimbot/killico
    end
	self:SetWeaponHoldType( self.HoldType )
end
----------------------------------------------------------------------------------------------------
-- The rest of the code I don't have to really bother with as the following is aimbot code.
----------------------------------------------------------------------------------------------------


function SWEP:Think()

end

function SWEP:Reload()
    self.Weapon:DefaultReload(ACT_VM_RELOAD)
end

function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    if (!self:CanPrimaryAttack()) or CLIENT then return end
	
	for i=1,3 do
		timer.Create( "Shot" .. i, (i-1)*0.1, 1, function()
			if self.Weapon ~= nil then
				self.Weapon:EmitSound(self.Primary.Sound)
				
				local bullet = {}
				bullet.Num = self.Primary.NumShots
				bullet.Src = self.Owner:GetShootPos()
				bullet.Dir = self.Owner:GetAimVector()
				bullet.Spread = Vector(self.Primary.Cone,self.Primary.Cone,self.Primary.Cone)*Vector(math.random(-100,100)/100,math.random(-100,100)/100,math.random(-100,100)/100)
				bullet.Tracer = 1
				bullet.Force = 1
				bullet.Damage = self.Primary.Damage/2

				self.Owner:FireBullets(bullet)
				self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				self.Owner:MuzzleFlash()
				self.Owner:SetAnimation(PLAYER_ATTACK1)
				self:TakePrimaryAmmo(1) -- I know I broke my promise, but I want this gun to be a wee bit less dissapointing..
			end
		end)
	end
end

function SWEP:SecondaryAttack()    
end

function SWEP:ShouldDropOnDie()
    return true
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
    draw.SimpleText("Burst Rifle","Arial",x + wide/2,y + tall*0.35,team.GetColor( LocalPlayer():Team() ),TEXT_ALIGN_CENTER) -- is this right?
end