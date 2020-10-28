waitUntil {{isNil _x} count ["CLY_vanilla_location", "CLY_vanilla_locationCapacity", "CLY_vanilla_tourDestinations", "CLY_DM_loadout", "CLY_vanilla_loadoutSetting"] == 0};
waitUntil {!isNull player};

_vanillaSettings = "";
_vanillaSettings = _vanillaSettings + "Location: " + (getArray (missionConfigFile / "Params" / "CLY_vanilla_location" / "texts") select (getArray (missionConfigFile / "Params" / "CLY_vanilla_location" / "values") find CLY_vanilla_location)) + "<br/>";
_vanillaSettings = _vanillaSettings + "Player capacity of random locations: " + (getArray (missionConfigFile / "Params" / "CLY_vanilla_locationCapacity" / "texts") select (getArray (missionConfigFile / "Params" / "CLY_vanilla_locationCapacity" / "values") find CLY_vanilla_locationCapacity)) + "<br/>";
if (CLY_vanilla_location == -2) then {_vanillaSettings = _vanillaSettings + "Tour destinations: " + str CLY_vanilla_tourDestinations + "<br/>";};
_vanillaSettings = _vanillaSettings + "Time of day: " + (getArray (missionConfigFile / "Params" / "CLY_vanilla_timeOfDay" / "texts") select (getArray (missionConfigFile / "Params" / "CLY_vanilla_timeOfDay" / "values") find CLY_vanilla_timeOfDay)) + "<br/>";
_vanillaSettings = _vanillaSettings + "Loadout: " + (getArray (missionConfigFile / "Params" / "CLY_DM_loadout" / "texts") select (getArray (missionConfigFile / "Params" / "CLY_DM_loadout" / "values") find CLY_vanilla_loadoutSetting));

player createDiaryRecord
[
	"Diary",
	[
		"Vanilla",
		"<img image='cly.paa' width='64' height='64'/><br/>Deathmatch<br/>Vanilla: Altis<br/><br/>War. You've seen enough of war. But still it constantly comes back to you in endless flashbacks, reminding you of the things you did or were done to you. The details change in every flashback, as if pestering you to remember how things really happened. You feel another one of those nightmarish episodes coming..." + "<br/><br/><marker name='CLY_DM_respawn'>Click here</marker> to center on your current location.<br/><br/>" + "Vanilla settings<br/>" + _vanillaSettings
	]
];