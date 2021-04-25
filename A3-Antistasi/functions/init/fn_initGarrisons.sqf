//Original Author: Barbolani
//Edited and updated by the Antistasi Community Development Team
scriptName "fn_initGarrisons";
private _fileName = "fn_initGarrisons";
[2,"InitGarrisons started",_fileName] call A3A_fnc_log;

_fnc_initMarker =
{
	params ["_mrkCSAT", "_target", "_mrkType", "_mrkText", ["_useSideName", false]];

	{
		private _pos = getMarkerPos _x;
		private _mrk = createMarker [format ["Dum%1", _x], _pos];
		//TODO Multilanguage variable insted text
		_mrk setMarkerShape "ICON";

		if (_useSideName) then
		{
			killZones setVariable [_x, [], true];
			server setVariable [_x, 0, true];

			private _sideName = if (_x in _mrkCSAT) then {nameInvaders} else {nameOccupants};
			_mrk setMarkerText format [_mrkText, _sideName];
		}
		else
		{
			_mrk setMarkerText _mrkText;
		};

		if (_x in airportsX) then
		{
			private _flagType = if (_x in _mrkCSAT) then {flagCSATmrk} else {flagNATOmrk};
			_mrk setMarkerType _flagType;
		}
		else
		{
			_mrk setMarkerType _mrkType;
		};

		if (_x in _mrkCSAT) then
		{
			if !(_x in airportsX) then {_mrk setMarkerColor colorInvaders;} else {_mrk setMarkerColor "Default"};
			sidesX setVariable [_x, Invaders, true];
		}
		else
		{
			if !(_x in airportsX) then {_mrk setMarkerColor colorOccupants;} else {_mrk setMarkerColor "Default"};
			sidesX setVariable [_x, Occupants, true];
		};

		[_x] call A3A_fnc_createControls;
	} forEach _target;
};


_fnc_initGarrison =
{
	params ["_markerArray", "_type"];
	private ["_side", "_groupsRandom", "_garrNum", "_garrisonOld", "_marker"];
	{
	    _marker = _x;
			_garrNum = ([_marker] call A3A_fnc_garrisonSize) / 8;
			_side = sidesX getVariable [_marker, sideUnknown];
			if(_side != Occupants) then
			{
				private _squads = [_side, "SQUAD"] call SCRT_fnc_unit_getGroupSet;
				_groupsRandom = [_squads, groupsFIASquad] select ((_marker in outposts) && (gameMode == 4));
			}
			else
			{
				if(_type != "Airport" && {_type != "Outpost"} && {_type != "MilitaryBase"}) then
				{
					_groupsRandom = groupsFIASquad;
				}
				else
				{
					private _squads = [_side, "SQUAD"] call SCRT_fnc_unit_getGroupSet;
	 				_groupsRandom = _squads;
				};
			};
			//Old system, keeping it intact for the moment
			_garrisonOld = [];
			for "_i" from 1 to _garrNum do
			{
				_garrisonOld append (selectRandom _groupsRandom);
			};
			//Old system, keeping it runing for now
			garrison setVariable [_marker, _garrisonOld, true];

	} forEach _markerArray;
};

private _mrkNATO = [];
private _mrkCSAT = [];
private _controlsNATO = [];
private _controlsCSAT = [];

if (debug) then
{
	diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | Setting Control Marks for Worldname: %2  .", servertime, worldName];
};

