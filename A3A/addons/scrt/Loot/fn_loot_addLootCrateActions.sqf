params ["_lootCrate"];

[_lootCrate] remoteExec ["SCRT_fnc_loot_addActionLoot", [teamPlayer, civilian], _lootCrate];
[_lootCrate] remoteExec ["SCRT_fnc_common_addActionMove", [teamPlayer, civilian], _lootCrate];
[_lootCrate] call A3A_Logistics_fnc_addLoadAction;