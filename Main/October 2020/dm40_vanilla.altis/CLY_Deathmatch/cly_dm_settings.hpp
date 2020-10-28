/*
	CLY Deathmatch settings
	
	Most of these settings can be included in description.ext mission parameters that override the default values if the parameter classnames match the variables.
*/

CLY_DM_missionCredits = format ["Mission created by %1", getText (missionConfigFile / "author")]; //Credits for this particular mission shown in Game Mode -> Acknowledgements. Author name is fetched from description.ext by default. Remember to credit script makers and 3rd party media sources if you use their work. Line break: <br/>

//--- General mechanics and settings
CLY_DM_gameMode = 0; //Game mode | 0: Deathmatch | 1: Flag Fight (remember to change in description.ext as well!)
CLY_DM_timeLimit = 20; //Time limit in minutes (0 is unlimited)
CLY_DM_scoreLimit = 0; //Score limit (0 is unlimited)
CLY_DM_relativeScoreLimit = 0; //BOOLEAN - A relative score limit requires the leader to have <CLY_DM_scoreLimit> points more than any other player
CLY_DM_suicidePenalty = 1; //BOOLEAN - A point is deducted from a player's score if he dies without another player as the killer
CLY_DM_hud = 1; //BOOLEAN - Use UI elements to show time and stats
CLY_DM_tasks = 1; //BOOLEAN - Use default tasks
CLY_DM_intro = 0; //BOOLEAN - Enable intro: mission won't start until CLY_DM_intro is set to false by a script
CLY_DM_outro = 0; //BOOLEAN - Enable outro: mission won't end until CLY_DM_outro is set to false by a script
CLY_DM_outroScript = ""; //Filename of the outro script (can be SQS, SQF or FSM)
//Show the mission result text in the outro script with: 10 call CLY_DM_outroText; (the number is how long the text stays on screen)
//End the outro with: CLY_DM_outro = false;

//--- Features
CLY_DM_respawnDirection = 45; //Direction faced upon respawn | -2: Direction faced when killed | -1: Random | 0, 1, 2...: Nearest enemy ± x°
CLY_DM_terrainGrid = 50000; //Terrain detail | 0: Default | 50000: No grass or clutter on the ground (best for PvP) | 25000; 12500; 6250; 3125: Increasing levels of grass/clutter and distant terrain complexity
CLY_DM_deathCamera = 1; //Special camera view upon death | 0: Disabled | 1: Passive (targets killer's last position) | 2: Active (targets killer's current position) | 3: Killer's POV
CLY_DM_announceKiller = 1; //BOOLEAN - Announce the name of your killer when you die; helps build rivalries on servers with disabled kill messages
CLY_DM_disableFatigue = 0; //BOOLEAN - Disable fatigue effects (shaky aim, slower running speed, visuals)
CLY_DM_protectArms = 0; //BOOLEAN - Keep player's arms at 0 damage
CLY_DM_protectLegs = 0; //BOOLEAN - Keep player's legs at 0 damage
CLY_DM_unlimitedAmmo = 0; //BOOLEAN - Unlimited ammo
CLY_DM_unlimitedAmmoExplosiveReloadTime = 0.5; //Reload time for explosive weapons with unlimited ammo (keeps rate of fire of launchers reasonable)
CLY_DM_antiProne = 0; //BOOLEAN - Prevent players from lying down in missions where it would negatively affect gameplay
CLY_DM_force1stPerson = 1; //BOOLEAN - Force first person view; recommended if using third person view would be detrimental to the mission's gameplay
CLY_DM_FAKHealsCompletely = 1; //BOOLEAN - First aid kits heal the player completely
CLY_DM_unlimitedFAKs = 1; //BOOLEAN - A new first aid kit is given every time one is used

//--- Advanced respawn position
/*
	This system replaces the normal respawn positioning system by generating a random position within a given area where no enemies have line of sight. It can drastically lower the chance of getting killed right after respawning or having an enemy respawn close to you.
	
	How to use:
	Move your respawn marker out of the way and instead use a marker named "CLY_DM_respawn" to cover the mission area.
*/
CLY_respawnPosition = 1; //BOOLEAN - Use the CLY Respawn Position system
CLY_respawnPosition_useAtStart = 0; //BOOLEAN - Use the CLY Respawn Position system at the start of the mission
CLY_respawnPosition_area = "CLY_DM_respawn"; //Trigger or marker used as an area to generate a position
CLY_respawnPosition_badAreas = []; //Triggers or markers within which a position cannot be generated
CLY_respawnPosition_losRadius = 500; //Radius at which enemies' lines of sight are taken into account
CLY_respawnPosition_tries = 1000; //Maximum number of tries to find a suitable position before settling for the last one

