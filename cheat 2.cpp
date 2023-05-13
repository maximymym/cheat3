#define WIN32_LEAN_AND_MEAN
#include <thread>
#include <iostream>
#include <cmath>
#include <sstream>
#include <string>
#include <functional>
#include <string_view>
#include <atomic>
#include "memory 2.h"
#include "Structurs.h"
#include "vector.h"
#include <mutex>
#include <chrono>
#include <windows.h>


std::mutex mtx;

std::atomic<float> smooth{ 35.0f };
std::atomic<float> fov{ 5.0f };
std::atomic<bool> aimbotEnabled{ true };
std::atomic<bool> glowEnabled{ true };

enum ConsoleColor {
	BLACK = 0,
	DARKBLUE = 1,
	DARKGREEN = 2,
	DARKCYAN = 3,
	DARKRED = 4,
	DARKMAGENTA = 5,
	DARKYELLOW = 6,
	GRAY = 7,
	DARKGRAY = 8,
	BLUE = 9,
	GREEN = 10,
	CYAN = 11,
	RED = 12,
	MAGENTA = 13,
	YELLOW = 14,
	WHITE = 15
};

namespace offset {
	constexpr ::std::ptrdiff_t cs_gamerules_data = 0x0;
	constexpr ::std::ptrdiff_t m_ArmorValue = 0x117CC;
	constexpr ::std::ptrdiff_t m_Collision = 0x320;
	constexpr ::std::ptrdiff_t m_CollisionGroup = 0x474;
	constexpr ::std::ptrdiff_t m_Local = 0x2FCC;
	constexpr ::std::ptrdiff_t m_MoveType = 0x25C;
	constexpr ::std::ptrdiff_t m_OriginalOwnerXuidHigh = 0x31D4;
	constexpr ::std::ptrdiff_t m_OriginalOwnerXuidLow = 0x31D0;
	constexpr ::std::ptrdiff_t m_SurvivalGameRuleDecisionTypes = 0x1328;
	constexpr ::std::ptrdiff_t m_SurvivalRules = 0xD00;
	constexpr ::std::ptrdiff_t m_aimPunchAngle = 0x303C;
	constexpr ::std::ptrdiff_t m_aimPunchAngleVel = 0x3048;
	constexpr ::std::ptrdiff_t m_angEyeAnglesX = 0x117D0;
	constexpr ::std::ptrdiff_t m_angEyeAnglesY = 0x117D4;
	constexpr ::std::ptrdiff_t m_bBombDefused = 0x29C0;
	constexpr ::std::ptrdiff_t m_bBombPlanted = 0x9A5;
	constexpr ::std::ptrdiff_t m_bBombTicking = 0x2990;
	constexpr ::std::ptrdiff_t m_bFreezePeriod = 0x20;
	constexpr ::std::ptrdiff_t m_bGunGameImmunity = 0x9990;
	constexpr ::std::ptrdiff_t m_bHasDefuser = 0x117DC;
	constexpr ::std::ptrdiff_t m_bHasHelmet = 0x117C0;
	constexpr ::std::ptrdiff_t m_bInReload = 0x32B5;
	constexpr ::std::ptrdiff_t m_bIsDefusing = 0x997C;
	constexpr ::std::ptrdiff_t m_bIsQueuedMatchmaking = 0x74;
	constexpr ::std::ptrdiff_t m_bIsScoped = 0x9974;
	constexpr ::std::ptrdiff_t m_bIsValveDS = 0x7C;
	constexpr ::std::ptrdiff_t m_bSpotted = 0x93D;
	constexpr ::std::ptrdiff_t m_bSpottedByMask = 0x980;
	constexpr ::std::ptrdiff_t m_bStartedArming = 0x3400;
	constexpr ::std::ptrdiff_t m_bUseCustomAutoExposureMax = 0x9D9;
	constexpr ::std::ptrdiff_t m_bUseCustomAutoExposureMin = 0x9D8;
	constexpr ::std::ptrdiff_t m_bUseCustomBloomScale = 0x9DA;
	constexpr ::std::ptrdiff_t m_clrRender = 0x70;
	constexpr ::std::ptrdiff_t m_dwBoneMatrix = 0x26A8;
	constexpr ::std::ptrdiff_t m_fAccuracyPenalty = 0x3340;
	constexpr ::std::ptrdiff_t m_fFlags = 0x104;
	constexpr ::std::ptrdiff_t m_flC4Blow = 0x29A0;
	constexpr ::std::ptrdiff_t m_flCustomAutoExposureMax = 0x9E0;
	constexpr ::std::ptrdiff_t m_flCustomAutoExposureMin = 0x9DC;
	constexpr ::std::ptrdiff_t m_flCustomBloomScale = 0x9E4;
	constexpr ::std::ptrdiff_t m_flDefuseCountDown = 0x29BC;
	constexpr ::std::ptrdiff_t m_flDefuseLength = 0x29B8;
	constexpr ::std::ptrdiff_t m_flFallbackWear = 0x31E0;
	constexpr ::std::ptrdiff_t m_flFlashDuration = 0x10470;
	constexpr ::std::ptrdiff_t m_flFlashMaxAlpha = 0x1046C;
	constexpr ::std::ptrdiff_t m_flLastBoneSetupTime = 0x2928;
	constexpr ::std::ptrdiff_t m_flLowerBodyYawTarget = 0x9ADC;
	constexpr ::std::ptrdiff_t m_flNextAttack = 0x2D80;
	constexpr ::std::ptrdiff_t m_flNextPrimaryAttack = 0x3248;
	constexpr ::std::ptrdiff_t m_flSimulationTime = 0x268;
	constexpr ::std::ptrdiff_t m_flTimerLength = 0x29A4;
	constexpr ::std::ptrdiff_t m_hActiveWeapon = 0x2F08;
	constexpr ::std::ptrdiff_t m_hBombDefuser = 0x29C4;
	constexpr ::std::ptrdiff_t m_hMyWeapons = 0x2E08;
	constexpr ::std::ptrdiff_t m_hObserverTarget = 0x339C;
	constexpr ::std::ptrdiff_t m_hOwner = 0x29DC;
	constexpr ::std::ptrdiff_t m_hOwnerEntity = 0x14C;
	constexpr ::std::ptrdiff_t m_hViewModel = 0x3308;
	constexpr ::std::ptrdiff_t m_iAccountID = 0x2FD8;
	constexpr ::std::ptrdiff_t m_iClip1 = 0x3274;
	constexpr ::std::ptrdiff_t m_iCompetitiveRanking = 0x1A84;
	constexpr ::std::ptrdiff_t m_iCompetitiveWins = 0x1B88;
	constexpr ::std::ptrdiff_t m_iCrosshairId = 0x11838;
	constexpr ::std::ptrdiff_t m_iDefaultFOV = 0x333C;
	constexpr ::std::ptrdiff_t m_iEntityQuality = 0x2FBC;
	constexpr ::std::ptrdiff_t m_iFOV = 0x31F4;
	constexpr ::std::ptrdiff_t m_iFOVStart = 0x31F8;
	constexpr ::std::ptrdiff_t m_iGlowIndex = 0x10488;
	constexpr ::std::ptrdiff_t m_iHealth = 0x100;
	constexpr ::std::ptrdiff_t m_iItemDefinitionIndex = 0x2FBA;
	constexpr ::std::ptrdiff_t m_iItemIDHigh = 0x2FD0;
	constexpr ::std::ptrdiff_t m_iMostRecentModelBoneCounter = 0x2690;
	constexpr ::std::ptrdiff_t m_iObserverMode = 0x3388;
	constexpr ::std::ptrdiff_t m_iShotsFired = 0x103E0;
	constexpr ::std::ptrdiff_t m_iState = 0x3268;
	constexpr ::std::ptrdiff_t m_iTeamNum = 0xF4;
	constexpr ::std::ptrdiff_t m_lifeState = 0x25F;
	constexpr ::std::ptrdiff_t m_nBombSite = 0x2994;
	constexpr ::std::ptrdiff_t m_nFallbackPaintKit = 0x31D8;
	constexpr ::std::ptrdiff_t m_nFallbackSeed = 0x31DC;
	constexpr ::std::ptrdiff_t m_nFallbackStatTrak = 0x31E4;
	constexpr ::std::ptrdiff_t m_nForceBone = 0x268C;
	constexpr ::std::ptrdiff_t m_nModelIndex = 0x258;
	constexpr ::std::ptrdiff_t m_nTickBase = 0x3440;
	constexpr ::std::ptrdiff_t m_nViewModelIndex = 0x29D0;
	constexpr ::std::ptrdiff_t m_rgflCoordinateFrame = 0x444;
	constexpr ::std::ptrdiff_t m_szCustomName = 0x304C;
	constexpr ::std::ptrdiff_t m_szLastPlaceName = 0x35C4;
	constexpr ::std::ptrdiff_t m_thirdPersonViewAngles = 0x31E8;
	constexpr ::std::ptrdiff_t m_vecOrigin = 0x138;
	constexpr ::std::ptrdiff_t m_vecVelocity = 0x114;
	constexpr ::std::ptrdiff_t m_vecViewOffset = 0x108;
	constexpr ::std::ptrdiff_t m_viewPunchAngle = 0x3030;
	constexpr ::std::ptrdiff_t m_zoomLevel = 0x33E0;
	constexpr ::std::ptrdiff_t anim_overlays = 0x2990;
	constexpr ::std::ptrdiff_t clientstate_choked_commands = 0x4D30;
	constexpr ::std::ptrdiff_t clientstate_delta_ticks = 0x174;
	constexpr ::std::ptrdiff_t clientstate_last_outgoing_command = 0x4D2C;
	constexpr ::std::ptrdiff_t clientstate_net_channel = 0x9C;
	constexpr ::std::ptrdiff_t convar_name_hash_table = 0x301A0;
	constexpr ::std::ptrdiff_t dwClientState = 0x59F19C;
	constexpr ::std::ptrdiff_t dwClientState_GetLocalPlayer = 0x180;
	constexpr ::std::ptrdiff_t dwClientState_IsHLTV = 0x4D48;
	constexpr ::std::ptrdiff_t dwClientState_Map = 0x28C;
	constexpr ::std::ptrdiff_t dwClientState_MapDirectory = 0x188;
	constexpr ::std::ptrdiff_t dwClientState_MaxPlayer = 0x388;
	constexpr ::std::ptrdiff_t dwClientState_PlayerInfo = 0x52C0;
	constexpr ::std::ptrdiff_t dwClientState_State = 0x108;
	constexpr ::std::ptrdiff_t dwClientState_ViewAngles = 0x4D90;
	constexpr ::std::ptrdiff_t dwEntityList = 0x4DFEF0C;
	constexpr ::std::ptrdiff_t dwForceAttack = 0x322CD48;
	constexpr ::std::ptrdiff_t dwForceAttack2 = 0x322CD54;
	constexpr ::std::ptrdiff_t dwForceBackward = 0x322CD9C;
	constexpr ::std::ptrdiff_t dwForceForward = 0x322CD90;
	constexpr ::std::ptrdiff_t dwForceJump = 0x52BAC68;
	constexpr ::std::ptrdiff_t dwForceLeft = 0x322CDA8;
	constexpr ::std::ptrdiff_t dwForceRight = 0x322CDB4;
	constexpr ::std::ptrdiff_t dwGameDir = 0x63AD80;
	constexpr ::std::ptrdiff_t dwGameRulesProxy = 0x532E474;
	constexpr ::std::ptrdiff_t dwGetAllClasses = 0xE0AF84;
	constexpr ::std::ptrdiff_t dwGlobalVars = 0x59EE60;
	constexpr ::std::ptrdiff_t dwGlowObjectManager = 0x5359988;
	constexpr ::std::ptrdiff_t dwInput = 0x525C4E0;
	constexpr ::std::ptrdiff_t dwInterfaceLinkList = 0x99A804;
	constexpr ::std::ptrdiff_t dwLocalPlayer = 0xDE997C;
	constexpr ::std::ptrdiff_t dwMouseEnable = 0x5238140;
	constexpr ::std::ptrdiff_t dwMouseEnablePtr = 0x5238110;
	constexpr ::std::ptrdiff_t dwPlayerResource = 0x322B0B0;
	constexpr ::std::ptrdiff_t dwRadarBase = 0x52359E4;
	constexpr ::std::ptrdiff_t dwSensitivity = 0xDEDB98;
	constexpr ::std::ptrdiff_t dwSensitivityPtr = 0xDEDB98;
	constexpr ::std::ptrdiff_t dwSetClanTag = 0x8DA80;
	constexpr ::std::ptrdiff_t dwViewMatrix = 0x4DEFD54;
	constexpr ::std::ptrdiff_t dwWeaponTable = 0x525D5BC;
	constexpr ::std::ptrdiff_t dwWeaponTableIndex = 0x326C;
	constexpr ::std::ptrdiff_t dwYawPtr = 0xDED928;
	constexpr ::std::ptrdiff_t dwZoomSensitivityRatioPtr = 0xDF3398;
	constexpr ::std::ptrdiff_t dwbSendPackets = 0xDD2B2;
	constexpr ::std::ptrdiff_t dwppDirect3DDevice9 = 0xA62C0;
	constexpr ::std::ptrdiff_t find_hud_element = 0x304AF630;
	constexpr ::std::ptrdiff_t force_update_spectator_glow = 0x3D8BEA;
	constexpr ::std::ptrdiff_t interface_engine_cvar = 0x3FA9C;
	constexpr ::std::ptrdiff_t is_c4_owner = 0x3E63F0;
	constexpr ::std::ptrdiff_t m_bDormant = 0xED;
	constexpr ::std::ptrdiff_t m_bIsLocalPlayer = 0x3628;
	constexpr ::std::ptrdiff_t m_flSpawnTime = 0x103C0;
	constexpr ::std::ptrdiff_t m_pStudioHdr = 0x2950;
	constexpr ::std::ptrdiff_t m_pitchClassPtr = 0x5238038;
	constexpr ::std::ptrdiff_t m_yawClassPtr = 0xDED928;
	constexpr ::std::ptrdiff_t model_ambient_min = 0x5A1194;
	constexpr ::std::ptrdiff_t set_abs_angles = 0x1E6D00;
	constexpr ::std::ptrdiff_t set_abs_origin = 0x1E6B40;
}

