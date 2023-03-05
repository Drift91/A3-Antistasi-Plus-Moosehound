#include "..\defines.inc"
FIX_LINE_NUMBERS()
#include "\a3\ui_f\hpp\definedikcodes.inc"

params ["_displayOrControl", "_key", "_shift", "_ctrl", "_alt"];

private _handled = false;

if (reviveKitsEnabled) then {
	switch (_key) do {
		case DIK_R: {
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
			player spawn A3A_fnc_respawn;
		};
		case DIK_T: {
			private _nearFriendlyUnits = [] call SCRT_fnc_common_getNearFriendlyAiUnits;

			if (time < (player getVariable ["A3A_possessTime", time - 1])) exitWith {
				[localize "STR_antistasi_dialogs_ai_control_title", localize "STR_A3AP_notifications_possess_cooldown"] call SCRT_fnc_misc_deniedHint;
			};
			
			if (_nearFriendlyUnits isNotEqualTo []) then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
				[_nearFriendlyUnits] spawn SCRT_fnc_common_possessNearestFriendlyAI;
			};
		};
		case DIK_Q: {
			if ("A3AP_SelfReviveKit" in (backpackItems player)) then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
				[player, player] call SCRT_fnc_common_revive;
			};
		};
	#if __A3_DEBUG__
		case DIK_F: {
			player setVariable ["incapacitated",false,true]; 
			player setDamage 0;
		};
	#endif
	};
} else {
	switch (_key) do {
		case DIK_R: {
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
			player spawn A3A_fnc_respawn;
		};
		case DIK_T: {
			private _nearFriendlyUnits = [] call SCRT_fnc_common_getNearFriendlyAiUnits;
			if (_nearFriendlyUnits isNotEqualTo []) then {
				(findDisplay 46) displayRemoveEventHandler ["KeyDown", respawnMenu];
				[_nearFriendlyUnits] spawn SCRT_fnc_common_possessNearestFriendlyAI;
			};
		};
	#if __A3_DEBUG__
		case DIK_F: {
			player setVariable ["incapacitated",false,true]; 
			player setDamage 0;
		};
	#endif
	};
};

_handled;