//Removes the arm bomb addaction.
bomber removeaction arm;
//provides the detonate and deactivate commands.
det = bomber addaction [("<t color=""#FC2B05"">Detonate Bomb</t>"),"scripts\detonatebomb.sqf"];
deac = bomber addaction [("<t color=""#0000ff"">Deactivate Bomb</t>"),"scripts\deactivatebomb.sqf"];