constexpr Vector3 CalculateAngle(
	const Vector3& localPosition,
	const Vector3& enemyPosition,
	const Vector3& viewAngles) noexcept
{
	return ((enemyPosition - localPosition).ToAngle() - viewAngles);
}

void SetConsoleColor(WORD color) {
	HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleTextAttribute(hConsole, color);
}

void RotationAnimation(const std::string& text, int repeat, int delay) {
	const std::vector<std::string> rotationChars = { "-", "\\", "|", "/" };

	for (int r = 0; r < repeat; ++r) {
		for (const auto& ch : rotationChars) {
			std::cout << "\r" << ch << " " << text << std::flush;
			std::this_thread::sleep_for(std::chrono::microseconds(delay));
		}
	}
}





void consoleInput() {
	while (true) {
		std::string input;
		SetConsoleColor(GREEN);
		std::cout << "Enter command (smooth, fov, aimbot, glow): ";
		SetConsoleColor(CYAN);
		std::getline(std::cin, input);

		if (input == "smooth") {
			SetConsoleColor(DARKBLUE);
			std::cout << "Enter new smooth value: ";
			SetConsoleColor(DARKCYAN);
			float newSmooth;
			std::cin >> newSmooth;
			smooth.store(newSmooth);
			std::cin.ignore();
		}
		else if (input == "fov") {
			SetConsoleColor(YELLOW);
			std::cout << "Enter new fov value: ";
			SetConsoleColor(RED);
			float newFov;
			std::cin >> newFov;
			fov.store(newFov);
			std::cin.ignore();
		}
		else if (input == "aimbot") {
			aimbotEnabled.store(!aimbotEnabled.load());
			SetConsoleColor(CYAN);
			std::cout << "Aimbot " << (aimbotEnabled.load() ? "enabled" : "disabled") << std::endl;
			SetConsoleColor(GRAY);
		}
		else if (input == "glow") {
			glowEnabled.store(!glowEnabled.load());
			SetConsoleColor(DARKBLUE);
			std::cout << "Glow " << (glowEnabled.load() ? "enabled" : "disabled") << std::endl;
			SetConsoleColor(DARKGREEN);
		}
		else {
			SetConsoleColor(MAGENTA);
			std::cout << "Invalid command." << std::endl;
			SetConsoleColor(MAGENTA);
		}
	}
}

