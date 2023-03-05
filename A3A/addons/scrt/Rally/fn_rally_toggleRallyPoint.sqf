#include "..\script_component.hpp"
FIX_LINE_NUMBERS()

private _rallyPointClass = FactionGet(reb,"rallyPoint");

if (!isNil "isRallyPointPlaced" && {isRallyPointPlaced}) then {
    private _hqMarkerPos = getMarkerPos "Synd_HQ";
    private _rallyPointMarkerPos = getMarkerPos "RallyPointMarker";

    if (player distance2D _hqMarkerPos > 50 && {player distance2D _rallyPointMarkerPos > 50}) exitWith {
        [localize "STR_dialogs_RP_header", localize "STR_dialogs_RP_abolish_fail"] call SCRT_fnc_misc_deniedHint;
    };

    private _cost = [_rallyPointClass] call A3A_fnc_vehiclePrice;
    private _remainingTravels = rallyPointRoot getVariable ["remainingTravels", 0];
    if (_remainingTravels > 0) then {
        private _finalCost = _cost * _remainingTravels;
        if (_finalCost < 100) then {
            _finalCost = 100;
        };
        
        [0, round (_finalCost/1.3)] remoteExec ["A3A_fnc_resourcesFIA",2];
    };

    isRallyPointPlaced = false;
    publicVariable "isRallyPointPlaced";

    {
        deleteVehicle _x;
    } forEach rallyProps;

    rallyProps = nil;
    publicVariable "rallyProps";

    deleteVehicle rallyPointRoot;
    rallyPointRoot = nil;
    publicVariable "rallyPointRoot";

    deleteMarker rallyPointMarker;
    deleteMarker "RallyPointMarker";
    publicVariable "rallyPointMarker";

    [petros, "support", localize "STR_dialogs_RP_abolish_success"] remoteExec ["A3A_fnc_commsMP", 0];
} else {
    private _cost = [_rallyPointClass] call A3A_fnc_vehiclePrice;
    private _finalCost = _cost * rallyPointSpawnCount;
    private _resourcesFIA = server getVariable "resourcesFIA";    

    if (_resourcesFIA < _finalCost) exitWith {
        [localize "STR_dialogs_RP_header", format [localize "STR_dialogs_RP_no_money_fail", str _finalCost]] call SCRT_fnc_misc_deniedHint;
    };

    if ([(position player), 50] call A3A_fnc_enemyNearCheck) exitWith {
        [localize "STR_dialogs_RP_header", localize "STR_dialogs_RP_enemies_near_fail"] call SCRT_fnc_misc_deniedHint;
    };

    if (player != theBoss) exitWith {
        [localize "STR_dialogs_RP_header", localize "STR_dialogs_RP_comm_only_fail"] call SCRT_fnc_misc_deniedHint;
    };

    vehiclePurchase_cost = _finalCost;

    private _extraMessage = format  [localize "STR_dialogs_RP_select_pos", vehiclePurchase_cost, A3A_faction_civ get "currencySymbol"];

    ["Land_TentSolar_01_folded_olive_F", "CREATERALLYPOINT", [], nil, nil, nil, false, _extraMessage] call HR_GRG_fnc_confirmPlacement;
};