GetDistance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
    return floatround( floatsqroot( ( ( x1 - x2 ) * ( x1 - x2 ) ) + ( ( y1 - y2 ) * ( y1 - y2 ) ) + ( ( z1 - z2 ) * ( z1 - z2 ) ) ) );

GetVehicleRotation(vehicleid, &Float:rx, &Float:ry, &Float:rz)
{
	new Float:qw,Float:qx,Float:qy,Float:qz;
	GetVehicleRotationQuat(vehicleid,qw,qx,qy,qz);
	rx = asin(2*qy*qz-2*qx*qw);
	ry = -atan2(qx*qz+qy*qw,0.5-qx*qx-qy*qy);
	rz = -atan2(qx*qy+qz*qw,0.5-qx*qx-qz*qz);
}

GetPlayerNameEx(playerid)
{
	new _pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, _pName, MAX_PLAYER_NAME);
	return _pName;
}