void Aimbot(Memory& memory, uintptr_t client_dll, uintptr_t engine_dll) {
	// module addresses
	const auto client = memory.GetModuleAddress("client.dll");
	const auto engine = memory.GetModuleAddress("engine.dll");

	// deathmatch mode
	bool deathmatchMode = false;

	// infinite hack loop
	while (true) {
		if (aimbotEnabled.load()) {
					
			// toggle deathmatch mode
			if (GetAsyncKeyState(VK_F6))
			{
				deathmatchMode = !deathmatchMode;
				std::this_thread::sleep_for(std::chrono::milliseconds(700)); // debounce delay
			}

			// aimbot key
			if (!GetAsyncKeyState(VK_LBUTTON))
				continue;

			// get local player
			const auto localPlayer = memory.Read<std::uintptr_t>(client + offset::dwLocalPlayer);
			const auto localTeam = memory.Read<std::int32_t>(localPlayer + offset::m_iTeamNum);

			// eye position = origin + viewOffset
			const auto localEyePosition = memory.Read<Vector3>(localPlayer + offset::m_vecOrigin) +
				memory.Read<Vector3>(localPlayer + offset::m_vecViewOffset);

			const auto clientState = memory.Read<std::uintptr_t>(engine + offset::dwClientState);

			const auto localPlayerId =
				memory.Read<std::int32_t>(clientState + offset::dwClientState_GetLocalPlayer);

			const auto viewAngles = memory.Read<Vector3>(clientState + offset::dwClientState_ViewAngles);
			const auto aimPunch = memory.Read<Vector3>(localPlayer + offset::m_aimPunchAngle) * 2;

			// aimbot fov
			auto bestFov = fov.load(); // Загрузка текущего значения FOV
			auto bestAngle = Vector3{};
			int bestBone = -1; // Initialize to an invalid value

			for (auto i = 1; i <= 32; ++i)
			{
				const auto player = memory.Read<std::uintptr_t>(client + offset::dwEntityList + i * 0x10);

				if (!deathmatchMode && memory.Read<std::int32_t>(player + offset::m_iTeamNum) == localTeam)
					continue;

				if (memory.Read<bool>(player + offset::m_bDormant))
					continue;

				if (memory.Read<std::int32_t>(player + offset::m_lifeState))
					continue;

				if (memory.Read<std::int32_t>(player + offset::m_bSpottedByMask) & (1 << localPlayerId))
				{
					const auto boneMatrix = memory.Read<std::uintptr_t>(player + offset::m_dwBoneMatrix);
					std::vector<int> bones = { 0, 3, 4, 5, 6, 7, 8 };

					// Iterate over all bones
					for (auto j : bones) {
						// pos of player bone j in 3d space
						const auto playerBonePosition = Vector3{
							memory.Read<float>(boneMatrix + 0x30 * j + 0x0C),
							memory.Read<float>(boneMatrix + 0x30 * j + 0x1C),
							memory.Read<float>(boneMatrix + 0x30 * j + 0x2C)
						};

						const auto angle = CalculateAngle(
							localEyePosition,
							playerBonePosition,
							viewAngles + aimPunch);

						const auto fov = std::hypot(angle.x, angle.y);

						if (fov < bestFov)
						{
							bestFov = fov;
							bestAngle = angle;
							bestBone = j; // Update the best bone
						}
					}
				}
			}

			// if we have a best angle, do aimbot
			if (!bestAngle.IsZero()) {
				std::unique_lock<std::mutex> lock(mtx);
				memory.Write<Vector3>(clientState + offset::dwClientState_ViewAngles, viewAngles + bestAngle / smooth.load()); // Использование текущего значения smooth
			}
		}
		else {
			std::this_thread::sleep_for(std::chrono::microseconds(1)); // Если Aimbot выключен, добавьте небольшую задержку
		}
	}
}



