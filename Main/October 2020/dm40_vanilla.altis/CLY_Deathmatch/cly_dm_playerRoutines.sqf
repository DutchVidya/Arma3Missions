waitUntil {alive player && !CLY_DM_intro};

player addEventHandler
[
	"Killed",
	{
		_victim = _this select 0;
		_killer = _this select 1;
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
				if (CLY_DM_announceKiller) then
				{
					["Killed", [name _killer]] call BIS_fnc_showNotification;
				};
				//--- Death camera
				if (CLY_DM_deathCamera > 0) then
				{
					[_victim, _killer] spawn
					{
						_victim = _this select 0;
						_killer = _this select 1;
						_camera = objNull;
						_targetObject = objNull;
						_cameraObject = objNull;
						if (CLY_DM_deathCamera in [1, 2]) then
						{
							_cameraPosition = if (missionNamespace getVariable ["CLY_DM_playerVehicle", _victim] == _victim) then
							{
								ASLToATL [eyePos _victim select 0, eyePos _victim select 1, (eyePos _victim select 2) + 0.15];
							}
							else
							{
								ASLToATL [(getPosASL CLY_DM_playerVehicle select 0), (getPosASL CLY_DM_playerVehicle select 1), (getPosASL CLY_DM_playerVehicle select 2) + ((boundingBox CLY_DM_playerVehicle select 1) select 2) + 0.2];
							};
							_target = vehicle _killer;
							if (CLY_DM_deathCamera == 1) then
							{
								_target = ASLToATL eyePos _target;
							};
							_cameraObject = createVehicle ["HeliHEmpty", [0, 0, 0], [], 0, "CAN_COLLIDE"];
							_cameraObject setPosASL _cameraPosition;
							_camera = "Camera" camCreate [0, 0, 0];
							_camera cameraEffect ["INTERNAL", "BACK"];
							showCinemaBorder false;
							_camera camPrepareTarget _target;
							_camera camPreparePos _cameraPosition;
							_camera camPrepareFOV 0.65;
							_camera camCommitPrepared 0;
						};
						if (CLY_DM_deathCamera == 3 && alive _killer && _killer isKindOf "Man") then
						{
							CLY_DM_effectLayer cutText ["", "WHITE IN", 1];
							while {!alive player && !CLY_DM_end} do
							{
								vehicle _killer switchCamera (_killer getVariable ["CLY_DM_cameraView", "INTERNAL"]);
								sleep 0.1;
							};
						};
						if (sunOrMoon < 0.1 && moonIntensity < 0.5) then
						{
							camUseNVG true;
						}
						else
						{
							camUseNVG false;
						};
						waitUntil {alive player && !CLY_DM_end};
						player cameraEffect ["TERMINATE", "BACK"];
						camDestroy _camera;
						{deleteVehicle _x} forEach [_targetObject, _cameraObject];
					};
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
					["Suicide", [-1]] call BIS_fnc_showNotification;
				};
			};
		};
	}
];

player addEventHandler ["Respawn", {[_this select 0, CLY_DM_loadout] call CLY_DM_fnc_playerRespawnRoutines}];
[player, CLY_DM_loadout] call CLY_DM_fnc_playerRespawnRoutines;

//--- Unlimited ammo
player addEventHandler
[
	"Fired",
	{
		if (CLY_DM_unlimitedAmmo) then
		{
			[_this select 0, _this select 1, _this select 2, getNumber (configFile / "CfgAmmo" / (_this select 4) / "explosive"), _this select 5] spawn
			{
				_unit = _this select 0;
				_weapon = _this select 1;
				_muzzle = _this select 2;
				_ammo = _this select 3;
				_magazine = _this select 4;
				if (_ammo == 1) then {sleep CLY_DM_unlimitedAmmoExplosiveReloadTime}; //Reload delay for explosive weapons
				if (getNumber (configFile / "CfgMagazines" / _magazine / "count") == 1) then
				{
					_unit addMagazine _magazine;
					if (getNumber (configFile / "CfgWeapons" / _weapon / "type") in [1, 2, 4, 5]) then
					{
						_unit removeWeapon _weapon;
						_unit addWeapon _weapon;
						_unit selectWeapon _muzzle;
					};
				}
				else
				{
					_unit setVehicleAmmoDef 1;
				};
			};
		};
	}
];

