/*
	Casual Game Engine: Solitarius
	
	A top-down 2D singleplayer space wave shooter
	
	(C) 2021 - 2022 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "item_ammo.as"

/* Laser ammo item entity */
class CItemAmmoLaser : CItemAmmoBase
{
	CItemAmmoLaser()
	{
		this.SetSprite("ammo\\ammo_laser_sym.bmp");
		this.SetWeapon("laser");
		this.SetSupplyCount(25);
	}
	
	//Return a name string here, e.g. the class name or instance name.
	string GetName()
	{
		return "item_ammo_laser";
	}
}

//Create ammo entity
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	CItemAmmoLaser @ammo = CItemAmmoLaser();
	ammo.SetTurnAround(false);
	Ent_SpawnEntity(szIdent, @ammo, vecPos);
}