void triggerbot(Memory& memory, uintptr_t client_dll, uintptr_t engine_dll)
{	bool deathmatchMode = false;

    const auto client = memory.GetModuleAddress("client.dll");
    const auto engine = memory.GetModuleAddress("engine.dll");


	while (true)
	{
		const auto localPlayer = memory.Read<std::uintptr_t>(client + offset::dwLocalPlayer);
		const auto localTeam = memory.Read<std::int32_t>(localPlayer + offset::m_iTeamNum);
		int crosshairID = memory.Read<std::uintptr_t>(localPlayer + offset::m_iCrosshairId);

		// activate triggerbot with Alt key
		if (GetAsyncKeyState(VK_XBUTTON2))
		{
			uintptr_t targetEntity = memory.Read<uintptr_t>(client_dll + offset::dwEntityList + (crosshairID - 1) * 0x10);

			if (targetEntity != NULL)
			{
				int targetHealth = memory.Read<int>(targetEntity + offset::m_iHealth);
				int targetTeam = memory.Read<int>(targetEntity + offset::m_iTeamNum);
				int localTeam = memory.Read<int>(localPlayer + offset::m_iTeamNum);

				if (deathmatchMode || targetTeam != localTeam)
				{
					if (targetHealth > 0)
					{
						memory.Write<std::uintptr_t>(client + offset::dwForceAttack, 6);
						std::this_thread::sleep_for(std::chrono::microseconds(1));
						memory.Write<std::uintptr_t>(client + offset::dwForceAttack, 4);
					}
				}
			}
		}
		if (GetAsyncKeyState(VK_F6))
		{
			deathmatchMode = !deathmatchMode;
			std::this_thread::sleep_for(std::chrono::milliseconds(700)); // debounce delay
		}
	}
}