//--- Custom damage handler - disabled until the EH works properly again
//if (CLY_DM_enableCustomDamageHandler) then {player addEventHandler CLY_DM_customDamageHandler;};

//--- Anti-prone
if (CLY_DM_antiProne) then
{
	[] spawn
	{
		sleep 0.01;
		CLY_DM_proneKeys = actionKeys "prone" + actionKeys "moveDown";
		findDisplay 46 displayAddEventHandler
		[
			"KeyDown",
			"
				if ((_this select 1) in CLY_DM_proneKeys) then
				{
					if (alive player && vehicle player == player) then
					{
						if (!CLY_DM_end) then
						{
							CLY_DM_tertiaryTextLayer cutText ['\n\nProning is disabled!', 'PLAIN DOWN', 0.2];
						};
						true;
					};
				};
			"
		];
		CLY_DM_kneelAnims = ["amovpknlmstpsraswnondnon", "amovpknlmstpsraswrfldnon", "amovpknlmstpsraswpstdnon", "amovpknlmstpsraswpstdnon", "amovpknlmstpsraswlnrdnon", "amovpercmstpsraswrfldnon"];
		CLY_DM_proneTrigger = createTrigger ["EmptyDetector", [0, 0, 0]];
		CLY_DM_proneTrigger setTriggerActivation ["NONE", "PRESENT", true];
		CLY_DM_proneTrigger setTriggerTimeout [1.5, 1.5, 1.5, true];
		CLY_DM_proneTrigger setTriggerStatements
		[
			"alive player && canStand player && vehicle player == player && stance player == 'PRONE' && (eyePos player select 2) - (getPosASL player select 2) < 0.75 && !CLY_DM_end",
			"
				player playMoveNow (CLY_DM_kneelAnims select getNumber (configFile / 'CfgWeapons' / (currentWeapon player) / 'type'));
				if (getNumber (configFile / 'CfgWeapons' / (currentWeapon player) / 'type') in [0, 4]) then
				{
					player playMoveNow 'amovppnemstpsnonwnondnon_amovpknlmstpsnonwnondnon'
				};
				CLY_DM_tertiaryTextLayer cutText ['\n\nProning is disabled!', 'PLAIN DOWN', 0.2];
			",
			""
		];
		while {true} do
		{
			sleep 0.5;
			CLY_DM_proneKeys = actionKeys "prone" + actionKeys "moveDown";
		};
	};
};

//--- Get initial loadout
if (CLY_DM_loadout == -1) then
{
	sleep 0.01;
	player setVariable ["CLY_DM_loadoutMagazines", magazines player, true];
	player setVariable ["CLY_DM_loadoutWeapons", weapons player, true];
	player setVariable ["CLY_DM_loadoutSelectedWeapon", currentWeapon player, true];
};

//--- First aid
if (CLY_DM_FAKHealsCompletely || CLY_DM_unlimitedFAKs) then
{
	[CLY_DM_FAKHealsCompletely, CLY_DM_unlimitedFAKs] execVM (CLY_DM_scriptPath + "cly_firstAid.sqf");
};

//--- Loop
_cameraView = "";
while {!CLY_DM_end} do
{
	if (alive player) then
	{
		CLY_DM_playerVehicle = vehicle player; //Remember player vehicle for death camera
		if (CLY_DM_deathCamera == 3) then //Broadcast view mode for POV death camera
		{
			if (_cameraView != cameraView) then
			{
				_cameraView = cameraView;
				player setVariable ["CLY_DM_cameraView", _cameraView, true];
			};
		};
		if (CLY_DM_protectArms) then
		{
			if (player getHitPointDamage "HitHands" != 0) then
			{
				player setHitPointDamage ["HitHands", 0]
			};
		};
		if (CLY_DM_protectLegs) then
		{
			if (player getHitPointDamage "HitLegs" != 0) then
			{
				player setHitPointDamage ["HitLegs", 0]
			};
		};
	}
	else
	{
		_cameraView = "";
	};
	if (rating player != -100000) then
	{
		player addRating (-100000 - rating player);
	};
	if (CLY_DM_force1stPerson) then
	{
		if (cameraView in ["EXTERNAL", "GROUP"]) then
		{
			vehicle player switchCamera "INTERNAL";
		};
	};
	sleep 0.01;
};