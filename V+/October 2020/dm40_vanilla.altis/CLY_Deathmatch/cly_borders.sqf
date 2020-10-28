/*
	CLY Borders
	Author: Mika Hannola AKA Celery
	
	Description:
	Border creation script for PVP missions.
	
	How to use:
	[
		[], //Universal borders
		[], //BLUFOR borders
		[], //OPFOR borders
		[], //Independent borders
		[], //Civilian borders
		false, //Inverse border: player has to stay inside the border
		0, //Border effect | 0: Heavy fog | 1: Death | 2: Custom
		"", //Custom effect
		0, //Warning time until the border effect is put into motion
		15, //Range at which the player receives a warning of a nearby border
		false //Flying units (at least 3 meters off the ground) are excluded
	] execVM "cly_borders.sqf";
	
	Place area markers in your mission and put their names in STRING format into the arrays. Execute the script multiple times with different parameters if you need borders with different effects or activation conditions. The border trigger will have the same name as the marker.
*/

//Get parameters
_borders_universal = _this select 0;
_borders_west = _this select 1;
_borders_east = _this select 2;
_borders_resistance = _this select 3;
_borders_civilian = _this select 4;
_inverse = _this select 5;
_effect = _this select 6;
_customEffect = _this select 7;
_warningTime = _this select 8;
_warningRange = if (_inverse) then {- (_this select 9);} else {_this select 9;};
_airExcluded = _this select 10;

//Make borders
{
	_side = _x;
	_borders = [_borders_universal, _borders_west, _borders_east, _borders_resistance, _borders_civilian] select _forEachIndex;
	{
		_marker = _x;
		if ((markerSize _marker select 0) + (markerSize _marker select 1) > 0) then
		{
			_trigger = [objNull, _marker] call BIS_fnc_triggerToMarker;
			_trigger setTriggerActivation ["ANY", "PRESENT", true];
			_trigger setTriggerTimeout [_warningTime, _warningTime, _warningTime, true];
			missionNamespace setVariable [_marker, _trigger];
			//Condition
			_condition = "";
			if (_inverse) then
			{
				_condition = _condition + "!";
			};
			_condition = _condition + "(vehicle player in thisList)";
			if (_forEachIndex > 0) then
			{
				_condition = _condition + " && side player getFriend " + _side + " < 0.6";
			};
			if (_airExcluded) then
			{
				_condition = _condition + " && getPos vehicle player select 2 < 3";
			};
			_condition = _condition + " && alive player";
			//Activation
			_onact = "";
			_deact = "";
			if (_effect == 0) then
			{
				_onact = "if (fog != 1 || isNil 'CLY_borders_originalFog') then {CLY_borders_originalFog = fog;};1 setFog 1;[] spawn {sleep 0.5;20 cutText ['You have entered a restricted area!', 'PLAIN', 0.5];};";
				_deact = "1 setFog CLY_borders_originalFog;";
			};
			if (_effect == 1) then
			{
				_onact = "player setDamage 1;[] spawn {sleep 0.5;20 cutText ['You have died for entering a restricted area!', 'PLAIN', 0.5];};";
			};
			if (_effect == 2 || _customEffect != "") then
			{
				_onact = _onact + _customEffect;
			};
			//Trigger statements
			_trigger setTriggerStatements
			[
				_condition,
				_onact,
				_deact
			];
			//Warning trigger
			if (_warningRange != 0 || _warningTime > 0) then
			{
				_trigger = createTrigger ["EmptyDetector", markerPos _marker];
				_trigger setTriggerArea [(markerSize _marker select 0) + _warningRange, (markerSize _marker select 1) + _warningRange, markerDir _marker, markerShape _marker == "RECTANGLE"];
				_trigger setTriggerActivation ["ANY", "PRESENT", true];
				missionNamespace setVariable [_marker + "warning", _trigger];
				
				_trigger setTriggerStatements
				[
					_condition,
					"20 cutText ['You are entering a restricted area!', 'PLAIN', 0.5];",
					""
				];
			};
		};
	} forEach _borders;
} forEach ["", "west", "east", "resistance", "civilian"];