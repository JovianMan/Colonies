function legBreaker( ply, vel ) 
	return 0
end
hook.Add( "GetFallDamage", "ThisWillNOTBreakYourLegs", legBreaker )
