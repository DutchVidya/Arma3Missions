//--- Draw location markers
_allColors =
[
	"ColorBlack",
	"ColorBlue",
	"ColorBrown",
	"ColorGreen",
	//"ColorGrey",
	//"ColorKhaki",
	"ColorOrange",
	"ColorPink",
	"ColorRed",
	"ColorWhite",
	"ColorYellow",
	"ColorBLUFOR",
	"ColorOPFOR",
	"ColorIndependent",
	"ColorCivilian",
	"ColorUnknown",
	"Color1_FD_F",
	//"Color2_FD_F",
	"Color3_FD_F",
	"Color4_FD_F"
];
_colorIndex = 0;
{
	_trigger = _x select 0;
	_name = _x select 1;
	_marker = [_name + " border", _trigger, true] call BIS_fnc_markerToTrigger;
	_marker setMarkerBrushLocal "Border";
	_marker setMarkerColorLocal (_allColors select _colorIndex);
	_colorIndex = _colorIndex + 1;
	if (_colorIndex >= count _allColors) then
	{
		_colorIndex = 0;
	};
} forEach CLY_vanilla_locations;

_pointer = createMarkerLocal ["vanillaPointer", [0, 0]];
_pointer setMarkerTypeLocal "mil_triangle";
_pointer setMarkerDirLocal 270;
_pointer setMarkerSizeLocal [0.5, 0.5];

//--- Move player to another location
waitUntil {{isNil _x} count ["CLY_vanilla_currentLocation", "CLY_DM_loadout", "CLY_DM_primaryTextLayer"] == 0};
waitUntil {!isNull player};
CLY_vanilla_loadoutSetting = CLY_DM_loadout;
_trigger = objNull;
while {true} do
{
	waitUntil {_trigger != (CLY_vanilla_currentLocation select 0)};
	_trigger = CLY_vanilla_currentLocation select 0;
	_name = CLY_vanilla_currentLocation select 1;
	_minPlayers = CLY_vanilla_currentLocation select 2;
	_maxPlayers = CLY_vanilla_currentLocation select 3;
	CLY_DM_loadout = CLY_vanilla_weaponPoolNames find (CLY_vanilla_currentLocation select 4);
	_maxPlayers = if (_maxPlayers > _minPlayers) then {"-" + str _maxPlayers;} else {"";};
	CLY_respawnPosition_badAreas = if (count CLY_vanilla_currentLocation > 5) then {CLY_vanilla_currentLocation select 5;} else {[];};
	_borderMarker = _name + " border";
	_marker = [CLY_respawnPosition_area, _trigger, true] call BIS_fnc_markerToTrigger;
	_marker setMarkerColorLocal markerColor _borderMarker;
	_marker setMarkerAlphaLocal 0.75;
	_pointer setMarkerTextLocal _name + " (" + str _minPlayers + _maxPlayers + ")";
	_pointer setMarkerColorLocal markerColor _borderMarker;
	_pointer setMarkerPosLocal [(markerPos _borderMarker select 0) + ([0, 0] distance markerSize _borderMarker) + 100, markerPos _borderMarker select 1];
	if (time == 0) then {sleep 0.01;};
	if (alive player) then
	{
		if (CLY_vanilla_loadoutSetting == -2) then
		{
			[player, CLY_DM_loadout] call CLY_DM_fnc_playerRespawnRoutines;
		}
		else
		{
			[player, -2] call CLY_DM_fnc_playerRespawnRoutines;
		};
	};
	waitUntil {alive player};
	CLY_DM_primaryTextLayer cutText ["Now arriving at " + _name + ".", "PLAIN DOWN", 0.7];
	[] spawn
	{
		0 fadeMusic 0.5;
		playMusic ["BackgroundTrack01_F", 0];
		sleep 5;
		5 fadeMusic 0;
	};
};