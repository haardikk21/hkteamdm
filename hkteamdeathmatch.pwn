/*Credits
	Y_Less - y_ini, Whirlpool and sscanf
	Incognito - Streamer
	ZeeX - ZCMD
	iPLEOMAX - TextDraw Editor
	convertFFS(kc) - For converting maps to be used with the Streamer
	Rodrigo_FusioN - Deathmatch - Arena 3.0 Map
	TheYoungCapone - Desert_Glory Team Deathmatch Map
	[HK]Ryder[AN] - Making of Script
*/
//Includes
#include <a_samp>
#include <streamer>
#include <sscanf2>
#include <YSI\y_ini>
#include <zcmd>
//Defines
#define GAME_MODE_TEXT "HKTeamDeathMatch"
#define TEAM1 1
#define TEAM2 2
#define TEAM1COLOR 0xFF00FFAA
#define TEAM2COLOR 0xFF7B00FF
#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_CREDITS 3
#define Userpath "HKDeathMatch/Users/%s.ini"
#define INI_Exists(%0) fexist(%0)
#define SCM SendClientMessage
#define SCMToAll SendClientMessageToAll
#define MAX_PING 500
#define MAX_WARNS 5
#define COLOR_WHITE           0xFFFFFFAA
#define COLOR_DBLUE           0x2641FEAA
#define COLOR_GREEN           0x00FF00FF
#define COLOR_GREY            0xAFAFAFAA
#define COLOR_RED             0xFF4646FF
#define PM_INCOMING_COLOR     0xFFFF22AA
#define PM_OUTGOING_COLOR     0xFFCC2299

