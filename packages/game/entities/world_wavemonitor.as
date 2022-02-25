/*
	Casual Game Engine: Solitarius
	
	A top-down 2D singleplayer space wave shooter
	
	(C) 2021 - 2022 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

/* Wave monitor entity */
class CWaveMonitor : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Model m_oModel;
	Timer m_tmrMonitor;
	Timer m_tmrCoinWatch;
	
	CWaveMonitor()
    {
    }
	
	//Indicate if all opponents are defeated
	bool AllOpponentsDefeated()
	{
		return Ent_GetEntityNameCount("alienboltship") == 0
			&& Ent_GetEntityNameCount("alienboss") == 0
			&& Ent_GetEntityNameCount("alienlasership") == 0
			&& Ent_GetEntityNameCount("alienmissileship") == 0
			&& Ent_GetEntityNameCount("alienrotatorship") == 0
			&& Ent_GetEntityNameCount("world_wavepoint") == 0;
	}

	//Handle goal achievements
	void HandleGoalAchievements()
	{
		if (GetCurrentMap() == "sectora.cfg") {
			if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_FINISH_SECTOR_A")) {
				Steam_SetAchievement("ACHIEVEMENT_FINISH_SECTOR_A");
			}
		} else if (GetCurrentMap() == "sectorb.cfg") {
			if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_FINISH_SECTOR_B")) {
				Steam_SetAchievement("ACHIEVEMENT_FINISH_SECTOR_B");
			}
		} else if (GetCurrentMap() == "sectorc.cfg") {
			if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_FINISH_SECTOR_C")) {
				Steam_SetAchievement("ACHIEVEMENT_FINISH_SECTOR_C");
			}
		} else if (GetCurrentMap() == "bossfight.cfg") {
			if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_DEFEAT_BOSS")) {
				Steam_SetAchievement("ACHIEVEMENT_DEFEAT_BOSS");
			}
		}
	}

	//Handle coin achievements
	bool HandleCoinAchievements()
	{
		if (Ent_GetEntityNameCount("item_coin") == 0) {
			if (GetCurrentMap() == "sectora.cfg") {
				if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_COLLECT_COINS_SECTORA")) {
					Steam_SetAchievement("ACHIEVEMENT_COLLECT_COINS_SECTORA");
				}
			} else if (GetCurrentMap() == "sectorb.cfg") {
				if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_COLLECT_COINS_SECTORB")) {
					Steam_SetAchievement("ACHIEVEMENT_COLLECT_COINS_SECTORB");
				}
			} else if (GetCurrentMap() == "sectorc.cfg") {
				if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_COLLECT_COINS_SECTORB")) {
					Steam_SetAchievement("ACHIEVEMENT_COLLECT_COINS_SECTORB");
				}
			} else if (GetCurrentMap() == "bossfight.cfg") {
				if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_COLLECT_COINS_BOSSFIGHT")) {
					Steam_SetAchievement("ACHIEVEMENT_COLLECT_COINS_BOSSFIGHT");
				}
			}

			return true;
		}

		return false;
	}
	
	//Called when the entity gets spawned. The position in the map is passed as argument
	void OnSpawn(const Vector& in vec)
	{	
		this.m_vecPos = vec;
		Ent_SetGoalActivationStatus(false);
		this.m_tmrMonitor.SetDelay(10000);
		this.m_tmrMonitor.Reset();
		this.m_tmrMonitor.SetActive(true);
		this.m_tmrCoinWatch.SetDelay(2000);
		this.m_tmrCoinWatch.Reset();
		this.m_tmrCoinWatch.SetActive(false);
		this.m_oModel.Alloc();
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		if (this.m_tmrMonitor.IsActive()) {
			this.m_tmrMonitor.Update();
			if (this.m_tmrMonitor.IsElapsed()) {
				this.m_tmrMonitor.Reset();
				
				if (this.AllOpponentsDefeated()) {
					this.m_tmrMonitor.SetActive(false);
					Ent_SetGoalActivationStatus(true);
					this.HandleGoalAchievements();
					TriggerGameSave();
					this.m_tmrCoinWatch.Reset();
					this.m_tmrCoinWatch.SetActive(true);
					HUD_AddMessage(_("app.portal_now_open", "Portal is now open!"), HUD_MSG_COLOR_GREEN);

					if (GetCurrentMap() == "bossfight.cfg") {
						CVar_SetBool("game_completed", true);
					}
				}
			}
		}

		if (this.m_tmrCoinWatch.IsActive()) {
			this.m_tmrCoinWatch.Update();
			if (this.m_tmrCoinWatch.IsElapsed()) {
				this.m_tmrCoinWatch.Reset();

				if (this.HandleCoinAchievements()) {
					this.m_tmrCoinWatch.SetActive(false);
				}
			}
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Draw on top
	void OnDrawOnTop()
	{
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return false;
	}
	
	//Indicate if entity can be collided
	bool IsCollidable()
	{
		return false;
	}
	
	//Indicate if entity can be dormant
	bool CanBeDormant()
	{
		return false;
	}
	
	//Called when the entity recieves damage
	void OnDamage(uint32 damageValue)
	{
	}
	
	//Called for wall collisions
	void OnWallCollided()
	{
	}
	
	//Called for entity collisions
	void OnCollided(IScriptedEntity@ ref)
	{
	}
	
	//Called for accessing the model data for this entity.
	Model& GetModel()
	{
		return this.m_oModel;
	}
	
	//Called for recieving the current position. This is useful if the entity shall move.
	Vector& GetPosition()
	{
		return this.m_vecPos;
	}
	
	//Set position
	void SetPosition(const Vector &in vec)
	{
	}
	
	//Return the rotation. 
	float GetRotation()
	{
		return 0.0;
	}
	
	//Set rotation
	void SetRotation(float fRot)
	{
	}
	
	//Return a name string here, e.g. the class name or instance name. 
	string GetName()
	{
		return "world_wavemonitor";
	}
	
	//This vector is used for drawing the selection box
	Vector& GetSize()
	{
		return this.m_vecPos;
	}
	
	//Return save game properties
	string GetSaveGameProperties()
	{
		return Props_CreateProperty("x", formatInt(this.m_vecPos[0])) +
			Props_CreateProperty("y", formatInt(this.m_vecPos[1]));
	}
}

//Create the associated entity here
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	CWaveMonitor @waveMonitor = CWaveMonitor();
	Ent_SpawnEntity(szIdent, @waveMonitor, vecPos);
}