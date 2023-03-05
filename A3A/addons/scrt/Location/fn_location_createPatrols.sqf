/*
Maintainer: Socrates
    Creates patrols for any outpost type. 
	Rough copy of typical patrol function from createAiOutposts/Airplane/Resource.


Return Value:
    <STRING> Unit class
    <ARRAY> Group of unit classnames

Scope: Client, Server
Environment: Scheduled
Public: Yes

Example:
[_markerX, _positionX, _sideX, 4] call SCRT_fnc_location_createPatrols;
*/

params [
	["_marker", "", [""]],
	["_markerPosition", [], [[]]],
	["_side", sideUnknown, [sideUnknown]],
	["_faction", createHashMap, [createHashMap]],
	["_patrolCount", 4, [0]]
];

private _countX = 0;
private _arrayGroups = [_faction, "groupsTierSmall"] call SCRT_fnc_unit_flattenTier;
private _sniperGroup = [_faction get "groupTierSniper"] call SCRT_fnc_unit_getTiered;

if ([_marker, false] call A3A_fnc_fogCheck < 0.3) then {
	_arrayGroups deleteAt 0;
};

while {_countX < _patrolCount} do {
	private _typeGroup = selectRandom _arrayGroups;
	private _groupX = [_markerPosition, _side, _typeGroup, false, true] call A3A_fnc_spawnGroup;
	if !(isNull _groupX) then
	{
		sleep 1;
		if ((random 10 < 2.5) && {_typeGroup isNotEqualTo _sniperGroup}) then
		{
			private _dog = [_groupX, "Fin_random_F",_markerPosition,[],0,"FORM"] call A3A_fnc_createUnit;
			_dogs pushBack _dog;
			[_dog] spawn A3A_fnc_guardDog;
			sleep 1;
		};
		_nul = [leader _groupX, _mrk, "LIMITED", "SAFE", "SPAWNED", "RANDOM", "NOVEH2"] spawn UPSMON_fnc_UPSMON;//TODO need delete UPSMON link
		_groups pushBack _groupX;
		{
			[_x,_markerX] call A3A_fnc_NATOinit; 
			_soldiers pushBack _x
		} forEach units _groupX;
	};
	_countX = _countX +1;
};