
#include "..\defines.inc"
FIX_LINE_NUMBERS()

private _lootCrateType = FactionGet(reb, "lootCrate");

vehiclePurchase_cost = round ([_lootCrateType] call A3A_fnc_vehiclePrice);

private _resourcesFIA = 0;

if (player != theBoss) then {
	_resourcesFIA = player getVariable "moneyX";
} else {
	private _factionMoney = server getVariable "resourcesFIA";
	if (vehiclePurchase_cost <= _factionMoney) then {
		_resourcesFIA = _factionMoney;
	} else {
		_resourcesFIA = player getVariable "moneyX";
	};
};

if (_resourcesFIA < vehiclePurchase_cost) exitWith {
    [localize "STR_scrt_stores_buy_item_not_enough_header", format [localize "STR_scrt_stores_buy_item_not_enough", vehiclePurchase_cost, A3A_faction_civ get "currencySymbol"]] call SCRT_fnc_misc_deniedHint;
};

private _extraMessage = format [localize "STR_veh_callback_placement_text", localize "STR_veh_callback_placement_text_additive_lootcrate", vehiclePurchase_cost, A3A_faction_civ get "currencySymbol"];

[_lootCrateType, "CREATELOOTCRATE", [], nil, nil, nil, false, _extraMessage] call HR_GRG_fnc_confirmPlacement;