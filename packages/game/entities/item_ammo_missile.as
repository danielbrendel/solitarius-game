/*
	Casual Game Engine: Solitarius
	
	A sample and test game for Casual Game Engine
	
	(C) 2021 - 2022 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "item_ammo.as"

/* Missile ammo item entity */
class CItemAmmoMissile : CItemAmmoBase
{
	CItemAmmoMissile()
	{
		this.SetSprite("ammo\\ammo_missile_sym.bmp");
		this.SetWeapon("missile");
		this.SetSupplyCount(10);
	}
	
	//Return a name string here, e.g. the class name or instance name.
	string GetName()
	{
		return "item_ammo_missile";
	}
}

//Create ammo entity
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	CItemAmmoMissile @ammo = CItemAmmoMissile();
	ammo.SetTurnAround(false);
	Ent_SpawnEntity(szIdent, @ammo, vecPos);
}