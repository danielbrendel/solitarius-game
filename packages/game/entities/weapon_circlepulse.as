/*
	Casual Game Engine: Solitarius
	
	A sample and test game for Casual Game Engine
	
	(C) 2021 - 2022 by Daniel Brendel

	Contact: dbrendel1988<at>gmail<dot>com
	GitHub: https://github.com/danielbrendel/

	Released under the MIT license
*/

/* Explosion entity */
const uint C_DEFAULT_CIRCLEPULSE_DAMAGE = 20;
const int C_SHIELD_FRAME_MAX = 10;
class CCirclePulseEntity : IScriptedEntity
{
	Vector m_vecPos;
	Vector m_vecSize;
	Model m_oModel;
	Timer m_oExpand;
	SpriteHandle m_hSprite;
	array<SpriteHandle> m_aShields;
	int m_iFrameIndex;
	SoundHandle m_hSound;
	IScriptedEntity@ m_pOwner;
    float m_fScale;
    size_t m_uiScaleCount;
	
	CCirclePulseEntity()
    {
		this.m_vecSize = Vector(128, 128);
		@this.m_pOwner = null;
		this.m_iFrameIndex = 0;
        this.m_fScale = 1.00;
        this.m_uiScaleCount = 0;
    }
	
	//Set owner
	void SetOwner(IScriptedEntity@ pOwner)
	{
		@this.m_pOwner = pOwner;
	}
	
	//Called when the entity gets spawned. The position in the map is passed as argument
	void OnSpawn(const Vector& in vec)
	{
		this.m_vecPos = vec;
		this.m_hSprite = R_LoadSprite(GetPackagePath() + "gfx\\shield\\00.png", 6, this.m_vecSize[0], this.m_vecSize[1], 6, false);
		for (int i = 0; i < 11; i++) {
			string toStr = "";
			if (i >= 10) {
				toStr = formatInt(i);
			} else {
				toStr = "0" + formatInt(i);
			}

			this.m_aShields.insertLast(R_LoadSprite(GetPackagePath() + "gfx\\shield\\" + toStr + ".png", 6, this.m_vecSize[0], this.m_vecSize[1], 6, true));
		}
		this.m_oExpand.SetDelay(100);
		this.m_oExpand.Reset();
		this.m_oExpand.SetActive(true);
		this.m_hSound = S_QuerySound(GetPackagePath() + "sound\\circlepulse.wav");
		S_PlaySound(this.m_hSound, 10);
		BoundingBox bbox;
		bbox.Alloc();
		bbox.AddBBoxItem(Vector(-64, -64), Vector(this.m_vecSize[0] * 2, this.m_vecSize[1] * 2));
		this.m_oModel.Alloc();
		this.m_oModel.Initialize2(bbox, this.m_hSprite);
	}
	
	//Called when the entity gets released
	void OnRelease()
	{
	}
	
	//Process entity stuff
	void OnProcess()
	{
		this.m_oExpand.Update();
		if (this.m_oExpand.IsElapsed()) {
			this.m_oExpand.Reset();
			this.m_fScale += 0.2;
            this.m_uiScaleCount++;
			this.m_iFrameIndex++;
			if (this.m_iFrameIndex >= C_SHIELD_FRAME_MAX) {
				this.m_iFrameIndex = 0;
			}
		}
	}
	
	//Entity can draw everything in default order here
	void OnDraw()
	{
	}
	
	//Entity can draw everything on top here
	void OnDrawOnTop()
	{
		if (!R_ShouldDraw(this.m_vecPos, this.m_vecSize))
			return;
			
		Vector vOut;
		R_GetDrawingPosition(this.m_vecPos, this.m_vecSize, vOut);
		
		R_DrawSprite(this.m_aShields[this.m_iFrameIndex], vOut, 0, 0.0, Vector(-1, -1), this.m_fScale, this.m_fScale, false, Color(0, 0, 0, 0));
	}
	
	//Indicate whether this entity shall be removed by the game
	bool NeedsRemoval()
	{
		return this.m_uiScaleCount >= 5;
	}
	
	//Indicate if entity can be collided
	bool IsCollidable()
	{
		return true;
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
		if (@this.m_pOwner != null) {
			if (@ref == @this.m_pOwner) {
				return;
			}
		}
		
		ref.OnDamage(C_DEFAULT_CIRCLEPULSE_DAMAGE);
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
		return "weapon_circlepulse";
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
