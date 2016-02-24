
--[[---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
-----------------------------------------------------------]]
function EFFECT:Init( data )
	
	local vOffset = data:GetOrigin()
	local Color = data:GetStart()
	local Radius = data:GetRadius()
	
	sound.Play( "garrysmod/balloon_pop_cute.wav", vOffset, 90, math.random( 90, 120 ) )
	
	local emitter = ParticleEmitter( vOffset, true )
	
		for i=0, math.random(3,4) do
			
			local X = math.random(-Radius,Radius)
			local Y = math.random(-Radius,Radius)
			local Z = math.sqrt(math.abs(X^2+Y^2-Radius^2))*math.random(-1,1)
			
			local Pos = Vector( X,Y,Z )
		
			local particle = emitter:Add( "vgui/colonies/bubble_drop", vOffset + Pos * 8 )
			if (particle) then
				
				particle:SetVelocity( Pos * 5 )
				
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 10 )
				
				particle:SetAngles( (vOffset-Pos):Angle() )
				
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 255 )
				
				local Size = math.Rand( 1, 3 )
				particle:SetStartSize( Size )
				particle:SetEndSize( 0 )
				
				particle:SetRoll( 0 )
				particle:SetRollDelta( 0 )
				
				particle:SetAirResistance( 10 )
				particle:SetGravity( Vector(0,0,-300) )
				
				local RandDarkness = math.Rand( 0.8, 1.0 )
				particle:SetColor( Color.r*RandDarkness, Color.g*RandDarkness, Color.b*RandDarkness )
				
				particle:SetCollide( true )
				
				particle:SetAngleVelocity( Angle( math.Rand( -160, 160 ), math.Rand( -160, 160 ), math.Rand( -160, 160 ) ) ) 
				
				particle:SetBounce( 0 )
				particle:SetLighting( true )
				
			end
			
		end
		
	emitter:Finish()
	
end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	return false
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()
end
