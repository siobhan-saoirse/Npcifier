#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2items>
#include <sdktools>

#define ZOMBIE "models/zombie/classic.mdl"
#define FZOMBIE "models/zombie/fast.mdl"
#define PZOMBIE "models/zombie/poison.mdl"
#define ANTLION "models/antlion.mdl"
#define COMBINE "models/combine_soldier.mdl"
#define VORTIGAUNT "models/vortigaunt_slave.mdl"
#define HEADCRAB "models/headcrabclassic.mdl"
#define FHEADCRAB "models/headcrab.mdl"
#define PHEADCRAB "models/headcrabblack.mdl"
#define AGUARD	"models/antlion_guard.mdl"
#define DOG "models/dog.mdl"
#define ALYX "models/alyx.mdl"
#define MALE "models/humans/group03/male_01_bloody.mdl"
#define FEMALE "models/humans/group03/female_01_bloody.mdl"
#define SKELETON "models/bots/skeleton_sniper/skeleton_sniper.mdl"

new bool:g_bIsZombie[MAXPLAYERS + 1];
new bool:g_bIsFastZombie[MAXPLAYERS + 1];
new bool:g_bIsBlackZombie[MAXPLAYERS + 1];
new bool:g_bIsAntlion[MAXPLAYERS + 1];
new bool:g_bIsCombine[MAXPLAYERS + 1];
new bool:g_bIsVortigaunt[MAXPLAYERS + 1];
new bool:g_bIsHeadcrab[MAXPLAYERS + 1];
new bool:g_bIsPoisonHeadcrab[MAXPLAYERS + 1];
new bool:g_bIsDog[MAXPLAYERS + 1];
new bool:g_bIsAntGuard[MAXPLAYERS + 1];
new bool:g_bIsAlyx[MAXPLAYERS + 1]; 
new bool:g_bIsMaleCitizen[MAXPLAYERS + 1];
new bool:g_bIsFemaleCitizen[MAXPLAYERS + 1];
new bool:g_bIsSkeleton[MAXPLAYERS + 1];
new bool:g_bIsSkeletonSmall[MAXPLAYERS + 1];
new bool:g_bSuperJumps;
new Handle:g_hCvarSuperJumps;
new bool:g_bIsBarney[MAXPLAYERS + 1];

/*These three up there from the previous plugins (betheantlion, brutalbosses, and bethealyx) will be removed from the server.*/

public Plugin:myinfo = 
{
	name = "[TF2] Npcifier",
	author = "Seamus's Server",
	description = "",
	version = "1.0",
	url = ""
}

public OnPluginStart()
{
	LogMessage("[NPCIFIER] This plugin is in alpha and has alot of bugs to fix. No animations is unfixable.");
	RegAdminCmd("sm_zombie",	Command_SetZombie,	ADMFLAG_CHEATS, "Make someone a zombie.");
	RegAdminCmd("sm_fastzombie",	Command_SetFastZombie,	ADMFLAG_CHEATS, "Make someone a fast zombie.");
	RegAdminCmd("sm_poisonzombie",	Command_SetPoisonZombie,	ADMFLAG_CHEATS, "Make someone a poison zombie.");
	RegAdminCmd("sm_antlion",	Command_SetAntlion,	ADMFLAG_CHEATS, "Make someone a Antlion.");
	RegAdminCmd("sm_combine",	Command_SetCombine,	ADMFLAG_CHEATS, "Make someone a Combine Soldier.");
	RegAdminCmd("sm_vortigaunt",	Command_SetVortigaunt,	ADMFLAG_CHEATS, "Make someone a Vortigaunt. GRIT.");
	RegAdminCmd("sm_headcrab",	Command_SetHeadcrab,	ADMFLAG_CHEATS,		"Make somone a Headcrab. These head humpers..");
	RegAdminCmd("sm_fastheadcrab",	Command_SetFastHeadcrab,	ADMFLAG_CHEATS,		"Make somone a Fast Headcrab. These head humpers..");
	RegAdminCmd("sm_poisonheadcrab",	Command_SetPoisonHeadcrab,	ADMFLAG_CHEATS,		"Make somone a Poisonous Headcrab. These head humpers..");
	RegAdminCmd("sm_dog",	Command_SetDog,	ADMFLAG_CHEATS,		"Make someone a Robotic Dog. *angry voice*");
	RegAdminCmd("sm_alyx",	Command_SetAlyx,	ADMFLAG_CHEATS,		"Make someone a Sexualized Character. Why do people call her that?");
	RegAdminCmd("sm_antlionguard",	Command_SetAntlionGuard,	ADMFLAG_CHEATS,		"Make someone a Stupid, Overpowered, peace of shit. *growls*");
	RegAdminCmd("sm_citizen",	Command_SetCitizen,		ADMFLAG_CHEATS,		"Welcome, Welcome to City 17.");
	RegAdminCmd("sm_skeletonize", Command_SetSkeleton,  ADMFLAG_CHEATS);
	RegAdminCmd("sm_skeletonize_small", Command_SetSkeleton_Small,  ADMFLAG_CHEATS);
	AddNormalSoundHook(ZombieSH);
	AddNormalSoundHook(FastZombieSH);
	AddNormalSoundHook(PoisonZombieSH);
	AddNormalSoundHook(AntlionSH);
	AddNormalSoundHook(VortigauntSH);
	AddNormalSoundHook(CombineSH);
	AddNormalSoundHook(HeadcrabSH);
	AddNormalSoundHook(PoisonHeadcrabSH);
	AddNormalSoundHook(DogSH);
	AddNormalSoundHook(AlyxSH);
	AddNormalSoundHook(AntlionGuardSH);
	AddNormalSoundHook(MaleCitizenSH);
	AddNormalSoundHook(FemaleCitizenSH);
	AddNormalSoundHook(SkeletonSH);
	AddNormalSoundHook(SkeletonSmallSH);
	g_hCvarSuperJumps = CreateConVar("sm_npcifier_flying", "1", "Enable flying\n0 = Disabled\n1 = Enabled", _, true, 0.0, true, 1.0);
	g_bSuperJumps = GetConVarBool(g_hCvarSuperJumps);
	HookConVarChange(g_hCvarSuperJumps, OnConVarChange);
	HookEvent("post_inventory_application", OnPlayerSpawn);
	HookEvent("player_death", Event_Death, EventHookMode_Post);
	HookEvent("player_death", Event_SkeletonDeath, EventHookMode_Pre);
	LoadTranslations("brutalbosses.phrases");
	CreateTimer(0.2, Timer_SuperJump, _, TIMER_REPEAT);
}

public OnConVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if(hConvar == g_hCvarSuperJumps)
		g_bSuperJumps = GetConVarBool(g_hCvarSuperJumps);
}

