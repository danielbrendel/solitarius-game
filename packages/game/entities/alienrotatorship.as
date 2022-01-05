/*
	Casual Game Engine: Solitarius
	
	A top-down 2D singleplayer space wave shooter
	
	(C) 2021 - 2022 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "alienrotatorshipcls.as"

//Spawn entity initially
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	CAlienRotatorShip @ent = CAlienRotatorShip();
	Ent_SpawnEntity(szIdent, @ent, vecPos);
}

