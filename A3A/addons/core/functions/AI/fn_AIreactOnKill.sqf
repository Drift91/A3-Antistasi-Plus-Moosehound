/*
Author: Wurzel0701, Triada, jaj22, Spoffy, Barbolani
    Defines and executes the behaviour of enemy AI in case of a down or KIA in their group

Arguments:
    <OBJECT> The unit which was downed or killed.
    <GROUP> The group of the unit. May have changed since.
    <OBJECT> The unit which downed or killed the unit

Return Value:
    <NIL>

Scope: Server/HC, local to unit/group
Environment: Scheduled
Public: Yes
Dependencies:
    <ARRAY> allMachineGuns
    <BOOL> haveNV
    <HashMap> A3A_faction_all

Example:
[_unit, _group, _killer] spawn A3A_fnc_AIreactOnKill;
*/
#include "..\..\script_component.hpp"
FIX_LINE_NUMBERS()

// TODO: what exactly should killer parameter be here?
params ["_unit", "_group", "_killer"];

if (_unit getVariable ["downedTimeout", 0] > time) exitWith {};         // only count each unit once, at least within timeout
_unit setVariable ["downedTimeout", time + 1200];

//If _killer is not set or the same side (collision for example), abort here
if((isNil "_killer") || {(isNull _killer) || {side (group _killer) == side _group}}) exitWith {};

// Add the unit to recent kills for reaction purposes
[side _group, getPosATL _unit, 10] remoteExec ["A3A_fnc_addRecentDamage", 2];

private _enemy = objNull;
private _activeGroupMembers = (units _group) select {_x call A3A_fnc_canFight};

//No group member left in fighting condition, no reaction possible
if(count _activeGroupMembers == 0) exitWith {};

//Call help if possible
if(_group getVariable ["A3A_canCallSupportAt", -1] < time) then {
    [_group, _killer] spawn A3A_fnc_callForSupportInfantry;
};

if (!fleeing leader _group and random 1 < 0.5) then
{
    private _courage = leader _group skill "courage";
    _group allowFleeing (2 - _courage - count _activeGroupMembers / count units _group);
};

{
    if (fleeing _x) then
	{
        if (_x call A3A_fnc_canFight) then
		{
            private _enemy = _x findNearestEnemy _x;
            if (!isNull _enemy) then
			{
                if ((_x distance _enemy < 50) && {vehicle _x == _x}) then
				{
                    private _fleeChance = switch (true) do {
                        case (_x getVariable ["isRival", false]): {
                            random 25
                        };
                        case (side _x == Occupants): {
                            sqrt aggressionOccupants * 2
                        };
                        default {
                            sqrt aggressionInvaders * 2
                        };
                    };

                    if (_fleeChance < 8) then {
                        _fleeChance = 8;
                    } else {
                        if (_fleeChance > 25) then {
                            _fleeChance = 25;
                        };
                    };

                    if ((random 100) < _fleeChance) then {
                        [_x] spawn SCRT_fnc_common_panicFlee;
                    } else {
                        [_x] spawn A3A_fnc_surrenderAction;
                    };
				}
                else
				{
                    if (([primaryWeapon _x] call BIS_fnc_baseWeapon) in allMachineGuns) then
                    {
                        [_x,_enemy] call A3A_fnc_suppressingFire
                    }
                    else
                    {
                        if ((random 100) < 35) then {
                            [_x,_x,_enemy] spawn A3A_fnc_chargeWithSmoke
                        };
                    };
				};
			};
		};
	}
    else
	{
        if (_x call A3A_fnc_canFight) then
		{
            //check if there is at least one soldier in squad without NVG
            private _squad = units _group;
            private _noNvgIndex = _squad findIf {hmd _x == "" || {getArray (configFile >> "CfgWeapons" >> (hmd _x) >> "visionMode") isEqualTo ["Normal","Normal"]}};

            _enemy = _x findNearestEnemy _x;
            if (!isNull _enemy) then
			{
                //machinegunner will suppress
                if (([primaryWeapon _x] call BIS_fnc_baseWeapon) in allMachineGuns) then {
                    [_x,_enemy] call A3A_fnc_suppressingFire;
                }
                else {
                    //ordinary soldier will throw smoke
                    if (sunOrMoon == 1) then {
                        if ((random 100) < 35) then {
                            [_x,_x,_enemy] spawn A3A_fnc_chargeWithSmoke;
                        };
                    } else {
                        //soldier with underbarrel launcher will launch flare if there is someone in his squad without NVG goggles, else smoke
                        if (_noNvgIndex != -1 && {count (getArray (configfile >> "CfgWeapons" >> primaryWeapon _x >> "muzzles")) == 2}) then {
                            [_x, side (group _x), _enemy] spawn A3A_fnc_useFlares;
                        } else {
                            if ((random 100) < 35) then {
                                [_x,_x,_enemy] spawn A3A_fnc_chargeWithSmoke;
                            };
                        };
					};
				};
			}
            else {
                //if there is not a day, there are people in squad without NVG goggles and there are underbarrel launcher, then flares
               if ((sunOrMoon <1) && _noNvgIndex != -1 && count (getArray (configfile >> "CfgWeapons" >> primaryWeapon _x >> "muzzles")) == 2) then {
                    [_x, side (group _x)] spawn A3A_fnc_useFlares;
				};
			};
		};
	};
    sleep (1 + random 1);
} forEach _activeGroupMembers;