public OnMapStart()
{
	PrecacheModel("models/zombie/classic.mdl", true);
	PrecacheModel("models/zombie/fast.mdl", true);
	PrecacheModel("models/zombie/poison.mdl", true);
	PrecacheModel("models/vortigaunt_slave.mdl", true);
	PrecacheModel("models/antlion.mdl", true);
	PrecacheSound("models/alyx.mdl",	true);
	PrecacheSound("npc/antlion/attack_double1.wav");
	PrecacheSound("npc/antlion/attack_double2.wav");
	PrecacheSound("npc/antlion/attack_double3.wav");
	PrecacheSound("npc/antlion/attack_single1.wav");
	PrecacheSound("npc/antlion/attack_single2.wav");
	PrecacheSound("npc/antlion/attack_single3.wav");
	PrecacheSound("npc/antlion/idle1.wav");
	PrecacheSound("npc/antlion/idle2.wav");
	PrecacheSound("npc/antlion/idle3.wav");
	PrecacheSound("npc/antlion/idle4.wav");
	PrecacheSound("npc/antlion/idle5.wav");
	PrecacheSound("npc/antlion/pain1.wav");
	PrecacheSound("npc/antlion/pain2.wav");
	PrecacheSound("npc/zombie/claw_miss1.wav");
	PrecacheSound("npc/zombie/claw_miss2.wav");
	PrecacheSound("npc/zombie/zombie_pain1.wav");
	PrecacheSound("npc/zombie/zombie_pain2.wav");
	PrecacheSound("npc/zombie/zombie_pain3.wav");
	PrecacheSound("npc/zombie/zombie_pain4.wav");
	PrecacheSound("npc/zombie/zombie_pain5.wav");
	PrecacheSound("npc/zombie/zombie_pain6.wav");	
	PrecacheSound("^weapons/ar1/ar1_dist1.wav");
	PrecacheSound("^weapons/ar1/ar1_dist2.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle1.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle2.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle3.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle4.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle5.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle6.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle7.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle8.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle9.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle10.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle11.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle12.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle13.wav");
	PrecacheSound("npc/zombie/zombie_voice_idle14.wav");
	PrecacheSound("npc/zombie_poison/pz_alert1.wav");
	PrecacheSound("npc/zombie_poison/pz_alert2.wav");
	PrecacheSound("npc/zombie_poison/pz_call1.wav");
	PrecacheSound("npc/zombie_poison/pz_idle2.wav");
	PrecacheSound("npc/zombie_poison/pz_idle3.wav");
	PrecacheSound("npc/zombie_poison/pz_idle4.wav");
	PrecacheSound("npc/zombie_poison/pz_pain1.wav");
	PrecacheSound("npc/zombie_poison/pz_pain2.wav");
	PrecacheSound("npc/zombie_poison/pz_pain3.wav");
	PrecacheSound("npc/fast_zombie/claw_miss1.wav");
	PrecacheSound("npc/fast_zombie/claw_miss2.wav");
	PrecacheSound("npc/fast_zombie/fz_scream1.wav");
	PrecacheSound("npc/fast_zombie/fz_frenzy1.wav");
	PrecacheSound("npc/fast_zombie/fz_alert_close1.wav");
	PrecacheSound("npc/fast_zombie/fz_alert_far1.wav");
	PrecacheSound("npc/combine_soldier/vo/readyweapons.wav");
	PrecacheSound("npc/combine_soldier/vo/readyweaponshostileinbound.wav");
	PrecacheSound("npc/combine_soldier/vo/coverme.wav");
	PrecacheSound("npc/combine_soldier/pain1.wav");
	PrecacheSound("npc/combine_soldier/pain2.wav");
	PrecacheSound("npc/combine_soldier/pain3.wav");
	PrecacheSound("npc/combine_soldier/gear1.wav");
	PrecacheSound("npc/combine_soldier/gear2.wav");
	PrecacheSound("npc/combine_soldier/gear3.wav");
	PrecacheSound("npc/combine_soldier/gear4.wav");
	PrecacheSound("npc/combine_soldier/gear5.wav");
	PrecacheSound("npc/combine_soldier/gear6.wav");
	PrecacheSound("npc/zombie/zombie_die1.wav");
	PrecacheSound("npc/zombie/zombie_die2.wav");
	PrecacheSound("npc/zombie/zombie_die3.wav");
	PrecacheSound("npc/fast_zombie/wake1.wav");
	PrecacheSound("npc/zombie_poison/pz_die1.wav");
	PrecacheSound("npc/zombie_poison/pz_die2.wav");
	PrecacheSound("npc/combine_soldier/die1.wav");
	PrecacheSound("npc/combine_soldier/die2.wav");
	PrecacheSound("npc/combine_soldier/die3.wav");
	PrecacheSound("npc/vort/attack_shoot.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese02.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese03.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese04.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese05.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese07.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese08.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese09.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese11.wav");
	PrecacheSound("vo/npc/vortigaunt/vortigese12.wav");
	PrecacheSound("npc/vort/vort_foot1.wav");
	PrecacheSound("npc/vort/vort_foot2.wav");
	PrecacheSound("npc/vort/vort_foot3.wav");
	PrecacheSound("npc/vort/vort_foot4.wav");
	PrecacheSound("npc/zombie/foot1.wav");
	PrecacheSound("npc/zombie/foot2.wav");
	PrecacheSound("npc/zombie/foot3.wav");
	PrecacheSound("npc/zombie/foot4.wav");
	PrecacheSound("npc/headcrab/attack1.wav");
	PrecacheSound("npc/headcrab/attack2.wav");
	PrecacheSound("npc/headcrab/attack3.wav");
	PrecacheSound("npc/headcrab/idle1.wav");
	PrecacheSound("npc/headcrab/idle2.wav");
	PrecacheSound("npc/headcrab/idle3.wav");
	PrecacheSound("npc/headcrab/pain1.wav");
	PrecacheSound("npc/headcrab/pain2.wav");
	PrecacheSound("npc/headcrab/pain3.wav");
	PrecacheSound("npc/headcrab/die1.wav");
	PrecacheSound("npc/headcrab/die2.wav");
	PrecacheSound("npc/headcrab_poison/ph_idle1.wav");
	PrecacheSound("npc/headcrab_poison/ph_idle2.wav");
	PrecacheSound("npc/headcrab_poison/ph_idle3.wav");
	PrecacheSound("npc/headcrab_poison/ph_pain1.wav");
	PrecacheSound("npc/headcrab_poison/ph_pain2.wav");
	PrecacheSound("npc/headcrab_poison/ph_pain3.wav");
	PrecacheSound("npc/headcrab_poison/ph_scream1.wav");
	PrecacheSound("npc/headcrab_poison/ph_scream2.wav");
	PrecacheSound("npc/headcrab_poison/ph_scream3.wav");
	PrecacheSound("npc/headcrab_poison/ph_rattle1.wav");
	PrecacheSound("npc/headcrab_poison/ph_rattle2.wav");
	PrecacheSound("npc/headcrab_poison/ph_rattle3.wav");
	PrecacheSound("npc/dog/dog_alarmed1.wav");
	PrecacheSound("npc/dog/dog_alarmed3.wav");
	PrecacheSound("npc/dog/dog_angry1.wav");
	PrecacheSound("npc/dog/dog_angry2.wav");
	PrecacheSound("npc/dog/dog_angry3.wav");
	PrecacheSound("vo/npc/alyx/coverme01.wav");
	PrecacheSound("vo/npc/alyx/coverme02.wav");
	PrecacheSound("vo/npc/alyx/coverme03.wav");
	PrecacheSound("vo/npc/alyx/hurt04.wav");
	PrecacheSound("vo/npc/alyx/hurt05.wav");
	PrecacheSound("vo/npc/alyx/hurt06.wav");
	PrecacheSound("vo/npc/alyx/hurt08.wav");
	PrecacheSound("vo/npc/alyx/gasp02.wav");
	PrecacheSound("vo/npc/alyx/gasp03.wav");
	PrecacheSound("^weapons/smg1/npc_smg1_fire1.wav");
	PrecacheSound("weapons/shotgun/shotgun_fire7.wav");
	PrecacheSound("npc/antlion_guard/angry1.wav");
	PrecacheSound("npc/antlion_guard/angry2.wav");
	PrecacheSound("npc/antlion_guard/angry3.wav");
	PrecacheSound("npc/antlion_guard/antlion_guard_die1.wav");
	PrecacheSound("npc/antlion_guard/antlion_guard_die2.wav");
	PrecacheSound("npc/antlion_guard/foot_heavy1.wav");
	PrecacheSound("npc/antlion_guard/foot_heavy2.wav");
	PrecacheSound("npc/antlion_guard/growl_high.wav");
	PrecacheSound("npc/antlion_guard/shove1.wav");
	PrecacheSound("npc/antlion/foot1.wav");
	PrecacheSound("npc/antlion/foot2.wav");
	PrecacheSound("npc/antlion/foot3.wav");
	PrecacheSound("npc/antlion/foot4.wav");
	PrecacheSound("vo/npc/male01/no01.wav");
	PrecacheSound("vo/npc/male01/no02.wav");
	PrecacheSound("vo/npc/male01/pain.wav");
	PrecacheSound("npc/fast_zombie/leap1.wav");
	PrecacheSound("npc/antlion/fly1.wav");
	PrecacheSound("npc/antlion/land1.wav");
	PrecacheSound("misc/halloween/skeletons/skelly_medium_01.wav");
	PrecacheSound("misc/halloween/skeletons/skelly_medium_02.wav");
	PrecacheSound("misc/halloween/skeletons/skelly_medium_03.wav");
	PrecacheSound("misc/halloween/skeletons/skelly_medium_04.wav");
	PrecacheSound("misc/halloween/skeletons/skelly_medium_05.wav");
	PrecacheSound("misc/halloween/skeletons/skelly_medium_06.wav");
	PrecacheSound("misc/halloween/skeletons/skelly_medium_07.wav");
}

public OnClientPutInServer(client)
{
	OnClientDisconnect_Post(client);
}

public Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new deathflags = GetEventInt(event, "death_flags");
	if (!(deathflags && TF_DEATHFLAG_DEADRINGER))
	{
		if (IsValidClient(client) && g_bIsZombie[client])
		{	
			switch(GetRandomInt(1,3))
			{
				case 1: EmitSoundToAll("npc/zombie/zombie_die1.wav", client, _, SNDLEVEL_TRAIN);
				case 2: EmitSoundToAll("npc/zombie/zombie_die2.wav", client, _, SNDLEVEL_TRAIN);
				case 3: EmitSoundToAll("npc/zombie/zombie_die3.wav", client, _, SNDLEVEL_TRAIN);
			}
		}
		if (IsValidClient(client) && g_bIsFastZombie[client])
		{	
			EmitSoundToAll("npc/fast_zombie/wake1.wav", client, _, SNDLEVEL_TRAIN);
		}
		if (IsValidClient(client) && g_bIsBlackZombie[client])
		{	
			switch(GetRandomInt(1,2))
			{
				case 1: EmitSoundToAll("npc/zombie_poison/pz_die1.wav", client, _, SNDLEVEL_TRAIN);
				case 2: EmitSoundToAll("npc/zombie_poison/pz_die2.wav", client, _, SNDLEVEL_TRAIN);
			}
		}
		if (IsValidClient(client) && g_bIsCombine[client])
		{	
			switch(GetRandomInt(1,3))
			{
				case 1: EmitSoundToAll("npc/combine_soldier/die1.wav", client, _, SNDLEVEL_TRAIN);
				case 2: EmitSoundToAll("npc/combine_soldier/die2.wav", client, _, SNDLEVEL_TRAIN);
				case 3: EmitSoundToAll("npc/combine_soldier/die3.wav", client, _, SNDLEVEL_TRAIN);
			}
		}
		if (IsValidClient(client) && g_bIsHeadcrab[client])
		{	
			switch(GetRandomInt(1,2))
			{
				case 1: EmitSoundToAll("npc/headcrab/die1.wav", client, _, SNDLEVEL_TRAIN);
				case 2: EmitSoundToAll("npc/headcrab/die2.wav", client, _, SNDLEVEL_TRAIN);
			}
		}
		if (IsValidClient(client) && g_bIsPoisonHeadcrab[client])
		{	
			switch(GetRandomInt(1,2))
			{
				case 1: EmitSoundToAll("npc/headcrab_poison/ph_rattle1.wav", client, _, SNDLEVEL_TRAIN);
				case 2: EmitSoundToAll("npc/headcrab_poison/ph_rattle2.wav", client, _, SNDLEVEL_TRAIN);
				case 3: EmitSoundToAll("npc/headcrab_poison/ph_rattle3.wav", client, _, SNDLEVEL_TRAIN);
			}
		}
		if (IsValidClient(client) && g_bIsAlyx[client])
		{	
			switch(GetRandomInt(1,2))
			{
				case 1: EmitSoundToAll("vo/npc/alyx/no01.wav", client, _, SNDLEVEL_TRAIN);
				case 2: EmitSoundToAll("vo/npc/alyx/no02.wav", client, _, SNDLEVEL_TRAIN);
				case 3: EmitSoundToAll("vo/npc/alyx/no03.wav", client, _, SNDLEVEL_TRAIN);
			}
		}
		if (IsValidClient(client) && g_bIsAntGuard[client])
		{	
			switch(GetRandomInt(1,2))
			{
				case 1: EmitSoundToAll("npc/antlion_guard/antlion_guard_die1.wav", client, _, SNDLEVEL_TRAIN);
				case 2: EmitSoundToAll("npc/antlion_guard/antlion_guard_die2.wav", client, _, SNDLEVEL_TRAIN);
			}
			StopSound(client, SNDCHAN_AUTO, "npc/antlion_guard/growl_high.wav");
		}
		if (IsValidClient(client) && g_bIsMaleCitizen[client])
		{
			EmitSoundToAll("vo/npc/male01/no02.wav", client, _, SNDLEVEL_TRAIN);
		}
		if (IsValidClient(client) && g_bIsSkeleton[client])
		{
			CreateTimer(0.1, DeleteRagdoll, client)
		
			decl Ent
			decl Float:ClientOrigin[3]
	
			//Initialize:
			Ent = CreateEntityByName("tf_ragdoll")
			GetClientAbsOrigin(client, ClientOrigin)

			//Write:
			SetEntPropVector(Ent, Prop_Send, "m_vecRagdollOrigin", ClientOrigin)
			SetEntProp(Ent, Prop_Send, "m_iPlayerIndex", client)
			SetEntPropVector(Ent, Prop_Send, "m_vecForce", NULL_VECTOR)
			SetEntPropVector(Ent, Prop_Send, "m_vecRagdollVelocity", NULL_VECTOR)
			SetEntProp(Ent, Prop_Send, "m_bGib", 1)
		
			DispatchSpawn(Ent)
			decl String:sample[PLATFORM_MAX_PATH]
			Format(sample, sizeof(sample), "misc/halloween/skeleton_break.wav");
			PrecacheSound(sample)
			EmitSoundToAll(sample, client, _, 95)
			
			CreateTimer(8.0, DeleteGibs, client)
		}
		if (IsValidClient(client) && g_bIsSkeletonSmall[client])
		{
			CreateTimer(0.1, DeleteRagdoll, client)
		
			decl Ent
			decl Float:ClientOrigin[3]
	
			//Initialize:
			Ent = CreateEntityByName("tf_ragdoll")
			GetClientAbsOrigin(client, ClientOrigin)

			//Write:
			SetEntPropVector(Ent, Prop_Send, "m_vecRagdollOrigin", ClientOrigin)
			SetEntProp(Ent, Prop_Send, "m_iPlayerIndex", client)
			SetEntPropVector(Ent, Prop_Send, "m_vecForce", NULL_VECTOR)
			SetEntPropVector(Ent, Prop_Send, "m_vecRagdollVelocity", NULL_VECTOR)
			SetEntProp(Ent, Prop_Send, "m_bGib", 1)
	
			DispatchSpawn(Ent)
			decl String:sample[PLATFORM_MAX_PATH]
			Format(sample, sizeof(sample), "misc/halloween/skeleton_break.wav");
			PrecacheSound(sample)
			EmitSoundToAll(sample, client, _, 95)
			
			CreateTimer(8.0, DeleteGibs, client)
		}		
	}
}

public Action Event_SkeletonDeath(Handle hEvent, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	int attacker = GetEventInt(hEvent, "inflictor_entindex");
	
	if(attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && g_bIsSkeleton[attacker])
	{
		SetEventInt(hEvent, "attacker", 0);
		SetEventString(hEvent, "weapon", "spellbook_skeleton"); 
		SetEventInt(hEvent, "customkill", 66); 
		SetEventString(hEvent, "weapon_logclassname", "spellbook_skeleton");
	}

	if(attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && g_bIsSkeletonSmall[attacker])
	{
		SetEventInt(hEvent, "attacker", 0);
		SetEventString(hEvent, "weapon", "spellbook_skeleton"); 
		SetEventInt(hEvent, "customkill", 66); 
		SetEventString(hEvent, "weapon_logclassname", "spellbook_skeleton");
	}
	
	return Plugin_Continue;
}


public Action:DeleteRagdoll(Handle:timer, any:client)
{
	new ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll")
	
	if (IsValidEdict(ragdoll))
    {
        RemoveEdict(ragdoll)
    }
}

public Action:DeleteGibs(Handle:timer, any:ent)
{
	if (IsValidEntity(ent))
    {
        new String:classname[256]
        GetEdictClassname(ent, classname, sizeof(classname))
        if (StrEqual(classname, "tf_ragdoll", false))
        {
            RemoveEdict(ent)
        }
    }
}

public Action:Timer_SuperJump(Handle:hTimer)
{
	if(!g_bSuperJumps)
		return Plugin_Continue;

	static iJumpCharge[MAXPLAYERS + 1];
	for(new i = 1; i <= MaxClients; i++) if(IsValidClient(i))
	{
		if(!IsPlayerAlive(i) || !g_bIsAntlion[i])
			continue;
		new iButtons = GetClientButtons(i);
		if((iButtons & IN_DUCK || iButtons & IN_ATTACK2) && iJumpCharge[i] >= 0 && !(iButtons & IN_JUMP))
		{
			if(iJumpCharge[i] + 5 < 25)
				iJumpCharge[i] += 5;
			else
				iJumpCharge[i] = 25;
			PrintCenterText(i, "%t", "jump_status", iJumpCharge[i] * 4);
		}
		else if(iJumpCharge[i] < 0)
		{
			iJumpCharge[i] += 5;
			PrintCenterText(i, "%t %i", "jump_status_2", -iJumpCharge[i] / 20);
		}
		else
		{
			decl Float:fAngles[3];
			GetClientEyeAngles(i, fAngles);

			if(fAngles[0] < -45.0 && iJumpCharge[i] > 1)
			{
				decl Float:fVelocity[3];
				GetEntPropVector(i, Prop_Data, "m_vecVelocity", fVelocity);

				SetEntProp(i, Prop_Send, "m_bJumping", 1);

				fVelocity[2] = 750 + iJumpCharge[i] * 13.0;
				fVelocity[0] *= (1 + Sine(float(iJumpCharge[i]) * FLOAT_PI / 50));
				fVelocity[1] *= (1 + Sine(float(iJumpCharge[i]) * FLOAT_PI / 50));
				TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, fVelocity);

				iJumpCharge[i] = -120;

				decl Float:fPosition[3];
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", fPosition);

				EmitSoundToAll("npc/antlion/fly1.wav", i, SNDCHAN_AUTO, SNDLEVEL_TRAIN);
			}
			if(GetEntityFlags(i) & FL_ONGROUND)
			{	
				StopSound(i, SNDCHAN_AUTO, "npc/antlion/fly1.wav");
			}
			else
			{
				iJumpCharge[i] = 0;
				PrintCenterText(i, "");
			}
		}
	}
	return Plugin_Continue;
}

