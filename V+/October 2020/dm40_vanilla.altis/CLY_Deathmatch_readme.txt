CLY Deathmatch
An Arma 3 multiplayer game mode framework written by Mika Hannola AKA Celery
Version 4



How to make a deathmatch in ten easy steps:
1) Choose a location and place a respawn marker (named e.g. "respawn_independent") to cover it.
2) Populate the area with some extra objects for cover or decoration if you wish.
3) Place some soldiers and set them as playable.
4) Give your mission a funky name in the intel screen! "DM 08 Missionname" is a good and functional naming standard. The number stands for the mission's maximum player capacity.
5) Save your mission and give it a logical filename, preferably replacing spaces with underscore (_).
6) Introduce the CLY Deathmatch files (CLY_Deathmatch folder, briefing.html and description.ext) into your newly created mission folder that is located in Documents\Arma 3 (Other Profiles)\playername\missions\missionname.
7) Open description.ext and put your name in the author part and make sure maxPlayers and other settings are correct.
8) Edit the mission's rules and features in CLY_Deathmatch\cly_dm_settings.hpp.
9) Create a script called init.sqf in your mission folder and paste the following line there: execVM "CLY_Deathmatch\cly_dm_init.sqf";
10) Save the mission again to make it load the newly added and modified description.ext and inspect your masterpiece by shift + clicking preview. Once you're satisfied, export the mission to multiplayer in the "save as" menu, host it online and trick your friends (and the Arma community) into playing it!