void bunnyhop(Memory& memory, uintptr_t client_dll)
{
	while (true)
	{
		const auto client = memory.GetModuleAddress("client.dll");
		const auto localPlayer = memory.Read<std::uintptr_t>(client + offset::dwLocalPlayer);
		const int jumpFlag = 1 << 0;
		int flags = memory.Read<int>(localPlayer + offset::m_fFlags);
		bool on_ground = flags & jumpFlag;

		if (GetAsyncKeyState(VK_SPACE) && on_ground) {
			memory.Write<int>(client_dll + offset::dwForceJump, 6);
			std::this_thread::sleep_for(std::chrono::microseconds(1));
			memory.Write<int>(client_dll + offset::dwForceJump, 4);
		}
	}
}


		



// функция GlowESP
void GlowESP(Memory& memory) {
	const std::uintptr_t moduleBase = memory.GetModuleAddress("client.dll");

	const auto glowObjectManager = memory.Read<std::uintptr_t>(moduleBase + offset::dwGlowObjectManager);

	// deathmatch mode
	bool deathmatchMode = false;

	while (true) {
		// toggle deathmatch mode
		if (GetAsyncKeyState(VK_F6))
		{
			deathmatchMode = !deathmatchMode;
			std::this_thread::sleep_for(std::chrono::microseconds(1)); // debounce delay
		}

		const auto localPlayer = memory.Read<std::uintptr_t>(moduleBase + offset::dwLocalPlayer);
		for (int i = 1; i <= 64; ++i) {
			if (!glowEnabled.load()) {
				std::this_thread::sleep_for(std::chrono::milliseconds(700));
				continue; // Если GlowESP выключен, добавьте небольшую задержку и перейдите к следующей итерации
			}

			const int myTeam = memory.Read<int>(localPlayer + offset::m_iTeamNum);
			const auto entity = memory.Read<std::uintptr_t>(moduleBase + offset::dwEntityList + (i - 1) * 0x10);

			if (entity) {
				const int team = memory.Read<int>(entity + offset::m_iTeamNum);
				const int glowIndex = memory.Read<int>(entity + offset::m_iGlowIndex);
				const bool isSpotted = memory.Read<bool>(entity + offset::m_bSpotted);

				// Если игрок в другой команде (противник) или в режиме deathmatch
				if (team != myTeam || deathmatchMode) {
					GlowObjectDefinition glowObject = memory.Read<GlowObjectDefinition>(glowObjectManager + glowIndex * sizeof(GlowObjectDefinition));

					if (isSpotted) {
						glowObject.SetColor(0, 255, 0, 255); // Green
					}
					else {
						if (team == 2) { // Terrorists
							glowObject.SetColor(255, 0, 0, 255); // Red
						}
						else if (team == 3) { // Counter-Terrorists
							glowObject.SetColor(0, 0, 255, 255); // Blue
						}
					}

					glowObject.renderWhenOccluded = true;
					glowObject.renderWhenUnoccluded = false;
					glowObject.fullBloomRender = false;
					glowObject.style = 0;

					std::unique_lock<std::mutex> lock(mtx);
					memory.Write<GlowObjectDefinition>(glowObjectManager + glowIndex * sizeof(GlowObjectDefinition), glowObject);
				}
			}
		}

		std::this_thread::sleep_for(std::chrono::microseconds(1)); // Небольшая задержка между итерациями
	}
}





int main() {
	Memory memory("csgo.exe");

	SetConsoleColor(CYAN);
	RotationAnimation("Cheat for Amirchik<3", 8, 100);
	SetConsoleColor(WHITE);

	// Check if the csgo.exe process is found
	if (memory.GetProcessId() == 0) {
		std::cerr << "CS:GO process not found!" << std::endl;
		return 1;
	}

	// Get module addresses
	const auto client = memory.GetModuleAddress("client.dll");
	const auto engine = memory.GetModuleAddress("engine.dll");
	

	std::thread consoleThread(consoleInput);

	std::thread glowThread([&]() {
		while (true) {
			GlowESP(memory);
		}
		});

	std::thread aimbotThread([&]() {
		while (true) {
			Aimbot(memory, client, engine);
		}
		});

	std::thread bunnyhopThread([&]() {
		while (true) {
			bunnyhop(memory, client);
		}
		});

	std::thread triggerbotThread([&]() {
		while (true) {
			triggerbot(memory, client, engine);
		}
		});

	// Дождитесь завершения работы потоков (хотя они никогда не завершатся из-за бесконечных циклов)
	consoleThread.join();
	glowThread.join();
	aimbotThread.join();
	triggerbotThread.join();

	return 0;
}