public OnClientDisconnect_Post(client)
{
	if(g_bIsZombie[client])
	{
		g_bIsZombie[client] = false
	}
	if(g_bIsFastZombie[client])
	{
		g_bIsFastZombie[client] = false
	}
	if(g_bIsBlackZombie[client])
	{
		g_bIsBlackZombie[client] = false
	}
	if(g_bIsAntlion[client])
	{
		g_bIsAntlion[client] = false
	}
	if(g_bIsCombine[client])
	{
		g_bIsCombine[client] = false
	}
	if(g_bIsVortigaunt[client])
	{
		g_bIsVortigaunt[client] = false
	}
	if(g_bIsHeadcrab[client])
	{
		g_bIsHeadcrab[client] = false
	}
	if(g_bIsPoisonHeadcrab[client])
	{
		g_bIsPoisonHeadcrab[client] = false
	}
	if(g_bIsDog[client])
	{
		g_bIsDog[client] = false
	}
	if(g_bIsAlyx[client])
	{
		g_bIsAlyx[client] = false
	}
	if(g_bIsAntGuard[client])
	{
		g_bIsAntGuard[client] = false
	}
	if(g_bIsMaleCitizen[client])
	{
		g_bIsMaleCitizen[client] = false
	}
	if(g_bIsFemaleCitizen[client])
	{
		g_bIsFemaleCitizen[client] = false
	}
	if(g_bIsSkeleton[client])
	{
		g_bIsSkeleton[client] = false
	}
	if(g_bIsSkeletonSmall[client])
	{
		g_bIsSkeletonSmall[client] = false
	}
}

