if (SERVER) then --the init.lua stuff goes in here
	AddCSLuaFile ()
   SWEP.Weight = 500;
   SWEP.AutoSwitchTo = false;
   SWEP.AutoSwitchFrom = false;
   --resource.AddFile( "materials/aimbot/killico.png" )
end
 
if (CLIENT) then --the cl_init.lua stuff goes in here
 
 
   SWEP.PrintName = "Rocket Launcher";
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
SWEP.Purpose        = "BLOW THOSE MOTHER F***ERS UP"
SWEP.Instructions   = "Click Mouse1 to shower your enemies in hot gasses"

SWEP.ViewModel                = "models/weapons/v_rpg.mdl"
SWEP.WorldModel                = "models/weapons/w_rocket_launcher.mdl"

SWEP.HoldType                = "rpg"
SWEP.ViewModelFlip            = false -- I don't like left-side SWEPs either.

SWEP.Primary.ClipSize        = 2
SWEP.Primary.DefaultClip    = 2
SWEP.Primary.Delay            = 2.4
SWEP.Primary.Automatic        = false
SWEP.Primary.Ammo            = "RPG_Round"

SWEP.Primary.Sound = 		Sound( "weapons/rpg/rocketfire1.wav" )
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
	if (!self:CanPrimaryAttack()) then return end
    self.Weapon:EmitSound(self.Primary.Sound)

    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self.Owner:SetAnimation(PLAYER_ATTACK1)
	timer.Create("RPG_RELOAD",0.7,1,function() 
		if self:Clip1() > 0 then
			self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		end
	end)
	if CLIENT then return end
	local firework = ents.Create( "ent_rocket" )
	firework:SetPos(self.Owner:GetShootPos()+self.Owner:GetAimVector()*50)
	firework.Owner = self.Owner
	firework:Spawn()
	firework:Activate()
	firework:SetAngles( self.Owner:EyeAngles()+Angle(math.random(-10,10)/10,math.random(-10,10)/10,math.random(-10,10)/10) )
	firework:GetPhysicsObject():AddAngleVelocity( Vector(math.random(-100,100)/10,math.random(-100,100)/10,math.random(-100,100)/10) )
	
	self:TakePrimaryAmmo(1)
	if self:Clip1() == 0 then
		self.Weapon:SetNextPrimaryFire(CurTime())
	end
end

function SWEP:SecondaryAttack()    
end

function SWEP:ShouldDropOnDie()
    return true
end

function SWEP:DrawWeaponSelection(x,y,wide,tall,alpha)
    draw.SimpleText("Rocket Launcher","Arial",x + wide/2,y + tall*0.35,team.GetColor( LocalPlayer():Team() ),TEXT_ALIGN_CENTER) -- is this right?
end