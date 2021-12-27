/*
	Casual Game Engine: Casual Pixel Warrior
	
	A sample and test game for Casual Game Engine
	
	(C) 2021 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

/* Planet entity */
class CPlanetEntity : IScriptedEntity
{
	Vector m_vecPos;
    float m_fRotation;
	Vector m_vecSize;
	Model m_oModel;
	SpriteHandle m_hSprite;
    string m_szSprite;
    float m_fTurnSpeed;
    Timer m_tmrTurn;
    size_t m_uiTurnTimer;
	
	CPlanetEntity()
    {
		this.m_vecSize = Vector(64, 64);
    }

    //Set sprite
    void SetSprite(const string &in szSprite)
    {
        this.m_szSprite = szSprite;
    }

    //Set size
    void SetSize(const Vector &in vecSize)
    {
        this.m_vecSize = vecSize;
    }

    //Set turn speed
    void SetTurnSpeed(float fSpeed)
    {
        this.m_fTurnSpeed = fSpeed;
    }

    //Set turn timer delay value
    void SetTimerDelay(size_t uiValue)
    {
        this.m_uiTurnTimer = uiValue;
    }
	
	//Called when the entity gets spawned. The position in the map is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
        this.m_fRotation = 0.0f;
		this.m_hSprite = R_LoadSprite(GetPackagePath() + "gfx\\" + this.m_szSprite, 1, this.m_vecSize[0], this.m_vecSize[1], 1, true);
		this.m_tmrTurn.SetDelay(this.m_uiTurnTimer);
		this.m_tmrTurn.Reset();
		this.m_tmrTurn.SetActive(true);
		this.m_oModel.Alloc();
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_tmrTurn.Update();
        if (this.m_tmrTurn.IsElapsed()) {
            this.m_tmrTurn.Reset();

            this.m_fRotation += this.m_fTurnSpeed;
        }
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
		if (!R_ShouldDraw(this.m_vecPos, this.m_vecSize))
			return;
			
		Vector vOut;
		R_GetDrawingPosition(this.m_vecPos, this.m_vecSize, vOut);
		
		R_DrawSprite(this.m_hSprite, vOut, 0, this.m_fRotation, Vector(-1, -1), 0.0, 0.0, false, Color(0, 0, 0, 0));
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
        this.m_vecPos = vec;
	}
	
	//Return the rotation. 
	float GetRotation()
	{
		return this.m_fRotation;
	}
	
	//Set rotation
	void SetRotation(float fRot)
	{
        this.m_fRotation = fRot;
	}
	
	//Return a name string here, e.g. the class name or instance name. 
	string GetName()
	{
		return "planet";
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

//Create the associated entity here
void CreateEntity(const Vector &in vecPos, float fRot, const string &in szIdent, const string &in szPath, const string &in szProps)
{
	CPlanetEntity@ ent = CPlanetEntity();
    ent.SetSprite(Props_ExtractValue(szProps, "sprite"));
    ent.SetSize(Vector(parseInt(Props_ExtractValue(szProps, "sizex")), parseInt(Props_ExtractValue(szProps, "sizey"))));
    ent.SetTurnSpeed(parseFloat(Props_ExtractValue(szProps, "tspeed")));
    ent.SetTimerDelay(parseInt(Props_ExtractValue(szProps, "delay")));
    Ent_SpawnEntity(szIdent, @ent, vecPos);
}