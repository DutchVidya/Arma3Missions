//Deathmatch info

_gameMode = switch (CLY_DM_gameMode) do
{
	case 1 : {"Flag Fight"};
	default {"Deathmatch"};
};
player createDiarySubject [_gameMode, _gameMode];

//--- Credits
_credits = "<br/>";
if (CLY_DM_missionCredits != "") then
{
	_credits = _credits + CLY_DM_missionCredits + "<br/><br/><br/><br/><br/>";
};
player createDiaryRecord [_gameMode, ["Acknowledgements", _credits + "CLY Deathmatch framework (version 4) created by Mika Hannola AKA Celery.<br/><br/>The framework can be used uncommercially without explicit permission."]];

//--- Settings
_settings = "";
_settings = _settings + "Respawn delay: " + str (getNumber (missionConfigFile / "respawnDelay")) + " seconds" + "<br/>";
_settings = _settings + "Relative score limit: " + (if (CLY_DM_relativeScoreLimit) then {"enabled"} else {"disabled"}) + "<br/>";
_settings = _settings + "Suicide score penalty: " + (if (CLY_DM_suicidePenalty) then {"enabled"} else {"disabled"}) + "<br/>";
_settings = _settings + "Respawn direction: " + (switch (CLY_DM_respawnDirection) do {case -2 : {"same as when killed"};case -1 : {"random"};default {format ["nearest enemy %1 %2%3", toString [177], CLY_DM_respawnDirection, toString [176]]}}) + "<br/>";
_settings = _settings + "Death camera: " + (switch (CLY_DM_deathCamera) do {case 0 : {"disabled"};case 1 : {"passive"};case 2 : {"active"};case 3 : {"killer's POV"}}) + "<br/>";
_settings = _settings + "Fatigue: " + (if (CLY_DM_disableFatigue) then {"disabled"} else {"enabled"}) + "<br/>";
_settings = _settings + "Arm protection: " + (if (CLY_DM_protectArms) then {"enabled"} else {"disabled"}) + "<br/>";
_settings = _settings + "Leg protection: " + (if (CLY_DM_protectLegs) then {"enabled"} else {"disabled"}) + "<br/>";
_settings = _settings + "Unlimited ammo: " + (if (CLY_DM_unlimitedAmmo) then {"enabled"} else {"disabled"}) + "<br/>";
_settings = _settings + "Anti-prone: " + (if (CLY_DM_antiProne) then {"enabled"} else {"disabled"}) + "<br/>";
_settings = _settings + "Force first person view: " + (if (CLY_DM_force1stPerson) then {"enabled"} else {"disabled"}) + "<br/>";
_settings = _settings + "First aid kits heal completely: " + (if (CLY_DM_FAKHealsCompletely) then {"enabled"} else {"disabled"}) + "<br/>";
_settings = _settings + "Unlimited first aid kits: " + (if (CLY_DM_unlimitedFAKs) then {"enabled"} else {"disabled"});
if (CLY_DM_gameMode == 1) then
{
	_settings = _settings + "<br/><br/>";
	_settings = _settings + "Flag score yield: " + (str CLY_DM_flagFightScoreYield) + " points" + "<br/>";
	_settings = _settings + "Flag scoring distance: " + (str CLY_DM_flagFightScoreDistance) + " meters" + "<br/>";
	_settings = _settings + "Flag return delay: " + (str CLY_DM_flagReturnDelay) + " seconds";
};
player createDiaryRecord [_gameMode, ["Settings", _settings]];

//--- Scoring
_scoring = "You get one point for each opponent you kill. Every combatant is a valid target.";
if (CLY_DM_gameMode == 1) then
{
	_scoring = _scoring + format ["<br/><br/>Taking a flag and bringing it to a return pole yields you %1 %2.", CLY_DM_flagFightScoreYield, if (CLY_DM_flagFightScoreYield == 1) then {"point"} else {"points"}];
};
if (CLY_DM_suicidePenalty) then
{
	_scoring = _scoring + "<br/><br/>If your death cannot be directly attributed to an enemy, you lose a point.";
};

