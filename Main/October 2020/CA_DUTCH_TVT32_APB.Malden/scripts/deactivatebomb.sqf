//Removes the detonate and deactivate commands, gives back the arm command
bomber removeaction det;
bomber removeaction deac;
arm = bomber addaction [("<t color=""#FC2B05"">Arm Bomb</t>"),"scripts\armbomb.sqf"]