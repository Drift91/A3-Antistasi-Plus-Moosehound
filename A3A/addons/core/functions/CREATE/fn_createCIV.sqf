params ["_markerX"];

if (!isServer and hasInterface) exitWith{};
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

private _spawnKey = _markerX + "_civ";				// civ part of cities has a separate spawn state from the garrison

if (_markerX in destroyedSites) exitWith {};

private _dataX = server getVariable _markerX;

private _numCiv = _dataX select 0;
private _numVeh = _dataX select 1;

private _roads = nearestTerrainObjects [getMarkerPos _markerX, ["MAIN ROAD", "ROAD", "TRACK"], 250, false, true];
_roads = _roads select { !(getRoadInfo _x # 8) and (count roadsConnectedTo [_x, true] <= 2) and (count (_x nearRoads 10) < 2)};		// no bridges or junctions
if (count _roads == 0) exitWith
{
    Error_1("Roads not found for marker %1", _markerX);
};

private _prestigeOPFOR = _dataX select 2;
private _prestigeBLUFOR = _dataX select 3;

private _civs = [];
private _groups = [];
private _vehiclesX = [];
private _civsPatrol = [];
private _groupsPatrol = [];
private _vehPatrol = [];
private _size = [_markerX] call A3A_fnc_sizeMarker;

private _typeVehX = "";
private _dirVeh = 0;

private _positionX = getMarkerPos _markerX;

private _area = [_markerX] call A3A_fnc_sizeMarker;

private _roads = _roads call BIS_fnc_arrayShuffle;
private _maxRoads = count _roads;

private _numCiv = 15 * sqrt _numCiv * (1 - tierWar / 20); 			// reduce civ activity with war level
private _numParked = (_numCiv * (1/120) * civTraffic);		// civTraffic is 0,1,2(default),4
private _numTraffic = _numCiv * (1/300) * civTraffic;

if ((daytime < 8) or {daytime > 21}) then {
	_numParked = _numParked * 1.5; _numTraffic = _numTraffic / 4;
};
_numParked = 1 max (round _numParked) min _maxRoads;
_numTraffic = 1 max (round _numTraffic) min _maxRoads;

private _countParked = 0;

while {(spawner getVariable _spawnKey != 2) and (_countParked < _numParked)} do {
	private _p1 = _roads select _countParked;
	private _road = roadAt _p1;
	if (!isNull _road) then {
		if ((count (nearestObjects [_p1, ["Car", "Truck"], 5]) == 0) and {!([50,1,_road,teamPlayer] call A3A_fnc_distanceUnits)}) then {
			private _dirveh = 0;
			private _roadcon = roadsConnectedTo [_road, true];

			if (count _roadcon != 0) then {
				_p2 = getPos (_roadcon # 0);
				_dirveh = _p1 getDir _p2;
			};

			private _width = 3 max (getRoadInfo _road # 1 / 2 - 1);
			private _pos = [_p1, _width, _dirveh + 90] call BIS_Fnc_relPos;
			private _typeVehX = selectRandomWeighted civVehiclesWeighted;
			private _veh = createVehicle [_typeVehX, _pos, [], 0, "CAN_COLLIDE"];
			_veh setVariable ["originalPos", _pos];
			_veh setDir _dirveh;
            _veh setFuel random [0.10, 0.30, 0.50];
			clearMagazineCargoGlobal _veh;
			clearWeaponCargoGlobal _veh;
			clearItemCargoGlobal _veh;
			clearBackpackCargoGlobal _veh;
			_vehiclesX pushBack _veh;
			[_veh, civilian] spawn A3A_fnc_AIVEHinit;		// should cleanup if destroyed...
			[_veh, 20, random 2] call SCRT_fnc_common_addRandomMoneyCargo;
			sleep 0.5;
		};
	};
	_countParked = _countParked + 1;
};

private _mrkMar = seaSpawn select {getMarkerPos _x inArea _markerX};
if (count _mrkMar > 0) then {
	for "_i" from 0 to (round (random 3)) do {
		if (spawner getVariable _spawnKey != 2) then {
			_typeVehX = selectRandomWeighted civBoatsWeighted;
			_pos = (getMarkerPos (_mrkMar select 0)) findEmptyPosition [0,20,_typeVehX];
			_veh = _typeVehX createVehicle _pos;
			_veh setDir (random 360);
			clearMagazineCargoGlobal _veh;
			clearWeaponCargoGlobal _veh;
			clearItemCargoGlobal _veh;
			clearBackpackCargoGlobal _veh;
			_vehiclesX pushBack _veh;
			[_veh, civilian] spawn A3A_fnc_AIVEHinit;
			_veh setVariable ["originalPos", getPos _veh];
			sleep 0.5;
		};
	};
};

if (spawner getVariable _spawnKey != 2) then {
	_markerX remoteExecCall ["SCRT_fnc_civilian_createCivilianPresence",2];

	//reporter spawn
	if (random 100 < (aggressionOccupants + aggressionInvaders)) then {
		private _pos = [];
		while {true} do {
			_pos = [_positionX, round (random _area), random 360] call BIS_Fnc_relPos;
			if (!surfaceIsWater _pos) exitWith {};
		};
		private _groupX = createGroup civilian;
		_groups pushBack _groupX;
		private _civ = [_groupX, FactionGet(civ, "unitPress"), _pos, [],0, "NONE"] call A3A_fnc_createUnit;
		_civ call A3A_fnc_CIVinit;
		_civs pushBack _civ;
		_nul = [_civ, _markerX, "LIMITED","SAFE","SPAWNED","NOFOLLOW","NOVEH2","NOSHARE","DoRelax"] spawn UPSMON_fnc_UPSMON;//TODO need delete UPSMON link
	};
};

if ([_markerX,false] call A3A_fnc_fogCheck > 0.2) then {
	private _countTraffic = 0;

	private _patrolCities = [_markerX] call A3A_fnc_citiesToCivPatrol;
	if (count _patrolCities > 0) then {
		while {(spawner getVariable _spawnKey != 2) and (_countTraffic < _numTraffic)} do {
			private _p1 = selectRandom _roads;
			private _road = roadAt _p1;
			if (!isNull _road) then {
				if (count (nearestObjects [_p1, ["Car", "Truck"], 5]) == 0) then {
					private _groupP = createGroup civilian;
					_groupsPatrol pushBack _groupP;
					private _roadcon = roadsConnectedto _road;
					//_p1 = getPos (_roads select _countX);
					private _p2 = getPos (_roadcon select 0);
					private _dirveh = [_p1,_p2] call BIS_fnc_DirTo;
					private _typeVehX = selectRandomWeighted civVehiclesWeighted;
					private _veh = _typeVehX createVehicle (getPos _p1);
					[_veh, 20, random 2] call SCRT_fnc_common_addRandomMoneyCargo;
					_veh setDir _dirveh;
					clearMagazineCargoGlobal _veh;
					clearWeaponCargoGlobal _veh;
					clearItemCargoGlobal _veh;
					clearBackpackCargoGlobal _veh;

					//_veh forceFollowRoad true;
					_vehPatrol = _vehPatrol + [_veh];
					private _civ = [_groupP, FactionGet(civ, "unitMan"), (getPos _p1), [],0, "NONE"] call A3A_fnc_createUnit;
					_civ call A3A_fnc_CIVinit;
					_civsPatrol pushBack _civ;
					_civ moveInDriver _veh;
					[_veh, civilian] call A3A_fnc_AIVEHInit;

					_groupP addVehicle _veh;
					_groupP setBehaviour "CARELESS";
					_veh limitSpeed 50;
					private _posDestination = getPos (selectRandom (nearestTerrainObjects [getMarkerPos (selectRandom _patrolCities), ["ROAD", "TRACK"], 250, false, true]));
					private _wp = _groupP addWaypoint [_posDestination,0];
					_wp setWaypointType "MOVE";
					_wp setWaypointSpeed "LIMITED";
					_wp setWaypointTimeout [30, 45, 60];
					_wp = _groupP addWaypoint [_positionX,1];
					_wp setWaypointType "MOVE";
					_wp setWaypointTimeout [30, 45, 60];
					private _wp1 = _groupP addWaypoint [_positionX,2];
					_wp1 setWaypointType "CYCLE";
					_wp1 synchronizeWaypoint [_wp];
				};
			};
			_countTraffic = _countTraffic + 1;
			sleep 5;
		};
	};
};

[_markerX] call SCRT_fnc_rivals_trySpawnCarDemo;

waitUntil {sleep 1; spawner getVariable _spawnKey == 2};


{deleteVehicle _x} forEach _civs;
{deleteGroup _x} forEach _groups;

_markerX remoteExec ["SCRT_fnc_civilian_removeCivilianPresence",2];

{
	// delete all parked vehicles that haven't been stolen
	if (_x getVariable "ownerSide" == civilian) then {
		if (_x distance2d (_x getVariable "originalPos") < 100) then { deleteVehicle _x }
		else { [_x] spawn A3A_fnc_VEHdespawner };
	};
} forEach _vehiclesX;

// Chuck all the civ vehicle patrols into the despawners
{ [_x] spawn A3A_fnc_groupDespawner } forEach _groupsPatrol;
{ [_x] spawn A3A_fnc_VEHdespawner } forEach _vehPatrol;
