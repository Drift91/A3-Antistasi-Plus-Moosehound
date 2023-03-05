params ["_treatedUnit", "_medic"];

if !(isNull (_treatedUnit getVariable ["helped",objNull])) exitWith {};
if (isPlayer _medic) exitWith {};
if (_medic getVariable ["helping",false]) exitWith {};

_treatedUnit setVariable ["helped",_medic];
_medic setVariable ["helping",true];
_medic setVariable ["maneuvering",true];

private _isCured = false;
private _hasPlayer = if ((units group _treatedUnit) findIf {isPlayer _x} != -1) then {true} else {false};

if (_medic != _treatedUnit) then {
	if !(_treatedUnit getVariable ["incapacitated",false]) then {
		if (_hasPlayer) then {_treatedUnit groupChat format [localize "STR_chats_help_ask", name _treatedUnit]};
		playSound3D [(selectRandom injuredSounds),_treatedUnit,false, getPosASL _treatedUnit, 1, 1, 50];
	};

	if (_hasPlayer) then {
		[_medic,_treatedUnit] spawn {
			sleep 2;
			private ["_medic","_treatedUnit"];
			_medic = _this select 0;
			_treatedUnit = _this select 1;
			_medic groupChat format [localize "STR_chats_help_response",name _treatedUnit]
		};
	};

	if (hasInterface && {player == _treatedUnit}) then {
		[localize "STR_chats_help_notification_header", format [localize "STR_chats_help_notification_desc", name _medic]] call A3A_fnc_customHint;
	};

	private _enemy = _medic findNearestEnemy _treatedUnit;
	if ((random 100) < 50) then {
		[_medic,_treatedUnit,_enemy] call A3A_fnc_chargeWithSmoke;
	};

	_medic stop false;
	_medic forceSpeed -1;
	private _timeOut = time + 60;
	sleep 5;
	_medic doMove getPosATL _treatedUnit;
	while {true} do {
		sleep 1;
		if (!([_medic] call A3A_fnc_canFight) or 
			(!alive _treatedUnit) or 
			(unitReady _medic) or 
			(_medic distance _treatedUnit <= 3) or 
			(_timeOut < time) or 
			(_treatedUnit != vehicle _treatedUnit) or 
			(_medic != vehicle _medic) or 
			(_medic != _treatedUnit getVariable ["helped",objNull]) or 
			!(isNull attachedTo _treatedUnit) or 
			(_medic getVariable ["cancelRevive",false]) or 
			(_treatedUnit getVariable ["A3A_blockRevive",false])
		) exitWith {};
	};

	if ((_treatedUnit distance _medic <= 3)
		&& !(_treatedUnit getVariable ["A3A_blockRevive",false])
		&& (alive _treatedUnit)
		&& ([_medic] call A3A_fnc_canFight)
		&& (_medic == vehicle _medic)
		&& (_medic == _treatedUnit getVariable ["helped",objNull])
		&& (isNull attachedTo _treatedUnit)
		&& !(_medic getVariable ["cancelRevive",false])) then {

		if (_treatedUnit getVariable ["incapacitated",false] &&
			!isNull _enemy &&
			_timeOut >= time &&
			_medic != _treatedUnit
		) then {
			private _coverX = [_treatedUnit,_enemy] call A3A_fnc_coverage;

			{
				if (([_x] call A3A_fnc_canFight) && (_x distance _medic < 50) && !(_x getVariable ["helping",false]) && (!isPlayer _x)) then {[_x,_enemy] call A3A_fnc_suppressingFire}
			} forEach units (group _medic);
			if (count _coverX == 3) then {
				_medic setUnitPos "MIDDLE";
				_medic playAction "grabDrag";
				sleep 0.1;
				_timeOut = time + 5;

				waitUntil {
					sleep 0.3;
					((animationState _medic) == "AmovPercMstpSlowWrflDnon_AcinPknlMwlkSlowWrflDb_2")
					|| ((animationState _medic) == "AmovPercMstpSnonWnonDnon_AcinPknlMwlkSnonWnonDb_2")
					|| !([_medic] call A3A_fnc_canFight)
					|| (_timeOut < time)
				};

				if ([_medic] call A3A_fnc_canFight) then {
					[_treatedUnit,"AinjPpneMrunSnonWnonDb"] remoteExec ["switchMove"];
					_medic disableAI "ANIM";
					_medic stop false;
					private _dummyGrp = createGroup civilian;
					private _dummy = [_dummyGrp, "C_man_polo_1_F", [0,0,20], [], 0, "FORM"] call A3A_fnc_createUnit;
					_dummy setUnitPos "MIDDLE";
					_dummy forceWalk true;
					_dummy setSkill 0;
					[_dummy,true] remoteExec ["hideObjectGlobal",2];
					_dummy allowdammage false;
					_dummy setBehaviour "CARELESS";
					_dummy disableAI "FSM";
					_dummy disableAI "SUPPRESSION";
				    _dummy forceSpeed 0.2;
				    _dummy setPosATL (getPosATL _medic);
					_medic attachTo [_dummy, [0, -0.2, 0]];
					_medic setDir 180;

					_treatedUnit attachTo [_dummy, [0,-1.1, 0.092]];
					_treatedUnit setDir 0;
					_dummy doMove _coverX;
					// [_medic] spawn {sleep 4.5; (_this select 0) playMove "AcinPknlMwlkSrasWrflDb"};
					_timeOut = time + 30;
					while {true} do {
						sleep 0.2;
						if (!([_medic] call A3A_fnc_canFight)
							|| (!alive _treatedUnit)
							|| (_medic distance _coverX <= 2)
							|| (_timeOut < time)
							|| (_medic != vehicle _medic)
							|| (_medic getVariable ["cancelRevive",false])
							|| (_treatedUnit getVariable ["A3A_blockRevive",false])
						) exitWith {};

						if (_treatedUnit distance _dummy > 3) then {
							detach _treatedUnit;
							_treatedUnit setPos (position _dummy);
							_treatedUnit attachTo [_dummy, [0,-1.1, 0.092]];
							_treatedUnit setDir 0;
						};
						if (_medic distance _dummy > 3) then {
							detach _medic;
							_medic setPos (position _dummy);
							_medic attachTo [_dummy, [0, -0.2, 0]];
							_medic setDir 180;
						};
					};
					detach _treatedUnit;
					detach _medic;
					detach _dummy;
					deleteVehicle _dummy;
					deleteGroup _dummyGrp;
					_medic enableAI "ANIM";
				};

				if ((alive _treatedUnit) 
					&& ([_medic] call A3A_fnc_canFight) 
					&& (_medic == vehicle _medic) 
					&& !(_medic getVariable ["cancelRevive",false])
					&& !(_treatedUnit getVariable ["A3A_blockRevive",false])
				) then {
					_medic playMove "amovpknlmstpsraswrfldnon";
					_medic stop true;
					_treatedUnit stop true;
					sleep 3;
					_isCured = [_treatedUnit,_medic] call A3A_fnc_actionRevive;
					_treatedUnit playMoveNow "";
					if (_isCured) then
						{
						if (_medic != _treatedUnit) then {if (_hasPlayer) then {_medic groupChat format [localize "STR_chats_help_success",name _treatedUnit]}};
						};
					sleep 5;
					_medic stop false;
					_treatedUnit stop false;
					_treatedUnit dofollow leader group _treatedUnit;
					_medic doFollow leader group _treatedUnit;
				} else {
					[_medic,""] remoteExec ["switchMove"];
					if ((alive _treatedUnit) && (_treatedUnit getVariable ["incapacitated",false])) then {
						_treatedUnit playMoveNow "";
						_treatedUnit setUnconscious false;
						_timeOut = time + 3;
						waitUntil {sleep 0.3; (lifeState _treatedUnit != "incapacitated") || (_timeOut < time)};
						_treatedUnit setUnconscious true;
					};
				};
			}
			else {
				_medic stop true;
				_treatedUnit stop true;
				_isCured = [_treatedUnit,_medic] call A3A_fnc_actionRevive;
				if (_isCured) then {
					if (_medic != _treatedUnit) then {if (_hasPlayer) then {_medic groupChat format [localize "STR_chats_help_success",name _treatedUnit]}};
					sleep 10;
				};
				_medic stop false;
				_treatedUnit stop false;
				_treatedUnit dofollow leader group _treatedUnit;
				_medic doFollow leader group _treatedUnit;
			};
			if ((animationState _medic == "amovpknlmstpsraswrfldnon") || (animationState _medic == "AmovPercMstpSlowWrflDnon_AcinPknlMwlkSlowWrflDb_2") || (animationState _medic == "AmovPercMstpSnonWnonDnon_AcinPknlMwlkSnonWnonDb_2")) then {_medic switchMove ""};
		} else {
			_medic stop true;
			_treatedUnit stop true;
			if (_treatedUnit getVariable ["incapacitated",false]) then {_isCured = [_treatedUnit,_medic] call A3A_fnc_actionRevive} else {_medic action ["HealSoldier",_treatedUnit]; _isCured = true};
			if (_isCured) then {
				if (_medic != _treatedUnit) then {if (_hasPlayer) then {_medic groupChat format [localize "STR_chats_help_success",name _treatedUnit]}};
				sleep 10;
			};
			_medic stop false;
			_treatedUnit stop false;
			_treatedUnit dofollow leader group _treatedUnit;
			_medic doFollow leader group _treatedUnit;
		};
	};
	if (_medic == _treatedUnit getVariable ["helped",objNull]) then {
		_treatedUnit setVariable ["helped",objNull]
	};
	_medic setUnitPos "AUTO";

	if (_medic getVariable ["cancelRevive",false]) then {
		_medic stop false;
		_medic doFollow leader group _treatedUnit;
		sleep 15;
	};
} else {
	if ((random 100) < 50) then {
		[_medic,_medic] call A3A_fnc_chargeWithSmoke;
	};
	if ([_medic] call A3A_fnc_canFight) then {
		_medic action ["HealSoldierSelf",_medic];
		sleep 10;
	};
	_treatedUnit setVariable ["helped",objNull];
	_isCured = true;
};
if (_medic getVariable ["cancelRevive",false]) then {
	_medic setVariable ["cancelRevive",false];
	sleep 15;
};

_medic setVariable ["helping",false];
_medic setVariable ["maneuvering",false];

_isCured