//Forwards
forward StartedNewRound();
forward NewMapTimer();
forward loadaccount_user(playerid, name[], value[]);
forward PingKick();
forward ClearSpam();
forward KillUpdate();
forward ClearMute();
forward TimeChange();
forward RestartCDTimer();
forward LoadingandRound();
forward updateinfo(playerid);
forward Unfreeze(playerid);
//Whirlpool
native WP_Hash(buffer[], len, const str[]);
//Player Enum
enum PlayerInfo
{
	pPass[129],
	pAdmin,
	pMoney,
	pScore,
	pMute,
	pFrozen,
	pWarns,
	pSpam,
	pDuty,
	pNoPM,
	pKills,
	pDeaths,
}
new pInfo[MAX_PLAYERS][PlayerInfo];
//Textdraws
new PlayerText:BanBox[MAX_PLAYERS];
new PlayerText:BanInfo[MAX_PLAYERS];
new PlayerText:BanReason[MAX_PLAYERS];
new PlayerText:BanBy[MAX_PLAYERS];
new PlayerText:Msg1[MAX_PLAYERS];
new PlayerText:Msg2[MAX_PLAYERS];
new PlayerText:InfoBox[MAX_PLAYERS];
new PlayerText:InfoName[MAX_PLAYERS];
new PlayerText:SpecBox[MAX_PLAYERS];
new PlayerText:SpecON[MAX_PLAYERS];
new PlayerText:SpecName[MAX_PLAYERS];
new PlayerText:SpecVeh[MAX_PLAYERS];
new Text:KillBox;
new Text:Kill1;
new Text:Kill2;
new Text:KillHead;
new Text:Countdown;
new Text:mapname;
//Variables
new MapChange;
new gTeam[MAX_PLAYERS];
new Float:SpecX[MAX_PLAYERS], Float:SpecY[MAX_PLAYERS], Float:SpecZ[MAX_PLAYERS], vWorld[MAX_PLAYERS], Inter[MAX_PLAYERS];
new IsSpecing[MAX_PLAYERS];
new IsBeingSpeced[MAX_PLAYERS];
new spectatorid[MAX_PLAYERS];
new RepeatedAttempts[MAX_PLAYERS];
new LastPM[MAX_PLAYERS];
new Team1Kills = 0;
new Team2Kills = 0;
new CountDownTime = 300;
new CDChange;
new FirstTimeSpawn[MAX_PLAYERS];
new Float:RandomSpawnDM3Team1[][4] =
{
	{1778.0983,4243.1909,2.5285,265.9285},
	{1782.5469,4262.9448,2.5285,285.0420},
	{1782.6361,4287.9663,2.5285,198.8745}
};
new Float:RandomSpawnDM3Team2[][4] =
{
	{1845.4630,4240.6758,2.5285,85.1334},
	{1839.8552,4272.6655,2.5285,44.3998},
	{1844.3364,4217.7183,2.5285,96.0769}
};
new Float:RandomSpawnDesertTeam1[][4] =
{
	{-1493.1298,-412.1708,267.0,1.1824},
	{-1490.7850,-394.7336,267.0,318.2553},
	{-1493.0719,-433.6069,267.0,54.9558}
};
new Float:RandomSpawnDesertTeam2[][4] =
{
	{-1632.2726,-274.3966,267.0,192.9442},
	{-1623.5513,-299.3244,267.0,227.0979},
	{-1657.2603,-310.3504,267.0,242.4514}
};
new RandomWeapons[][2] =
{
	{22, 100},
	{23, 100},
	{25, 100},
	{26, 10},
	{27, 50},
	{28, 500},
	{29, 500},
	{30, 500},
	{31, 500},
	{32, 500},
	{33, 500},
	{34, 20}
};
new VehicleNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
    "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
    "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
    "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
    "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
    "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
    "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
    "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin",
    "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
    "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
    "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
    "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
    "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
    "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
    "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
    "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
    "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
    "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
    "Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
    "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
    "Tiller", "Utility Trailer"
};
main()
{
	print("\n----------------------------------");
	print(" HKDeathMatch Script Loaded");
	print("----------------------------------\n");
}
public OnGameModeInit()
{
	SetGameModeText(GAME_MODE_TEXT);
	AddObjects();
	SetTimer("NewMapTimer", 300000, false);
	SetTimer("PingKick", 2000, true);
	SetTimer("ClearSpam", 5000, true);
	SetTimer("ClearMute", 180000, true);
	SetTimer("KillUpdate", 1000, true);
	CDChange = SetTimer("TimeChange", 1000, true);
	MapChange = 0;
	AddPlayerClass(28, 2064.69995117,2227.69995117,9.80000019,0.0, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(47, 2064.69995117,2227.69995117,9.80000019,0.0, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(60, 2064.69995117,2227.69995117,9.80000019,0.0, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(67, 2064.69995117,2227.69995117,9.80000019,0.0, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(71, 2064.69995117,2227.69995117,9.80000019,0.0, 0, 0, 0, 0, 0, 0);
	AddPlayerClass(82, 2064.69995117,2227.69995117,9.80000019,0.0, 0, 0, 0, 0, 0, 0);
	KillBox = TextDrawCreate(641.199829, 115.739997, "usebox");
	TextDrawLetterSize(KillBox, 0.000000, 10.373703);
	TextDrawTextSize(KillBox, 482.799987, 0.000000);
	TextDrawAlignment(KillBox, 1);
	TextDrawColor(KillBox, 0);
	TextDrawUseBox(KillBox, true);
	TextDrawBoxColor(KillBox, 102);
	TextDrawSetShadow(KillBox, 0);
	TextDrawSetOutline(KillBox, 0);
	TextDrawFont(KillBox, 0);

	Kill1 = TextDrawCreate(489.600036, 144.106750, "Team 1 Kills - Loading");
	TextDrawLetterSize(Kill1, 0.449999, 1.600000);
	TextDrawAlignment(Kill1, 1);
	TextDrawColor(Kill1, -16776961);
	TextDrawSetShadow(Kill1, 0);
	TextDrawSetOutline(Kill1, 1);
	TextDrawBackgroundColor(Kill1, 51);
	TextDrawFont(Kill1, 1);
	TextDrawSetProportional(Kill1, 1);

	Kill2 = TextDrawCreate(489.599975, 185.173355, "Team 2 Kills - Loading");
	TextDrawLetterSize(Kill2, 0.449999, 1.600000);
	TextDrawAlignment(Kill2, 1);
	TextDrawColor(Kill2, -16776961);
	TextDrawSetShadow(Kill2, 0);
	TextDrawSetOutline(Kill2, 1);
	TextDrawBackgroundColor(Kill2, 51);
	TextDrawFont(Kill2, 1);
	TextDrawSetProportional(Kill2, 1);

	KillHead = TextDrawCreate(537.600036, 118.719993, "Kills");
	TextDrawLetterSize(KillHead, 0.449999, 1.600000);
	TextDrawAlignment(KillHead, 1);
	TextDrawColor(KillHead, -65281);
	TextDrawSetShadow(KillHead, 0);
	TextDrawSetOutline(KillHead, 1);
	TextDrawBackgroundColor(KillHead, 51);
	TextDrawFont(KillHead, 2);
	TextDrawSetProportional(KillHead, 1);

	Countdown = TextDrawCreate(498.400024, 5.973327, "Time Left - 5:00");
	TextDrawLetterSize(Countdown, 0.449999, 1.600000);
	TextDrawAlignment(Countdown, 1);
	TextDrawColor(Countdown, -9961217);
	TextDrawSetShadow(Countdown, 0);
	TextDrawSetOutline(Countdown, 1);
	TextDrawBackgroundColor(Countdown, 51);
	TextDrawFont(Countdown, 3);
	TextDrawSetProportional(Countdown, 1);

	mapname = TextDrawCreate(5.599998, 342.720062, "Current Map - Desert Glory");
	TextDrawLetterSize(mapname, 0.397999, 1.607466);
	TextDrawAlignment(mapname, 1);
	TextDrawColor(mapname, -1);
	TextDrawSetShadow(mapname, 0);
	TextDrawSetOutline(mapname, 1);
	TextDrawBackgroundColor(mapname, 51);
	TextDrawFont(mapname, 3);
	TextDrawSetProportional(mapname, 1);
	return 1;
}
public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    InterpolateCameraPos(playerid,1452.445556,-814.403869,88.533508,1415.500000,-813.963256,90.274688,2222);
	InterpolateCameraLookAt(playerid,1449.309692,-817.947631,86.918464,1415.342529,-809.165588,91.673728,2222);
	SetPlayerPos(playerid,1415.590576,-808.479675,91.853370);
	SetPlayerFacingAngle(playerid,184.728164);
	SetPlayerTeamFromClass(playerid, classid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	FirstTimeSpawn[playerid] = 1;
	new name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof(name));
	if(INI_Exists(Path(playerid)))
	{
	    INI_ParseFile(Path(playerid), "loadaccount_%s", .bExtra = true, .extra = playerid);
	    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "This account is already regsitered. Please enter your password to login", "Login", "Kick");
	}
	else
	{
	    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", "This account is not registered. Please enter your password to register an account", "Register", "Kick");
	    return 1;
	}
	BanBox[playerid] = CreatePlayerTextDraw(playerid, 481.199981, 162.033325, "usebox");
	PlayerTextDrawLetterSize(playerid, BanBox[playerid], 0.000000, 13.372223);
	PlayerTextDrawTextSize(playerid, BanBox[playerid], 160.399993, 0.000000);
	PlayerTextDrawAlignment(playerid, BanBox[playerid], 1);
	PlayerTextDrawColor(playerid, BanBox[playerid], 0);
	PlayerTextDrawUseBox(playerid, BanBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, BanBox[playerid], 102);
	PlayerTextDrawSetShadow(playerid, BanBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, BanBox[playerid], 0);
	PlayerTextDrawFont(playerid, BanBox[playerid], 0);

	BanInfo[playerid] = CreatePlayerTextDraw(playerid, 165.600067, 165.013244, "You Have been banned from this server");
	PlayerTextDrawLetterSize(playerid, BanInfo[playerid], 0.333999, 1.614933);
	PlayerTextDrawAlignment(playerid, BanInfo[playerid], 1);
	PlayerTextDrawColor(playerid, BanInfo[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, BanInfo[playerid], 0);
	PlayerTextDrawSetOutline(playerid, BanInfo[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, BanInfo[playerid], 51);
	PlayerTextDrawFont(playerid, BanInfo[playerid], 2);
	PlayerTextDrawSetProportional(playerid, BanInfo[playerid], 1);

	BanReason[playerid] = CreatePlayerTextDraw(playerid, 227.199996, 193.386657, "Reason : LOLOLOLOLOL");
	PlayerTextDrawLetterSize(playerid, BanReason[playerid], 0.389999, 1.600000);
	PlayerTextDrawAlignment(playerid, BanReason[playerid], 1);
	PlayerTextDrawColor(playerid, BanReason[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, BanReason[playerid], 0);
	PlayerTextDrawSetOutline(playerid, BanReason[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, BanReason[playerid], 51);
	PlayerTextDrawFont(playerid, BanReason[playerid], 2);
	PlayerTextDrawSetProportional(playerid, BanReason[playerid], 1);

	BanBy[playerid] = CreatePlayerTextDraw(playerid, 227.199966, 217.279998, "Banned By : MAX_PLAYER_NAME");
	PlayerTextDrawLetterSize(playerid, BanBy[playerid], 0.348399, 1.607466);
	PlayerTextDrawAlignment(playerid, BanBy[playerid], 1);
	PlayerTextDrawColor(playerid, BanBy[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, BanBy[playerid], 0);
	PlayerTextDrawSetOutline(playerid, BanBy[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, BanBy[playerid], 51);
	PlayerTextDrawFont(playerid, BanBy[playerid], 2);
	PlayerTextDrawSetProportional(playerid, BanBy[playerid], 1);

	Msg1[playerid] = CreatePlayerTextDraw(playerid, 169.599975, 245.653320, "If you think this is an error press F8 to take a screenshot");
	PlayerTextDrawLetterSize(playerid, Msg1[playerid], 0.216399, 1.525333);
	PlayerTextDrawAlignment(playerid, Msg1[playerid], 1);
	PlayerTextDrawColor(playerid, Msg1[playerid], 8388863);
	PlayerTextDrawSetShadow(playerid, Msg1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Msg1[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Msg1[playerid], 51);
	PlayerTextDrawFont(playerid, Msg1[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Msg1[playerid], 1);

	Msg2[playerid] = CreatePlayerTextDraw(playerid, 226.399917, 262.826599, "and post it on our forums");
	PlayerTextDrawLetterSize(playerid, Msg2[playerid], 0.298799, 1.473066);
	PlayerTextDrawAlignment(playerid, Msg2[playerid], 1);
	PlayerTextDrawColor(playerid, Msg2[playerid], 8388863);
	PlayerTextDrawSetShadow(playerid, Msg2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Msg2[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Msg2[playerid], 51);
	PlayerTextDrawFont(playerid, Msg2[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Msg2[playerid], 1);

	InfoBox[playerid] = CreatePlayerTextDraw(playerid, 2.000000, 433.073333, "usebox");
	PlayerTextDrawLetterSize(playerid, InfoBox[playerid], 0.000000, 1.425554);
	PlayerTextDrawTextSize(playerid, InfoBox[playerid], 637.199951, 0.000000);
	PlayerTextDrawAlignment(playerid, InfoBox[playerid], 1);
	PlayerTextDrawColor(playerid, InfoBox[playerid], 0);
	PlayerTextDrawUseBox(playerid, InfoBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, InfoBox[playerid], 102);
	PlayerTextDrawSetShadow(playerid, InfoBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, InfoBox[playerid], 0);
	PlayerTextDrawFont(playerid, InfoBox[playerid], 0);

	InfoName[playerid] = CreatePlayerTextDraw(playerid, -0.000000, 430.079925, "Name : MAX_PLAYER_NAME	Admin level : 0	  Score : 10000");
	PlayerTextDrawLetterSize(playerid, InfoName[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, InfoName[playerid], 1);
	PlayerTextDrawColor(playerid, InfoName[playerid], -1);
	PlayerTextDrawSetShadow(playerid, InfoName[playerid], 0);
	PlayerTextDrawSetOutline(playerid, InfoName[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, InfoName[playerid], 51);
	PlayerTextDrawFont(playerid, InfoName[playerid], 1);
	PlayerTextDrawSetProportional(playerid, InfoName[playerid], 1);


	SpecBox[playerid] = CreatePlayerTextDraw(playerid, 642.000000, 312.859985, "usebox");
	PlayerTextDrawLetterSize(playerid, SpecBox[playerid], 0.000000, 8.527778);
	PlayerTextDrawTextSize(playerid, SpecBox[playerid], 454.800048, 0.000000);
	PlayerTextDrawAlignment(playerid, SpecBox[playerid], 1);
	PlayerTextDrawColor(playerid, SpecBox[playerid], 0);
	PlayerTextDrawUseBox(playerid, SpecBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, SpecBox[playerid], 102);
	PlayerTextDrawSetShadow(playerid, SpecBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecBox[playerid], 0);
	PlayerTextDrawFont(playerid, SpecBox[playerid], 0);

	SpecON[playerid] = CreatePlayerTextDraw(playerid, 459.999938, 315.093200, "Spectating Mode : ON");
	PlayerTextDrawLetterSize(playerid, SpecON[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, SpecON[playerid], 1);
	PlayerTextDrawColor(playerid, SpecON[playerid], 8388863);
	PlayerTextDrawSetShadow(playerid, SpecON[playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecON[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecON[playerid], 51);
	PlayerTextDrawFont(playerid, SpecON[playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecON[playerid], 1);

	SpecName[playerid] = CreatePlayerTextDraw(playerid, 482.399993, 340.479949, "MAX_PLAYER_NAME");
	PlayerTextDrawLetterSize(playerid, SpecName[playerid], 0.405200, 1.547732);
	PlayerTextDrawAlignment(playerid, SpecName[playerid], 1);
	PlayerTextDrawColor(playerid, SpecName[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, SpecName[playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecName[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecName[playerid], 51);
	PlayerTextDrawFont(playerid, SpecName[playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecName[playerid], 1);

	SpecVeh[playerid] = CreatePlayerTextDraw(playerid, 464.800140, 360.639984, "Vehicle : FiretruckLA");
	PlayerTextDrawLetterSize(playerid, SpecVeh[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, SpecVeh[playerid], 1);
	PlayerTextDrawColor(playerid, SpecVeh[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, SpecVeh[playerid], 0);
	PlayerTextDrawSetOutline(playerid, SpecVeh[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, SpecVeh[playerid], 51);
	PlayerTextDrawFont(playerid, SpecVeh[playerid], 1);
	PlayerTextDrawSetProportional(playerid, SpecVeh[playerid], 1);
	

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if(IsBeingSpeced[playerid] == 1)
    {
        for(new i=0;i<MAX_PLAYERS;++i)
        {
            if(spectatorid[i] == playerid)
            {
                TogglePlayerSpectating(i,false);
            }
        }
    }
    if(INI_Exists(Path(playerid)))
    {
        new INI:file = INI_Open(Path(playerid));
        INI_WriteInt(file, "AdminLevel",pInfo[playerid][pAdmin]);
        INI_WriteInt(file, "Money",GetPlayerMoney(playerid));
        INI_WriteInt(file, "Score",GetPlayerScore(playerid));
		INI_WriteInt(file, "Muted", pInfo[playerid][pMute]);
		INI_WriteInt(file, "Frozen", pInfo[playerid][pFrozen]);
		INI_WriteInt(file, "Warnings", pInfo[playerid][pWarns]);
		INI_WriteInt(file, "Duty", pInfo[playerid][pDuty]);
		INI_WriteInt(file, "NoPM", pInfo[playerid][pNoPM]);
		INI_WriteInt(file, "Kills", pInfo[playerid][pKills]);
		INI_WriteInt(file, "Deaths", pInfo[playerid][pDeaths]);
        INI_Close(file);
        return 1;
    }
    return 1;
}
public OnPlayerText(playerid, text[])
{
	if(pInfo[playerid][pMute] == 1)
	{
	    SCM(playerid, COLOR_RED, "[SERVER MUTE]You are muted, no one can hear you");
	    return 0;
	}
	pInfo[playerid][pSpam] += 1;
	if(pInfo[playerid][pSpam] == 5)
	{
	    new string[100];
	    format(string, sizeof(string), "[SERVER MUTE] You have been muted for spamming");
		SCM(playerid, COLOR_RED, string);
		pInfo[playerid][pMute] = 1;
		return 0;
	}
	if(pInfo[playerid][pSpam] == 4)
	{
	    SCM(playerid, COLOR_RED, "[SERVER]Stop with spam or you will be muted");
	    return 0;
	}
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_REGISTER:
	    {
	        if(!response) return Kick(playerid);
	        if(response)
			{
				if(!strlen(inputtext))
				{
				    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Register", "Please enter your password to register", "Register", "Quit");
				    return 1;
				}
				new hash[129];
				WP_Hash(hash, sizeof(hash), inputtext);
				new INI:file = INI_Open(Path(playerid));
				INI_WriteString(file, "Password", hash);
				INI_WriteInt(file, "AdminLevel", 0);
				INI_WriteInt(file, "Money", 0);
				INI_WriteInt(file, "Score", 0);
				INI_WriteInt(file, "Muted", 0);
				INI_WriteInt(file, "Frozen", 0);
				INI_WriteInt(file, "Warnings", 0);
				INI_WriteInt(file, "Duty", 0);
				INI_WriteInt(file, "NoPM", 0);
				INI_WriteInt(file, "Kills", 0);
				INI_WriteInt(file, "Deaths", 0);
				INI_Close(file);
				RepeatedAttempts[playerid] = 0;
				return 1;
			}
		}
		case DIALOG_LOGIN:
		{
		    if(!response) return Kick(playerid);
		    if(response)
		    {
		        new hash[129];
		        WP_Hash(hash, sizeof(hash), inputtext);
				if(!strcmp(hash, pInfo[playerid][pPass]))
				{
				    INI_ParseFile(Path(playerid), "loadaccount_%s", .bExtra = true, .extra = playerid);
				    SetPlayerScore(playerid, pInfo[playerid][pScore]);
				    GivePlayerMoney(playerid, pInfo[playerid][pMoney]);
					if(pInfo[playerid][pWarns] >= MAX_WARNS)
					{
						new string[100];
						format(string, sizeof(string), "[SERVER KICK]You have exceeded the warn limit. The maximum warn limit is %d", MAX_WARNS);
						SCM(playerid, COLOR_RED, string);
						Kick(playerid);
					}
				}
				else
				{
				    if(RepeatedAttempts[playerid] >= 3)
				    {
				    	Kick(playerid);
						return 1;
					}
					else
					{
					    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "This account is already regsitered. Please enter your password to login\n Please enter the correct password\nRepeated Attempts will get you kicked", "Login", "Kick");
						RepeatedAttempts[playerid]++;
					}
				}
			}
		}
	}
	return 1;
}
public OnPlayerSpawn(playerid)
{
	
    if(IsSpecing[playerid] == 1)
    {
        SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);// Remember earlier we stored the positions in these variables, now we're gonna get them from the variables.
        SetPlayerInterior(playerid,Inter[playerid]);//Setting the player's interior to when they typed '/spec'
        SetPlayerVirtualWorld(playerid,vWorld[playerid]);//Setting the player's virtual world to when they typed '/spec'
        IsSpecing[playerid] = 0;//Just saying you're free to use '/spec' again YAY :D
        IsBeingSpeced[spectatorid[playerid]] = 0;//Just saying that the player who was being spectated, is not free from your stalking >:D
    }
    new randwep1 = random(sizeof(RandomWeapons));
    new randwep2 = random(sizeof(RandomWeapons));
    new randwep3 = random(sizeof(RandomWeapons));
    new infostring[128];
    SetPlayerToTeamColor(playerid);
	switch(MapChange) {
	    case 0:
	    {
	        if(gTeam[playerid] == TEAM1)
	        {
	            new rand = random(sizeof(RandomSpawnDM3Team1));
	            SetPlayerPos(playerid, RandomSpawnDM3Team1[rand][0], RandomSpawnDM3Team1[rand][1], RandomSpawnDM3Team1[rand][2]);
	            SetPlayerFacingAngle(playerid, RandomSpawnDM3Team1[rand][3]);
			}
			else if(gTeam[playerid] == TEAM2)
			{
			    new rand = random(sizeof(RandomSpawnDM3Team2));
	            SetPlayerPos(playerid, RandomSpawnDM3Team2[rand][0], RandomSpawnDM3Team2[rand][1], RandomSpawnDM3Team2[rand][2]);
	            SetPlayerFacingAngle(playerid, RandomSpawnDM3Team2[rand][3]);
			}
		}
		case 1:
		{
		    if(gTeam[playerid] == TEAM1)
	        {
	            new rand = random(sizeof(RandomSpawnDesertTeam1));
	            SetPlayerPos(playerid, RandomSpawnDesertTeam1[rand][0], RandomSpawnDesertTeam1[rand][1], RandomSpawnDesertTeam1[rand][2]);
	            SetPlayerFacingAngle(playerid, RandomSpawnDesertTeam1[rand][3]);
			}
			else if(gTeam[playerid] == TEAM2)
			{
			    new rand = random(sizeof(RandomSpawnDesertTeam2));
	            SetPlayerPos(playerid, RandomSpawnDesertTeam2[rand][0], RandomSpawnDesertTeam2[rand][1], RandomSpawnDesertTeam2[rand][2]);
	            SetPlayerFacingAngle(playerid, RandomSpawnDesertTeam2[rand][3]);
			}
		}
	}
	if(FirstTimeSpawn[playerid] == 1)
	{
	    TogglePlayerControllable(playerid, 0);
		GameTextForPlayer(playerid, "Loading Objects", 3000, 3);
		SetTimerEx("Unfreeze", 3000, false, "i", playerid);
	}
	else
	{
		for(new i=0;i<MAX_PLAYERS;i++)
		{
			TogglePlayerControllable(i, 0);
	    	GameTextForAll("Loading Objects", 3000, 3);
	   	 	SetTimerEx("Unfreeze", 3000, false, "i", playerid);
		}
	}
	GivePlayerWeapon(playerid, RandomWeapons[randwep1][0], RandomWeapons[randwep1][1]);
	GivePlayerWeapon(playerid, RandomWeapons[randwep2][0], RandomWeapons[randwep2][1]);
	GivePlayerWeapon(playerid, RandomWeapons[randwep3][0], RandomWeapons[randwep3][1]);
    format(infostring, sizeof(infostring), "Name : %s   Admin Level : %d   Score : %d", GetName(playerid), pInfo[playerid][pAdmin], GetPlayerScore(playerid));
	PlayerTextDrawSetString(playerid, InfoName[playerid], infostring);
	PlayerTextDrawShow(playerid, InfoBox[playerid]);
	PlayerTextDrawShow(playerid, InfoName[playerid]);
	TextDrawShowForPlayer(playerid, Countdown);
	SetTimerEx("updateinfo", 1000, true, "i", playerid);
	TextDrawShowForPlayer(playerid, KillBox);
	TextDrawShowForPlayer(playerid, KillHead);
	TextDrawShowForPlayer(playerid, Kill1);
	TextDrawShowForPlayer(playerid, Kill2);
	if(MapChange == 0)
	{
	    TextDrawSetString(mapname, "Current Map - DM Arena 3.0");
	    TextDrawShowForPlayer(playerid, mapname);
	}
	else if(MapChange == 1)
	{
	    TextDrawSetString(mapname, "Current Map - Desert Glory");
	    TextDrawShowForPlayer(playerid, mapname);
	}
	return 1;
}
CMD:credits(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_CREDITS, DIALOG_STYLE_MSGBOX, "Credits", "SA:MP Team - Pawno and SA:MP\nITB Compuphase - PAWN Language\nY_Less - y_ini, Whirlpool and sscanf\nIncognito - Streamer\nZeeX - ZCMD\niPLEOMAX - TextDraw Editor\nconvertFFS(made by kc) - Converting maps to be used with Streamer\nRodrigo_FusioN - DM Arena 3.0 Map\nTheYoungCapone - Desert Glory Map\n[HK]Ryder[AN] - Making the script", "Ok", "");
	return 1;
}
CMD:cmds(playerid, params[]) return cmd_commands(playerid, params);
CMD:commands(playerid, params[])
{
	SCM(playerid, COLOR_GREEN, "Player Commands - /admins /report /togpm /pm /r /ask /afk /back /commands /cmds /credits");
	if(pInfo[playerid][pAdmin] < 0)
	{
	    SCM(playerid, COLOR_GREEN, "Admin Level 1 Commands - /duty /ban /kick /gethere /goto /[un]mute /getip");
		SCM(playerid, COLOR_GREEN, "Admin Level 1 Commands - /slap /slay /spec /specoff /achat /clearchat ");
		SCM(playerid, COLOR_GREEN, "Admin Level 2 Commands - /explode /announce");
		SCM(playerid, COLOR_GREEN, "Admin Level 3 Commands - /setmoney /setscore /healall /armourall");
	    SCM(playerid, COLOR_GREEN, "Admin Level 4 Commands - /jetpack");
		SCM(playerid, COLOR_GREEN, "Admin Level 5 Commands - /setlevel /setteam1kills /setteam2kills");
	}
	return 1;
}
CMD:admins(playerid, params[])
{
	new string[128];
	SCM(playerid, -1, "");
	SCM(playerid, COLOR_GREEN, "-------------------------ONLINE ADMINS-------------------------");
	SCM(playerid, -1, "");
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    if(IsPlayerConnected(i))
	    {
	        if(pInfo[i][pAdmin] > 0)
			{
			    new name[MAX_PLAYER_NAME];
			    GetPlayerName(i, name, sizeof(name));
			    format(string, sizeof(string), "Name : %s  Level : %d", name, pInfo[i][pAdmin]);
			    SCM(playerid, COLOR_GREEN, string);
			}
		}
	}
	return 1;
}
CMD:report(playerid, params[])
{
	new report[64], string[100], giveplayerid;
	if(sscanf(params, "is[64]", giveplayerid, report)) return SCM(playerid, COLOR_RED, "[USAGE] /report <playerid> <reason>");
	format(string, sizeof(string), "[REPORT] Against ID %d   Reason : %s", giveplayerid, report);
	SendMessageToAdmins(COLOR_DBLUE, string);
	return 1;
}
CMD:togpm(playerid, params[])
{
	if(pInfo[playerid][pNoPM] == 0)
	{
	    pInfo[playerid][pNoPM] = 1;
	    SCM(playerid, COLOR_GREEN, "[SERVER]You are no longer accepting private messages");
	}
	else
	{
	    pInfo[playerid][pNoPM] = 0;
	    SCM(playerid, COLOR_GREEN, "[SERVER]You are now accepting private messages");
	}
	return 1;
}
CMD:pm(playerid, params[])
{
    new pID, text[128], string[128];
    if(sscanf(params, "us", pID, text)) return SCM(playerid, COLOR_RED, "[USAGE] /pm <playerid/part of name> <message>");
    if(!IsPlayerConnected(pID)) return SCM(playerid, COLOR_RED, "Player is not connected.");
    if(pID == playerid) return SCM(playerid, COLOR_RED, "You cannot PM yourself.");
    format(string, sizeof(string), "%s (%d) is not accepting private messages at the moment.", GetName(pID), pID);
    if(pInfo[pID][pNoPM] == 1) return SCM(playerid, COLOR_RED, string);
    format(string, sizeof(string), "PM to %s: %s", GetName(pID), text);
    SCM(playerid, PM_OUTGOING_COLOR, string);
    format(string, sizeof(string), "PM from %s: %s", GetName(playerid), text);
    SCM(pID, PM_INCOMING_COLOR, string);
    LastPM[pID] = playerid;
    return 1;
}
CMD:r(playerid, params[])
{
    new text[128], string[128];
    if(sscanf(params, "s", text)) return SCM(playerid, COLOR_RED, "[USAGE] /r <message>");
    new pID = LastPM[playerid];
    if(!IsPlayerConnected(pID)) return SCM(playerid, COLOR_RED, "Player is not connected.");
    if(pID == playerid) return SCM(playerid, COLOR_RED, "You cannot PM yourself.");
    format(string, sizeof(string), "%s (%d) is not accepting private messages at the moment.", GetName(pID), pID);
    if(pInfo[pID][pNoPM] == 1) return SCM(playerid, COLOR_RED, string);
    format(string, sizeof(string), "PM to %s: %s", GetName(pID), text);
    SCM(playerid, PM_OUTGOING_COLOR, string);
    format(string, sizeof(string), "PM from %s: %s", GetName(playerid), text);
    SCM(pID, PM_INCOMING_COLOR, string);
    LastPM[pID] = playerid;
    return 1;
}
CMD:ask(playerid, params[])
{
	new string[128], text[64];
	if(sscanf(params, "s[64]", text)) return SCM(playerid, COLOR_RED, "[USAGE] /ask <question>");
	format(string, sizeof(string), "[QUESTION] By %s | %s", GetName(playerid), text);
	SendMessageToAdmins(COLOR_GREEN, string);
	return 1;
}
CMD:duty(playerid, params[])
{
	if(pInfo[playerid][pAdmin] < 1) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	new string[128];
	if(pInfo[playerid][pDuty] == 0)
	{
	    format(string, sizeof(string), "[SERVER] Admin %s is now on duty", GetName(playerid));
	    SCMToAll(COLOR_GREY, string);
	    SetPlayerHealth(playerid, 10000);
	    SetPlayerArmour(playerid, 10000);
	}
	else
	{
	    format(string, sizeof(string), "[SERVER] Admin %s is now off duty", GetName(playerid));
	    SCMToAll(COLOR_GREY, string);
	    SetPlayerHealth(playerid, 100);
	    SetPlayerArmour(playerid, 100);
	}
	return 1;
}
CMD:ban(playerid, params[])
{
	new targetid, reason[64], string[128], string2[MAX_PLAYER_NAME];
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "us[64]", targetid, reason)) return SCM(playerid, COLOR_RED, "[USAGE] /ban <playerid/part of name> <reason>");
	if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
	format(string, sizeof(string), "Reason : %s", reason);
	format(string2, sizeof(string), "Banned By : %s", GetName(playerid));
	PlayerTextDrawSetString(targetid, BanReason[targetid], string);
	PlayerTextDrawSetString(targetid, BanBy[targetid], string2);
	PlayerTextDrawShow(targetid, BanBox[targetid]);
	PlayerTextDrawShow(targetid, BanInfo[targetid]);
	PlayerTextDrawShow(targetid, BanReason[targetid]);
	PlayerTextDrawShow(targetid, BanBy[targetid]);
	PlayerTextDrawShow(targetid, Msg1[targetid]);
	PlayerTextDrawShow(targetid, Msg2[targetid]);
	Ban(targetid);
	return 1;
}
CMD:kick(playerid, params[])
{
	new targetid, reason[64], string[128];
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "us[64]", targetid, reason)) return SCM(playerid, COLOR_RED, "[USAGE] /kick <playerid/part of name> <reason>");
	if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
	format(string, sizeof(string), "You Have Been kicked by %s for %s", GetName(playerid), reason);
	SCM(targetid, COLOR_RED, string);
	Kick(targetid);
	return 1;
}
CMD:gethere(playerid, params[])
{
	new targetid, Float:X, Float:Y, Float:Z;
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", targetid)) return SCM(playerid, COLOR_RED, "[USAGE] /gethere <playerid/part of name>");
	if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
	GetPlayerPos(playerid, X, Y, Z);
	SetPlayerPos(targetid, X, Y+2, Z);
	return 1;
}
CMD:goto(playerid, params[])
{
	new targetid, Float:X, Float:Y, Float:Z;
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", targetid)) return SCM(playerid, COLOR_RED, "[USAGE] /goto <playerid/part of name>");
	if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
	GetPlayerPos(targetid, X, Y, Z);
	SetPlayerPos(playerid, X, Y+2, Z);
	return 1;
}
CMD:mute(playerid, params[])
{
	new targetid, string[100];
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", targetid)) return SCM(playerid, COLOR_RED, "[USAGE] /mute <playerid/part of name>");
	if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
	pInfo[targetid][pMute] = 1;
	format(string, sizeof(string), "[SERVER] You have been muted by %s", GetName(playerid));
	SCM(targetid, COLOR_RED, string);
	return 1;
}
CMD:unmute(playerid, params[])
{
	new targetid, string[100];
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", targetid)) return SCM(playerid, COLOR_RED, "[USAGE] /unmute <playerid/part of name>");
	if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
	pInfo[targetid][pMute] = 0;
	format(string, sizeof(string), "[SERVER] You have been unmuted by %s", GetName(playerid));
	SCM(targetid, COLOR_RED, string);
	return 1;
}
CMD:getip(playerid, params[])
{
	new targetid, string[128], IP[16];
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", targetid)) return SCM(playerid, COLOR_RED, "[USAGE] /getip <playerid/part of name>");
    if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
    GetPlayerIp(targetid, IP, sizeof(IP));
	format(string, sizeof(string), "The IP of %s is %s", GetName(targetid), IP);
	SCM(playerid, COLOR_GREEN, string);
	return 1;
}
CMD:slap(playerid, params[])
{
	new targetid, Float:Health, string[64];
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", targetid)) return SCM(playerid, COLOR_RED, "[USAGE] /slap <playerid/part of name>");
    if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
    GetPlayerHealth(targetid, Health);
    SetPlayerHealth(targetid, Health-20);
    format(string, sizeof(string), "Admin %s(%d) has slapped you", GetName(playerid), playerid);
    SendClientMessage(targetid, COLOR_DBLUE, string);
    return 1;
}
CMD:slay(playerid, params[])
{
	new targetid, string[64];
	if(pInfo[playerid][pAdmin] == 0) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", targetid)) return SCM(playerid, COLOR_RED, "[USAGE] /slay <playerid/part of name>");
    if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
    SetPlayerHealth(targetid, 0);
    format(string, sizeof(string), "Admin %s(%d) has slayed you", GetName(playerid), playerid);
    SendClientMessage(targetid, COLOR_DBLUE, string);
    return 1;
}
CMD:setlevel(playerid, params[])
{
	new targetid, level, string[100];
	if(pInfo[playerid][pAdmin] < 5 && !IsPlayerAdmin(playerid)) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "ud", targetid, level)) return SCM(playerid, COLOR_RED, "[USAGE] /setlevel <playerid/part of name> <level>");
    if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
    pInfo[targetid][pAdmin] = level;
    format(string, sizeof(string), "Admin %s has set your admin level to %d", GetName(playerid), level);
    SCM(targetid, COLOR_GREEN, string);
    format(string, sizeof(string), "You have successfully set %s's level to %d", GetName(targetid), level);
    SCM(playerid, COLOR_GREEN, string);
    return 1;
}
CMD:setteam1kills(playerid, params[])
{
	new kills, string[128];
	if(pInfo[playerid][pAdmin] < 5) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "d", kills)) return SCM(playerid, COLOR_RED, "[USAGE] /setteam1kills <kills>");
	Team1Kills = kills;
	format(string, sizeof(string), "You have successfully set Team 1 Kills to %d", kills);
	SCM(playerid, COLOR_GREEN, string);
	return 1;
}
CMD:setteam2kills(playerid, params[])
{
	new kills, string[128];
	if(pInfo[playerid][pAdmin] < 5) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "d", kills)) return SCM(playerid, COLOR_RED, "[USAGE] /setteam1kills <kills>");
	Team2Kills = kills;
	format(string, sizeof(string), "You have successfully set Team 2 Kills to %d", kills);
	SCM(playerid, COLOR_GREEN, string);
	return 1;
}
CMD:setmoney(playerid, params[])
{
	new targetid, money, string[100];
	if(pInfo[playerid][pAdmin] < 3) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "ud", targetid, money)) return SCM(playerid, COLOR_RED, "[USAGE] /setmoney <playerid/part of name> <amount>");
    if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
	ResetPlayerMoney(targetid);
	GivePlayerMoney(targetid, money);
	format(string, sizeof(string), "Admin %s has set your money to %d", GetName(playerid), money);
	SCM(targetid, COLOR_GREEN, string);
	format(string, sizeof(string), "You have successfully set %s's money to %d", GetName(targetid), money);
    SCM(playerid, COLOR_GREEN, string);
    return 1;
}
CMD:setscore(playerid, params[])
{
	new targetid, score, string[100];
	if(pInfo[playerid][pAdmin] < 3) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "ud", targetid, score)) return SCM(playerid, COLOR_RED, "[USAGE] /setscore <playerid/part of name> <amount>");
    if(!IsPlayerConnected(targetid)) return SCM(playerid, COLOR_RED, "Player is not connected");
	SetPlayerScore(targetid, score);
	format(string, sizeof(string), "Admin %s has set your score to %d", GetName(playerid), score);
	SCM(targetid, COLOR_GREEN, string);
	format(string, sizeof(string), "You have successfully set %s's score to %d", GetName(targetid), score);
    SCM(playerid, COLOR_GREEN, string);
    return 1;
}
CMD:spec(playerid, params[])
{
	new id, string[128], carstring[128];
	if(pInfo[playerid][pAdmin] < 1) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", id)) return SCM(playerid, COLOR_RED, "[USAGE] /spec <playerid/part of name>");
	if(id == playerid) return SCM(playerid, COLOR_RED, "[ERROR] You cannot spectate yourself");
	if(id == INVALID_PLAYER_ID) return SCM(playerid, COLOR_RED, "Player is not connected");
	if(IsSpecing[playerid] == 1) return SCM(playerid, COLOR_RED, "You are already spectating someone");
	GetPlayerPos(playerid, SpecX[playerid], SpecY[playerid], SpecZ[playerid]);
	Inter[playerid] = GetPlayerInterior(playerid);
	vWorld[playerid] = GetPlayerVirtualWorld(playerid);
	TogglePlayerSpectating(playerid, true);
	if(IsPlayerInAnyVehicle(id))
    {
        new vehicle;
        vehicle = GetPlayerVehicleID(playerid);
        if(GetPlayerInterior(id) > 0)
        {
            SetPlayerInterior(playerid,GetPlayerInterior(id));
        }
        if(GetPlayerVirtualWorld(id) > 0)
        {
            SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
        }
        PlayerSpectateVehicle(playerid,GetPlayerVehicleID(id));
		format(carstring, sizeof(carstring), "Vehicle Name : %s", GetVehicleName(vehicle));
		PlayerTextDrawSetString(playerid, SpecVeh[playerid], carstring);
	}
    else
    {
        if(GetPlayerInterior(id) > 0)
        {
            SetPlayerInterior(playerid,GetPlayerInterior(id));
        }
        if(GetPlayerVirtualWorld(id) > 0)
        {
            SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
        }
        PlayerSpectatePlayer(playerid,id);
		PlayerTextDrawSetString(playerid, SpecVeh[playerid], "Player On Foot");
    }
    format(string, sizeof(string), "%s", GetName(id));
    PlayerTextDrawSetString(playerid, SpecName[playerid], string);
	PlayerTextDrawShow(playerid, SpecBox[playerid]);
	PlayerTextDrawShow(playerid, SpecON[playerid]);
	PlayerTextDrawShow(playerid, SpecName[playerid]);
    PlayerTextDrawShow(playerid, SpecVeh[playerid]);
    IsSpecing[playerid] = 1;
    IsBeingSpeced[id] = 1;
    spectatorid[playerid] = id;
    return 1;
}
CMD:specoff(playerid, params[])
{
	if(IsSpecing[playerid] == 0) return SCM(playerid, COLOR_RED, "You are not spectating anyone");
	TogglePlayerSpectating(playerid, false);
	PlayerTextDrawHide(playerid, SpecBox[playerid]);
	PlayerTextDrawHide(playerid, SpecON[playerid]);
	PlayerTextDrawHide(playerid, SpecName[playerid]);
	PlayerTextDrawHide(playerid, SpecVeh[playerid]);
	return 1;
}
CMD:afk(playerid, params[])
{
	new string[128];
	format(string, sizeof(string), "[SERVER] %s is now Away-From-KeyBoard", GetName(playerid));
	SCMToAll(COLOR_GREEN, string);
	TogglePlayerControllable(playerid, 0);
	return 1;
}
CMD:back(playerid, params[])
{
	new string[128];
	format(string, sizeof(string), "[SERVER] %s is now Back", GetName(playerid));
	SCMToAll(COLOR_GREEN, string);
	TogglePlayerControllable(playerid, 1);
	return 1;
}
CMD:achat(playerid, params[])
{
	new string[128], text[128];
	if(pInfo[playerid][pAdmin] < 1) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "s[128]", text)) return SCM(playerid, COLOR_RED, "[USAGE] /achat <text>");
	format(string, sizeof(string), "[ADMIN CHAT]%s : %s", GetName(playerid), text);
	SendMessageToAdmins(COLOR_DBLUE, string);
	return 1;
}
CMD:clearchat(playerid, params[])
{
	if(pInfo[playerid][pAdmin] < 1) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	for(new i=0;i !=25;++i)
	{
		SCMToAll(-1, " ");
	}
	SCM(playerid, COLOR_GREEN, "Chat Cleared");
	return 1;
}
CMD:jetpack(playerid, params[])
{
	if(pInfo[playerid][pAdmin] < 4) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	SetPlayerSpecialAction(playerid,2);
	return 1;
}
CMD:announce(playerid, params[])
{
	new text[64];
	if(pInfo[playerid][pAdmin] < 2) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "s[64]", text)) return SCM(playerid, COLOR_RED, "[USAGE] /announce <text>");
	GameTextForAll(text, 3000, 3);
	return 1;
}
CMD:explode(playerid, params[])
{
	new Float:X, Float:Y, Float:Z, id;
	if(pInfo[playerid][pAdmin] < 2) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	if(sscanf(params, "u", id)) return SCM(playerid, COLOR_RED, "[USAGE] /explode <playerid/part of name>");
	GetPlayerPos(id, X, Y, Z);
	CreateExplosion(X, Y, Z, 7, 10);
	return 1;
}
CMD:healall(playerid, params[])
{
	if(pInfo[playerid][pAdmin] < 3) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    SetPlayerHealth(i, 100);
	}
	return 1;
}
CMD:armourall(playerid, params[])
{
	if(pInfo[playerid][pAdmin] < 3) return SCM(playerid, COLOR_RED, "[ERROR] You are not authorised to use this command");
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    SetPlayerArmour(i, 100);
	}
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
	pInfo[playerid][pDeaths]++;
	pInfo[killerid][pKills]++;
	SendDeathMessage(killerid, playerid, reason);
	if(IsBeingSpeced[playerid] == 1)
    {
        for(new i=0;i<MAX_PLAYERS;++i)
        {
            if(spectatorid[i] == playerid)
            {
                TogglePlayerSpectating(i,false);
            }
        }
    }
    if(gTeam[killerid] == TEAM1)
    {
        Team1Kills++;
	}
	else if(gTeam[killerid] == TEAM2)
	{
	    Team2Kills++;
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	if(gTeam[issuerid] == gTeam[playerid])
	{
		new Float:Health;
	    GetPlayerHealth(playerid, Health);
	    SetPlayerHealth(playerid, Health+amount);
	    SCM(issuerid, COLOR_RED, "Do Not Team Kill");
	}
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
    {
        if(IsBeingSpeced[playerid] == 1)
        {
            for(new i=0;i<MAX_PLAYERS;++i)
            {
                if(spectatorid[i] == playerid)
                {
                    new string[128];
                    new vehicle;
                    vehicle = GetPlayerVehicleID(playerid);
                    PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
                    format(string, sizeof(string), "Vehicle Name : %s", GetVehicleName(vehicle));
                    PlayerTextDrawSetString(i, SpecVeh[playerid], string);
                }
            }
        }
    }
    if(newstate == PLAYER_STATE_ONFOOT)
    {
        if(IsBeingSpeced[playerid] == 1)
        {
            for(new i=0;i<MAX_PLAYERS;++i)
            {
                if(spectatorid[i] == playerid)
                {
                    PlayerSpectatePlayer(i, playerid);
                    PlayerTextDrawSetString(i, SpecVeh[playerid], "Player On Foot");
                }
            }
        }
    }
    return 1;
}
public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    if(IsBeingSpeced[playerid] == 1)
    {
		for(new i=0;i<MAX_PLAYERS;++i)
        {
            if(spectatorid[i] == playerid)
            {
                SetPlayerInterior(i,GetPlayerInterior(playerid));
                SetPlayerVirtualWorld(i,GetPlayerVirtualWorld(playerid));
            }
        }
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}


public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
//Stocks
stock AddObjects()
{
    //Rodrigo_FusioN's Map
	CreateDynamicObject(10841,1823.1798096,4251.7031250,-0.2070001,0.0000000,0.0000000,0.0000000); //object(drydock1_sfse01)(2)
    CreateDynamicObject(3578,1834.8824463,4257.7612305,2.2885022,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(1)
    CreateDynamicObject(3620,1828.0212402,4215.7534180,14.9909515,0.0000000,0.0000000,270.9899902); //object(redockrane_las)(1)
    CreateDynamicObject(3458,1852.1464844,4271.3608398,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(1)
    CreateDynamicObject(3458,1847.0213623,4271.3681641,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(2)
    CreateDynamicObject(3458,1841.9071045,4271.3701172,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(3)
    CreateDynamicObject(3458,1836.7833252,4271.3671875,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(4)
    CreateDynamicObject(3458,1852.1466065,4230.9721680,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(5)
    CreateDynamicObject(3458,1847.0261231,4230.9750977,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(6)
    CreateDynamicObject(3458,1841.9077148,4230.9750977,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(7)
    CreateDynamicObject(3458,1836.7916260,4230.9731445,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(8)
    CreateDynamicObject(3578,1834.8959961,4268.0581055,2.2885022,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(2)
    CreateDynamicObject(3578,1834.9061279,4274.1435547,2.2885022,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(3)
    CreateDynamicObject(3578,1834.9143066,4286.3862305,2.2885022,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(4)
    CreateDynamicObject(10841,1823.3054199,4280.2666016,-0.2070001,0.0000000,0.0000000,0.0000000); //object(drydock1_sfse01)(3)
    CreateDynamicObject(3578,1834.8828125,4245.5805664,2.2885022,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(5)
    CreateDynamicObject(3578,1834.8674316,4235.2851562,2.2885022,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(6)
    CreateDynamicObject(3578,1834.8580322,4215.9648438,2.2885022,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(7)
    CreateDynamicObject(3578,1834.8569336,4228.1738281,2.2849021,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(8)
    CreateDynamicObject(10841,1823.2612305,4222.0966797,-0.2070001,0.0000000,0.0000000,0.0000000); //object(drydock1_sfse01)(4)
    CreateDynamicObject(3620,1827.1669922,4286.2397461,14.9909515,0.0000000,0.0000000,270.9887695); //object(redockrane_las)(2)
    CreateDynamicObject(10841,1800.4892578,4280.2666016,-0.2070001,0.0000000,0.0000000,0.0000000); //object(drydock1_sfse01)(5)
    CreateDynamicObject(10841,1800.3665772,4251.7094727,-0.2070001,0.0000000,0.0000000,0.0000000); //object(drydock1_sfse01)(6)
    CreateDynamicObject(10841,1800.4411621,4222.0991211,-0.2070001,0.0000000,0.0000000,0.0000000); //object(drydock1_sfse01)(7)
    CreateDynamicObject(5706,1863.5186768,4252.3291016,7.2452588,0.0000000,0.0000000,270.0000000); //object(studiobld03_law)(1)
    CreateDynamicObject(5706,1866.9736328,4226.8168945,7.2452588,0.0000000,0.0000000,90.0000000); //object(studiobld03_law)(2)
    CreateDynamicObject(5706,1866.9805908,4275.3710938,7.2452588,0.0000000,0.0000000,90.0000000); //object(studiobld03_law)(3)
    CreateDynamicObject(1448,1837.1480713,4226.2431641,1.5958504,0.0000000,0.0000000,42.1836853); //object(dyn_crate_1)(1)
    CreateDynamicObject(1448,1838.2268066,4224.9438477,1.5958504,0.0000000,0.0000000,317.8145752); //object(dyn_crate_1)(2)
    CreateDynamicObject(1448,1836.3988037,4224.2041016,1.5958504,0.0000000,0.0000000,16.8698425); //object(dyn_crate_1)(3)
    CreateDynamicObject(1449,1835.4156494,4226.0595703,2.0069227,0.0000000,0.0000000,91.5874023); //object(dyn_crate_2)(1)
    CreateDynamicObject(1372,1853.6253662,4246.0297852,1.7055359,0.0000000,0.0000000,270.0000000); //object(cj_dump2_low)(3)
    CreateDynamicObject(1558,1852.9064941,4248.8359375,2.2650743,0.0000000,0.0000000,33.7469482); //object(cj_cardbrd_pickup)(1)
    CreateDynamicObject(1558,1847.8176269,4253.2421875,2.1024218,0.0000000,0.0000000,92.8016663); //object(cj_cardbrd_pickup)(2)
    CreateDynamicObject(18257,1836.6672363,4269.0102539,1.5284696,0.0000000,0.0000000,268.5059814); //object(crates)(1)
    CreateDynamicObject(18257,1845.4882812,4283.8476562,1.5284696,0.0000000,0.0000000,175.7015381); //object(crates)(2)
    CreateDynamicObject(925,1853.0128174,4288.9042969,2.5903745,0.0000000,0.0000000,90.0000000); //object(rack2)(2)
    CreateDynamicObject(925,1846.6784668,4288.4785156,2.5903745,0.0000000,0.0000000,90.0000000); //object(rack2)(3)
    CreateDynamicObject(18260,1851.8304443,4272.4843750,3.1016622,0.0000000,0.0000000,89.9306335); //object(crates01)(1)
    CreateDynamicObject(18260,1840.6074219,4261.7451172,3.1016622,0.0000000,0.0000000,353.8142090); //object(crates01)(2)
    CreateDynamicObject(18260,1850.7144775,4262.7495117,3.1453958,0.0000000,0.0000000,92.6760254); //object(crates01)(3)
    CreateDynamicObject(2973,1848.1459961,4273.7119141,1.5284696,0.0000000,0.0000000,67.4938965); //object(k_cargo2)(1)
    CreateDynamicObject(2973,1841.9166260,4264.8691406,1.5284696,0.0000000,0.0000000,101.2359619); //object(k_cargo2)(2)
    CreateDynamicObject(2973,1838.9705810,4255.6367188,1.5284696,0.0000000,0.0000000,168.7274170); //object(k_cargo2)(3)
    CreateDynamicObject(2973,1848.4342041,4257.1337891,1.5284696,0.0000000,0.0000000,236.2164307); //object(k_cargo2)(4)
    CreateDynamicObject(2991,1849.4729004,4248.8984375,2.1562037,0.0000000,0.0000000,59.0571594); //object(imy_bbox)(1)
    CreateDynamicObject(2991,1837.8695068,4237.8027344,2.1562037,0.0000000,0.0000000,359.0570068); //object(imy_bbox)(2)
    CreateDynamicObject(2991,1837.8726807,4237.8095703,3.4139957,0.0000000,0.0000000,359.0551758); //object(imy_bbox)(3)
    CreateDynamicObject(3378,1860.7145996,4239.7128906,12.2356672,0.0000000,0.0000000,344.1837158); //object(ce_beerpile01)(1)
    CreateDynamicObject(3378,1862.2315674,4272.0205078,12.2356672,0.0000000,0.0000000,26.3634338); //object(ce_beerpile01)(2)
    CreateDynamicObject(3378,1866.2702637,4255.0317383,12.2356672,0.0000000,0.0000000,88.5453796); //object(ce_beerpile01)(3)
    CreateDynamicObject(3378,1862.9879150,4222.7587891,12.2356672,0.0000000,0.0000000,142.5443115); //object(ce_beerpile01)(4)
    CreateDynamicObject(3378,1866.1483154,4286.5400391,12.2356672,0.0000000,0.0000000,80.6114807); //object(ce_beerpile01)(5)
    CreateDynamicObject(18260,1850.5220947,4217.7099609,3.1016622,0.0000000,0.0000000,87.8016968); //object(crates01)(4)
    CreateDynamicObject(18260,1848.6855469,4228.5732422,3.1016622,0.0000000,0.0000000,180.6014404); //object(crates01)(5)
    CreateDynamicObject(18260,1839.6944580,4242.9672852,3.1016622,0.0000000,0.0000000,312.9904785); //object(crates01)(6)
    CreateDynamicObject(3066,1851.0600586,4238.2939453,2.6205728,0.0000000,0.0000000,0.0000000); //object(ammotrn_obj)(1)
    CreateDynamicObject(3458,1786.7843018,4271.2202148,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(9)
    CreateDynamicObject(3458,1786.7829590,4230.8256836,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(10)
    CreateDynamicObject(3458,1781.6640625,4271.2246094,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(11)
    CreateDynamicObject(3458,1776.5438232,4271.2290039,0.0000000,0.0000000,0.0000000,90.0000000); //amt 3458(12)
    CreateDynamicObject(3458,1771.4235840,4271.2333984,0.0000000,0.0000000,0.0000000,90.0000000); //amt 3458(13)
    CreateDynamicObject(3458,1781.6654053,4230.8271484,0.0000000,0.0000000,0.0000000,90.0000000); //object(vgncarshade1)(12)
    CreateDynamicObject(3458,1776.5478516,4230.8286133,0.0000000,0.0000000,0.0000000,90.0000000); //amt 3458(15)
    CreateDynamicObject(3458,1771.4302978,4230.8300781,0.0000000,0.0000000,0.0000000,90.0000000); //amt 3458(16)
    CreateDynamicObject(3578,1788.6896973,4286.2246094,2.3065028,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(9)
    CreateDynamicObject(3578,1788.6844482,4274.1904297,2.3065028,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(10)
    CreateDynamicObject(3578,1788.6726074,4263.8925781,2.3065028,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(11)
    CreateDynamicObject(3578,1788.6721191,4257.5395508,2.3065028,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(12)
    CreateDynamicObject(3578,1788.7092285,4245.6904297,2.3065028,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(13)
    CreateDynamicObject(3578,1788.6999512,4235.4135742,2.3065028,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(14)
    CreateDynamicObject(3578,1788.6900635,4228.2998047,2.3065028,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(15)
    CreateDynamicObject(3578,1788.7142334,4215.8525391,2.3065028,0.0000000,0.0000000,90.0000000); //object(dockbarr1_la)(16)
    CreateDynamicObject(1618,1853.8129883,4245.2392578,7.7115726,0.0000000,0.0000000,0.0000000); //object(nt_aircon1_02)(1)
    CreateDynamicObject(1618,1853.8353272,4224.1948242,7.8393455,0.0000000,0.0000000,0.0000000); //object(nt_aircon1_02)(2)
    CreateDynamicObject(1618,1853.8129883,4258.2241211,7.7581892,0.0000000,0.0000000,0.0000000); //object(nt_aircon1_02)(3)
    CreateDynamicObject(1618,1853.8422852,4278.8164062,7.7879910,0.0000000,0.0000000,0.0000000); //object(nt_aircon1_02)(4)
    CreateDynamicObject(5835,1748.8178711,4251.0991211,9.4111290,0.0000000,0.0000000,0.0000000); //object(ci_astage)(1)
    CreateDynamicObject(5835,1752.2377930,4265.9194336,9.4111290,0.0000000,0.0000000,90.0000000); //object(ci_astage)(3)
    CreateDynamicObject(5835,1752.8985596,4235.6865234,9.4111290,0.0000000,0.0000000,90.0000000); //object(ci_astage)(4)
    CreateDynamicObject(2653,1773.7524414,4229.8383789,2.2604086,0.0000000,0.0000000,0.0000000); //object(cj_aircon3)(1)
    CreateDynamicObject(2653,1773.7633057,4222.0024414,2.2604086,0.0000000,0.0000000,0.0000000); //object(cj_aircon3)(2)
    CreateDynamicObject(2653,1770.1591797,4218.3559570,2.2604086,0.0000000,0.0000000,88.8041077); //object(cj_aircon3)(3)
    CreateDynamicObject(2653,1773.5745850,4272.3349609,2.2604086,0.0000000,0.0000000,180.0000000); //object(cj_aircon3)(4)
    CreateDynamicObject(2653,1773.5595703,4280.2148438,2.2604086,0.0000000,0.0000000,179.9945068); //object(cj_aircon3)(5)
    CreateDynamicObject(2653,1769.9023438,4283.8725586,2.2604086,0.0000000,0.0000000,270.6151123); //object(cj_aircon3)(6)
    CreateDynamicObject(3258,1785.8489990,4213.7397461,1.5284696,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(1)
    CreateDynamicObject(3258,1785.7519531,4288.1323242,1.5284696,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(2)
    CreateDynamicObject(3258,1773.9244385,4214.8930664,1.5284696,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(3)
    CreateDynamicObject(3258,1773.3527832,4287.5654297,1.5284696,0.0000000,0.0000000,0.0000000); //object(refthinchim1)(4)
    CreateDynamicObject(2974,1786.8193359,4266.1572266,1.5284696,0.0000000,0.0000000,0.0000000); //object(k_cargo1)(1)
    CreateDynamicObject(2974,1785.4592285,4263.5546875,1.5284696,0.0000000,0.0000000,50.6204224); //object(k_cargo1)(2)
    CreateDynamicObject(2974,1782.2325440,4266.5957031,1.5284696,0.0000000,0.0000000,160.2971191); //object(k_cargo1)(3)
    CreateDynamicObject(2974,1785.5343018,4258.6943359,1.5284696,0.0000000,0.0000000,212.9166260); //object(k_cargo1)(4)
    CreateDynamicObject(2974,1781.9311523,4260.9550781,1.5284696,0.0000000,0.0000000,280.4089966); //object(k_cargo1)(5)
    CreateDynamicObject(2975,1786.3989258,4248.3769531,1.5284696,0.0000000,0.0000000,25.3102112); //object(k_cargo3)(1)
    CreateDynamicObject(2975,1783.2119141,4248.6528320,1.5284696,0.0000000,0.0000000,143.4213257); //object(k_cargo3)(2)
    CreateDynamicObject(2975,1782.5327148,4257.5449219,1.5284696,0.0000000,0.0000000,168.7311401); //object(k_cargo3)(3)
    CreateDynamicObject(2975,1777.1778565,4264.4453125,1.5284696,0.0000000,0.0000000,227.7852783); //object(k_cargo3)(4)
    CreateDynamicObject(2975,1775.7957764,4270.2944336,1.5284696,0.0000000,0.0000000,286.8422852); //object(k_cargo3)(5)
    CreateDynamicObject(2975,1776.4992676,4258.9755859,1.5284696,0.0000000,0.0000000,286.8420410); //object(k_cargo3)(6)
    CreateDynamicObject(2975,1776.7934570,4250.7861328,1.5284696,0.0000000,0.0000000,286.8420410); //object(k_cargo3)(7)
    CreateDynamicObject(2062,1778.4904785,4254.2895508,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(1)
    CreateDynamicObject(2062,1785.3310547,4253.3750000,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(2)
    CreateDynamicObject(2062,1781.2487793,4246.1376953,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(3)
    CreateDynamicObject(2062,1777.9370117,4241.2622070,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(4)
    CreateDynamicObject(2062,1784.2521973,4238.0537109,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(5)
    CreateDynamicObject(2062,1782.6707764,4230.8105469,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(6)
    CreateDynamicObject(2062,1781.8769531,4273.1855469,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(7)
    CreateDynamicObject(2062,1786.0618897,4273.4140625,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(8)
    CreateDynamicObject(2062,1777.0534668,4280.5605469,2.0971026,0.0000000,0.0000000,0.0000000); //object(cj_oildrum2)(9)
    CreateDynamicObject(3570,1779.8898926,4219.9008789,2.8764100,0.0000000,0.0000000,0.0000000); //object(lasdkrt2)(1)
    CreateDynamicObject(3570,1781.3267822,4281.1318359,2.8764100,0.0000000,0.0000000,89.9306335); //object(lasdkrt2)(2)
    CreateDynamicObject(3570,1783.9783935,4241.7026367,2.8764100,0.0000000,0.0000000,148.9857483); //object(lasdkrt2)(3)
    CreateDynamicObject(3570,1779.4381103,4233.6376953,1.5284696,0.0000000,0.0000000,212.0429077); //object(lasdkrt2)(4)
    CreateDynamicObject(2974,1782.2500000,4225.9282227,1.5284696,0.0000000,0.0000000,255.0987549); //object(k_cargo1)(6)
    CreateDynamicObject(2974,1776.7067871,4225.7060547,1.5284696,0.0000000,0.0000000,305.7175293); //object(k_cargo1)(7)
    CreateDynamicObject(2974,1785.8625488,4220.3261719,1.5284696,0.0000000,0.0000000,13.2104187); //object(k_cargo1)(8)
    CreateDynamicObject(2974,1786.5668945,4230.9658203,1.5284696,0.0000000,0.0000000,13.2055664); //object(k_cargo1)(9)
    CreateDynamicObject(3578,1783.3154297,4211.3896484,2.3065028,0.0000000,0.0000000,180.0000000); //object(dockbarr1_la)(17)
    CreateDynamicObject(3578,1773.0834961,4211.4033203,2.3065028,0.0000000,0.0000000,179.9945068); //object(dockbarr1_la)(18)
    CreateDynamicObject(3578,1840.2026367,4211.4868164,2.3065028,0.0000000,0.0000000,179.9945068); //object(dockbarr1_la)(19)
    CreateDynamicObject(3578,1850.4482422,4211.4785156,2.3065028,0.0000000,0.0000000,179.9945068); //object(dockbarr1_la)(20)
    CreateDynamicObject(3578,1783.3552246,4290.7236328,2.3065028,0.0000000,0.0000000,179.9945068); //object(dockbarr1_la)(21)
    CreateDynamicObject(3578,1773.0960693,4290.7402344,2.3065028,0.0000000,0.0000000,179.9945068); //object(dockbarr1_la)(22)
    CreateDynamicObject(3578,1839.9440918,4290.8813477,2.3065028,0.0000000,0.0000000,179.9945068); //object(dockbarr1_la)(23)
    CreateDynamicObject(3578,1850.2229004,4290.8676758,2.3065028,0.0000000,0.0000000,179.9945068); //object(dockbarr1_la)(25)
    CreateDynamicObject(8357,1793.8339844,4245.2939453,-6.3142872,0.0000000,179.9945068,0.0000000); //object(vgssairportland14)(2)
    CreateDynamicObject(8357,1832.9570312,4247.6625977,-6.3142872,0.0000000,179.9945068,0.0000000); //object(vgssairportland14)(3)
    CreateDynamicObject(8357,1794.3016357,4211.3237305,-5.8785744,180.0000000,270.0000000,90.0000000); //object(vgssairportland14)(4)
    CreateDynamicObject(8357,1795.0686035,4290.7802734,-5.8785744,0.0000000,90.0000000,90.0000000); //object(vgssairportland14)(5)
    CreateDynamicObject(8357,1834.2800293,4271.1435547,-104.8837433,270.0000000,180.0000000,90.0000000); //object(vgssairportland14)(8)
    CreateDynamicObject(8357,1834.2487793,4231.5991211,-104.8837433,270.0000000,179.9945068,90.0000000); //object(vgssairportland14)(8)
    CreateDynamicObject(8357,1787.9056397,4271.4628906,-104.8837433,270.0000000,0.0000000,90.0000000); //object(vgssairportland14)(8)
    CreateDynamicObject(8357,1788.0174560,4231.6997070,-104.8837433,270.0000000,0.0000000,90.0000000); //object(vgssairportland14)(8)
	//TheYoungCapone's Map
	CreateDynamicObject(12814,-1490.62988281,-324.32421875,264.95413208,0.00000000,0.00000000,0.00000000); //object(cuntyeland04) (1)
	CreateDynamicObject(16121,-1522.54931641,-296.46817017,263.88720703,0.00000000,0.00000000,65.99694824); //object(des_rockgp2_09) (1)
	CreateDynamicObject(16121,-1482.40234375,-282.37014771,263.88720703,0.00000000,0.00000000,159.99694824); //object(des_rockgp2_09) (2)
	CreateDynamicObject(3594,-1475.95361328,-306.79360962,265.59310913,0.00000000,0.00000000,0.00000000); //object(la_fuckcar1) (1)
    CreateDynamicObject(12814,-1460.72363281,-286.78710938,264.95413208,0.00000000,0.00000000,0.00000000); //object(cuntyeland04) (2)
    CreateDynamicObject(3594,-1475.88562012,-306.92178345,266.25546265,0.00000000,0.00000000,0.00000000); //object(la_fuckcar1) (2)
    CreateDynamicObject(16121,-1470.04785156,-327.37500000,263.88720703,0.00000000,0.00000000,335.99487305); //object(des_rockgp2_09) (3)
    CreateDynamicObject(12814,-1490.61914062,-374.31054688,264.95413208,0.00000000,0.00000000,0.00000000); //object(cuntyeland04) (3)
    CreateDynamicObject(16121,-1471.07299805,-379.01266479,263.88720703,0.00000000,0.00000000,335.99487305); //object(des_rockgp2_09) (4)
    CreateDynamicObject(16121,-1518.87329102,-368.09274292,263.88720703,0.00000000,0.00000000,335.99487305); //object(des_rockgp2_09) (5)
    CreateDynamicObject(16121,-1510.93750000,-415.60937500,263.88720703,0.00000000,0.00000000,157.99438477); //object(des_rockgp2_09) (6)
    CreateDynamicObject(12814,-1489.81665039,-424.08666992,264.95413208,0.00000000,0.00000000,180.00000000); //object(cuntyeland04) (4)
    CreateDynamicObject(16121,-1510.87963867,-432.66284180,263.88720703,0.00000000,0.00000000,157.99438477); //object(des_rockgp2_09) (7)
    CreateDynamicObject(16121,-1472.75097656,-430.00585938,263.88720703,0.00000000,0.00000000,335.99487305); //object(des_rockgp2_09) (8)
    CreateDynamicObject(16121,-1486.31420898,-458.72549438,263.88720703,0.00000000,0.00000000,281.99487305); //object(des_rockgp2_09) (9)
    CreateDynamicObject(12814,-1497.81774902,-473.90045166,264.95413208,0.00000000,0.00000000,359.99450684); //object(cuntyeland04) (5)
    CreateDynamicObject(12814,-1527.81835938,-478.17578125,264.95413208,0.00000000,0.00000000,359.98352051); //object(cuntyeland04) (6)
    CreateDynamicObject(12814,-1527.80859375,-428.21109009,264.95413208,0.00000000,0.00000000,179.98901367); //object(cuntyeland04) (7)
    CreateDynamicObject(16121,-1486.31347656,-458.72460938,263.88720703,0.00000000,0.00000000,281.99157715); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1514.28112793,-491.53433228,263.88720703,0.00000000,0.00000000,321.99157715); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1542.61718750,-523.31170654,263.88720703,0.00000000,0.00000000,247.98730469); //object(des_rockgp2_09) (10)
    CreateDynamicObject(12814,-1527.79040527,-528.07849121,264.95413208,0.00000000,0.00000000,179.98352051); //object(cuntyeland04) (6)
    CreateDynamicObject(12814,-1557.77416992,-486.06860352,264.95413208,0.00000000,0.00000000,359.97802734); //object(cuntyeland04) (6)
    CreateDynamicObject(12814,-1557.31372070,-535.50421143,264.95413208,0.00000000,0.00000000,179.97802734); //object(cuntyeland04) (6)
    CreateDynamicObject(12814,-1526.38000488,-311.55804443,267.15408325,354.00000000,0.00000000,270.00000000); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1576.13708496,-311.58364868,269.77413940,0.00000000,0.00000000,90.00000000); //object(cuntyeland04) (1)
    CreateDynamicObject(16667,-1548.66284180,-325.28222656,265.15173340,0.00000000,0.00000000,20.00000000); //object(des_rockgp2_14) (1)
    CreateDynamicObject(11011,-1572.69128418,-305.66302490,273.16561890,0.00000000,0.00000000,90.00000000); //object(crackfactjump_sfs) (1)
    CreateDynamicObject(3095,-1555.70617676,-299.39559937,271.08706665,90.00000000,179.95605469,270.04394531); //object(a51_jetdoor) (1)
    CreateDynamicObject(3095,-1555.67126465,-310.09753418,271.08706665,90.00000000,179.95056152,270.04394531); //object(a51_jetdoor) (2)
    CreateDynamicObject(16121,-1572.68432617,-290.17770386,263.88720703,0.00000000,0.00000000,65.99487305); //object(des_rockgp2_09) (1)
    CreateDynamicObject(16121,-1565.02270508,-281.11746216,263.88720703,0.00000000,0.00000000,191.99487305); //object(des_rockgp2_09) (1)
    CreateDynamicObject(3095,-1581.26708984,-301.20593262,273.80416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (3)
    CreateDynamicObject(3095,-1559.89807129,-306.15948486,271.08706665,90.00000000,179.95056152,0.04394531); //object(a51_jetdoor) (4)
    CreateDynamicObject(3095,-1572.00402832,-305.96548462,271.08706665,90.00000000,179.94506836,0.03845215); //object(a51_jetdoor) (5)
    CreateDynamicObject(3095,-1571.95434570,-302.48306274,271.08706665,90.00000000,179.94506836,180.03845215); //object(a51_jetdoor) (6)
    CreateDynamicObject(3095,-1576.45629883,-298.39346313,271.08706665,90.00000000,179.94506836,270.03295898); //object(a51_jetdoor) (7)
    CreateDynamicObject(3095,-1577.00756836,-310.02377319,271.08706665,90.00000000,179.94506836,270.03845215); //object(a51_jetdoor) (8)
    CreateDynamicObject(14877,-1575.81176758,-304.16940308,272.26412964,0.00000000,0.00000000,180.00000000); //object(michelle-stairs) (1)
    CreateDynamicObject(3095,-1581.36560059,-310.12332153,273.80416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (9)
    CreateDynamicObject(3095,-1590.30798340,-309.33605957,273.80416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (10)
    CreateDynamicObject(3095,-1590.04296875,-300.59747314,273.80416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (11)
    CreateDynamicObject(3095,-1572.44934082,-309.99746704,275.05416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (12)
    CreateDynamicObject(3095,-1559.50537109,-310.14947510,275.05416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (13)
    CreateDynamicObject(3095,-1564.77758789,-310.13952637,275.05416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (14)
    CreateDynamicObject(3095,-1559.61791992,-301.99243164,275.05416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (15)
    CreateDynamicObject(3095,-1567.61523438,-301.01498413,275.05416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (16)
    CreateDynamicObject(3095,-1571.69238281,-298.51055908,275.05416870,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (17)
    CreateDynamicObject(16667,-1536.43652344,-328.14746094,265.15173340,0.00000000,0.00000000,189.99206543); //object(des_rockgp2_14) (2)
    CreateDynamicObject(12814,-1576.13708496,-327.05697632,254.81909180,0.00000000,271.99993896,89.99993896); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1530.31640625,-335.34542847,264.95413208,0.00000000,0.00000000,92.00000000); //object(cuntyeland04) (1)
    CreateDynamicObject(16667,-1521.15893555,-327.00402832,265.15173340,0.00000000,0.00000000,189.99206543); //object(des_rockgp2_14) (3)
    CreateDynamicObject(17557,-1544.03918457,-376.29461670,267.36245728,0.00000000,0.00000000,180.00000000); //object(mstorcp2_lae2) (1)
    CreateDynamicObject(12814,-1529.24133301,-365.33251953,264.95413208,0.00000000,0.00000000,91.99951172); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1528.21057129,-395.31799316,264.95413208,0.00000000,0.00000000,91.99951172); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1557.71850586,-436.06881714,264.95413208,0.00000000,0.00000000,179.99450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1567.64355469,-385.59082031,264.95413208,0.00000000,0.00000000,179.99450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1569.68896484,-335.75848389,264.95413208,0.00000000,0.00000000,180.49450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1599.64599609,-335.41253662,264.95413208,0.00000000,0.00000000,180.48889160); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1597.59826660,-385.38363647,264.95413208,0.00000000,0.00000000,180.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(16121,-1588.60351562,-514.52783203,263.88720703,0.00000000,0.00000000,217.98339844); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1627.08947754,-489.03350830,263.88720703,0.00000000,0.00000000,207.97973633); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1660.80102539,-456.59197998,263.88720703,0.00000000,0.00000000,191.97668457); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1677.95837402,-411.94573975,263.88720703,0.00000000,0.00000000,159.97509766); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1678.35400391,-365.20770264,263.88720703,0.00000000,0.00000000,159.97192383); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1678.28491211,-322.16314697,263.88720703,0.00000000,0.00000000,159.97192383); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1677.05310059,-276.02746582,263.88720703,0.00000000,0.00000000,159.97192383); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1603.63854980,-256.61346436,263.88720703,0.00000000,0.00000000,1.97192383); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1614.70690918,-221.29391479,263.88720703,0.00000000,0.00000000,1.96655273); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1648.82019043,-214.59585571,263.88720703,0.00000000,0.00000000,73.96655273); //object(des_rockgp2_09) (10)
    CreateDynamicObject(16121,-1672.61389160,-239.95454407,263.88720703,0.00000000,0.00000000,127.96545410); //object(des_rockgp2_09) (10)
    CreateDynamicObject(12814,-1587.54113770,-435.57662964,264.95413208,0.00000000,0.00000000,179.99450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1587.50769043,-485.26937866,264.95413208,0.00000000,0.00000000,359.99450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1586.79211426,-535.26843262,264.95413208,0.00000000,0.00000000,179.98901367); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1617.41394043,-485.26647949,264.95413208,0.00000000,0.00000000,359.98901367); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1617.47583008,-435.25454712,264.95413208,0.00000000,0.00000000,179.99450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1647.27539062,-485.23529053,264.95413208,0.00000000,0.00000000,359.98901367); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1647.45776367,-435.40896606,264.95413208,0.00000000,0.00000000,179.99450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1677.44653320,-435.40679932,264.95413208,0.00000000,0.00000000,179.99450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1627.56274414,-386.19534302,264.95413208,0.00000000,0.00000000,180.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1657.48303223,-385.63522339,264.95413208,0.00000000,0.00000000,180.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1629.63684082,-336.23202515,264.95413208,0.00000000,0.00000000,180.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1659.58972168,-335.71823120,264.95413208,0.00000000,0.00000000,180.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1600.22521973,-286.20214844,264.95413208,0.00000000,0.00000000,0.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1630.16918945,-286.33612061,264.95413208,0.00000000,0.00000000,0.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1660.16613770,-285.80059814,264.95413208,0.00000000,0.00000000,0.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1660.59631348,-235.88627625,264.95413208,0.00000000,0.00000000,180.49438477); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1630.60510254,-236.35745239,264.95413208,0.00000000,0.00000000,180.48889160); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1600.66149902,-236.25875854,264.95413208,0.00000000,0.00000000,180.48889160); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1601.54760742,-301.60562134,254.81909180,0.00000000,271.99951172,359.99450684); //object(cuntyeland04) (1)
    CreateDynamicObject(12814,-1576.00061035,-296.11502075,254.81909180,0.00000000,271.99951172,269.98901367); //object(cuntyeland04) (1)
    CreateDynamicObject(3095,-1594.03942871,-300.61111450,269.87908936,271.99993896,180.00000000,268.00000000); //object(a51_jetdoor) (18)
    CreateDynamicObject(3095,-1589.78784180,-296.63476562,269.87908936,271.99951172,179.99450684,181.99499512); //object(a51_jetdoor) (19)
    CreateDynamicObject(3095,-1596.54748535,-292.65777588,269.20407104,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (20)
    CreateDynamicObject(3095,-1596.50634766,-283.69143677,269.20407104,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (21)
    CreateDynamicObject(3095,-1587.58605957,-291.99606323,269.20407104,0.00000000,0.00000000,0.00000000); //object(a51_jetdoor) (22)
    CreateDynamicObject(3576,-1583.40881348,-361.66244507,266.45462036,0.00000000,0.00000000,0.00000000); //object(dockcrates2_la) (1)
    CreateDynamicObject(3576,-1583.45507812,-363.56250000,266.45462036,0.00000000,0.00000000,0.00000000); //object(dockcrates2_la) (2)
    CreateDynamicObject(8077,-1581.34655762,-375.08679199,263.66033936,0.00000000,0.00000000,0.00000000); //object(vgsfrates06) (2)
    CreateDynamicObject(8355,-1532.08813477,-298.89501953,274.95828247,0.00000000,90.00000000,90.00000000); //object(vgssairportland18) (2)
    CreateDynamicObject(8355,-1474.73242188,-362.96679688,274.95828247,0.00000000,90.00000000,3.99902344); //object(vgssairportland18) (3)
    CreateDynamicObject(8355,-1510.30554199,-482.35842896,274.95828247,0.00000000,90.00000000,323.99902344); //object(vgssairportland18) (4)
    CreateDynamicObject(8355,-1590.12756348,-512.51879883,274.95828247,0.00000000,90.00000000,251.99780273); //object(vgssairportland18) (5)
    CreateDynamicObject(8355,-1640.20812988,-472.55096436,274.95828247,0.00000000,90.00000000,233.99743652); //object(vgssairportland18) (6)
    CreateDynamicObject(8355,-1678.84411621,-403.64981079,274.95828247,0.00000000,90.00000000,193.99475098); //object(vgssairportland18) (7)
    CreateDynamicObject(8355,-1682.78442383,-339.05349731,274.95828247,0.00000000,90.00000000,183.99108887); //object(vgssairportland18) (8)
    CreateDynamicObject(8355,-1680.46704102,-207.77810669,273.45828247,0.00000000,90.00000000,173.98803711); //object(vgssairportland18) (9)
    CreateDynamicObject(8355,-1649.74450684,-203.55859375,273.45828247,0.00000000,90.00000000,147.98498535); //object(vgssairportland18) (10)
    CreateDynamicObject(8355,-1597.61120605,-204.40565491,273.45828247,0.00000000,90.00000000,105.98034668); //object(vgssairportland18) (11)
    CreateDynamicObject(8355,-1608.26831055,-230.03602600,273.45828247,0.00000000,90.00000000,5.97961426); //object(vgssairportland18) (12)
    CreateDynamicObject(8615,-1602.08752441,-308.04702759,267.58584595,0.00000000,0.00000000,270.00000000); //object(vgssstairs04_lvs) (1)
    CreateDynamicObject(8615,-1581.11828613,-327.67950439,267.58584595,0.00000000,0.00000000,0.00000000); //object(vgssstairs04_lvs) (2)
    CreateDynamicObject(4585,-1582.75109863,-277.40960693,194.25704956,0.00000000,0.00000000,0.00000000); //object(towerlan2) (1)
    CreateDynamicObject(4585,-1582.75109863,-277.40960693,194.25704956,0.00000000,0.00000000,0.00000000); //object(towerlan2) (2)
    CreateDynamicObject(11088,-1631.65136719,-383.99121094,271.51007080,0.00000000,0.00000000,0.00000000); //object(crackfact_sfs) (1)
    CreateDynamicObject(8613,-1647.81250000,-382.59375000,269.06137085,0.00000000,0.00000000,87.99499512); //object(vgssstairs03_lvs) (1)
    CreateDynamicObject(3095,-1650.59704590,-376.39102173,271.84884644,0.00000000,0.00000000,358.00000000); //object(a51_jetdoor) (25)
    CreateDynamicObject(3095,-1645.98339844,-385.53570557,271.84884644,0.00000000,0.00000000,357.99499512); //object(a51_jetdoor) (26)
    CreateDynamicObject(3095,-1641.83471680,-377.50445557,271.84884644,0.00000000,0.00000000,359.99499512); //object(a51_jetdoor) (28)
    CreateDynamicObject(3095,-1637.11657715,-386.47216797,271.84884644,0.00000000,0.00000000,359.99499512); //object(a51_jetdoor) (30)
    CreateDynamicObject(3095,-1632.85253906,-377.69470215,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (31)
    CreateDynamicObject(3095,-1624.28527832,-377.72409058,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (32)
    CreateDynamicObject(3095,-1615.35595703,-377.72183228,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (33)
    CreateDynamicObject(3095,-1607.57897949,-377.70550537,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (34)
    CreateDynamicObject(3095,-1607.94726562,-386.69738770,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (35)
    CreateDynamicObject(3095,-1616.93237305,-386.70425415,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (36)
    CreateDynamicObject(3095,-1625.90307617,-386.67700195,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (37)
    CreateDynamicObject(3095,-1631.77404785,-386.27261353,271.87384033,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (38)
    CreateDynamicObject(17068,-1634.20800781,-372.08673096,272.63812256,0.00000000,0.00000000,89.99450684); //object(xjetty01) (1)
    CreateDynamicObject(17068,-1602.19299316,-383.93951416,272.63812256,0.00000000,0.00000000,359.99450684); //object(xjetty01) (2)
    CreateDynamicObject(17068,-1644.51367188,-418.72851562,272.63812256,0.00000000,0.00000000,269.98901367); //object(xjetty01) (3)
    CreateDynamicObject(17068,-1622.51953125,-418.73828125,272.63812256,0.00000000,0.00000000,269.98901367); //object(xjetty01) (4)
    CreateDynamicObject(8613,-1627.95715332,-397.33401489,269.06137085,0.00000000,0.00000000,87.99499512); //object(vgssstairs03_lvs) (2)
    CreateDynamicObject(3095,-1650.34594727,-392.69213867,271.84884644,0.00000000,0.00000000,359.99499512); //object(a51_jetdoor) (39)
    CreateDynamicObject(3095,-1650.35693359,-401.67840576,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (40)
    CreateDynamicObject(3095,-1641.44677734,-392.74029541,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (41)
    CreateDynamicObject(3095,-1636.45983887,-394.28530884,271.87384033,0.00000000,0.00000000,357.99450684); //object(a51_jetdoor) (42)
    CreateDynamicObject(3095,-1636.56738281,-403.20605469,271.84884644,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (43)
    CreateDynamicObject(3095,-1643.27246094,-401.67968750,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1625.76721191,-394.48867798,271.84884644,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (45)
    CreateDynamicObject(3095,-1625.77343750,-403.43066406,271.84884644,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (46)
    CreateDynamicObject(3095,-1630.49377441,-403.63372803,271.87384033,0.00000000,0.00000000,359.99450684); //object(a51_jetdoor) (47)
    CreateDynamicObject(11428,-1597.88220215,-437.55236816,268.28009033,0.00000000,0.00000000,190.00000000); //object(des_indruin02) (1)
    CreateDynamicObject(11440,-1583.53515625,-464.12500000,264.18713379,0.00000000,0.00000000,0.00000000); //object(des_pueblo1) (1)
    CreateDynamicObject(11442,-1580.08496094,-477.28906250,264.96194458,0.00000000,0.00000000,90.00000000); //object(des_pueblo3) (1)
    CreateDynamicObject(11443,-1581.21582031,-492.71679688,264.96194458,0.00000000,0.00000000,90.00000000); //object(des_pueblo4) (1)
    CreateDynamicObject(11457,-1613.57812500,-450.34472656,263.71194458,0.00000000,0.00000000,0.00000000); //object(des_pueblo09) (1)
    CreateDynamicObject(11458,-1542.24560547,-449.22891235,264.46194458,0.00000000,0.00000000,260.00000000); //object(des_pueblo10) (1)
    CreateDynamicObject(11492,-1536.53613281,-480.28027344,264.96194458,0.00000000,0.00000000,90.00000000); //object(des_rshed1_) (1)
    CreateDynamicObject(11440,-1614.82360840,-345.10073853,264.18713379,0.00000000,0.00000000,0.00000000); //object(des_pueblo1) (2)
    CreateDynamicObject(8337,-1627.94433594,-345.10839844,264.91009521,0.00000000,0.00000000,0.00000000); //object(vgsfrates10) (1)
    CreateDynamicObject(17068,-1612.29199219,-372.05371094,272.63812256,0.00000000,0.00000000,89.99450684); //object(xjetty01) (1)
    CreateDynamicObject(17068,-1602.11621094,-405.92187500,272.63812256,0.00000000,0.00000000,359.98352051); //object(xjetty01) (2)
    CreateDynamicObject(3095,-1650.62597656,-410.66406250,271.87384033,0.00000000,0.00000000,359.98352051); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1636.59558105,-412.17651367,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1627.65478516,-412.47454834,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1618.70227051,-412.39694214,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1609.74560547,-412.39465332,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1616.83374023,-403.39898682,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1607.85095215,-403.37814331,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1607.55578613,-394.63327026,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(3095,-1616.70349121,-394.37219238,271.87384033,0.00000000,0.00000000,359.98901367); //object(a51_jetdoor) (44)
    CreateDynamicObject(17068,-1643.52124023,-416.38558960,268.48834229,20.00000000,0.00000000,359.98901367); //object(xjetty01) (3)
    CreateDynamicObject(3798,-1603.65649414,-380.54379272,272.35302734,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (1)
    CreateDynamicObject(3798,-1603.66992188,-380.71679688,273.57772827,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1603.98669434,-395.53680420,272.80291748,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (3)
    CreateDynamicObject(5269,-1618.55371094,-381.61035156,272.91326904,0.00000000,90.00000000,0.00000000); //object(las2dkwar05) (2)
    CreateDynamicObject(5269,-1618.55371094,-381.61035156,272.91326904,0.00000000,90.00000000,0.00000000); //object(las2dkwar05) (3)
    CreateDynamicObject(3798,-1610.96228027,-381.30664062,272.37765503,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1610.94458008,-379.45568848,272.37765503,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1610.94531250,-377.49966431,272.37765503,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1613.66711426,-361.33273315,263.52792358,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(11440,-1595.80590820,-415.86111450,264.18713379,0.00000000,0.00000000,0.00000000); //object(des_pueblo1) (1)
    CreateDynamicObject(11457,-1568.09570312,-411.02929688,263.71194458,0.00000000,0.00000000,90.00000000); //object(des_pueblo09) (1)
    CreateDynamicObject(8337,-1544.72265625,-420.27929688,262.06060791,0.00000000,0.00000000,179.99450684); //object(vgsfrates10) (1)
    CreateDynamicObject(11457,-1527.67639160,-406.13223267,263.71194458,0.00000000,0.00000000,90.00000000); //object(des_pueblo09) (1)
    CreateDynamicObject(3798,-1587.78588867,-409.86489868,264.74771118,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1585.75207520,-409.86547852,264.74771118,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1583.66369629,-409.87420654,264.74771118,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1589.74853516,-409.85308838,264.74771118,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1591.76806641,-409.85339355,264.74771118,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1593.81225586,-409.85665894,264.74771118,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(6959,-1539.68737793,-379.60266113,272.78085327,0.00000000,0.00000000,0.00000000); //object(vegasnbball1) (1)
    CreateDynamicObject(6959,-1539.90405273,-382.99447632,272.75585938,0.00000000,0.00000000,0.00000000); //object(vegasnbball1) (2)
    CreateDynamicObject(3798,-1604.05432129,-411.42990112,272.30303955,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1604.04626465,-409.58398438,272.30303955,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1604.07055664,-409.58016968,274.27755737,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(3798,-1604.07482910,-411.57821655,274.27755737,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(17068,-1612.16162109,-418.77493286,272.66311646,0.00000000,0.00000000,269.98901367); //object(xjetty01) (4)
    CreateDynamicObject(3798,-1602.13818359,-417.33410645,270.90338135,0.00000000,0.00000000,0.00000000); //object(acbox3_sfs) (2)
    CreateDynamicObject(5269,-1600.01367188,-394.32324219,263.16387939,12.14538574,0.00000000,90.14282227); //object(las2dkwar05) (2)
    CreateDynamicObject(5269,-1600.00866699,-396.30844116,263.16387939,12.14538574,0.00000000,90.14282227); //object(las2dkwar05) (2)
    CreateDynamicObject(17068,-1542.98339844,-413.19421387,270.61343384,10.00000000,0.00000000,357.98901367); //object(xjetty01) (4)
    CreateDynamicObject(17068,-1543.73046875,-434.52737427,265.68927002,15.99755859,0.00000000,357.98400879); //object(xjetty01) (4)
    CreateDynamicObject(16667,-1534.00366211,-328.72332764,265.15173340,0.00000000,0.00000000,189.99206543); //object(des_rockgp2_14) (2)
    CreateDynamicObject(11442,-1623.29541016,-289.02154541,264.96194458,0.00000000,0.00000000,90.00000000); //object(des_pueblo3) (1)
    CreateDynamicObject(11442,-1631.54821777,-310.54254150,264.96194458,0.00000000,0.00000000,0.00000000); //object(des_pueblo3) (1)
    CreateDynamicObject(11457,-1621.10009766,-305.71276855,263.71194458,0.00000000,0.00000000,90.00000000); //object(des_pueblo09) (1)
    CreateDynamicObject(11457,-1657.25244141,-280.68731689,263.71194458,0.00000000,0.00000000,90.00000000); //object(des_pueblo09) (1)
    CreateDynamicObject(11492,-1633.22155762,-268.25570679,264.96194458,0.00000000,0.00000000,90.00000000); //object(des_rshed1_) (1)
    CreateDynamicObject(3576,-1585.51721191,-340.27236938,266.45462036,0.00000000,0.00000000,0.00000000); //object(dockcrates2_la) (2)
    CreateDynamicObject(3576,-1585.53503418,-343.28012085,266.45462036,0.00000000,0.00000000,0.00000000); //object(dockcrates2_la) (2)
    CreateDynamicObject(7191,-1552.52746582,-381.41448975,263.98648071,0.00000000,0.00000000,180.00000000); //object(vegasnnewfence2b) (1)
    CreateDynamicObject(7191,-1554.42822266,-381.40234375,265.86145020,0.00000000,270.00000000,0.00000000); //object(vegasnnewfence2b) (3)
    CreateDynamicObject(7191,-1556.42187500,-381.19628906,263.98648071,0.00000000,0.00000000,0.00000000); //object(vegasnnewfence2b) (4)
    CreateDynamicObject(3576,-1556.45959473,-340.34442139,266.45462036,0.00000000,0.00000000,0.00000000); //object(dockcrates2_la) (2)
    CreateDynamicObject(11443,-1551.58703613,-347.24621582,264.96194458,0.00000000,0.00000000,270.00000000); //object(des_pueblo4) (1)
    CreateDynamicObject(5269,-1618.55371094,-381.61035156,272.88827515,0.00000000,90.00000000,180.00000000); //object(las2dkwar05) (3)
    CreateDynamicObject(4239,-1472.56481934,-298.65011597,268.83251953,0.00000000,0.00000000,214.00000000); //object(billbrdlan_11) (1)
    CreateDynamicObject(16121,-1470.44384766,-286.03268433,263.88720703,0.00000000,0.00000000,25.99487305); //object(des_rockgp2_09) (3)
    CreateDynamicObject(5269,-1557.99328613,-377.34957886,269.08392334,0.00000000,270.00000000,180.28823853); //object(las2dkwar05) (2)
    CreateDynamicObject(5269,-1558.04394531,-369.20263672,269.08392334,0.00000000,270.00000000,180.28564453); //object(las2dkwar05) (2)
    CreateDynamicObject(5269,-1557.99169922,-387.67016602,269.08392334,0.00000000,270.00000000,180.28564453); //object(las2dkwar05) (2)
    CreateDynamicObject(5269,-1551.97070312,-382.62396240,269.08392334,0.00000000,270.00000000,272.28564453); //object(las2dkwar05) (2)
    CreateDynamicObject(5269,-1551.97070312,-382.62304688,269.05892944,0.00000000,270.00000000,92.28515625); //object(las2dkwar05) (2)
    CreateDynamicObject(3576,-1504.63452148,-347.76464844,266.45462036,0.00000000,0.00000000,90.00000000); //object(dockcrates2_la) (2)
    CreateDynamicObject(3576,-1504.99755859,-342.77807617,266.45462036,0.00000000,0.00000000,90.00000000); //object(dockcrates2_la) (2)
    CreateDynamicObject(2991,-1482.64843750,-383.95562744,265.58969116,0.00000000,0.00000000,0.00000000); //object(imy_bbox) (1)
    CreateDynamicObject(2991,-1487.83020020,-391.57388306,265.58969116,0.00000000,0.00000000,0.00000000); //object(imy_bbox) (2)
    CreateDynamicObject(2991,-1484.18286133,-407.78448486,265.58969116,0.00000000,0.00000000,0.00000000); //object(imy_bbox) (3)
    CreateDynamicObject(2973,-1492.85058594,-386.68637085,264.96194458,0.00000000,0.00000000,0.00000000); //object(k_cargo2) (1)
    CreateDynamicObject(2973,-1496.47448730,-422.63748169,264.96194458,0.00000000,0.00000000,0.00000000); //object(k_cargo2) (2)
    CreateDynamicObject(2934,-1495.74633789,-376.09777832,266.41387939,0.00000000,0.00000000,60.00000000); //object(kmb_container_red) (1)
    CreateDynamicObject(2934,-1487.88610840,-417.66510010,266.41387939,0.00000000,0.00000000,59.99633789); //object(kmb_container_red) (2)
    CreateDynamicObject(2062,-1478.84375000,-373.75567627,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (1)
    CreateDynamicObject(2062,-1478.24194336,-372.93060303,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (2)
    CreateDynamicObject(2062,-1479.49035645,-372.66891479,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (3)
    CreateDynamicObject(2062,-1496.48498535,-369.39212036,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (4)
    CreateDynamicObject(2062,-1489.05932617,-383.93539429,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (5)
    CreateDynamicObject(2062,-1495.83239746,-367.41232300,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (6)
    CreateDynamicObject(2062,-1497.27233887,-368.54391479,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (7)
    CreateDynamicObject(2062,-1488.05969238,-383.95883179,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (8)
    CreateDynamicObject(2062,-1494.94384766,-407.58682251,265.53057861,0.00000000,0.00000000,0.00000000); //object(cj_oildrum2) (9)
    CreateDynamicObject(18260,-1491.46557617,-399.36468506,266.53512573,0.00000000,0.00000000,0.00000000); //object(crates01) (1)
    CreateDynamicObject(930,-1503.33789062,-344.84899902,265.43780518,0.00000000,0.00000000,90.00000000); //object(o2_bottles) (1)
    CreateDynamicObject(931,-1563.96777344,-301.48022461,271.40722656,0.00000000,0.00000000,90.00000000); //object(rack3) (1)
    CreateDynamicObject(1362,-1502.28393555,-326.30606079,265.56042480,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (1)
    CreateDynamicObject(1362,-1552.50732422,-308.07293701,270.26043701,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (2)
    CreateDynamicObject(3461,-1502.21093750,-326.33139038,264.46206665,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (1)
    CreateDynamicObject(3461,-1552.57958984,-307.93368530,268.98229980,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (2)
    CreateDynamicObject(1362,-1552.71972656,-302.77835083,270.38043213,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (3)
    CreateDynamicObject(3461,-1552.62304688,-302.79608154,269.40701294,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (3)
    CreateDynamicObject(1362,-1484.23132324,-375.08752441,265.56042480,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (4)
    CreateDynamicObject(3576,-1579.45617676,-320.25961304,270.90487671,0.00000000,0.00000000,90.00000000); //object(dockcrates2_la) (2)
    CreateDynamicObject(1362,-1483.20593262,-398.55627441,265.56042480,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (5)
    CreateDynamicObject(1362,-1490.43017578,-409.90872192,265.56042480,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (6)
    CreateDynamicObject(1362,-1490.53283691,-433.60067749,265.56042480,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (7)
    CreateDynamicObject(1362,-1499.12658691,-436.52734375,265.56042480,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (8)
    CreateDynamicObject(1362,-1494.79455566,-392.87545776,265.56042480,0.00000000,0.00000000,0.00000000); //object(cj_firebin) (9)
    CreateDynamicObject(3461,-1484.17529297,-374.88543701,264.43679810,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (4)
    CreateDynamicObject(3461,-1494.65136719,-392.89398193,264.43679810,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (5)
    CreateDynamicObject(3461,-1483.17016602,-398.57669067,264.43679810,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (6)
    CreateDynamicObject(3461,-1490.39465332,-409.87438965,264.43679810,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (7)
    CreateDynamicObject(3461,-1490.48510742,-433.55554199,264.43679810,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (8)
    CreateDynamicObject(3461,-1499.20764160,-436.60064697,264.43679810,0.00000000,0.00000000,0.00000000); //object(tikitorch01_lvs) (9)
    CreateDynamicObject(851,-1494.66455078,-433.30075073,264.96194458,0.00000000,0.00000000,0.00000000); //object(cj_urb_rub_2) (1)
    CreateDynamicObject(849,-1487.73864746,-430.98074341,265.26168823,0.00000000,0.00000000,0.00000000); //object(cj_urb_rub_3) (1)
    CreateDynamicObject(3119,-1493.30798340,-429.95007324,265.26187134,0.00000000,0.00000000,0.00000000); //object(cs_ry_props) (1)
    CreateDynamicObject(3005,-1492.88476562,-438.77450562,264.96194458,0.00000000,0.00000000,0.00000000); //object(smash_box_stay) (1)
    CreateDynamicObject(2890,-1596.57653809,-319.13812256,269.78195190,0.00000000,0.00000000,90.00000000); //object(kmb_skip) (1)
    return 1;
 }
SetPlayerTeamFromClass(playerid, classid)
{
	if (classid == 0 || classid == 1 || classid == 2)
	{
		gTeam[playerid] = TEAM1;
		GameTextForPlayer(playerid, "Team 1", 2000, 3);
	}
	else
	{
		gTeam[playerid] = TEAM2;
		GameTextForPlayer(playerid, "Team 2", 2000, 3);
	}
}
SetPlayerToTeamColor(playerid)
{
	if (gTeam[playerid] == TEAM1)
	{
		SetPlayerColor(playerid, TEAM1COLOR);
	}
	else if (gTeam[playerid] == TEAM2)
	{
		SetPlayerColor(playerid, TEAM2COLOR);
	}
}
public NewMapTimer()
{
	if(MapChange == 0)
	{
	    MapChange = 1;
	    TextDrawSetString(mapname, "Current Map - Desert Glory");
	}
	else if(MapChange == 1)
	{
	    MapChange = 0;
	    TextDrawSetString(mapname, "Current Map - DM Arena 3.0");
	}
	
	return 1;
}
public LoadingandRound()
{
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    TogglePlayerControllable(i, 0);
	}
    GameTextForAll("~b~Loading New Map", 4000, 3);
	SetTimer("StartedNewRound", 4000, false);
	return 1;
}
public StartedNewRound()
{
	for(new i=0;i<MAX_PLAYERS;++i)
	{
	    SpawnPlayer(i);
	    TogglePlayerControllable(i, 0);
	    GameTextForAll("Loading Objects", 3000, 3);
	    SetTimer("Unfreeze", 3000, false);
	}
	return 1;
}
stock Path(playerid)
{
    new str[128],name[MAX_PLAYER_NAME];
    GetPlayerName(playerid,name,sizeof(name));
    format(str,sizeof(str),Userpath,name);
    return str;
}
public loadaccount_user(playerid, name[], value[])
{
    INI_String("Password", pInfo[playerid][pPass],129);
    INI_Int("AdminLevel",pInfo[playerid][pAdmin]);
    INI_Int("Money",pInfo[playerid][pMoney]);
    INI_Int("Score",pInfo[playerid][pScore]);
    INI_Int("Muted", pInfo[playerid][pMute]);
    INI_Int("Frozen", pInfo[playerid][pFrozen]);
    INI_Int("Warnings", pInfo[playerid][pWarns]);
	INI_Int("Duty", pInfo[playerid][pDuty]);
	INI_Int("NoPM", pInfo[playerid][pNoPM]);
	INI_Int("Kills", pInfo[playerid][pKills]);
	INI_Int("Deaths", pInfo[playerid][pDeaths]);
    return 1;
}
public PingKick()
{
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    if(GetPlayerPing(i) > MAX_PING)
	    {
			new string[100];
			format(string, sizeof(string), "[SERVER KICK]You have exceeded the ping limit. Maximum ping is %d", MAX_PING);
			SCM(i, COLOR_RED, string);
			Kick(i);
		}
	}
	return 1;
}
public ClearSpam()
{
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    if(pInfo[i][pSpam] == 1)
	    {
	        pInfo[i][pSpam] = 0;
		}
	}
	return 1;
}
public ClearMute()
{
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    if(pInfo[i][pMute] == 1)
	    {
	        pInfo[i][pMute] = 0;
		}
	}
	return 1;
}
stock SendMessageToAdmins(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    if(pInfo[i][pAdmin] > 0)
		    {
		        SCM(i, color, string);
			}
		}
	}
	return 1;
}
stock GetName(playerid)
{
        new pName[MAX_PLAYER_NAME];
        GetPlayerName(playerid, pName, sizeof(pName));
        return pName;
}
stock GetVehicleName(vehicleid)
{
	new String[128];
    format(String,sizeof(String),"%s",VehicleNames[GetVehicleModel(vehicleid) - 400]);
    return String;
}
public KillUpdate()
{
	new string[128];
	format(string, sizeof(string), "Team 1 Kills - %d", Team1Kills);
	TextDrawSetString(Kill1, string);
	format(string, sizeof(string), "Team 2 Kills - %d", Team2Kills);
	TextDrawSetString(Kill2, string);
	return 1;
}
public TimeChange()
{
	new seconds = CountDownTime % 60;
	new minutes = (CountDownTime - seconds) / 60;
	if(CountDownTime > 0)
	{
	    new string[64];
	    format(string, sizeof(string), "Time Left - %02d:%02d", minutes, seconds);
	    TextDrawSetString(Countdown, string);
	    CountDownTime--;
	}
	else if(CountDownTime == 0)
	{
	    if(Team1Kills > Team2Kills)
		{
			for(new i=0;i<MAX_PLAYERS;i++)
			{
 				if(gTeam[i] == TEAM1)
   				{
		        	GameTextForPlayer(i, "You Won! When is the party?", 4000, 3);
					SetPlayerScore(i, GetPlayerScore(i) + 1);
					GivePlayerMoney(i, 2000);
		       		SetTimer("LoadingandRound", 4000, false);
				}
				else
				{
			    	GameTextForPlayer(i, "You brought Disgrace!You LOST!", 4000, 3);
			    	SetTimer("LoadingandRound", 4000, false);
				}
			}
		}
		else if(Team2Kills > Team1Kills)
		{
			for(new i=0;i<MAX_PLAYERS;i++)
			{
		    	if(gTeam[i] == TEAM2)
		    	{
		        	GameTextForPlayer(i, "You Won! When is the party?", 4000, 3);
		        	SetPlayerScore(i, GetPlayerScore(i) + 1);
		        	GivePlayerMoney(i, 2000);
		        	SetTimer("LoadingandRound", 4000, false);
				}
				else
				{
			    	GameTextForPlayer(i, "You brought Disgrace!You LOST!", 4000, 3);
			    	SetTimer("LoadingandRound", 4000, false);
				}
			}
		}
		else if(Team1Kills == Team2Kills)
		{
			GameTextForAll("Round Draw!", 4000, 3);
			SetTimer("LoadingandRound", 4000, false);
		}
		TextDrawSetString(Countdown, "Time Left - 00:00");
	    SetTimer("RestartCDTimer", 4000, false);
	    KillTimer(CDChange);
	}
	return 1;
}
public RestartCDTimer()
{
	CountDownTime = 300;
	CDChange = SetTimer("TimeChange", 1000, true);
	return 1;
}
public updateinfo(playerid)
{
    new infostring[128];
	format(infostring, sizeof(infostring), "Name : %s   Admin Level : %d   Score : %d   Cash : %d", GetName(playerid), pInfo[playerid][pAdmin], GetPlayerScore(playerid), GetPlayerMoney(playerid));
	PlayerTextDrawSetString(playerid, InfoName[playerid], infostring);
}
public Unfreeze(playerid)
{
	if(FirstTimeSpawn[playerid] == 1)
	{
		GameTextForPlayer(playerid, "Loaded Objects!Let's Play", 1000, 3);
		TogglePlayerControllable(playerid, 1);
	}
	else
	{
		
		GameTextForAll("Loaded!Let's Play", 1000, 3);
		for(new i=0;i<MAX_PLAYERS;i++)
		{
		    TogglePlayerControllable(i, 1);
		    SpawnPlayer(i);
		}
		Team1Kills = 0;
		Team2Kills = 0;
		SetTimer("NewMapTimer", 300000, false);
	}
	return 1;
}
