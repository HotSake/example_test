-- Additional utitility functions for the mod

-- Find the interior angle between 3 points
function getAngleFromPoints(center,p1,p2)
	if type(center) ~= "table" or type(p1) ~= "table" or type(p2) ~= "table" then return end
	-- Make vectors A and B from the points
	local A = {p1.x-center.x,p1.y-center.y}
	local B = {p2.x-center.x,p2.y-center.y}

	return math.deg(math.atan2(B[2],B[1]) - math.atan2(A[2],A[1]))
end