//--- Winning
_winning = "";
if (CLY_DM_timeLimit > 0) then
{
	_winning = _winning + format ["the %1 minute time limit is reached", CLY_DM_timeLimit * 60 ^ - 1];
};
if (CLY_DM_scorelimit > 0) then
{
	if (_winning != "") then {_winning = _winning + " or "};
	_winning = _winning + format ["<br/>a player has %1 %2%3", CLY_DM_scoreLimit, if (CLY_DM_scorelimit == 1) then {"point"} else {"points"}, if (CLY_DM_relativeScoreLimit) then {" more than any other opponent"} else {""}];
};
if (_winning == "") then
{
	_winning = "There are no active ending conditions in this game. The mission will go on until an admin ends it.";
}
else
{
	_winning = "The game will end when " + _winning + "." + "<br/><br/>The winner is the player that has the most points when the game ends.";
};
player createDiaryRecord [_gameMode, ["Scoring & winning", _scoring + "<br/><br/><br/>" + _winning]];

//--- Tasks
if (CLY_DM_tasks) then
{
	CLY_DM_task1 = player createSimpleTask [""];
	_text = "Kill the most enemies";
	_description = "Have the most kills when the mission ends.";
	if (CLY_DM_gameMode == 1) then
	{
		_text = "Score the most points";
		_description = "Have the most points when the mission ends.";
	};
	CLY_DM_task1 setSimpleTaskDescription [_description, _text, _text];
	player setCurrentTask CLY_DM_task1;
	//--- Flag Fight task
	if (CLY_DM_gameMode == 1) then
	{
		CLY_DM_task2 = player createSimpleTask [""];
		_takeText = "Take the flag";
		_description = "Take the flag and bring it to a return pole!";
		CLY_DM_task2 setSimpleTaskDescription [_description, _takeText, _takeText];
		player setCurrentTask CLY_DM_task2;
		[_takeText, _description] spawn
		{
			_takeText = _this select 0;
			_description = _this select 1;
			_scoreText = "Score the flag";
			_text = _takeText;
			while {!CLY_DM_end} do
			{
				_target = objNull;
				_maxDistance = 100000;
				if ({flagOwner _x == player} count CLY_DM_flags == 0) then
				{
					_text = _takeText;
					{
						_distance = vehicle player distance _x;
						if (isNull flagOwner _x && _distance < _maxDistance) then
						{
							_target = _x;
							_maxDistance = _distance;
						};
					} forEach CLY_DM_flags;
				}
				else
				{
					_text = _scoreText;
					{
						_distance = vehicle player distance _x;
						if (isNull flagOwner _x && _distance < _maxDistance) then
						{
							_target = _x;
							_maxDistance = _distance;
						};
					} forEach CLY_DM_returnFlags;
				};
				if (!isNull _target) then
				{
					CLY_DM_task2 setSimpleTaskTarget [_target, true];
					CLY_DM_task2 setSimpleTaskDescription [_description, _text, _text];
					if (currentTask player == CLY_DM_task2) then
					{
						player setCurrentTask CLY_DM_task2;
					};
				}
				else
				{
					CLY_DM_task2 setSimpleTaskTarget [objNull, true];
					CLY_DM_task2 setSimpleTaskDescription [_description, _text, _text]; //FADE THIS SOMEHOW?!
				};
				sleep 0.5;
			};
			player removeSimpleTask CLY_DM_task2;
			player setCurrentTask CLY_DM_task1;
		};
	};
};

//--- Flag Fight markers
if (CLY_DM_gameMode == 1) then
{
	if (CLY_DM_flagMarker != "") then
	{
		{
			_marker = createMarkerLocal ["flag" + str (_forEachIndex + 1), getPosATL _x];
			_marker setMarkerTypeLocal CLY_DM_flagMarker;
			_marker setMarkerColorLocal "ColorYellow";
			_marker setMarkerSizeLocal [0.75, 0.75];
		} forEach CLY_DM_flags;
	};
	if (CLY_DM_returnFlagMarker != "") then
	{
		{
			_marker = createMarkerLocal ["return" + str (_forEachIndex + 1), getPosATL _x];
			_marker setMarkerTypeLocal CLY_DM_returnFlagMarker;
			_marker setMarkerColorLocal "ColorWhite";
			_marker setMarkerSizeLocal [0.75, 0.75];
		} forEach CLY_DM_returnFlags;
	};
};