/*
	Casual Game Engine: Solitarius
	
	A sample and test game for Casual Game Engine
	
	(C) 2021 - 2022 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

/* Smoke entity */
const int C_FRAME_MAX = 30;
class CSmokeEntity : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Model m_oModel;
	Timer m_oFrameChange;
	SpriteHandle m_hSprite;
	int m_iFrameIndex;
	float m_fScale;
	
	CSmokeEntity()
    {
		this.m_vecSize = Vector(256, 256);
		this.m_iFrameIndex = 0;
		this.m_fScale = 1.00;
    }

	//Set custom scale
	void SetScale(float fScale)
	{
		this.m_fScale = fScale;
	}
	
	//Called when the entity gets spawned. The position in the map is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_hSprite = R_LoadSprite(GetPackagePath() + "gfx\\smoke.png", 30, 256, 256, 6, false);
		this.m_oFrameChange.SetDelay(100);
		this.m_oFrameChange.Reset();
		this.m_oFrameChange.SetActive(true);
		this.m_oModel.Alloc();
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_oFrameChange.Update();
		if (this.m_oFrameChange.IsElapsed()) {
			this.m_oFrameChange.Reset();

			this.m_iFrameIndex++;
			if (this.m_iFrameIndex >= 30) {
				this.m_iFrameIndex = 0;
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
		//if (!R_ShouldDraw(this.m_vecPos, this.m_vecSize))
		//	return;
			
		Vector vOut;
		R_GetDrawingPosition(this.m_vecPos, this.m_vecSize, vOut);
		
		R_DrawSprite(this.m_hSprite, vOut, this.m_iFrameIndex, 0.0, Vector(-1, -1), this.m_fScale, this.m_fScale, false, Color(0, 0, 0, 0));
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
		return "decal";
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
			Props_CreateProperty("y", formatInt(this.m_vecPos[1])) +
			Props_CreateProperty("rot", formatFloat(this.GetRotation()));
	}
}

//Spawn entity initially
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	CSmokeEntity @ent = CSmokeEntity();
	ent.SetScale(parseFloat(Props_ExtractValue(szProps, "scale")));
	Ent_SpawnEntity(szIdent, @ent, vecPos);
}