if (gameMode == 1) then
{
	_controlsNATO = controlsX;
	switch (toLower worldName) do {
		case "tanoa": {
			_mrkCSAT = ["airport_1", "seaport_5", "outpost_10", "control_20"];
			_controlsCSAT = ["control_20"];
		};
		case "altis": {
			_mrkCSAT = ["airport_2", "seaport_4", "outpost_5", "outpost_6", "milbase_4", "control_52", "control_33"];
			_controlsCSAT = ["control_52", "control_33"];
		};
		case "enoch": {
			_mrkCSAT = ["airport_3", "factory_6", "factory_7", "outpost_16", "resource_15"];
			_controlsCSAT = ["control_14", "control_47"];
		};
		case "vt7": {
			_mrkCSAT = ["airport_2", "control_25", "control_29", "control_30", "control_31", "control_32", "Seaport_1", "Outpost_3"];
			_controlsCSAT = ["control_25", "control_29", "control_30", "control_31", "control_32"];
		};
		case "stratis": {
			_mrkCSAT = ["outpost_3"];
		};
		case "cup_chernarus_a3": {
			_mrkCSAT = ["airport_3","outpost_24","outpost_20", "outpost_23", "outpost_20","seaport_5","control_143", "control_144", "control_145", "control_149", "control_147","control_169", "control_165", "control_138", "control_137", "control_158"];
            _controlsCSAT = ["control_143", "control_144", "control_145", "control_149", "control_147","control_169", "control_165", "control_138", "control_137", "control_158"];
		};
		case "napf": {
			_mrkCSAT = ["airport_2", "outpost_5", "outpost_6", "outpost_7", "seaport_1","control_44", "control_49", "control_43", "control_53", "control_23", "control_52", "control_46", "control_47", "control_54", "control_50", "control_16", "control_17"];
            _controlsCSAT = ["control_44", "control_49", "control_43", "control_53", "control_23", "control_52", "control_46", "control_47", "control_54", "control_50", "control_16", "control_17"];
		};
		case "abramia": {
			_mrkCSAT = ["airport_2", "outpost_5", "outpost_7", "factory_4", "outpost_8", "resource_2", "resource_4", "seaport_3", "airport_3"];
            _controlsCSAT = ["control_43", "control_39", "control_40", "control_41", "control_44", "control_45", "control_46", "control_36", "control_37", "control_42"];
		};
		case "panthera3": {
			_mrkCSAT = ["airport_4", "outpost_9", "outpost_10", "outpost_12", "control_64", "control_63", "control_50", "control_65"];
            _controlsCSAT = ["control_64", "control_63", "control_50", "control_65"];
		};
		case "takistan": {
			_mrkCSAT = ["airport_1", "outpost_5", "outpost_6", "outpost_7", "outpost_8", "resource", "resource_5", "resource_6"];
			_controlsCSAT = ["control", "control_1", "control_2", "control_5", "control_13", "control_20", "control_21", "control_22", "control_24", "control_25", "control_31"];
		};
		case "sara": {
			_mrkCSAT = ["airport_1", "seaport_6", "outpost_22", "outpost_15", "resource_9", "outpost_19", "outpost_14", "resource_11"];
			_controlsCSAT = ["control_28", "control_27"];
		};
	};
    _controlsNATO = _controlsNATO - _controlsCSAT;
	_mrkNATO = markersX - _mrkCSAT - ["Synd_HQ"];

	if (debug) then {
		diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | _mrkCSAT: %2.", servertime, _mrkCSAT];
		diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | _mrkNATO: %2.", servertime, _mrkNATO];
	};
}
else
{
	if (gameMode == 4) then
	{
		_mrkCSAT = markersX - ["Synd_HQ"];
		_controlsCSAT = controlsX;
	}
	else
	{
		_mrkNATO = markersX - ["Synd_HQ"];
		_controlsNATO = controlsX;
	};
};

{sidesX setVariable [_x, Occupants, true]} forEach _controlsNATO;
{sidesX setVariable [_x, Invaders, true]} forEach _controlsCSAT;

[_mrkCSAT, airportsX, flagCSATmrk, "%1 Airbase", true] call _fnc_initMarker;
[_mrkCSAT, resourcesX, "loc_rock", "Resources"] call _fnc_initMarker;
[_mrkCSAT, factories, "u_installation", "Factory"] call _fnc_initMarker;
[_mrkCSAT, outposts, "loc_bunker", "%1 Outpost", true] call _fnc_initMarker;
[_mrkCSAT, seaports, "b_naval", "Sea Port"] call _fnc_initMarker;
[_mrkCSAT, milbases, "b_hq", "%1 Military Base", true] call _fnc_initMarker;

if (!(isNil "loadLastSave") && {loadLastSave}) exitWith {};

//Set carrier markers to the same as airbases below.
if (isServer) then {"NATO_carrier" setMarkertype flagNATOmrk};
if (isServer) then {"CSAT_carrier" setMarkertype flagCSATmrk};

if (debug) then {
	diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | Setting up Airbase stuff.", servertime];
};

[airportsX, "Airport"] call _fnc_initGarrison;					//Old system
[airportsX, "Airport", [0,0,0]] call A3A_fnc_createGarrison;	//New system

if (debug) then {
	diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | Setting up Resource stuff.", servertime];
};

[resourcesX, "Resource"] call _fnc_initGarrison;			//Old system
[resourcesX, "Other", [0,0,0]] call A3A_fnc_createGarrison;	//New system

if (debug) then {
	diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | Setting up Factory stuff.", servertime];
};

[factories, "Factory"] call _fnc_initGarrison;
[factories, "Other", [0,0,0]] call A3A_fnc_createGarrison;

if (debug) then {
	diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | Setting up Outpost stuff.", servertime];
};

[outposts, "Outpost"] call _fnc_initGarrison;
[outposts, "Outpost", [1,1,0]] call A3A_fnc_createGarrison;

if (debug) then {
	diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | Setting up Seaport stuff.", servertime];
};

[seaports, "Seaport"] call _fnc_initGarrison;
[seaports, "Other", [1,0,0]] call A3A_fnc_createGarrison;

if (debug) then {
	diag_log format ["%1: [Antistasi] | DEBUG | initGarrisons.sqf | Setting up Military Base stuff.", servertime];
};

[milbases, "MilitaryBase"] call _fnc_initGarrison;
[milbases, "MilitaryBase", [0,0,0]] call A3A_fnc_createGarrison;

//New system, adding cities
[citiesX, "City", [0,0,0]] call A3A_fnc_createGarrison;

[2,"InitGarrisons completed",_fileName] call A3A_fnc_log;
