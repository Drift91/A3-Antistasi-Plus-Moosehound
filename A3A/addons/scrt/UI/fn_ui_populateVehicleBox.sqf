private _buyableVehiclesList = [];

// Add civ vehicles to the list
private _civilianVehicles = [
	A3A_faction_reb get "vehicleCivCar", 
	A3A_faction_reb get "vehicleCivTruck", 
	A3A_faction_reb get "vehicleCivBoat"
] select {_x isNotEqualTo ""};

private _civHeli = A3A_faction_reb get "vehicleCivHeli";
if (!isNil "_civHeli" && {{sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0}) then {
	_civilianVehicles pushBack _civHeli;
};

{
	private _vehiclePrice = [_x] call A3A_fnc_vehiclePrice;
	_buyableVehiclesList pushBack [_x, _vehiclePrice, true];
} forEach _civilianVehicles;

// Add military vehicles to the list
private _militaryVehicles = [
	A3A_faction_reb get "vehicleBasic", 
	A3A_faction_reb get "vehicleTruck", 
	A3A_faction_reb get "vehicleLightUnarmed"
] select {_x isNotEqualTo ""};

if (tierWar > 2) then {
	private _availableVehs = [
		A3A_faction_reb get "vehicleLightArmed", 
		A3A_faction_reb get "staticMG"
	] select {_x isNotEqualTo ""};
	_militaryVehicles append _availableVehs;
};

if (tierWar > 3) then {
	private _availableVehs = [
		A3A_faction_reb get "vehicleAT", 
		A3A_faction_reb get "vehicleAA", 
		A3A_faction_reb get "staticAT", 
		A3A_faction_reb get "staticAA"
	] select {_x isNotEqualTo ""};
	_militaryVehicles append _availableVehs;
};

if (tierWar > 4) then {
	private _mortar = A3A_faction_reb get "staticMortar";
	if (_mortar isNotEqualTo "") then {
		_militaryVehicles pushBack _mortar;
	};
};

if ({sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count factories > 4) then {
	private _repairVehicle = A3A_faction_reb get "vehicleRepair";
	if (_repairVehicle isNotEqualTo "") then {
		_militaryVehicles pushBack _repairVehicle;
	};
};

if ({sidesX getVariable [_x,sideUnknown] isEqualTo teamPlayer} count airportsX > 0) then {
	private _plane = A3A_faction_reb get "vehiclePlane";
	if (_plane isNotEqualTo "") then {
		_militaryVehicles pushBack _plane;
	};
};

{
	private _vehiclePrice = [_x] call A3A_fnc_vehiclePrice;
	_buyableVehiclesList pushBack [_x, _vehiclePrice, false];
} forEach _militaryVehicles;

_buyableVehiclesList;