//--- Flag Fight
CLY_DM_flags = []; //Flagpoles containing capturable flags
CLY_DM_returnFlags = []; //Flagpoles where the flag(s) should be taken
CLY_DM_flagFightScoreYield = 20; //Score yield from scoring a flag in Flag Fight
CLY_DM_flagFightScoreDistance = 6; //Distance from a return pole (or rather its middle part) at which one can score a flag
CLY_DM_flagReturnDelay = 60; //Time in seconds until a flag returns to its pole from a dead body
CLY_DM_flagMarker = "mil_flag"; //Marker class that is used to mark a flag
CLY_DM_returnFlagMarker = "mil_end"; //Marker class that is used to mark a return flag

//--- Borders - See CLY_Deathmatch\cly_borders.sqf for detailed instructions
[
	[], //Universal borders
	[], //BLUFOR borders
	[], //OPFOR borders
	[], //Independent borders
	[], //Civilian borders
	true, //Inverse border: player has to stay inside the border
	0, //Border effect | 0: Heavy fog | 1: Death | 2: Custom
	"", //Custom effect
	0, //Warning time until the border effect is put into motion
	0, //Range at which a player receives a warning of a border
	false //Flying units (at least 3 meters off the ground) are excluded
] execVM (CLY_DM_scriptPath + "cly_borders.sqf");

//--- Body and wreck removal
[
	120, //Removal delay for bodies (-1 disables removal for this type)
	-1, //Removal delay for soft vehicle wrecks (-1 disables removal for this type)
	-1, //Removal delay for armored vehicle wrecks (-1 disables removal for this type)
	-1, //Removal delay for aircraft wrecks (-1 disables removal for this type)
	[], //Units that aren't removed
	[], //Weapons or items that prevent units from being removed if they have them
	[], //Magazines that prevent units from being removed if they have them
	[] //Backpacks that prevent units from being removed if they have them
] execVM (CLY_DM_scriptPath + "cly_bodyRemoval.sqf");

//--- Resource layers
CLY_DM_primaryTextLayer = 30;
CLY_DM_secondaryTextLayer = 29;
CLY_DM_tertiaryTextLayer = 28;
CLY_DM_hudLayer = 27;
CLY_DM_effectLayer = 26;

//--- Weapon loadouts
CLY_DM_loadout = 1; //-2: Unscripted | -1: Unit's initial loadout is always given | 0, 1, 2...: Use respective loadout pool listed further below
	
//The settings below only work for CLY_DM_loadout = 0 or higher
CLY_DM_vest = ["V_Chestrig_blk", "V_Chestrig_khk", "V_Chestrig_oli", "V_Chestrig_rgr"]; //Vest that is always given - empty array leaves default vest, empty string removes it
CLY_DM_backpack = []; //Backpack that is always given - empty array leaves default backpack, empty string removes it
CLY_DM_magazines = ["HandGrenade", "Chemlight_yellow"]; //Magazines that are always given
CLY_DM_weapons = ["ItemCompass", "ItemGPS", "ItemMap", "ItemRadio", "ItemWatch", "Rangefinder"]; //Weapons (or items of a specific type) that are always given - Some items: ["Binocular", "FirstAidKit", "ItemCompass", "ItemGPS", "ItemMap", "ItemRadio", "ItemWatch", "NVGoggles", "Rangefinder"]
CLY_DM_items = ["FirstAidKit"]; //Items (usables and accessories) that are always given

