if (!isServer) exitWith {};

CLY_DM_playerNames = [];
CLY_DM_playerScores = [];

CLY_DM_addScorePVEH =
{
	if (isServer) then
	{
		_array = _this select 1;
		_unitName = _array select 0;
		_add = _array select 1;
		_i = CLY_DM_playerNames find _unitName;
		if (_i == -1) then
		{
			_i = count CLY_DM_playerNames;
			CLY_DM_playerNames set [_i, _unitName];
			CLY_DM_playerScores set [_i, 0];
		};
		CLY_DM_playerScores set [_i, (CLY_DM_playerScores select _i) + _add];
	};
};
publicVariable "CLY_DM_addScorePVEH";
"CLY_DM_addScore" addPublicVariableEventHandler CLY_DM_addScorePVEH;

while {!CLY_DM_end} do
{
	sleep 0.2;
	//Keep player scores in line with actual kills
	{
		_unit = _x;
		_score = 0;
		_i = CLY_DM_playerNames find name _unit;
		if (_i == -1) then
		{
			_i = count CLY_DM_playerNames;
			CLY_DM_playerNames set [_i, name _unit];
			CLY_DM_playerScores set [_i, 0];
		}
		else
		{
			_score = CLY_DM_playerScores select _i;
			_name = CLY_DM_playerNames select _i;
			if (score _unit != _score) then
			{
				_unit addScore (_score - score _unit);
			};
		};
	} forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
	//Find the biggest score
	_mostPointsArray = +CLY_DM_mostPoints;
	_mostPoints = -10000;
	{
		if (_x > _mostPoints) then {_mostPoints = _x};
	} forEach CLY_DM_playerScores;
	if (_mostPoints == -10000) then {_mostPoints = 0;};
	_mostPointsArray set [0, _mostPoints];
	//Update leaders
	_leaders = [];
	if (_mostPoints > 0) then
	{
		{
			if (CLY_DM_playerScores select _forEachIndex == _mostPoints) then
			{
				_leaders set [count _leaders, _x];
			};
		} forEach CLY_DM_playerNames;
	};
	_mostPointsArray set [1, _leaders];
	if !([_mostPointsArray, CLY_DM_mostPoints] call BIS_fnc_arrayCompare) then
	{
		CLY_DM_mostPoints = _mostPointsArray;
		publicVariable "CLY_DM_mostPoints";
	};
};