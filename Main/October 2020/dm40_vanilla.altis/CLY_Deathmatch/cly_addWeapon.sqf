/*
	CLY addWeapon
	Author: Mika Hannola AKA Celery
	
	Description:
	Add a weapon to a unit with the right magazines. Magazine class is fetched from the weapon's config.
	
	Parameter(s):
	_this select 0: <object> unit that is issued new equipment
	_this select 1: <string> weapon classname
	_this select 2: <scalar> number of magazines
	_this select 3 (Optional): <scalar> index of magazine class in weapon's config (default 0) OR <string> magazine classname
	_this select 4 (Optional): <scalar> number of secondary magazines
	_this select 5 (Optional): <scalar> index of magazine class in weapon's config (default 0) OR <string> magazine classname
	
	Returns:
	Array of the weapon's muzzle names for a followup selectWeapon.
	
	How to use:
	_muzzles = [player, "arifle_SDAR_F", 6] call BIS_fnc_addWeapon;
	player selectWeapon (_muzzles select 0);
	Equips the player with an underwater rifle and six magazines of underwater ammo and makes the player select the weapon.
	
	_muzzles = [player, "arifle_SDAR_F", 6, 1] call BIS_fnc_addWeapon;
	OR
	_muzzles = [player, "arifle_SDAR_F", 6, "30Rnd_556x45_Stanag"] call BIS_fnc_addWeapon;
	Equips the player with an underwater rifle and six normal magazines.
	
	_muzzles = [player, "arifle_MX_GL_F", 6, 0, 4] call BIS_fnc_addWeapon;
	player selectWeapon (_muzzles select 1);
	Gives the player a rifle with a grenade launcher, six magazines, four grenades, and makes the launcher the active weapon.
*/

private ["_unit", "_weapon", "_magazineCount", "_magazineClass", "_magazineCountSecondary", "_magazineClassSecondary", "_weaponExists", "_muzzles", "_primaryMagazineAdded", "_secondaryMagazineAdded", "_magazines", "_i"];

_unit = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_weapon = [_this, 1, "", [""]] call BIS_fnc_param;
_magazineCount = [_this, 2, 0, [0]] call BIS_fnc_param;
_magazineClass = [_this, 3, 0, [0, ""]] call BIS_fnc_param;
_magazineCountSecondary = [_this, 4, 0, [0]] call BIS_fnc_param;
_magazineClassSecondary = [_this, 5, 0, [0, ""]] call BIS_fnc_param;
_weaponExists = isClass (configFile / "CfgWeapons" / _weapon);

//--- Determine muzzles and correct primary muzzle name
_muzzles = if (_weaponExists) then {getArray (configFile / "CfgWeapons" / _weapon / "muzzles");} else {[];};
if (count _muzzles > 0) then
{
	_muzzles set [0, if (_muzzles select 0 == "this") then {_weapon} else {_muzzles select 0}];
};

//--- Determine primary magazine
_primaryMagazineAdded = false;
if (_magazineCount > 0) then
{
	if (typeName _magazineClass == typeName 0) then
	{
		_magazines = getArray (configFile / "CfgWeapons" / _weapon / "magazines");
		if (count _magazines > 0 && _weaponExists) then
		{
			_magazineClass = _magazines select (_magazineClass min (count _magazines - 1));
		}
		else
		{
			_magazineClass = "";
		};
	};
	if (isClass (configFile / "CfgMagazines" / _magazineClass)) then
	{
		for "_i" from 1 to 1 do
		{
			_unit addMagazine _magazineClass;
		};
		_primaryMagazineAdded = true;
	};
};

//--- Determine secondary magazine
_secondaryMagazineAdded = false;
if (_magazineCountSecondary > 0) then
{
	if (typeName _magazineClassSecondary == typeName 0) then
	{
		if (count _muzzles > 1) then
		{
			_magazines = getArray (configFile / "CfgWeapons" / _weapon / (getArray (configFile / "CfgWeapons" / _weapon / "muzzles") select 1) / "magazines");
			if (count _magazines > 0) then
			{
				_magazineClassSecondary = _magazines select (_magazineClassSecondary min (count _magazines - 1));
			};
		}
		else
		{
			_magazineClassSecondary = "";
		};
	};
	if (isClass (configFile / "CfgMagazines" / _magazineClassSecondary)) then
	{
		for "_i" from 1 to 1 do
		{
			_unit addMagazine _magazineClassSecondary;
		};
		_secondaryMagazineAdded = true;
	};
};

//--- Add weapon if unit doesn't have it yet
if (_weaponExists) then
{
	if !(_weapon in weapons _unit) then
	{
		_unit addWeapon _weapon;
	};
};

//--- Add the rest of the magazines
if (_primaryMagazineAdded) then
{
	for "_i" from 2 to _magazineCount do
	{
		_unit addMagazine _magazineClass;
	};
};
if (_secondaryMagazineAdded) then
{
	for "_i" from 2 to _magazineCountSecondary do
	{
		_unit addMagazine _magazineClassSecondary;
	};
};

_muzzles; //Return array of muzzles