/*
	The description.ext weapon selection parameter (CLY_DM_loadout) will select a loadout pool matching the parameter's value
	You can add as many pools as you like as long as they're named appropriately
	Loadout format:
	["WeaponClassName", <# of primary mags>, <primary magazine type (string or config index)>, <# of GL mags>, <GL magazine type>]
*/
CLY_DM_loadoutPool0 = [
	["arifle_Katiba_ARCO_pointer_F", 15, "30Rnd_65x39_caseless_green"],
	["arifle_Katiba_C_ACO_pointer_snds_F", 15, "30Rnd_65x39_caseless_green"],
	["arifle_Mk20_Holo_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_Mk20_MRCO_plain_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_Mk20C_ACO_pointer_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_Mk20_GL_MRCO_pointer_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"],
	["arifle_MX_ACO_pointer_F", 15, "30Rnd_65x39_caseless_mag"],
	["arifle_MX_SW_Hamr_pointer_F", 6, "100Rnd_65x39_caseless_mag_Tracer"],
	["arifle_MXC_Holo_pointer_snds_F", 15, "30Rnd_65x39_caseless_mag"],
	["arifle_MXM_Hamr_pointer_F", 15, "30Rnd_65x39_caseless_mag"],
	["arifle_SDAR_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_TRG20_ACO_Flash_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_TRG21_ARCO_pointer_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_TRG21_GL_MRCO_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"],
	["hgun_PDW2000_Holo_snds_F", 12, "30Rnd_9x21_Mag"],
	["LMG_Mk200_MRCO_F", 3, "200Rnd_65x39_cased_Box_Tracer"],
	["LMG_Zafir_pointer_F", 3, "150Rnd_762x51_Box_Tracer"],
	["SMG_01_Holo_F", 12, "30Rnd_45ACP_Mag_SMG_01"],
	["SMG_02_ACO_F", 12, "30Rnd_9x21_Mag"],
	["srifle_EBR_ARCO_pointer_F", 11, "20Rnd_762x51_Mag"],
	[["srifle_GM6_SOS_F", 11, "5Rnd_127x108_Mag"], ["srifle_LRR_SOS_F", 8, "7Rnd_408_Mag"]]
];

CLY_DM_loadoutPool1 =
[
	[["arifle_Katiba_F", 15, "30Rnd_65x39_caseless_green"], ["arifle_Katiba_C_F", 15, "30Rnd_65x39_caseless_green"]],
	[["arifle_Mk20_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20_plain_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20C_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20C_plain_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20_GL_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"], ["arifle_Mk20_GL_plain_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"]],
	[["arifle_MX_F", 15, "30Rnd_65x39_caseless_mag"], ["arifle_MXC_F", 15, "30Rnd_65x39_caseless_mag"], ["arifle_MXM_F", 15, "30Rnd_65x39_caseless_mag"]],
	["arifle_MX_SW_F", 6, "100Rnd_65x39_caseless_mag_Tracer"],
	["arifle_SDAR_F", 17, "30Rnd_556x45_Stanag"],
	[["arifle_TRG20_F", 17, "30Rnd_556x45_Stanag"], ["arifle_TRG21_F", 17, "30Rnd_556x45_Stanag"], ["arifle_TRG21_GL_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"]],
	["hgun_PDW2000_F", 12, "30Rnd_9x21_Mag"],
	["LMG_Mk200_F", 3, "200Rnd_65x39_cased_Box_Tracer"],
	["LMG_Zafir_F", 3, "150Rnd_762x51_Box_Tracer"],
	["SMG_01_F", 12, "30Rnd_45ACP_Mag_SMG_01"],
	["SMG_02_F", 12, "30Rnd_9x21_Mag"],
	["srifle_EBR_F", 11, "20Rnd_762x51_Mag"],
	[["srifle_GM6_F", 11, "5Rnd_127x108_Mag"], ["srifle_LRR_F", 8, "7Rnd_408_Mag"]]
];

CLY_DM_loadoutPool2 =
[
	["arifle_Katiba_ARCO_pointer_F", 15, "30Rnd_65x39_caseless_green"],
	["arifle_Katiba_C_ACO_pointer_snds_F", 15, "30Rnd_65x39_caseless_green"],
	["arifle_Mk20_Holo_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_Mk20_MRCO_plain_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_Mk20C_ACO_pointer_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_Mk20_GL_MRCO_pointer_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"],
	["arifle_MX_ACO_pointer_F", 15, "30Rnd_65x39_caseless_mag"],
	["arifle_MXC_Holo_pointer_snds_F", 15, "30Rnd_65x39_caseless_mag"],
	["arifle_SDAR_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_TRG20_ACO_Flash_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_TRG21_ARCO_pointer_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_TRG21_GL_MRCO_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"],
	["srifle_EBR_ARCO_pointer_F", 11, "20Rnd_762x51_Mag"]
];

CLY_DM_loadoutPool3 =
[
	[["arifle_Katiba_F", 15, "30Rnd_65x39_caseless_green"], ["arifle_Katiba_C_F", 15, "30Rnd_65x39_caseless_green"]],
	[["arifle_Mk20_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20_plain_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20C_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20C_plain_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20_GL_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"], ["arifle_Mk20_GL_plain_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"]],
	[["arifle_MX_F", 15, "30Rnd_65x39_caseless_mag"], ["arifle_MXC_F", 15, "30Rnd_65x39_caseless_mag"]],
	["arifle_SDAR_F", 17, "30Rnd_556x45_Stanag"],
	[["arifle_TRG20_F", 17, "30Rnd_556x45_Stanag"], ["arifle_TRG21_F", 17, "30Rnd_556x45_Stanag"], ["arifle_TRG21_GL_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"]],
	["srifle_EBR_F", 11, "20Rnd_762x51_Mag"]
];

