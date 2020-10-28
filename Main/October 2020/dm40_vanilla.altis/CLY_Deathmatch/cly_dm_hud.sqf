disableSerialization;

if (isDedicated) exitWith {};

sleep 0.01;
CLY_DM_hudLayer cutRsc ["CLY_hud", "PLAIN"];

waitUntil {!isNil "CLY_DM_serverTime"};

_alive = alive player;
while {CLY_DM_hud && !CLY_DM_end} do
{
	if (!_alive && alive player) then
	{
		CLY_DM_hudLayer cutRsc ["CLY_hud", "PLAIN"];
	};
	_ui = uiNamespace getVariable "CLY_hud";
	if (CLY_DM_timeLimit > 0) then
	{
		_hud = _ui displayCtrl 23501;
		_hud ctrlSetPosition [safeZoneX + safeZoneW - 1, safeZoneY + safeZoneH - 0.03];
		_timeLeft = CLY_DM_timeLimit - CLY_DM_serverTime;
		_zero = if (_timeLeft mod 60 < 10) then {0;} else {"";};
		_text = if (_timeLeft >= 0) then {format ["%1:%2%3", abs (floor (_timeLeft * 0.01666666667)), _zero, _timeLeft mod 60];} else {"";};
		_hud ctrlSetText _text;
		_hud ctrlCommit 0;
	};
	if (CLY_DM_mostPoints select 0 > 0) then
	{
		_hud = _ui displayCtrl 23502;
		_hud ctrlSetPosition [safeZoneX + safeZoneW - 1, safeZoneY + safeZoneH - 0.06];
		_text = "";
		_leaderText = if (count (CLY_DM_mostPoints select 1) > 1) then {"Leaders";} else {"Leader";};
		_leaders = "";
		{
			_comma = "";
			if (_forEachIndex + 1 < count (CLY_DM_mostPoints select 1)) then {_comma=", ";};
			_leaders = _leaders + format ["%1%2",_x,_comma];
		} forEach (CLY_DM_mostPoints select 1);
		_scoreLimit = missionNamespace getVariable ["CLY_DM_realScoreLimit", CLY_DM_scoreLimit];
		_text = format ["%1: %2 (%3%4)", _leaderText, _leaders, CLY_DM_mostPoints select 0, if (_scoreLimit > 0) then {"/" + str _scoreLimit} else {""}];
		_hud ctrlSetText _text;
		_hud ctrlCommit 0;
	};
	_alive = alive player;
	sleep 0.1;
};

//Erase HUD
_ui = uiNamespace getVariable "CLY_hud";
_hud = _ui displayCtrl 23501;
_hud ctrlSetText "";
_hud ctrlCommit 0;
_hud = _ui displayCtrl 23502;
_hud ctrlSetText "";
_hud ctrlCommit 0;