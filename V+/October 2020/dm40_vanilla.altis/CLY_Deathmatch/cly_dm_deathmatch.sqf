//--- Disable AI for the duration of the intro
_disabledUnits = [];
if (isServer) then
{
	{
		_unit = _x;
		if (!isPlayer _unit) then
		{
			{
				_unit disableAI _x;
			} forEach ["TARGET", "AUTOTARGET", "MOVE", "ANIM", "FSM"];
			_disabledUnits set [count _disabledUnits, _unit];
		};
	} forEach allUnits;
};

//--- Put player in a safe place until the intro ends
_intro = false;
_vehicle = vehicle player;
_startPos = getPosATL _vehicle;
if (CLY_DM_intro && !isDedicated) then
{
	_intro = true;
	_vehicle setPosATL [_startPos select 0, _startPos select 1, 10000];
	_vehicle enableSimulation false;
};

sleep 0.01; //Wait for the mission to start
waitUntil {!CLY_DM_intro}; //Wait for the intro to end

//--- Put player back where he was
if (_intro) then
{
	if (_vehicle == vehicle player) then
	{
		_vehicle setPosATL _startPos;
	};
	_vehicle enableSimulation true;
};

//--- Server only
if (isServer) then
{
	//--- Reactivate AI
	{
		_unit = _x;
		{
			_unit enableAI _x;
		} forEach ["TARGET", "AUTOTARGET", "MOVE", "ANIM", "FSM"];
	} forEach _disabledUnits;
	//--- Establish and update server time
	CLY_DM_serverTime = 0;
	publicVariable "CLY_DM_serverTime";
	CLY_DM_serverTime spawn
	{
		_oldTime = 0;
		while {true} do
		{
			sleep 0.05;
			CLY_DM_serverTime = floor time;
			if (CLY_DM_serverTime > _oldTime) then
			{
				publicVariable "CLY_DM_serverTime";
				_oldTime = CLY_DM_serverTime;
			};
		};
	};
	//--- Relative score limit updater
	CLY_DM_realScoreLimit = CLY_DM_scorelimit;
	publicVariable "CLY_DM_realScoreLimit";
	if (CLY_DM_relativeScoreLimit && CLY_DM_scoreLimit > 0) then
	{
		[] spawn
		{
			_realScoreLimit = CLY_DM_scorelimit;
			while {true} do
			{
				_mostPoints = CLY_DM_mostPoints select 0;
				_secondMostPoints = 0;
				if (count (CLY_DM_mostPoints select 1) == 1) then
				{
					{
						if (_x > _secondMostPoints && _x < _mostPoints) then
						{
							_secondMostPoints = _x;
						};
					} forEach CLY_DM_playerScores;
					
				}
				else
				{
					_secondMostPoints = _mostPoints;
				};
				CLY_DM_realScoreLimit = CLY_DM_scorelimit + _secondMostPoints;
				if (CLY_DM_realScoreLimit != _realScoreLimit) then
				{
					publicVariable "CLY_DM_realScoreLimit";
					_realScoreLimit = CLY_DM_realScoreLimit;
				};
				sleep 0.2;
			};
		};
	};
	//--- Flags
	if (CLY_DM_gameMode == 1) then
	{
		{
			_x setFlagSide sideEnemy;
		} forEach CLY_DM_flags;
	};
	//--- Flag Fight variables
	_flagOwners = [];
	{
		_flagOwners set [_forEachIndex, objNull];
	} forEach CLY_DM_flags;
	_flagReturnTimes = [];
	{
		_flagReturnTimes set [_forEachIndex, -1];
	} forEach CLY_DM_flags;
	//--- Deathmatch ending condition loop (and Flag Fight mechanics)
	_step = 0.2;
	_wait = _step;
	_end = false;
	_scoreLimitReached = false;
	_scoreLimitReachedTime = 0;
	while {!_end && !CLY_DM_end} do
	{
		waitUntil {time >= _wait};
		_wait = _wait + _step;
		//--- Flag Fight
		if (CLY_DM_gameMode == 1) then
		{
			{
				_flag = _x;
				_flagOwner = _flagOwners select _forEachIndex;
				_flagReturnTime = _flagReturnTimes select _forEachIndex;
				if (!alive _flagOwner && flagOwner _flag != _flagOwner && !isNull flagOwner _flag) then
				{
					if (alive flagOwner _flag) then
					{
						_flagOwner = flagOwner _flag;
						_flagOwners set [_forEachIndex, _flagOwner];
						CLY_DM_notification = ["FlagTaken", [format ["%1 has taken %2 flag!", name _flagOwner, if (count CLY_DM_flags == 1) then {"the"} else {"a"}]]];
						(["CLY_DM_notification"] + [CLY_DM_notification]) call CLY_DM_notificationPVEH;
						publicVariable "CLY_DM_notification";
					}
					else
					{
						_flag setFlagOwner objNull;
					};
				};
				if (!alive _flagOwner && !isNull _flagOwner && _flagReturnTime == -1) then
				{
					_flagReturnTime = time + CLY_DM_flagReturnDelay;
					_flagReturnTimes set [_forEachIndex, _flagReturnTime];
				};
				if (_flagReturnTime != -1 && !isNull _flagOwner && alive _flagOwner) then
				{
					_flagReturnTime = -1;
					_flagReturnTimes set [_forEachIndex, _flagReturnTime];
				};
				if (_flagReturnTime != -1 && (time >= _flagReturnTime || isNull _flagOwner)) then
				{
					_flag setFlagOwner objNull;
					_flagOwner = objNull;
					_flagOwners set [_forEachIndex, objNull];
					_flagReturnTime = -1;
					_flagReturnTimes set [_forEachIndex, _flagReturnTime];
					CLY_DM_notification = ["FlagReturned", [format ["%1 flag has returned to its pole!", if (count CLY_DM_flags == 1) then {"The"} else {"A"}]]];
					(["CLY_DM_notification"] + [CLY_DM_notification]) call CLY_DM_notificationPVEH;
					publicVariable "CLY_DM_notification";
				};
				if (alive _flagOwner) then
				{
					if ({_flagOwner distance _x <= CLY_DM_flagFightScoreDistance} count CLY_DM_returnFlags > 0) then
					{
						_flagOwnerName = name _flagOwner;
						CLY_DM_notification = ["FlagScored", [format ["%1 scores %2 points for delivering %3 flag!", _flagOwnerName, CLY_DM_flagFightScoreYield, if (count CLY_DM_flags == 1) then {"the"} else {"a"}]]];
						(["CLY_DM_notification"] + [CLY_DM_notification]) call CLY_DM_notificationPVEH;
						publicVariable "CLY_DM_notification";
						["CLY_DM_addScore", [_flagOwnerName, CLY_DM_flagFightScoreYield]] call CLY_DM_addScorePVEH;
						_flag setFlagOwner objNull;
						_flagOwner = objNull;
						_flagOwners set [_forEachIndex, objNull];
					};
				};
			} forEach CLY_DM_flags;
		};
		//--- Time limit
		if (CLY_DM_timeLimit > 0 && CLY_DM_serverTime >= CLY_DM_timeLimit) then
		{
			_end = true;
		};
		//--- Score limit
		if (CLY_DM_scoreLimit > 0) then
		{
			_mostPoints = CLY_DM_mostPoints select 0;
			if (_mostPoints >= CLY_DM_realScoreLimit) then
			{
				if (!_scoreLimitReached) then
				{
					_scoreLimitReached = true;
					_scoreLimitReachedTime = time + 3;
				};
			}
			else
			{
				if (_scoreLimitReached) then
				{
					_scoreLimitReached = false;
				};
			};
			if (_scoreLimitReached && time >= _scoreLimitReachedTime) then
			{
				CLY_DM_scoreLimitReached = true;
				publicVariable "CLY_DM_scoreLimitReached";
				_end = true;
			};
		};
	};
	CLY_DM_end = true;
	publicVariable "CLY_DM_end";
};

