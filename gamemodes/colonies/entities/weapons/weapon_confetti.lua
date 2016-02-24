if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 500;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;
   --resource.AddFile( "materials/aimbot/killico.png" )
end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Confetti Blaster";
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
SWEP.Purpose        = "To fill the battlefield with hard to clean up peices of paper!"
SWEP.Instructions   = "Click Mouse1 to make the clean-up crews' lives a living hell"

SWEP.ViewModel                = "models/weapons/v_shotgun.mdl"
SWEP.WorldModel                = "models/weapons/w_shotgun.mdl"

SWEP.HoldType                = "shotgun"
SWEP.ViewModelFlip            = false -- I don't like left-side SWEPs either.

SWEP.Primary.ClipSize        = 0
SWEP.Primary.DefaultClip    = 0
SWEP.Primary.Delay            = 0.85
SWEP.Primary.Automatic        = false
SWEP.Primary.Ammo            = "none"

SWEP.Primary.Sound = 		Sound( "weapons/smg1/smg1_fire1.wav" )
SWEP.Primary.Recoil            = 500
SWEP.Primary.Damage            = 1
SWEP.Primary.NumShots        = 1
SWEP.Primary.Cone            = 0.1

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
	
    killicon.Add( "weapon_confetti", "", color_white ) --aimbot/killico
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
    
    self.Weapon:EmitSound("weapons/shotgun/shotgun_fire" .. math.random(6,7) .. ".wav",65)

    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local fx = EffectData()
	fx:SetOrigin(self.Owner:GetShootPos()+self.Owner:GetAimVector()*30)
	fx:SetNormal(self.Owner:GetAimVector())
	util.Effect("confetti_blast", fx)
	
	timer.Create( "pump", 0.25, 1, function() 
		self.Weapon:SendWeaponAnim(ACT_SHOTGUN_PUMP)
	end)
end

function SWEP:SecondaryAttack()    
end

function SWEP:ShouldDropOnDie()
    return true
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
    draw.SimpleText("Confetti Blaster","Arial",x + wide/2,y + tall*0.35,team.GetColor( LocalPlayer():Team() ),TEXT_ALIGN_CENTER) -- is this right?
end