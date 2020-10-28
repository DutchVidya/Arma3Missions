_healCompletely = _this select 0;
_unlimitedKits = _this select 1;

while {true} do
{
	_damage = damage player;
	_kits = {_x == "FirstAidKit"} count items player;
	sleep 0.1;
	if (damage player != _damage) then
	{
		if (damage player == 0.25) then
		{
			if ({_x == "FirstAidKit"} count items player < _kits) then
			{
				if (_healCompletely) then {player setDamage 0;};
				if (_unlimitedKits) then {player addItem "FirstAidKit";};
			};
		};
	};
};