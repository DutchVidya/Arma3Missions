/*
	CLY Respawn Position
	Author: Mika Hannola AKA Celery
	
	Description:
	Generates a random position within a certain area where enemies have no line of sight.
	
	Parameters:
	_this select 0: <object> unit for which the position is being generated
	_this select 1: <object> trigger or <string> marker used as an area
	_this select 2 (Optional): <object> trigger, <string> marker or a <array> combination of either within which a position cannot be generated
	_this select 3 (Optional): <scalar> maximum line of sight range (default: 300 meters)
	_this select 4 (Optional): <scalar> maximum number of tries to find a suitable position before settling for the last one (default: 1000)
	_this select 5 (Optional): <boolean> debug message reports number of tries when the script terminates (default: false)
	
	Returns:
	ATL position array.
	
	How to use:
	CLY_fnc_respawnPosition = compileFinal preprocessFile "cly_respawnPosition.sqf";
	_position = [player, "respawn_west"] call CLY_fnc_respawnPosition;
	player setPosATL _position;
	
	I'd recommend moving the actual respawn marker someplace else and using another marker for this script to avoid newly respawning players blinking in and out in the mission area.
*/

private ["_this", "_unit", "_area", "_badArea", "_losRange", "_tries", "_debug", "_trigger", "_tempTrigger", "_tempTriggers", "_areaPos", "_areaX", "_areaY", "_areaDir", "_areaRectangle", "_areaRadius", "_helper", "_badAreas", "_zCheckHeight", "_maxFloorHeight", "_position", "_lastPosition", "_inTrigger", "_eyeHeight", "_positionFound", "_i", "_floorHeight", "_floorHeightASL", "_intersectWithRock", "_seen"];

_unit = [_this, 0, player, [objNull]] call BIS_fnc_param;
_area = [_this, 1, "", [objNull, ""]] call BIS_fnc_param;
_badArea = [_this, 2, [], [objNull, "", []]] call BIS_fnc_param;
_losRange = [_this, 3, 300, [0]] call BIS_fnc_param;
_tries = [_this, 4, 1000, [0]] call BIS_fnc_param;
_debug = [_this, 5, false, [true]] call BIS_fnc_param;

//Define area
_trigger = objNull;
_tempTrigger = objNull;
_tempTriggers = [];
if (typeName _area == typeName "") then
{
	_tempTrigger = [objNull, _area] call BIS_fnc_triggerToMarker;
	_tempTriggers set [count _tempTriggers, _tempTrigger];
	_trigger = _tempTrigger;
}
else
{
	_trigger = _area;
};
_areaPos = getPosATL _trigger;
_areaX = triggerArea _trigger select 0;
_areaY = triggerArea _trigger select 1;
_areaDir = triggerArea _trigger select 2;
_areaRectangle = triggerArea _trigger select 3;
_areaRadius = if (_areaRectangle) then {[0, 0] distance [_areaX, _areaY];} else {_areaX max _areaY;};

//Create helper object for easy coordinate transformation
_helper = "Sign_Sphere10cm_F" createVehicleLocal [0, 0, 10000];
_helper hideObject true;
_helper setPosATL _areaPos;
_helper setDir _areaDir;

//Manage bad areas
_badAreas = [];
if (typeName _badArea != typeName []) then
{
	_badArea = [_badArea];
};
{
	if (typeName _x == typeName "") then
	{
		_tempTrigger = [objNull, _x] call BIS_fnc_triggerToMarker;
		_tempTriggers set [count _tempTriggers, _tempTrigger];
		_x = _tempTrigger;
	};
	if (typeName _x == typeName objNull) then
	{
		_badAreas set [count _badAreas, _x];
	};
} forEach _badArea;

//Find position
_eyeHeight = (eyePos _unit select 2) - (getPosASL _unit select 2);
_zCheckHeight = 3;
_maxFloorHeight = 0.3;
_position = _areaPos;
_lastPosition = _areaPos;
_positionFound = false;
_i = 0;
while {!_positionFound && _i < _tries} do
{
	_helper setPosATL _areaPos;
	_position = _helper modelToWorld [- _areaX + random (_areaX * 2), - _areaY + random (_areaY * 2), 0];
	_position set [2, _zCheckHeight];
	if (!surfaceIsWater _position) then
	{
		if (surfaceNormal _position select 2 > 0.6) then
		{
			_inTrigger = if (_areaRectangle) then {true;} else {[_trigger, +_position] call BIS_fnc_inTrigger;};
			if (_inTrigger) then
			{
				if ({[_x, +_position] call BIS_fnc_inTrigger} count _badAreas == 0) then
				{
					_helper setPosATL _position;
					_floorHeight = (getPosATL _helper select 2) - (getPos _helper select 2);
					if (_floorHeight <= _maxFloorHeight) then
					{
						_position = [_position select 0, _position select 1, _floorHeight];
						_floorHeightASL = (ATLToASL _position) select 2;
						_intersectWithRock = false;
						{
							if (typeOf _x == "") then
							{
								if (["rock", str _x] call BIS_fnc_inString) then
								{
									_intersectWithRock = true;
								};
							};
						} forEach lineIntersectsWith [ATLToASL [_position select 0, _position select 1, _zCheckHeight], ATLToASL [_position select 0, _position select 1, 30]];
						if (!lineIntersects [ATLToASL [_position select 0, _position select 1, (_position select 2) + _zCheckHeight], ATLToASL _position] && !_intersectWithRock) then
						{
							if (!lineIntersects [[(_position select 0) - 0.5, _position select 1, _floorHeightASL + 0.5], [(_position select 0) + 0.5, _position select 1, _floorHeightASL + 0.5]]) then
							{
								if (!lineIntersects [[_position select 0, (_position select 1) - 0.5, _floorHeightASL + 0.5], [_position select 0, (_position select 1) + 0.5, _floorHeightASL + 0.5]]) then
								{
									_lastPosition = _position;
									_seen = false;
									{
										if (!_seen) then
										{
											if (alive _x) then
											{
												if (_x != _unit) then
												{
													if (_unit countEnemy [_x] == 1) then
													{
														_eyeHeight = _eyeHeight + _floorHeight;
														if !(lineIntersects [eyePos _x, ATLToASL [_position select 0, _position select 1, _eyeHeight]] || terrainIntersectASL [eyePos _x, ATLToASL [_position select 0, _position select 1, _eyeHeight]]) then
														{
															_seen = true;
														};
													};
												};
											};
										};
									} forEach (_position nearEntities ["Man", _losRange]);
									if (!_seen) then
									{
										_positionFound = true;
									};
								};
							};
						};
					};
				};
			};
		};
	};
	_i = _i + 1;
};

{deleteVehicle _x;} forEach _tempTriggers + [_helper];
if (_debug) then {player commandChat (str time + " - " + "CLY Respawn Position tries: " + str _i);};
_lastPosition;