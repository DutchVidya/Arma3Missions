CLY_DM_fnc_playerRespawnRoutines =
{
	private ["_unit", "_loadout", "_selectedWeapon", "_weaponType", "_muzzles", "_muzzle", "_anim", "_vest", "_backpack", "_pool", "_weaponArray", "_nearest", "_nearestDistance", "_distance"];
	_unit = _this select 0;
	_loadout = _this select 1;
	if (!CLY_DM_end) then
	{
		_unit addRating (-100000 - rating _unit);
	};
	if (CLY_DM_disableFatigue) then
	{
		_unit enableFatigue false;
	};
	//--- Loadout
	if (_loadout != -2) then
	{
		if (_loadout == -1) then
		{
			if (!isNil {_unit getVariable "CLY_DM_loadoutSelectedWeapon"}) then
			{
				{_unit removeMagazine _x;} forEach magazines _unit;
				{_unit removeWeapon _x;} forEach weapons _unit;
				{_unit unassignItem _x;_unit removeItem _x;} forEach assignedItems _unit;
				{_unit addMagazine _x;} forEach CLY_DM_magazines;
				{_unit addWeapon _x;} forEach CLY_DM_items;
				{_unit addMagazine _x;} forEach (_unit getVariable ["CLY_DM_loadoutMagazines", []]);
				{_unit addWeapon _x;} forEach (_unit getVariable ["CLY_DM_loadoutWeapons", []]);
				_selectedWeapon = _unit getVariable ["CLY_DM_loadoutSelectedWeapon", ""];
				if (_selectedWeapon != "") then
				{
					_weaponType = getNumber (configFile / "CfgWeapons" / _selectedWeapon / "type");
					_muzzles = getArray (configFile / "CfgWeapons" / _selectedWeapon / "muzzles");
					_muzzle = if !("this" in _muzzles) then {_muzzles select 0;} else {_selectedWeapon;};
					if (_weaponType in [1, 2, 4, 5] && _unit isKindOf "Man") then
					{
						_unit selectWeapon _muzzle;
						if (vehicle _unit == _unit && alive _unit && isPlayer _unit) then
						{
							_anim = "amovpercmstpsnonwnondnon";
							if (_weaponType in [1, 5]) then {_anim = "amovpercmstpsraswrfldnon";};
							if (_weaponType == 2) then {_anim = "amovpercmstpsraswpstdnon";};
							if (_weaponType == 4) then {_anim = "amovpercmstpsraswlnrdnon";};
							_unit switchMove _anim;
							_unit playMoveNow _anim;
							CLY_DM_switchMove = [_unit, _anim];
							publicVariable "CLY_DM_switchMove";
						};
					};
				};
			}
			else
			{
				{_unit addMagazine _x;} forEach CLY_DM_magazines;
				{
					if !(_x in weapons _unit) then
					{
						_unit addWeapon _x;
					};
				} forEach CLY_DM_items;
			};
		}
		else
		{
			_vest = CLY_DM_vest;
			if (typeName _vest == typeName "") then {_vest = [_vest];};
			if (count _vest > 0) then
			{
				removeVest _unit;
				_vest = _vest select floor random count _vest;
				if (_vest != "") then {_unit addVest _vest;};
			};
			_backpack = CLY_DM_backpack;
			if (typeName _backpack == typeName "") then {_backpack = [_backpack];};
			if (count _backpack > 0) then
			{
				removeBackpack _unit;
				_backpack = _backpack select floor random count _backpack;
				if (_backpack != "") then {_unit addBackpack _backpack;};
			};
			{_unit removeMagazine _x;} forEach magazines _unit;
			{_unit removeWeapon _x;} forEach weapons _unit;
			{_unit unassignItem _x;_unit removeItem _x;} forEach (assignedItems _unit + items _unit);
			{_unit addMagazine _x;} forEach CLY_DM_magazines;
			{_unit addWeapon _x;} forEach CLY_DM_weapons;
			{_unit addItem _x;} forEach CLY_DM_items;
			_pool = +(missionNamespace getVariable ("CLY_DM_loadoutPool" + str _loadout));
			_weaponArray = [];
			while {count _weaponArray == 0} do
			{
				if (typeName (_pool select 0) == typeName "") then
				{
					_weaponArray = _pool;
				}
				else
				{
					_pool = _pool select floor random count _pool;
				};
			};
			_muzzles = ([_unit] + _weaponArray) call CLY_fnc_addWeapon;
			_muzzle = _muzzles select 0;
			if (_weaponArray select 1 == 0 && count _muzzles > 1) then
			{
				if (count _weaponArray > 3) then
				{
					if (_weaponArray select 3 > 0) then
					{
						_muzzle = _muzzles select 1;
					};
				};
			};
			_unit selectWeapon _muzzle;
			_weaponType = getNumber (configFile / "CfgWeapons" / (currentWeapon _unit) / "type");
			if (vehicle _unit == _unit && alive _unit && isPlayer _unit) then
			{
				_anim = "amovpercmstpsnonwnondnon";
				if (_weaponType in [1, 5]) then {_anim = "amovpercmstpsraswrfldnon";};
				if (_weaponType == 2) then {_anim = "amovpercmstpsraswpstdnon";};
				if (_weaponType == 4) then {_anim = "amovpercmstpsraswlnrdnon";};
				_unit switchMove _anim;
				_unit playMoveNow _anim;
				CLY_DM_switchMove = [_unit, _anim];
				publicVariable "CLY_DM_switchMove";
			};
		};
	};
	//--- Respawn position
	if (CLY_respawnPosition) then
	{
		if (!(missionNamespace getVariable ["CLY_DM_fnc_playerRespawnRoutines_firstRun", true]) || CLY_respawnPosition_useAtStart) then
		{
			if (!CLY_DM_end) then {CLY_DM_effectLayer cutText ["", "BLACK IN", 0.5];};
			_position = [_unit, CLY_respawnPosition_area, CLY_respawnPosition_badAreas, CLY_respawnPosition_losRadius, CLY_respawnPosition_tries] call CLY_fnc_respawnPosition;
			_unit setPosATL _position;
		};
	};
	CLY_DM_fnc_playerRespawnRoutines_firstRun = false;
	//--- Respawn direction
	if (CLY_DM_respawnDirection != -2) then
	{
		if (CLY_DM_respawnDirection == -1) then
		{
			_unit setDir random 360;
		};
		if (CLY_DM_respawnDirection >= 0) then
		{
			_nearest = objNull;
			_nearestDistance = 10000;
			{
				_distance = _unit distance _x;
				if (_distance < _nearestDistance) then
				{
					_nearest = _x;
					_nearestDistance = _distance;
				};
			} forEach (playableUnits - [_unit]);
			if (!isNull _nearest) then
			{
				_unit setDir ((getPosASL _unit select 0) - (getPosASL _nearest select 0)) atan2 ((getPosASL _unit select 1) - (getPosASL _nearest select 1)) + 180 + (random (CLY_DM_respawnDirection * 2)) - CLY_DM_respawnDirection;
			}
			else
			{
				_unit setDir random 360;
			};
		};
	};
};

CLY_DM_outroText =
{
	private ["_winningScore", "_winners", "_text", "_lastIndex"];
	_textTime = 1;
	if (!isNil "_this") then
	{
		_textTime = _this * 0.1;
	};
	_winningScore = CLY_DM_mostPoints select 0;
	_winners = CLY_DM_mostPoints select 1;
	_text = "\n\n" + (if (CLY_DM_scoreLimitReached) then {"Score limit reached!"} else {"Time limit reached!"}) + "\n\n";
	if (count _winners > 0) then
	{
		_text = _text + "Winner";
		if (count _winners == 1) then
		{
			_text = _text + format [" (%1 point%2):\n", _winningScore, if (_winningScore != 1) then {"s"} else {""}];
			_text = _text + (_winners select 0);
		}
		else
		{
			_text = _text + format ["s (%1 point%2):\n", _winningScore, if (_winningScore != 1) then {"s"} else {""}];
			_lastIndex = (count _winners) - 1;
			{
				_text = _text + _x;
				if (_forEachIndex != _lastIndex) then
				{
					_text = _text + "\n";
				};
			} forEach _winners;
		};
	};
	CLY_DM_primaryTextLayer cutText [_text, "PLAIN", _textTime];
};