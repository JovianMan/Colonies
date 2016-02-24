

--[[---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
-----------------------------------------------------------]]
function EFFECT:Init( data )
	
	self.Target = data:GetEntity()
	self.StartTime	= CurTime()
	self.Length		= 0.3
	self.Direction	= data:GetScale()
	
end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )
	
	return self.StartTime + self.Length > CurTime()
	
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	if ( !IsValid( self.Target ) ) then return end
	
	local delta = ((CurTime() - self.StartTime) / self.Length) ^ 0.5
	local idelta = 1-delta
	
	local percent = self.Direction/10
	local color = Color(255-(255*percent),255*percent,0,255)-- alpha = 255 * idelta

	local size = 5
	halo.Add( { self.Target }, color, size, size, 1, true, false )

end
