/*
	Casual Game Engine: Solitarius
	
	A top-down 2D singleplayer space wave shooter
	
	(C) 2021 - 2022 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

#include "explosion.as"
#include "weapon_gun.as"
#include "weapon_laser.as"
#include "weapon_missile.as"
#include "weapon_circlepulse.as"
#include "infomenu.as"

const int PLAYER_SPEED = 450;
const int BTN_FORWARD = (1 << 0);
const int BTN_BACKWARD = (1 << 1);
const int BTN_MOVELEFT = (1 << 2);
const int BTN_MOVERIGHT = (1 << 3);
const int BTN_TURNLEFT = (1 << 4);
const int BTN_TURNRIGHT = (1 << 5);
const int BTN_SPEED = (1 << 6);
const int BTN_ATTACK = (1 << 7);
const int BTN_THROW = (1 << 8);
const int BTN_DODGE = (1 << 9);
const int WEAPON_GUN = 1;
const int WEAPON_LASER = 2;
const int WEAPON_MISSILE = 3;
const uint GAME_COUNTER_MAX = 5;

/* Player entity manager */
class CPlayerEntity : IScriptedEntity, IPlayerEntity, ICollectingEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Vector m_vecCursorPos;
	Vector m_vecCrosshair;
	SpriteHandle m_hPlayer;
	SpriteHandle m_hCrosshair;
	Model m_oModel;
	float m_fRotation;
	uint32 m_uiButtons;
	uint32 m_uiHealth;
	Timer m_tmrMayDamage;
	Timer m_tmrAttack;
	bool m_bMoving;
	bool m_bShooting;
	int m_iCurrentWeapon;
	bool m_bMayThrow;
	int m_iScore;
	uint32 m_uiFlickerCount;
	Timer m_tmrFlicker;
	Timer m_tmrDodging;
	Timer m_tmrMayDodge;
	MovementDir m_dodgeType;
	uint m_uiDodgeCounter;
	SoundHandle m_hDodge;
	Timer m_tmrGameCounter;
	uint m_uiGameCounter;
	Timer m_tmrGoInfo;
	FontHandle m_hGameInfoFont;
	bool m_bProcessOnce;
	CInfoMenu m_oInfoMenu;
	SpriteHandle m_hCursor;
	bool m_bBossDefeatedDlgOpen;
	
	CPlayerEntity()
    {
		this.m_uiButtons = 0;
		this.m_uiHealth = 100;
		this.m_vecSize = Vector(101, 93);
		this.m_vecCrosshair = Vector(32, 32);
		this.m_uiFlickerCount = 0;
		this.m_bMoving = false;
		this.m_bShooting = false;
		this.m_iCurrentWeapon = WEAPON_GUN;
		this.m_bMayThrow = true;
		this.m_iScore = 0;
		this.m_uiDodgeCounter = 0;
		this.m_bProcessOnce = false;
		this.m_bBossDefeatedDlgOpen = false;

		CVar_Register("game_started", CVAR_TYPE_BOOL, "0");
		CVar_Register("game_completed", CVAR_TYPE_BOOL, "0");

		this.m_oInfoMenu = CInfoMenu();
    }
	
	//Aim at screen view position
	void AimAtScreenPoint(const Vector &in vecPos)
	{
		Vector vecScreenPos = Vector(Wnd_GetWindowCenterX(), Wnd_GetWindowCenterY());
		vecScreenPos[0] = vecPos[0] - vecScreenPos[0];
		vecScreenPos[1] = vecPos[1] - vecScreenPos[1];
		
		Vector vecWorldPos = Vector(this.m_vecPos[0] + vecScreenPos[0], this.m_vecPos[1] + vecScreenPos[1]);
	
		float flAngle = atan2(float(vecWorldPos[1] - this.m_vecPos[1]), float(vecWorldPos[0] - this.m_vecPos[0]));
		this.SetRotation(flAngle + 6.30 / 1.36);
	}

	//Load Sector A dialog
	void LoadSectorADialog()
	{
		array<string> dialog1;
		dialog1.insertLast("Well, as I can see, the space ship is working.");
		dialog1.insertLast("");
		dialog1.insertLast("Finally some good news after the aliens have");
		dialog1.insertLast("destroyed our planet... We managed to escape ");
		dialog1.insertLast("with our newly built space ship into space and ");
		dialog1.insertLast("now it is up to us to defeat the alien army.");
		dialog1.insertLast("");
		dialog1.insertLast("In fact we need to find their boss in order to");
		dialog1.insertLast("stop their attack.");

		array<string> dialog2;
		dialog2.insertLast("This will not be easy, since before we can");
		dialog2.insertLast("reach the boss via the portals we have to make");
		dialog2.insertLast("it through each infiltrated sector. There we");
		dialog2.insertLast("will face many enemy ships.");
		dialog2.insertLast("");
		dialog2.insertLast("But fear not: We are equipped with heavy weaponry,");
		dialog2.insertLast("so at least we have a chance.");

		array<string> dialog3;
		dialog3.insertLast("Destroy all enemy waves in each sector and");
		dialog3.insertLast("then escape through the portal to the next");
		dialog3.insertLast("sector. Cleaning up sector by sector, we");
		dialog3.insertLast("will finally face the boss.");
		dialog3.insertLast("");
		dialog3.insertLast("Don't get too close to the enemies battleships tho,");
		dialog3.insertLast("since they are armed, too. You can use dodging to");
		dialog3.insertLast("evade their bullets. Keep in mind that some may have");
		dialog3.insertLast("direct impact tho.");

		array<string> dialog4;
		dialog4.insertLast("For bullets you should also use the shield protector");
		dialog4.insertLast("which destroys nearby enemy bullets.");
		dialog4.insertLast("");
		dialog4.insertLast("You can collect items such as ship shield energy and ammo.");
		dialog4.insertLast("You should also collect all the coins, since they will increase");
		dialog4.insertLast("your ships shield health energy on each specific amount.");

		array<string> dialog5;
		dialog5.insertLast("I guess it is now up to you...");
		dialog5.insertLast("");
		dialog5.insertLast("Good luck, soldier!");

		this.m_oInfoMenu.AddDialog(dialog1);
		this.m_oInfoMenu.AddDialog(dialog2);
		this.m_oInfoMenu.AddDialog(dialog3);
		this.m_oInfoMenu.AddDialog(dialog4);
		this.m_oInfoMenu.AddDialog(dialog5);
	}

	//Load Sector B dialog
	void LoadSectorBDialog()
	{
		array<string> dialog1;
		dialog1.insertLast("Okay, so we have cleaned up the previous sector.");
		dialog1.insertLast("");
		dialog1.insertLast("There are some to go tho.");
		dialog1.insertLast("");
		dialog1.insertLast("I sense that some enemy ships have direct impact weapons.");
		dialog1.insertLast("You should not come too close to them, since they may inflict");
		dialog1.insertLast("instant damage to our ship.");

		array<string> dialog2;
		dialog2.insertLast("Keep a healthy distance to them and attack them from afar.");
		dialog2.insertLast("");
		dialog2.insertLast("I fear that our energy protector will not work against them.");
		dialog2.insertLast("");
		dialog2.insertLast("You have been warned!");
		dialog2.insertLast("");
		dialog2.insertLast("Now, good luck, soldier!");

		this.m_oInfoMenu.AddDialog(dialog1);
		this.m_oInfoMenu.AddDialog(dialog2);
	}

	//Load Sector C dialog
	void LoadSectorCDialog()
	{
		array<string> dialog1;
		dialog1.insertLast("We are so close to the enemy boss...");
		dialog1.insertLast("");
		dialog1.insertLast("But for now we have to clean this sector first.");
		dialog1.insertLast("");
		dialog1.insertLast("There are alien rotator ships in this sector which shoot");
		dialog1.insertLast("multiple bullets at once. So beware of the upcoming bullet hell!");

		array<string> dialog2;
		dialog2.insertLast("I surely don't need to remind you of your ");
		dialog2.insertLast("energy protector, right? It will come in");
		dialog2.insertLast("handy for any bullet hell situation.");
		dialog2.insertLast("");
		dialog2.insertLast("I am certain that you will manage to defeat the upcoming waves, too!");

		array<string> dialog3;
		dialog3.insertLast("We will talk again when you have reached the next station...");
		dialog3.insertLast("");
		dialog3.insertLast("Now, good luck, soldier!");

		this.m_oInfoMenu.AddDialog(dialog1);
		this.m_oInfoMenu.AddDialog(dialog2);
		this.m_oInfoMenu.AddDialog(dialog3);
	}

	//Load bossfight dialog
	void LoadBossfightDialog()
	{
		array<string> dialog1;
		dialog1.insertLast("Finally... we have reached the enemy boss mother ship!");
		dialog1.insertLast("");
		dialog1.insertLast("We now need to gather all our strength and defeat it.");
		dialog1.insertLast("");
		dialog1.insertLast("If we don't defeat the boss, all our efforts were in vain,");
		dialog1.insertLast("because it then may breed more alien ships to plague the galaxy.");

		array<string> dialog2;
		dialog2.insertLast("So, gather your weapons and show this intruder our power.");
		dialog2.insertLast("");
		dialog2.insertLast("Beware tho, since the boss is heavly armed. No comparision ");
		dialog2.insertLast("to its minions at all. ");
		dialog2.insertLast("");
		dialog2.insertLast("The boss has multiple different weapons which include direct");
		dialog2.insertLast("impact weapons as well. Nonetheless use your shield protector");
		dialog2.insertLast("whenever possible and keep a healthy distance");

		array<string> dialog3;
		dialog3.insertLast("I am sure victory will be ours.");
		dialog3.insertLast("");
		dialog3.insertLast("");
		dialog3.insertLast("Good luck, soldier. The survivors of planet earth count on you!");

		this.m_oInfoMenu.AddDialog(dialog1);
		this.m_oInfoMenu.AddDialog(dialog2);
		this.m_oInfoMenu.AddDialog(dialog3);
	}
	
	//Load boss defeated dialog
	void LoadBossDefeatedDialog()
	{
		this.m_oInfoMenu.Clear();

		array<string> dialog1;
		dialog1.insertLast("I can't believe it, but...!");
		dialog1.insertLast("");
		dialog1.insertLast("WE ARE VICTORIOUS!");
		dialog1.insertLast("");
		dialog1.insertLast("We have defeated the boss and its minions and thus the invasion is over.");
		dialog1.insertLast("It was a wild and uncertain ride, but we finally won the battle of our lifes.");

		array<string> dialog2;
		dialog2.insertLast("Now we need to focus on rebuilding our civilization.");
		dialog2.insertLast("");
		dialog2.insertLast("This won't be easy, but I am sure we will manage that");
		dialog2.insertLast("task, too. Well, as long as we all stand together.");
		dialog2.insertLast("");
		dialog2.insertLast("However, this is a different story.");
		dialog2.insertLast("You can now travel back to earth using the portal.");

		array<string> dialog3;
		dialog3.insertLast("");
		dialog3.insertLast("I just hope that we are safe from further invasions now...");

		this.m_oInfoMenu.AddDialog(dialog1);
		this.m_oInfoMenu.AddDialog(dialog2);
		this.m_oInfoMenu.AddDialog(dialog3);

		this.m_oInfoMenu.Start();

		this.m_bBossDefeatedDlgOpen = true;
	}

	//Called when the entity gets spawned. The position in the map is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_fRotation = 0.0f;
		this.m_hPlayer = R_LoadSprite(GetPackagePath() + "gfx\\player.png", 1, this.m_vecSize[0], this.m_vecSize[1], 1, false);
		this.m_hCrosshair = R_LoadSprite(GetPackagePath() + "gfx\\crosshair.png", 1, this.m_vecCrosshair[0], this.m_vecCrosshair[1], 1, false);
		this.m_hCursor = R_LoadSprite(GetPackagePath() + "gfx\\menucursor.png", 1, 16, 16, 1, false);
		this.m_hDodge = S_QuerySound(GetPackagePath() + "sound\\swoosh.wav");
		this.m_hGameInfoFont = R_LoadFont("Verdana", 21, 45);
		this.m_tmrMayDamage.SetDelay(2000);
		this.m_tmrMayDamage.Reset();
		this.m_tmrMayDamage.SetActive(true);
		this.m_tmrAttack.SetDelay(100);
		this.m_tmrAttack.Reset();
		this.m_tmrAttack.SetActive(true);
		this.m_tmrDodging.SetDelay(10);
		this.m_tmrDodging.Reset();
		this.m_tmrDodging.SetActive(false);
		this.m_tmrMayDodge.SetDelay(1650);
		this.m_tmrMayDodge.Reset();
		this.m_tmrMayDodge.SetActive(true);
		this.m_tmrFlicker.SetDelay(250);
		this.m_tmrFlicker.Reset();
		this.m_tmrFlicker.SetActive(false);
		this.m_tmrGameCounter.SetDelay(1000);
		this.m_tmrGameCounter.Reset();
		this.m_tmrGameCounter.SetActive(true);
		this.m_tmrGoInfo.SetDelay(1500);
		CVar_SetBool("game_started", false);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(0, 0), this.m_vecSize);
		this.m_oModel.Alloc();
		this.m_oModel.SetCenter(Vector(this.m_vecSize[0] / 2, this.m_vecSize[1] / 2));
		this.m_oModel.Initialize2(bbox, this.m_hPlayer);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		//First call processings
		if (!this.m_bProcessOnce) {
			this.m_bProcessOnce = true;

			if (!Steam_IsAchievementUnlocked("ACHIEVEMENT_FIRST_START")) {
				Steam_SetAchievement("ACHIEVEMENT_FIRST_START");
			}

			if (GetCurrentMap() == "sectora.cfg") {
				this.LoadSectorADialog();
			} else if (GetCurrentMap() == "sectorb.cfg") {
				this.LoadSectorBDialog();
			} else if (GetCurrentMap() == "sectorc.cfg") {
				this.LoadSectorCDialog();
			} else if (GetCurrentMap() == "bossfight.cfg") {
				this.LoadBossfightDialog();
			}

			this.m_oInfoMenu.SetPosition(Vector(Wnd_GetWindowCenterX() - 250, Wnd_GetWindowCenterY() - 250));
			this.m_oInfoMenu.Start();
		}

		if ((CVar_GetBool("game_completed", false)) && (!this.m_bBossDefeatedDlgOpen)) {
			this.LoadBossDefeatedDialog();
		}

		//Process game counter
		if (!this.m_oInfoMenu.IsActive()) {
			if (this.m_tmrGameCounter.IsActive()) {
				this.m_tmrGameCounter.Update();
				if (this.m_tmrGameCounter.IsElapsed()) {
					this.m_uiGameCounter++;
					if (this.m_uiGameCounter >= GAME_COUNTER_MAX) {
						this.m_tmrGameCounter.SetActive(false);
						this.m_tmrGoInfo.Reset();
						this.m_tmrGoInfo.SetActive(true);
					}
				}
			}
		}

		this.m_oInfoMenu.Process();

		if (this.m_uiGameCounter < GAME_COUNTER_MAX) {
			return;
		}

		if (this.m_tmrGoInfo.IsActive()) {
			this.m_tmrGoInfo.Update();
			if (this.m_tmrGoInfo.IsElapsed()) {
				this.m_tmrGoInfo.SetActive(false);
				CVar_SetBool("game_started", true);
			}
		}

		//Process movement

		this.m_bMoving = false;
		this.m_bShooting = false;

		//Handle button flags

		if ((this.m_uiButtons & BTN_FORWARD) == BTN_FORWARD) {
			Ent_Move(this, PLAYER_SPEED, MOVE_NORTH);
			this.m_bMoving = true;
		} 
		
		if ((this.m_uiButtons & BTN_BACKWARD) == BTN_BACKWARD) {
			Ent_Move(this, PLAYER_SPEED, MOVE_SOUTH);
			this.m_bMoving = true;
		} 
		
		if ((this.m_uiButtons & BTN_MOVELEFT) == BTN_MOVELEFT) {
			float fSpeed;

			/*if ((this.m_fRotation > 4.725f) || (this.m_fRotation < 1.575f)) {
				fSpeed = -PLAYER_SPEED;
			} else {
				fSpeed = PLAYER_SPEED;
			}*/
			
			Ent_Move(this, PLAYER_SPEED, MOVE_WEST);

			this.m_bMoving = true;
		}
		
		if ((this.m_uiButtons & BTN_MOVERIGHT) == BTN_MOVERIGHT) {
			float fSpeed;
			
			/*if ((this.m_fRotation > 4.725f) || (this.m_fRotation < 1.575f)) {
				fSpeed = -PLAYER_SPEED;
			} else {
				fSpeed = PLAYER_SPEED;
			}*/
			
			Ent_Move(this, PLAYER_SPEED, MOVE_EAST);

			this.m_bMoving = true;
		}

		if ((this.m_uiButtons & BTN_TURNLEFT) == BTN_TURNLEFT) {
			this.m_fRotation += 0.05f;
		} 

		if ((this.m_uiButtons & BTN_TURNRIGHT) == BTN_TURNRIGHT) {
			this.m_fRotation -= 0.05f;
		}

		//Process flickering
		if (this.m_tmrFlicker.IsActive()) {
			this.m_tmrFlicker.Update();
			if (this.m_tmrFlicker.IsElapsed()) {
				this.m_tmrFlicker.Reset();
				
				this.m_uiFlickerCount++;
				if (this.m_uiFlickerCount >= 6) {
					this.m_tmrFlicker.SetActive(false);
					this.m_uiFlickerCount = 0;
				}
			}
		}
		
		HUD_UpdateHealth(this.m_uiHealth);

		//Process attacking
		if ((this.m_uiButtons & BTN_ATTACK) == BTN_ATTACK) {
			this.m_bShooting = true;
			this.m_tmrAttack.Update();
			if (this.m_tmrAttack.IsElapsed()) {
				this.m_tmrAttack.Reset();
				
				Vector vecBulletPos = this.m_vecPos;
				vecBulletPos[0] += int(sin(this.GetRotation()) * 50);
				vecBulletPos[1] -= int(cos(this.GetRotation()) * 50);
				vecBulletPos[0] -= int(sin(this.GetRotation() + 80.0) * 20);
				vecBulletPos[1] += int(cos(this.GetRotation() + 80.0) * 20);
				
				if (this.m_iCurrentWeapon == WEAPON_GUN) {
					if (HUD_GetAmmoItemCurrent("gun") > 0) {
						CGunEntity @gun = CGunEntity();
						
						gun.SetRotation(this.GetRotation());
						gun.SetOwner(@this);
						
						Ent_SpawnEntity("weapon_gun", @gun, vecBulletPos);
						
						HUD_UpdateAmmoItem("gun", HUD_GetAmmoItemCurrent("gun") - 1, HUD_GetAmmoItemMax("gun"));
						
						SoundHandle hSound = S_QuerySound(GetPackagePath() + "sound\\gun.wav");
						S_PlaySound(hSound, S_GetCurrentVolume());
					}
				} else if (this.m_iCurrentWeapon == WEAPON_LASER) {
					if (HUD_GetAmmoItemCurrent("laser") > 0) {
						for (int i = 0; i < 3; i++) {
							CLaserEntity @laser = CLaserEntity();

							float fGunRot = this.GetRotation();

							if (i == 0) {
								fGunRot -= 0.2;
							} else if (i == 2) {
								fGunRot += 0.2;
							}

							laser.SetRotation(fGunRot);
							laser.SetOwner(@this);
							
							Ent_SpawnEntity("weapon_laser", @laser, vecBulletPos);
						}
						
						HUD_UpdateAmmoItem("laser", HUD_GetAmmoItemCurrent("laser") - 1, HUD_GetAmmoItemMax("laser"));
						
						SoundHandle hSound = S_QuerySound(GetPackagePath() + "sound\\laser.wav");
						S_PlaySound(hSound, S_GetCurrentVolume());
					}
				} else if (this.m_iCurrentWeapon == WEAPON_MISSILE) {
					if (HUD_GetAmmoItemCurrent("missile") > 0) {
						CMissileEntity@ missile = CMissileEntity();
						missile.SetRotation(this.GetRotation());
						missile.SetOwner(@this);
						Ent_SpawnEntity("weapon_missile", @missile, this.m_vecPos);
						
						HUD_UpdateAmmoItem("missile", HUD_GetAmmoItemCurrent("missile") - 1, HUD_GetAmmoItemMax("missile"));
						
						SoundHandle hSound = S_QuerySound(GetPackagePath() + "sound\\missile_launch.wav");
						S_PlaySound(hSound, S_GetCurrentVolume());
					}
				}
			}
		}
		
		//Process throwing
		if ((this.m_uiButtons & BTN_THROW) == BTN_THROW) {
			if (this.m_bMayThrow) {
				this.m_bMayThrow = false;
				
				if (HUD_GetCollectableCount("circlepulse") > 0) {
					CCirclePulseEntity@ ent = CCirclePulseEntity();
					ent.SetOwner(@this);
					Ent_SpawnEntity("weapon_circlepulse", @ent, this.m_vecPos);
					
					HUD_UpdateCollectable("circlepulse", HUD_GetCollectableCount("circlepulse") - 1);
				}
			}
		}

		//Proess dodging

		if ((this.m_uiButtons & BTN_DODGE) == BTN_DODGE) {
			if ((this.m_uiButtons & BTN_FORWARD) == BTN_FORWARD) {
				if (this.m_tmrMayDodge.IsElapsed()) {
					this.m_tmrDodging.Reset();
					this.m_tmrDodging.SetActive(true);
					this.m_tmrMayDodge.Reset();
					this.m_dodgeType = MOVE_NORTH;
					S_PlaySound(this.m_hDodge, S_GetCurrentVolume());
				}
			} else if ((this.m_uiButtons & BTN_BACKWARD) == BTN_BACKWARD) {
				if (this.m_tmrMayDodge.IsElapsed()) {
					this.m_tmrDodging.Reset();
					this.m_tmrDodging.SetActive(true);
					this.m_tmrMayDodge.Reset();
					this.m_dodgeType = MOVE_SOUTH;
					S_PlaySound(this.m_hDodge, S_GetCurrentVolume());
				}
			} else if ((this.m_uiButtons & BTN_MOVELEFT) == BTN_MOVELEFT) {
				if (this.m_tmrMayDodge.IsElapsed()) {
					this.m_tmrDodging.Reset();
					this.m_tmrDodging.SetActive(true);
					this.m_tmrMayDodge.Reset();
					this.m_dodgeType = MOVE_WEST;
					S_PlaySound(this.m_hDodge, S_GetCurrentVolume());
				}
			} else if ((this.m_uiButtons & BTN_MOVERIGHT) == BTN_MOVERIGHT) {
				if (this.m_tmrMayDodge.IsElapsed()) {
					this.m_tmrDodging.Reset();
					this.m_tmrDodging.SetActive(true);
					this.m_tmrMayDodge.Reset();
					this.m_dodgeType = MOVE_EAST;
					S_PlaySound(this.m_hDodge, S_GetCurrentVolume());
				}
			}

			this.m_uiButtons &= ~BTN_DODGE;
		}

		if (this.m_tmrMayDodge.IsActive()) {
			this.m_tmrMayDodge.Update();
		}

		if (this.m_tmrDodging.IsActive()) {
			this.m_tmrDodging.Update();
			if (this.m_tmrDodging.IsElapsed()) {
				Ent_Move(this, PLAYER_SPEED * 3, this.m_dodgeType);
				this.m_uiDodgeCounter++;
				if (this.m_uiDodgeCounter >= 5) {
					this.m_tmrDodging.SetActive(false);
					this.m_uiDodgeCounter = 0;
				}
			}
		}
		
		//Update damage permission timer
		this.m_tmrMayDamage.Update();
		
		//Process flickering
		if (this.m_tmrFlicker.IsActive()) {
			this.m_tmrFlicker.Update();
			if (this.m_tmrFlicker.IsElapsed()) {
				this.m_tmrFlicker.Reset();
				
				this.m_uiFlickerCount++;
				if (this.m_uiFlickerCount >= 6) {
					this.m_tmrFlicker.SetActive(false);
					this.m_uiFlickerCount = 0;
				}
			}
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw on-top stuff here
	void OnDrawOnTop()
	{
		bool bDrawCustomColor = false;
		
		if ((this.m_tmrFlicker.IsActive()) && (this.m_uiFlickerCount % 2 == 0)) {
			bDrawCustomColor = true;
		}
		
		Color sDrawingColor = (this.m_tmrFlicker.IsActive()) ? Color(255, 0, 0, 150) : Color(0, 0, 0, 0);
		
		R_DrawSprite(this.m_hPlayer, Vector(Wnd_GetWindowCenterX() - 101 / 2, Wnd_GetWindowCenterY() - 93 / 2), 0, this.m_fRotation, Vector(-1, -1), 0.0, 0.0, bDrawCustomColor, sDrawingColor);

		if (this.m_tmrGameCounter.IsActive()) {
			R_DrawString(this.m_hGameInfoFont, formatInt(GAME_COUNTER_MAX - this.m_uiGameCounter), Vector(Wnd_GetWindowCenterX() - 10, Wnd_GetWindowCenterY() - 100), Color(100, 0, 0, 255));
		} else if (this.m_tmrGoInfo.IsActive()) {
			R_DrawString(this.m_hGameInfoFont, _("app.go", "GO!"), Vector(Wnd_GetWindowCenterX() - 30, Wnd_GetWindowCenterY() - 100), Color(100, 0, 0, 255));
		}

		this.m_oInfoMenu.Draw();

		if (this.m_oInfoMenu.IsActive()) {
			R_DrawSprite(this.m_hCursor, Vector(this.m_vecCursorPos[0] - this.m_vecCrosshair[0] / 2, this.m_vecCursorPos[1] - this.m_vecCrosshair[1] / 2), 0, 0.0, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
		} else {
			R_DrawSprite(this.m_hCrosshair, Vector(this.m_vecCursorPos[0] - this.m_vecCrosshair[0] / 2, this.m_vecCursorPos[1] - this.m_vecCrosshair[1] / 2), 0, 0.0, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
		}
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_uiHealth == 0;
	}
	
	//Indicate whether this entity is collidable
	bool IsCollidable()
	{
		return true;
	}
	
	//Indicate if entity can be dormant
	bool CanBeDormant()
	{
		return false;
	}
	
	//Called when the entity collided with another entity
	void OnCollided(IScriptedEntity@ ref)
	{
	}
	
	//Called when entity gets damaged
	void OnDamage(uint32 damageValue)
	{
		if (this.m_tmrMayDamage.IsElapsed()) {
			if (this.m_uiHealth < damageValue) {
				this.m_uiHealth = 0;
			} else {
				this.m_uiHealth -= damageValue;
			}
			
			this.m_tmrMayDamage.Reset();
			
			this.m_tmrFlicker.Reset();
			this.m_tmrFlicker.SetActive(true);
			this.m_uiFlickerCount = 0;
		}
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
	
	//Set new position
	void SetPosition(const Vector &in vecPos)
	{
		this.m_vecPos = vecPos;
	}
	
	//This vector is used for getting the overall drawing size
	Vector& GetSize()
	{
		return this.m_vecSize;
	}
	
	//Return the rotation.
	float GetRotation()
	{
		return this.m_fRotation + 6.30 / 4;
	}
	
	//Set new rotation
	void SetRotation(float fRot)
	{
		this.m_fRotation = fRot + 6.30 / 4;
	}
	
	//Set health
	void SetHealth(uint health)
	{
		this.m_uiHealth = health;
	}
	
	//Get health
	uint GetHealth()
	{
		return this.m_uiHealth;
	}
	
	//Return a name string here, e.g. the class name or instance name.
	string GetName()
	{
		return "player";
	}
	
	//Called for wall collisions
	void OnWallCollided()
	{
	}
	
	//Called for key presses
	void OnKeyPress(int vKey, bool bDown)
	{
		if ((this.m_tmrGameCounter.IsActive()) || (this.m_oInfoMenu.IsActive())) {
			return;
		}
		
		if (vKey == GetKeyBinding("TURN_LEFT")) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_TURNLEFT) == BTN_TURNLEFT)) {
					this.m_uiButtons |= BTN_TURNLEFT;
				}
			} else {
				if ((this.m_uiButtons & BTN_TURNLEFT) == BTN_TURNLEFT) {
					this.m_uiButtons &= ~BTN_TURNLEFT;
				}
			}
		} else if (vKey == GetKeyBinding("TURN_RIGHT")) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_TURNRIGHT) == BTN_TURNRIGHT)) {
					this.m_uiButtons |= BTN_TURNRIGHT;
				}
			} else {
				if ((this.m_uiButtons & BTN_TURNRIGHT) == BTN_TURNRIGHT) {
					this.m_uiButtons &= ~BTN_TURNRIGHT;
				}
			}
		} 
		
		if (vKey == GetKeyBinding("MOVE_FORWARD")) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_FORWARD) == BTN_FORWARD)) {
					this.m_uiButtons |= BTN_FORWARD;
				}
			} else {
				if ((this.m_uiButtons & BTN_FORWARD) == BTN_FORWARD) {
					this.m_uiButtons &= ~BTN_FORWARD;
				}
			}
		} else if (vKey == GetKeyBinding("MOVE_BACKWARD")) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_BACKWARD) == BTN_BACKWARD)) {
					this.m_uiButtons |= BTN_BACKWARD;
				}
			} else {
				if ((this.m_uiButtons & BTN_BACKWARD) == BTN_BACKWARD) {
					this.m_uiButtons &= ~BTN_BACKWARD;
				}
			}
		} else if (vKey == GetKeyBinding("MOVE_LEFT")) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_MOVELEFT) == BTN_MOVELEFT)) {
					this.m_uiButtons |= BTN_MOVELEFT;
				}
			} else {
				if ((this.m_uiButtons & BTN_MOVELEFT) == BTN_MOVELEFT) {
					this.m_uiButtons &= ~BTN_MOVELEFT;
				}
			}
		} else if (vKey == GetKeyBinding("MOVE_RIGHT")) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_MOVERIGHT) == BTN_MOVERIGHT)) {
					this.m_uiButtons |= BTN_MOVERIGHT;
				}
			} else {
				if ((this.m_uiButtons & BTN_MOVERIGHT) == BTN_MOVERIGHT) {
					this.m_uiButtons &= ~BTN_MOVERIGHT;
				}
			}
		}
		
		if (vKey == GetKeyBinding("DODGE")) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_DODGE) == BTN_DODGE)) {
					this.m_uiButtons |= BTN_DODGE;
				}
			} else {
				if ((this.m_uiButtons & BTN_DODGE) == BTN_DODGE) {
					this.m_uiButtons &= ~BTN_DODGE;
				}
			}
		}
		
		if (vKey == GetKeyBinding("THROW")) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_THROW) == BTN_THROW)) {
					this.m_uiButtons |= BTN_THROW;
				}
			} else {
				if ((this.m_uiButtons & BTN_THROW) == BTN_THROW) {
					this.m_uiButtons &= ~BTN_THROW;
				}
				
				this.m_bMayThrow = true;
			}
		}
		
		if (vKey == GetKeyBinding("SLOT1")) {
			this.m_iCurrentWeapon = WEAPON_GUN;
			HUD_SetAmmoDisplayItem("gun");
			this.m_tmrAttack.SetDelay(100);
		} else if (vKey == GetKeyBinding("SLOT2")) {
			this.m_iCurrentWeapon = WEAPON_LASER;
			HUD_SetAmmoDisplayItem("laser");
			this.m_tmrAttack.SetDelay(400);
		} else if (vKey == GetKeyBinding("SLOT3")) {
			this.m_iCurrentWeapon = WEAPON_MISSILE;
			HUD_SetAmmoDisplayItem("missile");
			this.m_tmrAttack.SetDelay(500);
		}
	}
	
	//Called for mouse presses
	void OnMousePress(int key, bool bDown)
	{
		if (this.m_oInfoMenu.IsActive()) {
			if ((key == 1) && (!bDown)) {
				this.m_oInfoMenu.OnMouseClick();
			}
		}

		if ((this.m_tmrGameCounter.IsActive()) || (this.m_oInfoMenu.IsActive())) {
			return;
		}

		if (key == 1) {
			if (bDown) {
				if (!((this.m_uiButtons & BTN_ATTACK) == BTN_ATTACK)) {
					this.m_uiButtons |= BTN_ATTACK;
				}
			} else {
				if ((this.m_uiButtons & BTN_ATTACK) == BTN_ATTACK) {
					this.m_uiButtons &= ~BTN_ATTACK;
				}
			}
		}
	}
	
	//Called for getting current cursor position
	void OnUpdateCursor(const Vector &in pos)
	{
		//Store cursor pos
		this.m_vecCursorPos = pos;
		
		//Aim at cursor position
		this.AimAtScreenPoint(this.m_vecCursorPos);

		//Inform info menu
		this.m_oInfoMenu.OnUpdateCursorPos(pos);
	}
	
	//Return save game properties
	string GetSaveGameProperties()
	{	
		return Props_CreateProperty("id", formatInt(Ent_GetId(@this))) + 
			Props_CreateProperty("x", formatInt(this.m_vecPos[0])) +
			Props_CreateProperty("y", formatInt(this.m_vecPos[1])) +
			Props_CreateProperty("rot", formatFloat(this.m_fRotation)) +
			Props_CreateProperty("health", formatInt(this.m_uiHealth)) +
			Props_CreateProperty("score", formatInt(this.m_iScore));
	}
	
	//Add to player score
	void AddPlayerScore(int amount)
	{
		this.m_iScore += amount;
	}
	
	//Called for returning the current score
	int GetPlayerScore()
	{
		return this.m_iScore;
	}
	
	//Add health
	void AddHealth(uint health)
	{
		this.m_uiHealth += health;
		if (this.m_uiHealth > 100) {
			this.m_uiHealth = 100;
		}
	}
	
	//Add ammo
	void AddAmmo(const string &in ident, uint amount)
	{
		if (ident != "circlepulse") {
			HUD_UpdateAmmoItem(ident, HUD_GetAmmoItemCurrent(ident) + amount, HUD_GetAmmoItemMax(ident));
		} else {
			HUD_UpdateCollectable(ident, HUD_GetCollectableCount(ident) + amount);
		}
	}
}