CLY_DM_loadoutPool4 =
[
	["arifle_Mk20_Holo_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_Mk20_MRCO_plain_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_Mk20C_ACO_pointer_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_SDAR_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_TRG20_ACO_Flash_F", 17, "30Rnd_556x45_Stanag"],
	["arifle_TRG21_MRCO_F", 17, "30Rnd_556x45_Stanag"]
];

CLY_DM_loadoutPool5 =
[
	[["arifle_Mk20_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20_plain_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20C_F", 17, "30Rnd_556x45_Stanag"], ["arifle_Mk20C_plain_F", 17, "30Rnd_556x45_Stanag"]],
	["arifle_SDAR_F", 17, "30Rnd_556x45_Stanag"],
	[["arifle_TRG20_F", 17, "30Rnd_556x45_Stanag"], ["arifle_TRG21_F", 17, "30Rnd_556x45_Stanag"]]
];

CLY_DM_loadoutPool6 =
[
	["arifle_Katiba_ARCO_pointer_F", 15, "30Rnd_65x39_caseless_green"],
	["arifle_Katiba_C_ACO_pointer_snds_F", 15, "30Rnd_65x39_caseless_green"],
	["arifle_MX_ACO_pointer_F", 15, "30Rnd_65x39_caseless_mag"],
	["arifle_MXC_Holo_pointer_snds_F", 15, "30Rnd_65x39_caseless_mag"]
];

CLY_DM_loadoutPool7 =
[
	[["arifle_Katiba_F", 15, "30Rnd_65x39_caseless_green"], ["arifle_Katiba_C_F", 15, "30Rnd_65x39_caseless_green"]],
	[["arifle_MX_F", 15, "30Rnd_65x39_caseless_mag"], ["arifle_MXC_F", 15, "30Rnd_65x39_caseless_mag"]]
];

CLY_DM_loadoutPool8 = [["arifle_MX_SW_Hamr_pointer_F", 6, "100Rnd_65x39_caseless_mag_Tracer"], ["LMG_Mk200_MRCO_F", 3, "200Rnd_65x39_cased_Box_Tracer"], ["LMG_Zafir_pointer_F", 3, "150Rnd_762x51_Box_Tracer"]];

CLY_DM_loadoutPool9 = [["srifle_GM6_SOS_F", 11, "5Rnd_127x108_Mag"], ["srifle_LRR_SOS_F", 8, "7Rnd_408_Mag"]];

CLY_DM_loadoutPool10 = [["srifle_GM6_F", 11, "5Rnd_127x108_Mag"], ["srifle_LRR_F", 8, "7Rnd_408_Mag"]];

CLY_DM_loadoutPool11 = [["arifle_MXM_SOS_pointer_F", 3, "30Rnd_65x39_caseless_mag"], ["srifle_EBR_SOS_F", 3, "20Rnd_762x51_Mag"], ["srifle_GM6_SOS_F", 11, "5Rnd_127x108_Mag"], ["srifle_LRR_SOS_F", 8, "7Rnd_408_Mag"]];

CLY_DM_loadoutPool12 = [["arifle_MXM_Hamr_pointer_F", 15, "30Rnd_65x39_caseless_mag"], ["srifle_EBR_ARCO_pointer_F", 11, "20Rnd_762x51_Mag"]];

CLY_DM_loadoutPool13 = [["hgun_PDW2000_Holo_F", 12, "30Rnd_9x21_Mag"], ["SMG_01_Holo_pointer_snds_F", 12, "30Rnd_45ACP_Mag_SMG_01"], ["SMG_02_ACO_F", 12, "30Rnd_9x21_Mag"]];

CLY_DM_loadoutPool14 = [["hgun_PDW2000_F", 12, "30Rnd_9x21_Mag"], ["SMG_01_F", 12, "30Rnd_45ACP_Mag_SMG_01"], ["SMG_02_F", 12, "30Rnd_9x21_Mag"]];

CLY_DM_loadoutPool15 = [["hgun_PDW2000_Holo_F", 12, "30Rnd_9x21_Mag"], ["SMG_02_ACO_F", 12, "30Rnd_9x21_Mag"]];

