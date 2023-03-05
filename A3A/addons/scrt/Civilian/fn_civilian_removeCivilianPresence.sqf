
#include "..\defines.inc"
FIX_LINE_NUMBERS()

if (civPedestrians == 0) exitWith {};

private _marker = _this;

if (_marker in destroyedSites) exitWith {};

private _position = getMarkerPos _marker;

Info_1("Removing Civ Presence Modules for %1", _marker);

private _cities = ["NameCityCapital","NameCity"] call SCRT_fnc_misc_getWorldPlaces;
private _isCity = _cities findIf {(_x select 1) distance2D _position <= 250} == 0;
private _size = if (_isCity) then {550} else {300}; 
private _presenceModules = nearestObjects [_position, ["ModuleCivilianPresenceSafeSpot_F", "ModuleCivilianPresenceUnit_F", "ModuleCivilianPresence_F"], _size, true];
{
	deleteVehicle _x;
} forEach _presenceModules;

Info_1("Removed Civ Presence Modules for %1, waiting 30 sec before deleting remaining agents.", _marker);
sleep 30;
Info_1("Removing leftover agents.", _marker);

{
	deleteVehicle (agent _x);
} forEach (agents select {private _agent = agent _x; _agent isKindOf "CAManBase" && {_agent inArea [_position,_size,_size,0,true,-1]}});

Info("Civ Presence removed, job has been completed.");