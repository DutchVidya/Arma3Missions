/*
	CLY Deathmatch - An Arma 3 game mode template by Mika Hannola AKA Celery
*/

CLY_DM_scriptPath = "CLY_Deathmatch\";

if (isNil "CLY_DM_end") then {CLY_DM_end = false;};
if (isNil "CLY_DM_scoreLimitReached") then {CLY_DM_scoreLimitReached = false;};
if (isNil "CLY_DM_mostPoints") then {CLY_DM_mostPoints = [0, []]};

CLY_fnc_addWeapon = compileFinal preprocessFile (CLY_DM_scriptPath + "cly_addWeapon.sqf");
CLY_fnc_respawnPosition = compileFinal preprocessFile (CLY_DM_scriptPath + "cly_respawnPosition.sqf");

#include "cly_dm_settings.hpp"
#include "cly_dm_functions.hpp"

enableSaving [false, false]; //Disable saving
enableTeamSwitch false; //Disable team switching

//--- Initialize description.ext parameters as variables
paramsArray = if (!isNil "paramsArray") then {paramsArray;} else {[];};
for "_i" from 0 to ((count paramsArray) - 1) do
{
	_name = configName ((missionConfigFile / "Params") select _i);
	missionNamespace setVariable [_name, paramsArray select _i];
};

//--- Booleanize variables
{
	if (typeName (missionNamespace getVariable [_x, false]) == "SCALAR") then
	{
		missionNamespace setVariable [_x, missionNamespace getVariable _x == 1];
	};
} forEach CLY_DM_booleanVariables;

//--- Miscellaneous
CLY_DM_timeLimit = CLY_DM_timeLimit * 60; //Convert time limit into seconds
if (CLY_DM_terrainGrid > 0) then {setTerrainGrid (CLY_DM_terrainGrid * 0.001);}; //Set terrain detail

//--- Message transmissions PVEH
CLY_DM_notificationPVEH =
{
	_array = _this select 1;
	_array call BIS_fnc_showNotification;
};
"CLY_DM_notification" addPublicVariableEventHandler CLY_DM_notificationPVEH;

//--- Globally broadcast switchMove PVEH
CLY_DM_switchMovePVEH =
{
	_array = _this select 1;
	(_array select 0) switchMove (_array select 1);
};
"CLY_DM_switchMove" addPublicVariableEventHandler CLY_DM_switchMovePVEH;

//--- Execute scripts
execVM (CLY_DM_scriptPath + "cly_dm_info.sqf"); //Deathmatch info
if (!isDedicated) then {execVM (CLY_DM_scriptPath + "cly_dm_playerRoutines.sqf");}; //Player routines
execVM (CLY_DM_scriptPath + "cly_dm_deathmatch.sqf"); //Deathmatch routines
execVM (CLY_DM_scriptPath + "cly_dm_score.sqf"); //Score handling
execVM (CLY_DM_scriptPath + "cly_dm_hud.sqf"); //HUD

//--- AI routines - very rudimentary, does not imply support for AI
if (isServer) then
{
	{
		if (!isPlayer _x) then
		{
			_x addEventHandler
			[
				"Killed",
				{
					_victim = _this select 0;
					_killer = _this select 1;
					if (!isPlayer _victim) then
					{
						if (!CLY_DM_end) then
						{
							if (_victim != _killer) then
							{
								if (!isServer) then
								{
									CLY_DM_addScore = [name _killer, 1];
									publicVariable "CLY_DM_addScore";
								}
								else
								{
									["CLY_DM_addScore", [name _killer, 1]] call CLY_DM_addScorePVEH;
								};
							}
							else
							{
								if (CLY_DM_suicidePenalty) then
								{
									if (!isServer) then
									{
										CLY_DM_addScore = [name _killer, -1];
										publicVariable "CLY_DM_addScore";
									}
									else
									{
										["CLY_DM_addScore", [name _killer, -1]] call CLY_DM_addScorePVEH;
									};
								};
							};
						};
					};
				}
			];
			_x addRating -100000;
			_x addEventHandler
			[
				"Respawn",
				{
					_unit = _this select 0;
					if (!CLY_DM_end) then
					{
						_unit addRating -100000;
					};
				}
			];
			//if (CLY_DM_enableCustomDamageHandler) then {_x addEventHandler CLY_DM_customDamageHandler;};
		};
	} forEach (if (isMultiplayer) then {playableUnits} else {switchableUnits});
};