CLY_DM_loadoutPool16 = [["hgun_PDW2000_F", 12, "30Rnd_9x21_Mag"], ["SMG_02_F", 12, "30Rnd_9x21_Mag"]];

CLY_DM_loadoutPool17 = [["hgun_ACPC2_F", 12, "9Rnd_45ACP_Mag"], ["hgun_P07_F", 16, "16Rnd_9x21_Mag"], ["hgun_Rook40_F", 16, "16Rnd_9x21_Mag"]];

CLY_DM_loadoutPool18 = [["hgun_P07_F", 16, "16Rnd_9x21_Mag"], ["hgun_Rook40_F", 16, "16Rnd_9x21_Mag"]];

CLY_DM_loadoutPool19 = ["arifle_Katiba_ARCO_pointer_F", 15, "30Rnd_65x39_caseless_green"];

CLY_DM_loadoutPool20 = ["arifle_Mk20C_ACO_pointer_F", 17, "30Rnd_556x45_Stanag"];

CLY_DM_loadoutPool21 = ["arifle_Mk20_GL_MRCO_pointer_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"];

CLY_DM_loadoutPool22 = ["arifle_MXC_F", 15, "30Rnd_65x39_caseless_mag"];

CLY_DM_loadoutPool23 = ["arifle_MXM_Hamr_pointer_F", 15, "30Rnd_65x39_caseless_mag"];

CLY_DM_loadoutPool24 = ["arifle_MX_SW_Hamr_pointer_F", 6, "100Rnd_65x39_caseless_mag_Tracer"];

CLY_DM_loadoutPool25 = ["arifle_SDAR_F", 15, "30Rnd_556x45_Stanag"];

CLY_DM_loadoutPool26 = ["arifle_TRG20_F", 15, "30Rnd_556x45_Stanag"];

CLY_DM_loadoutPool27 = ["arifle_TRG21_GL_F", 12, "30Rnd_556x45_Stanag", 4, "1Rnd_HE_Grenade_shell"];

CLY_DM_loadoutPool28 = ["srifle_EBR_F", 11, "20Rnd_762x51_Mag"];

CLY_DM_loadoutPool29 = ["LMG_Mk200_F", 3, "200Rnd_65x39_cased_Box_Tracer"];

CLY_DM_loadoutPool30 = ["LMG_Zafir_F", 3, "150Rnd_762x51_Box_Tracer"];

CLY_DM_loadoutPool31 = ["SMG_01_F", 12, "30Rnd_45ACP_Mag_SMG_01"];

CLY_DM_loadoutPool32 = ["SMG_02_F", 12, "30Rnd_9x21_Mag"];

CLY_DM_loadoutPool33 = ["hgun_PDW2000_Holo_snds_F", 12, "30Rnd_9x21_Mag"];

CLY_DM_loadoutPool34 = ["srifle_GM6_SOS_F", 11, "5Rnd_127x108_Mag"];

CLY_DM_loadoutPool35 = ["srifle_GM6_F", 11, "5Rnd_127x108_Mag"];

CLY_DM_loadoutPool36 = ["srifle_LRR_SOS_F", 8, "7Rnd_408_Mag"];

CLY_DM_loadoutPool37 = ["srifle_LRR_F", 8, "7Rnd_408_Mag"];

CLY_DM_loadoutPool38 = ["hgun_ACPC2_F", 12, "9Rnd_45ACP_Mag"];

CLY_DM_loadoutPool39 = ["hgun_P07_F", 16, "16Rnd_9x21_Mag"];

CLY_DM_loadoutPool40 = ["hgun_Rook40_F", 16, "16Rnd_9x21_Mag"];

//--- Variables that will be converted from binary to boolean
CLY_DM_booleanVariables = ["CLY_DM_relativeScoreLimit", "CLY_DM_suicidePenalty", "CLY_DM_hud", "CLY_DM_tasks", "CLY_DM_intro", "CLY_DM_outro", "CLY_DM_announceKiller", "CLY_DM_disableFatigue", "CLY_DM_protectArms", "CLY_DM_protectLegs", "CLY_DM_unlimitedAmmo", "CLY_DM_antiProne", "CLY_DM_force1stPerson", "CLY_DM_FAKHealsCompletely", "CLY_DM_unlimitedFAKs", "CLY_DM_enableCustomDamageHandler", "CLY_respawnPosition", "CLY_respawnPosition_useAtStart"];