waitUntil {CLY_DM_end};

//--- Freeze everything
{
	_x enableSimulation false;
	_x removeAllEventHandlers "HandleDamage";
	_x allowDamage false;
} forEach (allUnits + allDead);
[] spawn
{
	while {true} do
	{
		waitUntil {!alive player};
		waitUntil {alive player};
		player enableSimulation false;
		player removeAllEventHandlers "HandleDamage";
		player allowDamage false;
	};
};

//--- Ending type
CLY_DM_endType = "Lose";
if (!isDedicated) then
{
	if (name player in (CLY_DM_mostPoints select 1)) then
	{
		if (count (CLY_DM_mostPoints select 1) == 1) then
		{
			missionNamespace getVariable ["CLY_DM_task1", taskNull] setTaskState "Succeeded";
			CLY_DM_endType = "Win";
		}
		else
		{
			missionNamespace getVariable ["CLY_DM_task1", taskNull] setTaskState "Canceled";
			CLY_DM_endType = "Draw";
		};
	}
	else
	{
		missionNamespace getVariable ["CLY_DM_task1", taskNull] setTaskState "Failed";
		CLY_DM_endType = "Lose";
	};
};

//--- Show outro
if (CLY_DM_outro) then
{
	if (CLY_DM_outroScript != "") then
	{
		_suffix = [];
		_filenameArray = toArray CLY_DM_outroScript;
		_lastIndex = (count _filenameArray) - 1;
		{
			if (_lastIndex - _forEachIndex < 3) then
			{
				_suffix set [count _suffix, _x]
			};
		} forEach _filenameArray;
		_suffix = toLower (toString _suffix);
		switch (_suffix) do
		{
			case "sqf" : {execVM CLY_DM_outroScript;};
			case "sqs" : {[] exec CLY_DM_outroScript;};
			case "fsm" : {execFSM CLY_DM_outroScript;};
		};
	};
}
else
{
	11 call CLY_DM_outroText;
	CLY_DM_effectLayer cutText ["", "BLACK OUT", 10];
	0 fadeMusic 0.5;
	1 fadeSound 0;
	playMusic ["LeadTrack01_F", 130.5];
	sleep 5;
	5 fadeMusic 0;
	sleep 5;
};
waitUntil {!CLY_DM_outro};

endMission CLY_DM_endType;