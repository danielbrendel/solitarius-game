/*
	Casual Game Engine: Casual Pixel Warrior
	
	A sample and test game for Casual Game Engine
	
	(C) 2021 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "item_ammo.as"

/* Gun ammo item entity */
class CItemAmmoGun : CItemAmmoBase
{
	CItemAmmoGun()
	{
		this.SetSprite("ammo\\ammo_gun_sym.bmp");
		this.SetWeapon("gun");
		this.SetSupplyCount(50);
	}
	
	//Return a name string here, e.g. the class name or instance name.
	string GetName()
	{
		return "item_ammo_gun";
	}
}

//Create ammo entity
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	CItemAmmoGun @ammo = CItemAmmoGun();
	ammo.SetTurnAround(false);
	Ent_SpawnEntity(szIdent, @ammo, vecPos);
}