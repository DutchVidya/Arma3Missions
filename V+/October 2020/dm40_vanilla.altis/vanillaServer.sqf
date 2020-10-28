waitUntil {{isNil _x} count ["CLY_vanilla_location", "CLY_vanilla_locationCapacity", "CLY_DM_end", "CLY_DM_timeLimit"] == 0};

_locations = CLY_vanilla_locations;
_unusedLocations = + _locations;

_getRandomLocation =
{
	private ["_playersCount", "_usableLocations", "_usableLocationsIndices", "_playersAdjust", "_minPlayers", "_maxPlayers", "_forEachIndex", "_index", "_locationArray", "_loadout"];
	_playersCount = (if (isMultiplayer) then {count playableUnits} else {1}) max 2;
	if (CLY_vanilla_locationCapacity > 0) then {_playersCount = CLY_vanilla_locationCapacity;};
	_usableLocations = [];
	_usableLocationsIndices = [];
	_playersAdjust = -1;
	while {count _usableLocations == 0} do
	{
		{
			_minPlayers = (_x select 2) - (_playersAdjust max 0);
			_maxPlayers = (_x select 3) + (_playersAdjust max 0);
			if (CLY_vanilla_locationCapacity == 0) then
			{
				_minPlayers = 0;
				_maxPlayers = 1000;
			};
			if (_playersCount >= _minPlayers && _playersCount <= _maxPlayers) then
			{
				_usableLocations set [count _usableLocations, _x];
				_usableLocationsIndices set [count _usableLocationsIndices, _forEachIndex];
			};
		} forEach _unusedLocations;
		if (count _usableLocations == 0 && count _unusedLocations != count _locations) then
		{
			_unusedLocations = + _locations;
		};
		_playersAdjust = _playersAdjust + 1;
	};
	_index = floor random count _usableLocations;
	_locationArray = _usableLocations select _index;
	[_unusedLocations, _usableLocationsIndices select _index] call BIS_fnc_removeIndex;
	_loadout = _locationArray select 4;
	while {typeName _loadout == typeName []} do
	{
		_loadout = _loadout select floor random count _loadout;
	};
	_locationArray set [4, _loadout];
	CLY_vanilla_currentLocation = _locationArray;
	publicVariable "CLY_vanilla_currentLocation";
	/*{
		for "_i" from 1 to 24 do
		{
			_x animate ["Door_" + str _i + "_rot", 1];
			_x animate ["Door_" + str _i + "A_move", 1];
			_x animate ["Door_" + str _i + "B_move", 1];
		};
	} forEach (getPosATL (CLY_vanilla_currentLocation select 0) nearObjects ["Building", 500]);*/
};

if (CLY_vanilla_location >= 0) then
{
	_locationArray = _locations select CLY_vanilla_location;
	_loadout = _locationArray select 4;
	while {typeName _loadout == typeName []} do
	{
		_loadout = _loadout select floor random count _loadout;
	};
	_locationArray set [4, _loadout];
	CLY_vanilla_currentLocation = _locationArray;
	publicVariable "CLY_vanilla_currentLocation";
	/*{
		for "_i" from 1 to 24 do
		{
			_x animate ["Door_" + str _i + "_rot", 1];
			_x animate ["Door_" + str _i + "A_move", 1];
			_x animate ["Door_" + str _i + "B_move", 1];
		};
	} forEach (getPosATL (CLY_vanilla_currentLocation select 0) nearObjects ["Building", 500]);*/
};

if (CLY_vanilla_location == -1) then
{
	call _getRandomLocation;
};

if (CLY_vanilla_location == -2) then
{
	_destinations = CLY_vanilla_tourDestinations;
	_interval = CLY_DM_timeLimit / _destinations;
	while {_destinations > 0 && !CLY_DM_end} do
	{
		call _getRandomLocation;
		_destinations = _destinations - 1;
		[] spawn
		{
			_allDead = allDead;
			sleep 10;
			{deleteVehicle _x;} forEach _allDead;
		};
		sleep _interval;
	};
};