//Create the associated entity here
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	Ent_SetGoalActivationStatus(false);
	
	CPlayerEntity @player = CPlayerEntity();
	Ent_SpawnEntity(szIdent, @player, vecPos);
	player.SetRotation(fRot);
	
	HUD_AddAmmoItem("gun", GetPackagePath() + "gfx\\ammo\\ammo_gun_sym.bmp");
	HUD_UpdateAmmoItem("gun", 125, 0);

	HUD_AddAmmoItem("laser", GetPackagePath() + "gfx\\ammo\\ammo_laser_sym.bmp");
	HUD_UpdateAmmoItem("laser", 50, 0);

	HUD_AddAmmoItem("missile", GetPackagePath() + "gfx\\ammo\\ammo_missile_sym.bmp");
	HUD_UpdateAmmoItem("missile", 25, 0);

	HUD_AddCollectable("coins", GetPackagePath() + "gfx\\coin.png", true);
	HUD_UpdateCollectable("coins", 0);

	HUD_AddCollectable("circlepulse", GetPackagePath() + "gfx\\circlepulse_small.bmp", true);
	HUD_UpdateCollectable("circlepulse", 10);

	HUD_SetAmmoDisplayItem("gun");
}

//Restore game state
void RestoreState(const string &in szIdent, const string &in szValue)
{
	Ent_SetGoalActivationStatus(true);
	IScriptedEntity@ ent = Ent_GetPlayerEntity();
	ent.SetPosition(Vector(950, 700));
	
	/*string id = Props_ExtractValue(szValue, "id");
	if (id != "") {
		IScriptedEntity@ ent = Ent_GetEntityHandle(parseInt(id));
		if (@ent != null) {
			int x = parseInt(Props_ExtractValue(szValue, "x"));
			int y = parseInt(Props_ExtractValue(szValue, "y"));
			float rot = parseFloat(Props_ExtractValue(szValue, "rot"));
			
			ent.SetPosition(Vector(x, y));
			ent.SetRotation(rot);
			
			string health = Props_ExtractValue(szValue, "health");
			if (health != "") {
				if (ent.GetName() == "player") {
					CPlayerEntity@ casted = cast<CPlayerEntity>(ent);
					casted.SetHealth(parseInt(health));
				} else if (ent.GetName() == "tank") {
					CTankEntity@ casted = cast<CTankEntity>(ent);
					casted.SetHealth(parseInt(health));
				}
			}
			
			string score = Props_ExtractValue(szValue, "score");
			if (score != "") {
				if (ent.GetName() == "player") {
					CPlayerEntity@ casted = cast<CPlayerEntity>(ent);
					casted.AddPlayerScore(parseInt(score));
				}
			}
		}
	} else {
		int x = parseInt(Props_ExtractValue(szValue, "x"));
		int y = parseInt(Props_ExtractValue(szValue, "y"));
		float rot = parseFloat(Props_ExtractValue(szValue, "rot"));
	
		if (szIdent == "decal") {
			CDecalEntity @dcl = CDecalEntity();
			dcl.SetRotation(rot);
			Ent_SpawnEntity("decal", @dcl, Vector(x, y));
		} else if (szIdent == "explosion") {
			CExplosionEntity @expl = CExplosionEntity();
			expl.SetRotation(rot);
			Ent_SpawnEntity("explosion", @expl, Vector(x, y));
		} else {
			Print("Unknown spawnable entity ident: " + szIdent);
		}
	}*/
}

//Save game state to disk
bool SaveGame()
{
	Print("Saving game...");
	
	SaveGameWriter writer;
	writer.BeginSaveGame();
	writer.WritePackage(GetPackageName());
	writer.WriteMap(GetCurrentMap());
	
	for (size_t i = 0; i < Ent_GetEntityCount(); i++) {
		IScriptedEntity@ ent = Ent_GetEntityHandle(i);
		if (@ent != null) {
			writer.WriteAttribute(ent.GetName(), ent.GetSaveGameProperties());
		}
	}
	
	writer.EndSaveGame();
	
	Print("Done!");
	
	return true;
}
