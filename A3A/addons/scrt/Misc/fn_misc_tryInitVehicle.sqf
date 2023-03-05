/*
Maintainer: Socrates
    Sets animation source on already spawn vehicle if it exists. 

Arguments:
    <OBJECT> Vehicle

Return Value:
    <NIL>

Scope: Server
Environment: Any
Public: Yes
Dependencies:
    <HASHMAP> animations
    <HASHMAP> variants

Example:
[_vehicle] call SCRT_fnc_misc_tryInitVehicle;
*/

params [
	["_vehicle", objNull, [objNull, ""]]
];


private _anims = (A3A_faction_all get "animations") getOrDefault [(typeOf _vehicle), []];
private _variants = (A3A_faction_all get "variants") getOrDefault [(typeOf _vehicle), false];

if (_anims isEqualTo [] && _variants isEqualTo false) exitWith {};

[_vehicle, _variants, _anims] call BIS_fnc_initVehicle;