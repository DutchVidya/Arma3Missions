execVM "CLY_Deathmatch\cly_dm_init.sqf"; //Initiate CLY Deathmatch

CLY_fnc_respawnPosition = compileFinal preprocessFile "CLY_Deathmatch\cly_respawnPosition.sqf";

//Vanilla
#include "vanillaLocations.hpp"
if (isServer) then {execVM "vanillaServer.sqf";};
if (!isDedicated) then
{
	execVM "vanillaBriefing.sqf";
	execVM "vanillaClient.sqf";
};
CLY_vanilla_weaponPoolNames = ["CLY_loadout_random", "CLY_loadout_random_i", "CLY_loadout_ar", "CLY_loadout_ar_i", "CLY_loadout_ar_l", "CLY_loadout_ar_l_i", "CLY_loadout_ar_m", "CLY_loadout_ar_m_i", "CLY_loadout_mg", "CLY_loadout_am", "CLY_loadout_am_i", "CLY_loadout_lr", "CLY_loadout_mr", "CLY_loadout_smg", "CLY_loadout_smg_i", "CLY_loadout_smg_l", "CLY_loadout_smg_l_i", "CLY_loadout_hg", "CLY_loadout_hg_l", "arifle_Katiba_ARCO_pointer_F", "arifle_Mk20C_ACO_pointer_F", "arifle_Mk20_GL_MRCO_pointer_F", "arifle_MXC_F", "arifle_MXM_Hamr_pointer_F", "arifle_MX_SW_Hamr_pointer_F", "arifle_SDAR_F", "arifle_TRG20_F", "arifle_TRG21_GL_F", "srifle_EBR_F", "LMG_Mk200_F", "LMG_Zafir_F", "SMG_01_F", "SMG_02_F", "hgun_PDW2000_Holo_snds_F", "srifle_GM6_SOS_F", "srifle_GM6_F", "srifle_LRR_SOS_F", "srifle_LRR_F", "hgun_ACPC2_F", "hgun_P07_F", "hgun_Rook40_F"];

//Other settings
setViewDistance 600;
"respawn_independent" setMarkerAlphaLocal 0;
26 cutText ["", "BLACK FADED", 1];

//--- Time of day
_timeOfDay = daytime;
waitUntil {!isNil "CLY_vanilla_timeOfDay" && !isNil "CLY_DM_serverTime"};
if (CLY_vanilla_timeOfDay == -1 && isServer) then
{
	_timeOfDayArray = (getArray (missionConfigFile / "Params" / "CLY_vanilla_timeOfDay" / "values")) - [-1];
	CLY_vanilla_timeOfDay = _timeOfDayArray select floor random count _timeOfDayArray;
	CLY_vanilla_timeOfDayRandom = CLY_vanilla_timeOfDay;
	publicVariable "CLY_vanilla_timeOfDayRandom";
};
if (CLY_vanilla_timeOfDay == -1) then
{
	waitUntil {!isNil "CLY_vanilla_timeOfDayRandom"};
	CLY_vanilla_timeOfDay = CLY_vanilla_timeOfDayRandom;
};
_timeOfDay = (CLY_vanilla_timeOfDay * 0.01) + (CLY_DM_serverTime * (3600 ^ -1));
skipTime (_timeOfDay - daytime);