public Action:OnPlayerSpawn(Handle:hEvent, const String:strName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(!IsValidClient(client))
		return Plugin_Continue;
	if(g_bIsZombie[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		ZombieClaws(client);
	}
	else if(g_bIsFastZombie[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		FastZombieClaws(client);
	}
	else if(g_bIsBlackZombie[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		ZombieClaws(client);
	}
	else if(g_bIsAntlion[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		ZombieClaws(client);
	}
	else if(g_bIsCombine[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 6);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		switch(GetRandomInt(1,3))
		{
			case 1: CombineAR2(client);
			case 2: CombineSMG1(client);
			case 3: CombineShotgun(client);
		}
	}
	else if(g_bIsVortigaunt[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 6);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		VortigauntEnergyShock(client);
	}
	else if(g_bIsHeadcrab[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		ZombieClaws(client);
	}
	else if(g_bIsPoisonHeadcrab[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		NeurotoxinBite(client);
	}
	else if(g_bIsDog[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		DogAttack(client);
	}
	else if(g_bIsAlyx[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 6);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		switch(GetRandomInt(1,4))
		{
			case 1: CombineAR2(client);
			case 2: CombineSMG1(client);
			case 3: CombineShotgun(client);
			case 4: AlyxGun(client);
		}
	}	
	else if(g_bIsAntGuard[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		AntlionGuardAttack(client);
		EmitSoundToAll("npc/antlion_guard/growl_high.wav", client, SNDCHAN_AUTO);
	}
	else if(g_bIsFemaleCitizen[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 6);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		switch(GetRandomInt(1,3))
		{
			case 1: CombineAR2(client);
			case 2: CombineSMG1(client);
			case 3: CombineShotgun(client);
		}
	}
	else if(g_bIsMaleCitizen[client])
	{
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 6);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		switch(GetRandomInt(1,3))
		{
			case 1: CombineAR2(client);
			case 2: CombineSMG1(client);
			case 3: CombineShotgun(client);
		}
	}
	else if(g_bIsSkeleton[client])
	{
		SetModel(client, "models/bots/skeleton_sniper/skeleton_sniper.mdl")
		TF2_SetPlayerClass(client, TFClass_DemoMan);
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		SkeletonMelee(client);
		new iEntity = -1;
		while((iEntity = FindEntityByClassname(iEntity, "tf_wearable")) != -1)
		{
			if(GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity") == client)
				AcceptEntityInput(iEntity, "Kill");
		}
		return Plugin_Continue;
	}
	else if(g_bIsSkeletonSmall[client])
	{
		SetModel(client, "models/bots/skeleton_sniper/skeleton_sniper.mdl")
		TF2_SetPlayerClass(client, TFClass_DemoMan);
		TF2_RemoveWeaponSlot(client, -1);
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 2);
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 5);
		TF2_RemoveWeaponSlot(client, 3);
		TF2_RemoveWeaponSlot(client, 4);
		SkeletonSmallMelee(client);
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", 0.50);
		new iEntity = -1;
		while((iEntity = FindEntityByClassname(iEntity, "tf_wearable")) != -1)
		{
			if(GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity") == client)
				AcceptEntityInput(iEntity, "Kill");
		}
		return Plugin_Continue;
	}
}
	
public Action:Command_SetZombie(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_zombie <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetZombie(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetFastZombie(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_fastzombie <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetFastZombie(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetPoisonZombie(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_poisonzombie <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetPoisonZombie(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetAntlion(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_antlion <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetAntlion(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetCombine(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_combine <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetCombine(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetVortigaunt(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_vortigaunt <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetVortigaunt(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetHeadcrab(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_headcrab <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetHeadcrab(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetFastHeadcrab(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_fastheadcrab <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetFastHeadcrab(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetPoisonHeadcrab(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_poisonheadcrab <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetPoisonHeadcrab(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetDog(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_dog <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetDog(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetAlyx(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_alyx <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetAlyx(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetCitizen(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_citien <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1: SetMaleCitizen(target_list[i]);
			case 2: SetFemaleCitizen(target_list[i]);
		}	
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetAntlionGuard(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_antlionguard <target>");
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetAntlionGuard(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetSkeleton(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_skeletonize <target>")
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetSkeleton(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

public Action:Command_SetSkeleton_Small(int client, int args)
{
	decl String:arg1[32];
	if (args < 1)
	{
		PrintToChat(client,	"[SM] Usage: sm_skeletonize_small <target>")
	}
	else GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE|(args < 1 ? COMMAND_FILTER_NO_IMMUNITY : 0),
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		SetSkeletonSmall(target_list[i]);
		LogAction(client, target_list[i], "\"%L\" made \"%L\" a NPC!", client, target_list[i]);
	}
	
	return Plugin_Handled
}

SetZombie(client)
{
	SetModel(client, ZOMBIE);
	TF2_SetPlayerClass(client, TFClass_Heavy);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	ZombieClaws(client);
	g_bIsZombie[client] = true
}

SetSkeleton(client)
{
	SetModel(client, "models/bots/skeleton_sniper_boss/skeleton_sniper_boss.mdl");
	TF2_SetPlayerClass(client, TFClass_Pyro);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	SkeletonMelee(client);
	g_bIsSkeleton[client] = true;
	new iEntity = -1;
	while((iEntity = FindEntityByClassname(iEntity, "tf_wearable")) != -1)
	{
		if(GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity") == client)
			AcceptEntityInput(iEntity, "Kill");
	}
}

SetSkeletonSmall(client)
{
	SetModel(client, "models/bots/skeleton_sniper_boss/skeleton_sniper_boss.mdl")
	TF2_SetPlayerClass(client, TFClass_Pyro);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	SkeletonSmallMelee(client);
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", 0.50);
	new iEntity = -1;
	while((iEntity = FindEntityByClassname(iEntity, "tf_wearable")) != -1)
	{
		if(GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity") == client)
			AcceptEntityInput(iEntity, "Kill");
	}
	g_bIsSkeletonSmall[client] = true;
}

SetPoisonZombie(client)
{
	SetModel(client, PZOMBIE);
	TF2_SetPlayerClass(client, TFClass_Heavy);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	ZombieClaws(client);
	g_bIsBlackZombie[client] = true
}

SetHeadcrab(client)
{
	SetModel(client, HEADCRAB);
	TF2_SetPlayerClass(client, TFClass_Heavy);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	ZombieClaws(client);
	g_bIsHeadcrab[client] = true
}

SetPoisonHeadcrab(client)
{
	SetModel(client, PHEADCRAB);
	TF2_SetPlayerClass(client, TFClass_Heavy);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	NeurotoxinBite(client);
	g_bIsPoisonHeadcrab[client] = true
}

SetFastHeadcrab(client)
{
	SetModel(client, FHEADCRAB);
	TF2_SetPlayerClass(client, TFClass_Scout);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	ZombieClaws(client);
	g_bIsHeadcrab[client] = true
}

SetFastZombie(client)
{
	SetModel(client, FZOMBIE);
	TF2_SetPlayerClass(client, TFClass_Scout);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	FastZombieClaws(client);
	g_bIsFastZombie[client] = true
}

SetDog(client)
{
	SetModel(client, DOG);
	TF2_SetPlayerClass(client, TFClass_Engineer);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	DogAttack(client);
	g_bIsDog[client] = true
}

SetAntlion(client)
{
	SetModel(client, ANTLION);
	TF2_SetPlayerClass(client, TFClass_Scout);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	AntlionMelee(client);
	g_bIsAntlion[client] = true
}

SetCombine(client)
{
	SetModel(client, COMBINE);
	TF2_SetPlayerClass(client, TFClass_Soldier);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 6);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	switch(GetRandomInt(1,3))
	{
		case 1: CombineAR2(client);
		case 2: CombineSMG1(client);
		case 3: CombineShotgun(client);
	}
	g_bIsCombine[client] = true
}

SetAlyx(client)
{
	SetModel(client, ALYX);
	TF2_SetPlayerClass(client, TFClass_Pyro);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 6);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	switch(GetRandomInt(1, 4))
	{
		case 1: CombineSMG1(client);
		case 2: CombineShotgun(client);
		case 3: CombineAR2(client);
		case 4: AlyxGun(client);
	}
	g_bIsAlyx[client] = true
}

SetMaleCitizen(client)
{
	SetModel(client, MALE);
	TF2_SetPlayerClass(client, TFClass_Pyro);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 6);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	switch(GetRandomInt(1, 4))
	{
		case 1: CombineSMG1(client);
		case 2: CombineShotgun(client);
		case 3: CombineAR2(client);
	}
	g_bIsMaleCitizen[client] = true;
}

SetFemaleCitizen(client)
{
	SetModel(client, FEMALE);
	TF2_SetPlayerClass(client, TFClass_Pyro);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 6);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	switch(GetRandomInt(1, 4))
	{
		case 1: CombineSMG1(client);
		case 2: CombineShotgun(client);
		case 3: CombineAR2(client);
	}
	g_bIsFemaleCitizen[client] = true;
}


SetVortigaunt(client)
{
	SetModel(client, VORTIGAUNT);
	TF2_SetPlayerClass(client, TFClass_Soldier);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	VortigauntEnergyShock(client);
	g_bIsVortigaunt[client] = true
}

SetAntlionGuard(client)
{
	SetModel(client, AGUARD);
	TF2_SetPlayerClass(client, TFClass_Heavy);
	TF2_RemoveWeaponSlot(client, -1);
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 2);
	TF2_RemoveWeaponSlot(client, 1);
	TF2_RemoveWeaponSlot(client, 5);
	TF2_RemoveWeaponSlot(client, 3);
	TF2_RemoveWeaponSlot(client, 4);
	AntlionGuardAttack(client);
	g_bIsAntGuard[client] = true;
	EmitSoundToAll("npc/antlion_guard/growl_high.wav", client, SNDCHAN_AUTO);
}

public Action:SetModel(client, const String:model[])
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");

		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
}

public Action ZombieSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if(!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsZombie[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 6))
			{
				case 1:	Format(sample, sizeof(sample), "npc/zombie/zombie_pain1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/zombie/zombie_pain2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/zombie/zombie_pain3.wav");
				case 4:	Format(sample, sizeof(sample), "npc/zombie/zombie_pain4.wav");
				case 5:	Format(sample, sizeof(sample), "npc/zombie/zombie_pain5.wav");
				case 6:	Format(sample, sizeof(sample), "npc/zombie/zombie_pain6.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 14))
			{
				case 1:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle3.wav");
				case 4:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle4.wav");
				case 5:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle5.wav");
				case 6:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle6.wav");
				case 7:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle7.wav");
				case 8:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle8.wav");
				case 9:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle9.wav");
				case 10:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle10.wav");
				case 11:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle11.wav");
				case 12:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle12.wav");
				case 13:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle13.wav");
				case 14:	Format(sample, sizeof(sample), "npc/zombie/zombie_voice_idle14.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "npc/zombie/claw_miss1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/zombie/claw_miss2.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:	Format(sample, sizeof(sample), "npc/zombie/foot1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/zombie/foot2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/zombie/foot3.wav");
		}
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	return Plugin_Continue;
}	

public Action SkeletonSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if(!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsSkeleton[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 7))
			{
				case 1:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_01.wav");
				case 2:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_02.wav");
				case 3:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_03.wav");
				case 4:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_04.wav");
				case 5:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_05.wav");
				case 6:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_06.wav");
				case 7:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_07.wav");
			}
			PrecacheSound(sample);
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 7))
			{
				case 1:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_01.wav");
				case 2:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_02.wav");
				case 3:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_03.wav");
				case 4:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_04.wav");
				case 5:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_05.wav");
				case 6:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_06.wav");
				case 7:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_medium_07.wav");
			}
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "npc/zombie/claw_miss1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/zombie/claw_miss2.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	return Plugin_Continue;
}	

public Action SkeletonSmallSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if(!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsSkeletonSmall[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 22))
			{
				case 1:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_01.wav");
				case 2:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_02.wav");
				case 3:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_03.wav");
				case 4:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_04.wav");
				case 5:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_05.wav");
				case 6:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_06.wav");
				case 7:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_07.wav");
				case 8:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_08.wav");
				case 9:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_09.wav");
				case 10:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_10.wav");
				case 11:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_11.wav");
				case 12:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_12.wav");
				case 13:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_13.wav");
				case 14:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_14.wav");
				case 15:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_15.wav");
				case 16:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_16.wav");
				case 17:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_17.wav");
				case 18:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_18.wav");
				case 19:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_19.wav");
				case 20:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_20.wav");
				case 21:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_21.wav");
				case 22:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_22.wav");
			}
			PrecacheSound(sample);
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 22))
			{
				case 1:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_01.wav");
				case 2:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_02.wav");
				case 3:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_03.wav");
				case 4:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_04.wav");
				case 5:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_05.wav");
				case 6:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_06.wav");
				case 7:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_07.wav");
				case 8:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_08.wav");
				case 9:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_09.wav");
				case 10:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_10.wav");
				case 11:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_11.wav");
				case 12:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_12.wav");
				case 13:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_13.wav");
				case 14:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_14.wav");
				case 15:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_15.wav");
				case 16:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_16.wav");
				case 17:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_17.wav");
				case 18:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_18.wav");
				case 19:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_19.wav");
				case 20:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_20.wav");
				case 21:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_21.wav");
				case 22:	Format(sample, sizeof(sample), "misc/halloween/skeletons/skelly_small_22.wav");
			}
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "npc/zombie/claw_miss1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/zombie/claw_miss2.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	return Plugin_Continue;
}	

public Action FastZombieSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsFastZombie[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 2))
			{
				case 1:	Format(sample, sizeof(sample), "npc/fast_zombie/fz_frenzy1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/fast_zombie/fz_scream1.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 	4))
			{
				case 1:	Format(sample, sizeof(sample), "npc/fast_zombie/fz_alert_close1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/fast_zombie/fz_alert_far1.wav");
				case 3:	Format(sample, sizeof(sample), "npc/fast_zombie/fz_frenzy1.wav");
				case 4:	Format(sample, sizeof(sample), "npc/fast_zombie/fz_scream1.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "npc/fast_zombie/claw_miss1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/fast_zombie/claw_miss2.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:	Format(sample, sizeof(sample), "npc/zombie/foot1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/zombie/foot2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/zombie/foot3.wav");
		}
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	return Plugin_Continue;
}

public Action VortigauntSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsVortigaunt[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 9))
			{
				case 1:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese02.wav");
				case 2:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese03.wav");
				case 3:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese04.wav");
				case 4:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese05.wav");
				case 5:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese07.wav");
				case 6:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese08.wav");
				case 7:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese09.wav");
				case 8:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese11.wav");
				case 9:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese12.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 9))
			{
				case 1:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese02.wav");
				case 2:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese03.wav");
				case 3:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese04.wav");
				case 4:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese05.wav");
				case 5:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese07.wav");
				case 6:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese08.wav");
				case 7:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese09.wav");
				case 8:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese11.wav");
				case 9:	Format(sample, sizeof(sample), "vo/npc/vortigaunt/vortigese12.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "rocket_shoot", false) != -1 || StrContains(sample, "rocket_shoot_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "npc/vort/attack_shoot.wav");
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAIN, 0, 1.0, 100);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:	Format(sample, sizeof(sample), "npc/vort/vort_foot1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/vort/vort_foot2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/vort/vort_foot3.wav");
			case 4:	Format(sample, sizeof(sample), "npc/vort/vort_foot4.wav");
		}
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	return Plugin_Continue;
}

public Action CombineSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsCombine[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:	Format(sample, sizeof(sample), "npc/combine_soldier/pain1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/combine_soldier/pain2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/combine_soldier/pain3.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:	Format(sample, sizeof(sample), "npc/combine_soldier/vo/readyweapons.wav");
				case 2:	Format(sample, sizeof(sample), "npc/combine_soldier/vo/readyweaponshostileinbound.wav");
				case 3:	Format(sample, sizeof(sample), "npc/combine_soldier/vo/coverme.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "smg_shoot", false) != -1 || StrContains(sample, "smg_shoot_crit", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "^weapons/ar1/ar1_dist1.wav");
			case 2:	Format(sample, sizeof(sample), "^weapons/ar1/ar1_dist2.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_STATIC, 130, 0, 1.0, 100);
	}
	else if(StrContains(sample, "shotgun_shoot", false) != -1 || StrContains(sample, "shotgun_shoot_crit", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "weapons/shotgun/shotgun_fire6.wav");
			case 2:	Format(sample, sizeof(sample), "weapons/shotgun/shotgun_fire7.wav");
		}
		EmitSoundToAll(sample, entity, _, 130, 0, 1.0, 100);
	}
	else if(StrContains(sample, "doom_sniper_smg", false) != -1 || StrContains(sample, "doom_sniper_smg_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "^weapons/smg1/npc_smg1_fire1.wav");
		EmitSoundToAll(sample, entity, SNDCHAN_STATIC, 130, 0, 1.0, 100);
	}
	if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 6))
		{
			case 1:	Format(sample, sizeof(sample), "npc/combine_soldier/gear1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/combine_soldier/gear2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/combine_soldier/gear3.wav");
			case 4:	Format(sample, sizeof(sample), "npc/combine_soldier/gear4.wav");
			case 5:	Format(sample, sizeof(sample), "npc/combine_soldier/gear5.wav");
			case 6:	Format(sample, sizeof(sample), "npc/combine_soldier/gear6.wav");
		}
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	return Plugin_Continue;
}

public Action AlyxSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsAlyx[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 6))
			{
				case 1:	Format(sample, sizeof(sample), "vo/npc/alyx/hurt04.wav");
				case 2:	Format(sample, sizeof(sample), "vo/npc/alyx/hurt05.wav");
				case 3:	Format(sample, sizeof(sample), "vo/npc/alyx/hurt06.wav");
				case 4:	Format(sample, sizeof(sample), "vo/npc/alyx/hurt08.wav");
				case 5:	Format(sample, sizeof(sample), "vo/npc/alyx/gasp02.wav");
				case 6:	Format(sample, sizeof(sample), "vo/npc/alyx/gasp03.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:	Format(sample, sizeof(sample), "vo/npc/alyx/coverme01.wav");
				case 2:	Format(sample, sizeof(sample), "vo/npc/alyx/coverme02.wav");
				case 3:	Format(sample, sizeof(sample), "vo/npc/alyx/coverme03.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "smg_shoot", false) != -1 || StrContains(sample, "smg_shoot_crit", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "^weapons/ar1/ar1_dist1.wav");
			case 2:	Format(sample, sizeof(sample), "^weapons/ar1/ar1_dist2.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_STATIC, 130, 0, 1.0, 100);
	}
	else if(StrContains(sample, "shotgun_shoot", false) != -1 || StrContains(sample, "shotgun_shoot_crit", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "weapons/shotgun/shotgun_fire6.wav");
			case 2:	Format(sample, sizeof(sample), "weapons/shotgun/shotgun_fire7.wav");
		}
		EmitSoundToAll(sample, entity, _, 130, 0, 1.0, 100);
	}
	else if(StrContains(sample, "doom_sniper_smg", false) != -1 || StrContains(sample, "doom_sniper_smg_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "^weapons/smg1/npc_smg1_fire1.wav");
		EmitSoundToAll(sample, entity, SNDCHAN_STATIC, 130, 0, 1.0, 100);
	}
	else if(StrContains(sample, "pistol_shoot", false) != -1 || StrContains(sample, "pistol_shoot_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "^weapons/pistol/pistol_fire3.wav");
		EmitSoundToAll(sample, entity, SNDCHAN_STATIC, 150, 0, 1.0, 100);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 7))
		{
			case 1:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic3.wav");
			case 4:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic4.wav");
			case 5:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic5.wav");
			case 6:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic6.wav");
			case 7:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic8.wav");
		}
		PrecacheSound(sample);
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	return Plugin_Continue;
}

public Action MaleCitizenSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsMaleCitizen[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 7))
			{
				case 1:	Format(sample, sizeof(sample), "vo/npc/male01/pain04.wav");
				case 2:	Format(sample, sizeof(sample), "vo/npc/male01/pain05.wav");
				case 3:	Format(sample, sizeof(sample), "vo/npc/male01/pain06.wav");
				case 4:	Format(sample, sizeof(sample), "vo/npc/male01/pain07.wav");
				case 5:	Format(sample, sizeof(sample), "vo/npc/male01/pain08.wav");
				case 6:	Format(sample, sizeof(sample), "vo/npc/male01/pain09.wav");
				case 7:	Format(sample, sizeof(sample), "vo/npc/male01/no01.wav");
			}
			PrecacheSound(sample);
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 31))
			{
				case 1:	Format(sample, sizeof(sample), "vo/npc/male01/question01.wav");
				case 2:	Format(sample, sizeof(sample), "vo/npc/male01/question02.wav");
				case 3:	Format(sample, sizeof(sample), "vo/npc/male01/question03.wav");
				case 4:	Format(sample, sizeof(sample), "vo/npc/male01/question04.wav");
				case 5:	Format(sample, sizeof(sample), "vo/npc/male01/question05.wav");
				case 6:	Format(sample, sizeof(sample), "vo/npc/male01/question06.wav");
    			case 7:	Format(sample, sizeof(sample), "vo/npc/male01/question07.wav");
				case 8:	Format(sample, sizeof(sample), "vo/npc/male01/question08.wav");
				case 9:	Format(sample, sizeof(sample), "vo/npc/male01/question09.wav");
				case 10:	Format(sample, sizeof(sample), "vo/npc/male01/question10.wav");
				case 11:	Format(sample, sizeof(sample), "vo/npc/male01/question11.wav");
				case 12:	Format(sample, sizeof(sample), "vo/npc/male01/question12.wav");
				case 13:	Format(sample, sizeof(sample), "vo/npc/male01/question13.wav");
				case 14:	Format(sample, sizeof(sample), "vo/npc/male01/question14.wav");
				case 15:	Format(sample, sizeof(sample), "vo/npc/male01/question15.wav");
				case 16:	Format(sample, sizeof(sample), "vo/npc/male01/question16.wav");
				case 17:	Format(sample, sizeof(sample), "vo/npc/male01/question17.wav");
				case 18:	Format(sample, sizeof(sample), "vo/npc/male01/question18.wav");
				case 19:	Format(sample, sizeof(sample), "vo/npc/male01/question19.wav");
				case 20:	Format(sample, sizeof(sample), "vo/npc/male01/question20.wav");
				case 21:	Format(sample, sizeof(sample), "vo/npc/male01/question21.wav");
				case 22:	Format(sample, sizeof(sample), "vo/npc/male01/question22.wav");
				case 23:	Format(sample, sizeof(sample), "vo/npc/male01/question23.wav");
				case 24:	Format(sample, sizeof(sample), "vo/npc/male01/question24.wav");
				case 25:	Format(sample, sizeof(sample), "vo/npc/male01/question25.wav");
				case 26:	Format(sample, sizeof(sample), "vo/npc/male01/question26.wav");
				case 27:	Format(sample, sizeof(sample), "vo/npc/male01/question27.wav");
				case 28:	Format(sample, sizeof(sample), "vo/npc/male01/question28.wav");
				case 29:	Format(sample, sizeof(sample), "vo/npc/male01/question29.wav");
				case 30:	Format(sample, sizeof(sample), "vo/npc/male01/question30.wav");
				case 31:	Format(sample, sizeof(sample), "vo/npc/male01/question31.wav");
			}
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "smg_shoot", false) != -1 || StrContains(sample, "smg_shoot_crit", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "^weapons/ar1/ar1_dist1.wav");
			case 2:	Format(sample, sizeof(sample), "^weapons/ar1/ar1_dist2.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_STATIC, 130, 0, 1.0, 100);
	}
	else if(StrContains(sample, "shotgun_shoot", false) != -1 || StrContains(sample, "shotgun_shoot_crit", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "weapons/shotgun/shotgun_fire6.wav");
			case 2:	Format(sample, sizeof(sample), "weapons/shotgun/shotgun_fire7.wav");
		}
		EmitSoundToAll(sample, entity, _, 130, 0, 1.0, 100);
	}
	else if(StrContains(sample, "doom_sniper_smg", false) != -1 || StrContains(sample, "doom_sniper_smg_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "^weapons/smg1/npc_smg1_fire1.wav");
		EmitSoundToAll(sample, entity, SNDCHAN_STATIC, 130, 0, 1.0, 100);
	}
	else if(StrContains(sample, "pistol_shoot", false) != -1 || StrContains(sample, "pistol_shoot_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "^weapons/pistol/pistol_fire3.wav");
		EmitSoundToAll(sample, entity, _, 150, 0, 1.0, 100);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 7))
		{
			case 1:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic3.wav");
			case 4:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic4.wav");
			case 5:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic5.wav");
			case 6:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic6.wav");
			case 7:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic8.wav");
		}
		PrecacheSound(sample);
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	return Plugin_Continue;
}

public Action FemaleCitizenSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsFemaleCitizen[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(4, 9))
			{
				case 4:	Format(sample, sizeof(sample), "vo/npc/female01/pain04.wav");
				case 5:	Format(sample, sizeof(sample), "vo/npc/female01/pain05.wav");
				case 6:	Format(sample, sizeof(sample), "vo/npc/female01/pain06.wav");
				case 7:	Format(sample, sizeof(sample), "vo/npc/female01/pain07.wav");
				case 8:	Format(sample, sizeof(sample), "vo/npc/female01/pain08.wav");
				case 9:	Format(sample, sizeof(sample), "vo/npc/female01/pain09.wav");
			}
			PrecacheSound(sample);
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 31))
			{
				case 1:	Format(sample, sizeof(sample), "vo/npc/female01/question01.wav");
				case 2:	Format(sample, sizeof(sample), "vo/npc/female01/question02.wav");
				case 3:	Format(sample, sizeof(sample), "vo/npc/female01/question03.wav");
				case 4:	Format(sample, sizeof(sample), "vo/npc/female01/question04.wav");
				case 5:	Format(sample, sizeof(sample), "vo/npc/female01/question05.wav");
				case 6:	Format(sample, sizeof(sample), "vo/npc/female01/question06.wav");
    			case 7:	Format(sample, sizeof(sample), "vo/npc/female01/question07.wav");
				case 8:	Format(sample, sizeof(sample), "vo/npc/female01/question08.wav");
				case 9:	Format(sample, sizeof(sample), "vo/npc/female01/question09.wav");
				case 10:	Format(sample, sizeof(sample), "vo/npc/female01/question10.wav");
				case 11:	Format(sample, sizeof(sample), "vo/npc/female01/question11.wav");
				case 12:	Format(sample, sizeof(sample), "vo/npc/female01/question12.wav");
				case 13:	Format(sample, sizeof(sample), "vo/npc/female01/question13.wav");
				case 14:	Format(sample, sizeof(sample), "vo/npc/female01/question14.wav");
				case 15:	Format(sample, sizeof(sample), "vo/npc/female01/question15.wav");
				case 16:	Format(sample, sizeof(sample), "vo/npc/female01/question16.wav");
				case 17:	Format(sample, sizeof(sample), "vo/npc/female01/question17.wav");
				case 18:	Format(sample, sizeof(sample), "vo/npc/female01/question18.wav");
				case 19:	Format(sample, sizeof(sample), "vo/npc/female01/question19.wav");
				case 20:	Format(sample, sizeof(sample), "vo/npc/female01/question20.wav");
				case 21:	Format(sample, sizeof(sample), "vo/npc/female01/question21.wav");
				case 22:	Format(sample, sizeof(sample), "vo/npc/female01/question22.wav");
				case 23:	Format(sample, sizeof(sample), "vo/npc/female01/question23.wav");
				case 24:	Format(sample, sizeof(sample), "vo/npc/female01/question24.wav");
				case 25:	Format(sample, sizeof(sample), "vo/npc/female01/question25.wav");
				case 26:	Format(sample, sizeof(sample), "vo/npc/female01/question26.wav");
				case 27:	Format(sample, sizeof(sample), "vo/npc/female01/question27.wav");
				case 28:	Format(sample, sizeof(sample), "vo/npc/female01/question28.wav");
				case 29:	Format(sample, sizeof(sample), "vo/npc/female01/question29.wav");
				case 30:	Format(sample, sizeof(sample), "vo/npc/female01/question30.wav");
				case 31:	Format(sample, sizeof(sample), "vo/npc/female01/question31.wav");
			}
			PrecacheSound(sample);
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "smg_shoot", false) != -1 || StrContains(sample, "smg_shoot_crit", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "^weapons/ar1/ar1_dist1.wav");
			case 2:	Format(sample, sizeof(sample), "^weapons/ar1/ar1_dist2.wav");
		}
		EmitSoundToAll(sample, entity, _, 150, 0, 1.0, 100);
	}
	else if(StrContains(sample, "shotgun_shoot", false) != -1 || StrContains(sample, "shotgun_shoot_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "weapons/shotgun/shotgun_fire6.wav");
		EmitSoundToAll(sample, entity, _, 95, 0, 1.0, 100);
	}
	else if(StrContains(sample, "doom_sniper_smg", false) != -1 || StrContains(sample, "doom_sniper_smg_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "^weapons/smg1/npc_smg1_fire1.wav");
		EmitSoundToAll(sample, entity, _, 150, 0, 1.0, 100);
	}
	else if(StrContains(sample, "pistol_shoot", false) != -1 || StrContains(sample, "pistol_shoot_crit", false) != -1)
	{
		Format(sample, sizeof(sample), "^weapons/pistol/pistol_fire3.wav");
		EmitSoundToAll(sample, entity, _, 150, 0, 1.0, 100);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 7))
		{
			case 1:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic3.wav");
			case 4:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic4.wav");
			case 5:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic5.wav");
			case 6:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic6.wav");
			case 7:	Format(sample, sizeof(sample), "npc/footsteps/hardboot_generic8.wav");
		}
		PrecacheSound(sample);
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}

	return Plugin_Continue;
}

public Action PoisonZombieSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{	
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsBlackZombie[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_pain1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_pain2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_pain3.wav");
				case 4:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_alert1.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 6))
			{
				case 1:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_call1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_idle2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_idle3.wav");
				case 4:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_idle4.wav");
				case 5:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_alert2.wav");
				case 6:	Format(sample, sizeof(sample), "npc/zombie_poison/pz_alert1.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "npc/zombie/claw_miss1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/zombie/claw_miss2.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:	Format(sample, sizeof(sample), "npc/zombie/foot1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/zombie/foot2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/zombie/foot3.wav");
		}
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	return Plugin_Continue;
}

public Action HeadcrabSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{	
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsHeadcrab[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:	Format(sample, sizeof(sample), "npc/headcrab/pain1.wav");
				case 2: Format(sample, sizeof(sample), "npc/headcrab/pain2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/headcrab/pain3.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 3))
			{
				case 1: Format(sample, sizeof(sample), "npc/headcrab/idle1.wav");
				case 2: Format(sample, sizeof(sample), "npc/headcrab/idle2.wav");
				case 3: Format(sample, sizeof(sample), "npc/headcrab/idle3.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1: Format(sample, sizeof(sample), "npc/headcrab/attack1.wav");
			case 2: Format(sample, sizeof(sample), "npc/headcrab/attack2.wav");
			case 3: Format(sample, sizeof(sample), "npc/headcrab/attack3.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	return Plugin_Continue;
}

public Action DogSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{	
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsDog[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 5))
			{
				case 1:	Format(sample, sizeof(sample), "npc/dog/dog_alarmed1.wav");
				case 2: Format(sample, sizeof(sample), "npc/dog/dog_alarmed3.wav");
				case 3:	Format(sample, sizeof(sample), "npc/dog/dog_angry1.wav");
				case 4:	Format(sample, sizeof(sample), "npc/dog/dog_angry2.wav");
				case 5:	Format(sample, sizeof(sample), "npc/dog/dog_angry3.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 5))
			{
				case 1:	Format(sample, sizeof(sample), "npc/dog/dog_alarmed1.wav");
				case 2: Format(sample, sizeof(sample), "npc/dog/dog_alarmed3.wav");
				case 3:	Format(sample, sizeof(sample), "npc/dog/dog_angry1.wav");
				case 4:	Format(sample, sizeof(sample), "npc/dog/dog_angry2.wav");
				case 5:	Format(sample, sizeof(sample), "npc/dog/dog_angry3.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 5))
		{
			case 1:	Format(sample, sizeof(sample), "npc/dog/dog_alarmed1.wav");
			case 2: Format(sample, sizeof(sample), "npc/dog/dog_alarmed3.wav");
			case 3:	Format(sample, sizeof(sample), "npc/dog/dog_angry1.wav");
			case 4:	Format(sample, sizeof(sample), "npc/dog/dog_angry2.wav");
			case 5:	Format(sample, sizeof(sample), "npc/dog/dog_angry3.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	return Plugin_Continue;
}

public Action PoisonHeadcrabSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{	
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsPoisonHeadcrab[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:	Format(sample, sizeof(sample), "npc/headcrab_poison/ph_pain1.wav");
				case 2: Format(sample, sizeof(sample), "npc/headcrab_poison/ph_pain2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/headcrab_poison/ph_pain3.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 3))
			{
				case 1: Format(sample, sizeof(sample), "npc/headcrab_poison/ph_idle1.wav");
				case 2: Format(sample, sizeof(sample), "npc/headcrab_poison/ph_idle2.wav");
				case 3: Format(sample, sizeof(sample), "npc/headcrab_poison/ph_idle3.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		pitch = GetRandomInt(95, 100);
		switch(GetRandomInt(1, 3))
		{
			case 1: Format(sample, sizeof(sample), "npc/headcrab_poison/ph_scream1.wav");
			case 2: Format(sample, sizeof(sample), "npc/headcrab_poison/ph_scream2.wav");
			case 3: Format(sample, sizeof(sample), "npc/headcrab_poison/ph_scream3.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, pitch);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:	Format(sample, sizeof(sample), "npc/headcrab_poison/ph_step1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/headcrab_poison/ph_step2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/headcrab_poison/ph_step3.wav");
			case 4: Format(sample, sizeof(sample), "npc/headcrab_poison/ph_step4.wav");
		}
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	return Plugin_Continue;
}


public Action AntlionSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{	
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsAntlion[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 4))
			{
				case 1:	Format(sample, sizeof(sample), "npc/antlion/attack_double1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/antlion/attack_double2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/antlion/pain1.wav");
				case 4:	Format(sample, sizeof(sample), "npc/antlion/pain2.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 5))
			{
				case 1:	Format(sample, sizeof(sample), "npc/antlion/idle1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/antlion/idle2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/antlion/idle3.wav");
				case 4:	Format(sample, sizeof(sample), "npc/antlion/idle4.wav");
				case 5:	Format(sample, sizeof(sample), "npc/antlion/idle5.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 6))
		{
			case 1:	Format(sample, sizeof(sample), "npc/antlion/attack_double1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/antlion/attack_double2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/antlion/attack_double3.wav");
			case 4:	Format(sample, sizeof(sample), "npc/antlion/attack_single1.wav");
			case 5:	Format(sample, sizeof(sample), "npc/antlion/attack_single2.wav");
			case 6:	Format(sample, sizeof(sample), "npc/antlion/attack_single3.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	else if (strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 4))
		{
			case 1:	Format(sample, sizeof(sample), "npc/antlion/foot1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/antlion/foot2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/antlion/foot3.wav");
			case 4: Format(sample, sizeof(sample), "npc/antlion/foot4.wav");
		}
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}	
	else if (strncmp(sample, "pl_fallpain", 17, false) == 0)
	{
		Format(sample, sizeof(sample), "npc/antlion/land1.wav");
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}	
	return Plugin_Continue;
}	

public Action AntlionGuardSH(clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{	
	if (!IsValidClient(entity)) return Plugin_Continue;
	if(!g_bIsAntGuard[entity]) return Plugin_Continue;
	if(StrContains(sample, "vo/", false) != -1)
	{
		if(StrContains(sample, "pain", false) != -1)
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:	Format(sample, sizeof(sample), "npc/antlion_guard/angry1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/antlion_guard/angry2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/antlion_guard/angry3.wav");
			}
			return Plugin_Changed;
		}
		else
		{
			switch(GetRandomInt(1, 3))
			{
				case 1:	Format(sample, sizeof(sample), "npc/antlion_guard/angry1.wav");
				case 2:	Format(sample, sizeof(sample), "npc/antlion_guard/angry2.wav");
				case 3:	Format(sample, sizeof(sample), "npc/antlion_guard/angry3.wav");
			}
			
			return Plugin_Changed;
		}
	}
	else if(StrContains(sample, "sword_swing", false) != -1 || StrContains(sample, "cbar_miss", false) != -1)
	{
		switch(GetRandomInt(1, 3))
		{
			case 1:	Format(sample, sizeof(sample), "npc/antlion_guard/angry1.wav");
			case 2:	Format(sample, sizeof(sample), "npc/antlion_guard/angry2.wav");
			case 3:	Format(sample, sizeof(sample), "npc/antlion_guard/angry3.wav");
		}
		EmitSoundToAll(sample, entity, SNDCHAN_VOICE, 95, 0, 1.0, 100);
	}
	else if(strncmp(sample, "player/footsteps/", 17, false) == 0)
	{
		switch(GetRandomInt(1, 2))
		{
			case 1:	Format(sample, sizeof(sample), "npc/antlion_guard/foot_heavy1.wav");
			case 2: Format(sample, sizeof(sample), "npc/antlion_guard/foot_heavy2.wav");
		}
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAFFIC);
	}
	else if(StrContains(sample, "bat_hit", false) != -1)
	{
		pitch = GetRandomInt(89, 105)
		Format(sample, sizeof(sample),	"npc/antlion_guard/shove1.wav");
		EmitSoundToAll(sample, entity, _, SNDLEVEL_TRAIN, 0, 1.0, pitch);
	}
	return Plugin_Continue;
}

stock ZombieClaws(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_bat");
		TF2Items_SetItemIndex(hWeapon, 5);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "5 ; 2.65");	
	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock SkeletonMelee(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_bonesaw");
		TF2Items_SetItemIndex(hWeapon, 426);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "5 ; 1.65");	
	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
		SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", PrecacheModel("models/empty.mdl"));
		SetEntProp(weapon, Prop_Send, "m_nModelIndexOverrides", PrecacheModel("models/empty.mdl"), _, 0);
	}	
}


stock SkeletonSmallMelee(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_bonesaw");
		TF2Items_SetItemIndex(hWeapon, 426);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "5 ; 1.45 ; 444 ; 3.5");	
	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
		SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", PrecacheModel("models/empty.mdl"));
		SetEntProp(weapon, Prop_Send, "m_nModelIndexOverrides", PrecacheModel("models/empty.mdl"), _, 0);
	}	
}

stock DogAttack(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_bat");
		TF2Items_SetItemIndex(hWeapon, 5);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "5 ; 2.65 ; 2 ; 99999 ; 57 ; 1000 ; 26 ; 1000");
	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock AntlionGuardAttack(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_bat");
		TF2Items_SetItemIndex(hWeapon, 5);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "5 ; 2.65 ; 2 ; 2.5 ; 57 ; 10 ; 26 ; 5000");
	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock NeurotoxinBite(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_bat");
		TF2Items_SetItemIndex(hWeapon, 5);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "5 ; 2.65 ; 149 ; 20 ; 182 ; 20");	
	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock AntlionMelee(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_bat");
		TF2Items_SetItemIndex(hWeapon, 5);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "5 ; 1.65 ; 106 ; 2 ; 326 ; 5.5");	
	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock FastZombieClaws(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_bat");
		TF2Items_SetItemIndex(hWeapon, 5);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "107 ; 1.5 ; 106 ; 2 ; 326 ; 2.5 ; 275 ; 1");	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock CombineAR2(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_smg");
		TF2Items_SetItemIndex(hWeapon, 16);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "6 ; 0.8");	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock CombineSMG1(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_smg");
		TF2Items_SetItemIndex(hWeapon, 751);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "6 ; 0.8");	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock CombineShotgun(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_shotgun_pyro");
		TF2Items_SetItemIndex(hWeapon, 9);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "6 ; 1.35");	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock AlyxGun(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_pistol");
		TF2Items_SetItemIndex(hWeapon, 5);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "6 ; 0.7");	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock VortigauntEnergyShock(client)
{
	TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_particle_cannon");
		TF2Items_SetItemIndex(hWeapon, 5);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		new String:weaponAttribs[881];
		
		Format(weaponAttribs, sizeof(weaponAttribs), "6 ; 1.65 ; 2 ; 999999 ; 436 ; 1");	
		new String:weaponAttribsArray[32][32];
		new attribCount = ExplodeString(weaponAttribs, " ; ", weaponAttribsArray, 32, 32);
		if (attribCount > 0) {
			TF2Items_SetNumAttributes(hWeapon, attribCount/2);
			new i2 = 0;
			for (new i = 0; i < attribCount; i+=2) {
				TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i+1]));
				i2++;
			}
		} else {
			TF2Items_SetNumAttributes(hWeapon, 0);
		}
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
	}	
}

stock bool:IsValidClient(client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
	return IsClientInGame(client);
}