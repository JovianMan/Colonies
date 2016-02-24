if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 500;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;
   --resource.AddFile( "materials/aimbot/killico.png" )
end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Fireworks Gun";
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
SWEP.Purpose        = "To fill the air with colorful chemicals!"
SWEP.Instructions   = "Click Mouse1 to shower everyone in celebration!"

SWEP.ViewModel                = "models/weapons/v_smg1.mdl"
SWEP.WorldModel                = "models/weapons/w_smg1.mdl"

SWEP.HoldType                = "smg"
SWEP.ViewModelFlip            = false -- I don't like left-side SWEPs either.

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Delay            = 0.2
SWEP.Primary.Automatic        = true
SWEP.Primary.Ammo            = "none"

SWEP.Primary.Sound = 		Sound( "weapons/smg1/smg1_fire1.wav" )
SWEP.Primary.Recoil            = 500
SWEP.Primary.Damage            = 1
SWEP.Primary.NumShots        = 1
SWEP.Primary.Cone            = 0.04

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
	
    killicon.Add( "weapon_fireworks", "", color_white ) --aimbot/killico
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

    self.Weapon:EmitSound(self.Primary.Sound)

    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	if CLIENT then return end
	local firework = ents.Create( "ent_firework" )
	firework:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*100)
	firework.Owner = self.Owner
	firework:Spawn()
	firework:Activate()
	firework:SetAngles( self.Owner:EyeAngles()+Angle(math.random(-10,10)/10,math.random(-10,10)/10,math.random(-10,10)/10) )
	firework:GetPhysicsObject():AddAngleVelocity( Vector(math.random(-100,100)/10,math.random(-100,100)/10,math.random(-100,100)/10) )
end

function SWEP:SecondaryAttack()    
end

function SWEP:ShouldDropOnDie()
    return true
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
    draw.SimpleText("Fireworks Gun","Arial",x + wide/2,y + tall*0.35,team.GetColor( LocalPlayer():Team() ),TEXT_ALIGN_CENTER) -- is this right?
end