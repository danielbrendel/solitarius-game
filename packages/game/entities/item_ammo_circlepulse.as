/*
	Casual Game Engine: Casual Pixel Warrior
	
	A sample and test game for Casual Game Engine
	
	(C) 2021 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "item_ammo.as"

/* Circlepulse ammo item entity */
class CItemAmmoCirclePulse : CItemAmmoBase
{
	CItemAmmoCirclePulse()
	{
		this.SetSprite("ammo\\ammo_cp_sym.bmp");
		this.SetWeapon("circlepulse");
		this.SetSupplyCount(5);
	}
	
	//Return a name string here, e.g. the class name or instance name.
	string GetName()
	{
		return "item_ammo_circlepulse";
	}
}

//Create ammo entity
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	CItemAmmoCirclePulse @ammo = CItemAmmoCirclePulse();
	ammo.SetTurnAround(false);
	Ent_SpawnEntity(szIdent, @ammo, vecPos);
}