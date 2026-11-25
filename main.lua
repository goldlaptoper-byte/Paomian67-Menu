-- =====================================================================
-- 泡面67 MENU | 完整繁體中文版 - 第 1 段 (核心狀態 + 主視窗 UI + 造型解鎖模組)
-- =====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
local MENU_FONT = Enum.Font.Arcade
local QueueTeleport = queue_on_teleport or queueteleport

local function num(v, fallback)
	local n = tonumber(v)
	if n == nil or n ~= n or n == math.huge or n == -math.huge then
		return fallback or 0
	end
	return n
end

local GUI_NAME = "PaoMian67_FullMenu"
if PlayerGui:FindFirstChild(GUI_NAME) then
	PlayerGui[GUI_NAME]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local THEME = {
	BgDark      = Color3.fromRGB(16, 17, 23),
	BgGradTop   = Color3.fromRGB(25, 27, 38),
	BgGradBot   = Color3.fromRGB(13, 14, 20),
	HeaderBg    = Color3.fromRGB(22, 24, 34),
	TabBg       = Color3.fromRGB(20, 22, 30),
	CardBg      = Color3.fromRGB(28, 30, 42),
	AccentCyan  = Color3.fromRGB(0, 220, 255),
	AccentBlue  = Color3.fromRGB(88, 101, 242),
	AccentPink  = Color3.fromRGB(236, 72, 153),
	OnGreen     = Color3.fromRGB(34, 197, 94),
	OffGray     = Color3.fromRGB(52, 55, 72),
	TextMain    = Color3.fromRGB(245, 247, 255),
	TextSub     = Color3.fromRGB(165, 172, 195),
	StrokeColor = Color3.fromRGB(55, 60, 82),
}

local OrigLighting = {
	Brightness = num(Lighting.Brightness, 2),
	ClockTime = num(Lighting.ClockTime, 14),
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	GlobalShadows = Lighting.GlobalShadows,
	FogColor = Lighting.FogColor,
	FogEnd = num(Lighting.FogEnd, 100000),
	ExposureCompensation = num(Lighting.ExposureCompensation, 0),
}
local OrigGravity = num(workspace.Gravity, 196.2)
local OrigFOV = num(Camera.FieldOfView, 70)
local OrigCamType = Camera.CameraType
local OrigCamMinZoom = num(LocalPlayer.CameraMinZoomDistance, 0.5)
local OrigCamMaxZoom = num(LocalPlayer.CameraMaxZoomDistance, 400)

-- 全域狀態表：戰鬥預設全關 (false)，避免一進來就自動開一堆功能
local S = {
	isMinimized = false,
	uiScale = (num(Camera.ViewportSize.X, 1280) < 760 or num(Camera.ViewportSize.Y, 720) < 460) and 0.9 or 1.0,
	currentTab = "Combat",
	expandedSize = UDim2.fromOffset(540, 325),
	minimizedSize = UDim2.fromOffset(540, 38),
	totalDamage = 0,
	comboCount = 0,
	lastComboTime = 0,
	isLeftDown = false,
	isRightDown = false,
	lastAttackTime = 0,
	lastDashTime = 0,
	crosshairPulse = 0,

	-- 1. 戰鬥（預設全部關閉）
	RealisticAim = false,
	AutoAim = false,
	FPMouseFix = false,
	TargetNPC = false,
	HeadPriority = false,
	ClosestPriority = false,
	LowestHpPriority = false,
	VisibleOnly = false,
	WallbangAim = false,
	BulletPenetration = false,
	SmoothBoost = false,
	aimTrackSpeed = 6.5,
	ShowFOVRing = false,
	FOVRadius = 180,
	CenterDot = false,
	LockDot = false,
	DynamicCross = false,
	HitFX = false,
	HitSound = false,
	HeadshotPing = false,
	KillSound = false,
	ComboHUD = false,
	TargetHUD = false,
	DistMeter = false,
	SilentAim = false,
	Manipulation = false,
	ClosestPart = false,
	VisualizeAim = false,
	SilentFOVRadius = 1000,
	HitChance = 100,
	IgnoreProtected = false,
	IgnoreKatanaDeflect = false,
	DisableOnFlash = false,
	LimitDistance = false,
	MaxAimDistance = 500,
	ReactionTimeMs = 0,
	ForgetTimeSec = 1.5,
	TargetPart = "Head",
	PartBlacklist = { LeftFoot = true, LeftLowerLeg = true },
	Triggerbot = false,
	TriggerOffsetMs = 0,
	ShootDelayMs = 0,
	TriggerMaxDist = 500,
	NoDelayBetweenTargets = false,
	CheckScopedWeapons = { Sniper = true, Crossbow = true },
	NoSpread = false,
	FullAuto = false,
	AlwaysBackstab = false,
	ExplodeOnThrow = false,
	RemoveGrenade = false,
	Ragebot = false,
	VoidSpan = false,
	ShootAttempts = 2,
	AttackMode = "Gun",
	PreferredWeapon = "Auto",

	-- 2. 移動
	WalkSpeedEnabled = false,
	WalkSpeedValue = 50,
	AutoSprint = false,
	TapTP = false,
	QuickDash = false,
	BlinkDistance = 12,
	AirWalk = false,
	DoubleAirPad = false,
	SuperJump = false,
	InfJump = false,
	AutoHop = false,
	IceSkate = false,
	FastFall = false,
	LowGravity = false,
	FeatherGravity = false,
	Noclip = false,
	DevFly = false,
	FlySpeedMultiplier = 1,
	BaseFlySpeed = 65,
	SavedCFrame = nil,
	SpawnCFrame = nil,
	LastDeathCFrame = nil,
	VelocityEnabled = false,
	VelocitySpeed = 80,
	SlideBoostEnabled = false,
	SlideBoostMult = 1.9,
	DoubleJumpHeightEnabled = false,
	DoubleJumpMult = 1.5,
	MaulSlamMult = 1.0,
	InfiniteDoubleJump = false,
	ThirdPerson = false,
	AntiAim = false,
	PitchMode = "Down",
	ExtendedRandom = false,
	YawMode = "Spin",
	CustomYawAngle = 0,
	Underground = false,
	AnimPlayerEnabled = false,
	SelectedAnimation = "The Worm",
	CustomAnimationId = "",
	AnimSpeed = 1.0,
	AnimStartPct = 0,
	AnimEndPct = 100,

	-- 3. 視覺 & 造型外觀
	BoxESP = false,
	Snaplines = false,
	EnemyHPTag = false,
	ESP = false,
	Box3D = false,
	StretchedRes = false,
	StretchRatioY = 0.75,
	Freecam = false,
	freecamCF = CFrame.new(),
	freecamRot = Vector2.new(),
	FOV110 = false,
	FarCam = false,
	GhostGun = false,
	Fullbright = false,
	UltraFB = false,
	ContrastFB = false,
	BlenderFX = false,
	BlenderDOF = false,
	CharTrail = false,
	TrailRGB = false,
	FootAura = false,
	SpinCrosshair = false,
	RGBCrosshair = false,
	MCFont = false,
	WeatherMode = "Off",
	WeaponSkinIdx = 1,
	SkyboxIdx = 1,
	MovingRotation = false,
	RotationSpeed = 0.1,
	BoxFill = false,
	SkeletonESP = false,
	OutlineEnabled = false,
	OutlineThickness = 1,
	ShowName = false,
	NameRotation = 0,
	FontOverride = false,
	ShowWeapon = false,
	WeaponRotation = 0,
	ShowDistance = false,
	DistanceRotation = 0,
	Healthbar = false,
	ResizeOutline = false,
	MovingHealthbar = false,
	HealthbarType = "Gradient",
	Slices = 1,
	HealthbarSpeed = 1,
	HealthLerp = 0.05,
	OverrideAppearance = false,
	OverrideColor = Color3.fromRGB(0, 220, 255),
	OverrideMaterial = "Neon",
	OverrideTransparency = 0,
	HighlightEnabled = false,
	IncludeTeammates = false,
	BoundingMode = "Dynamic",
	CustomFontName = "Proggy Tiny",
	NameType = "Name",
	ViewmodelOverride = false,
	CosmeticsChangerEnabled = false,
	SkinUnlockEnabled = false,
	SaveCosmeticJSON = true,
	SwayTiltBobbing = false,
	OverrideFPS = false,
	RecoilPercent = 0,
	ChamsEnabled = false,
	ChamsTransparency = 0.25,
	ChamsThroughWalls = false,
	ViewmodelOffset = Vector3.new(0, 0, 0),
	CustomTracers = false,
	TracerStyle = "Zigzag",
	TracerHoldTime = 1,
	TracerFadeTime = 1,
	TracerSize = 0.2,
	TracerGlow = 5,
	TracerSpeed = 2,
	CrosshairEnabled = false,
	HitEffectsEnabled = false,
	WeldToPlayer = false,
	HitEffectType = "Cyclone",
	CycleTextColors = false,
	PreferredMaterial = "ForceField",
	DisableHitMarker = false,
	DisableDamageNumbers = false,
	TargetHUDEnabled = false,
	IndicatorsEnabled = false,
	ManipulatedIndicator = false,
	RagebotStyle = false,
	AmmoDisplay = false,
	AmmoStyle = "Ammo, Max Ammo, Reserve",
	IndicatorLerp = 0.25,
	IndicatorOffsetX = 0,
	IndicatorOffsetY = 25,
	IndicatorFont = "Proggy Tiny",

	-- 4. 光影
	ShaderPresetIndex = 1,
	ShaderBoost = false,
	BrightBoost = false,
	VividColor = false,
	TimeCycle = false,
	ColorCorrection = false,
	Saturation = 0,
	Contrast = 0,
	Brightness = 0,
	AtmosphereEnabled = false,
	SkyboxSelection = "Red Dusk",
	WeatherEnabled = false,
	AmbienceSun = true,
	AmbienceMoon = true,
	AmbientColor = Color3.fromRGB(128, 128, 128),
	ColorShiftBottom = Color3.fromRGB(0, 0, 0),
	ColorShiftTop = Color3.fromRGB(0, 0, 0),
	FogColor = Color3.fromRGB(191, 191, 191),
	FogEnd = 100000,
	FogStart = 0,
	ExposureCompensation = 0,
	ClockTime = 14,
	GlobalShadows = true,
	BloomEnabled = false,
	BloomIntensity = 1,
	BloomSize = 24,
	BloomThreshold = 0.9,
	SunRaysEnabled = false,
	AntiFlashbang = false,
	FOVChanger = false,
	CustomFOV = 90,
	AspectRatioX = 1,
	AspectRatioY = 1,
	BlurAmount = 0,

	-- 5. 防卡
	ClearParticles = false,
	NoFog = false,
	SimpleMaterial = false,
	NoTerrainDeco = false,
	NoAmbientOcclusion = false,
	LowVisualRate = false,
	Cap60FPS = false,
	MuteOtherFX = false,
	UltraAntiLag = false,

	-- 6. 娛樂
	FakeTargetInput = "",
	disguiseActive = false,
	disguiseTargetName = "",
	disguiseTargetUserId = nil,
	FakeNameplateRGB = false,
	GiantVisual = false,
	MiniVisual = false,
	BounceDance = false,
	SwayDance = false,
	CamShake = false,

	-- 7. 雜項
	RGBUI = false,
	PanelAlpha = false,
	FPSBoost = false,
	AntiAFK = false,
	SpinChar = false,
	AutoBackOnDeath = false,
	RGBChar = false,
	DiscordInvite = "https://discord.gg/VcMbq6qdW",
	AutoLoad = false,
	SilentMode = false,
	AutoQueue = false,
	QueueMode = "Ranked 1v1",
	AutoSelectLoadout = false,
	Loadout = { Primary = "Shotgun", Secondary = "Revolver", Melee = "Maul", Utility = "Medkit" },
	LocalNameSpoof = "",
	OtherNameSpoof = "",
	AutoGrabDrops = false,
	AutoRespawn = false,
	ChatSpam = false,
	ChatSpamMode = "Custom",
	ChatSpamMessages = { "泡面67 MENU 啟動中！", "gg wp!" },
	NotifyHit = false,
	NotifyDuration = 1.0,
	RandomNotifyText = false,
	CustomNotifyText = "擊中 {NAME} 造成 {DMG} 傷害 ({PART} / {WEA})",

	-- 8. 版面與設定
	LayoutPreset = "Center",
	HideStatusBar = false,
	HideAimUI = false,
	MenuBind = Enum.KeyCode.RightShift,
	KeybindMenuEnabled = true,
	MenuTransparency = 0.08,
	KeybindMenuMode = "Active",
	NotificationsEnabled = true,
	ThemeName = "泡面67 Cyan",
	Configs = {},
	CurrentConfigName = "default",
	AutoLoadConfigName = "67",
	CommunityConfigs = { "[LEGIT] Ren's Config", "[RAGE] Paomian67 Preset" },
}

-- 造型解鎖與外觀同步模組（強化安全等待、防重複掛載、跨場接續、即時刷新）
local SkinUnlock = {
	Started = false,
	HookedNamecall = false,
	HookedClient = false,
	Equipped = {},
	Favorites = {},
	ConstructingWeapon = nil,
	ViewingProfile = nil,
	LastUsedWeapon = nil,
	SaveDir = "unlockall",
	SaveFile = "unlockall/config.json",
	Modules = {},
}

local function waitForPath(parent, name, timeout, step)
	if not parent then return nil end
	local found = parent:FindFirstChild(name)
	if found then return found end
	local elapsed = 0
	local dt = step or 0.3
	local limit = timeout or 15
	while elapsed < limit do
		task.wait(dt)
		elapsed += dt
		found = parent:FindFirstChild(name)
		if found then return found end
	end
	return parent:FindFirstChild(name)
end

function SkinUnlock:CloneCosmetic(name, cosmeticType, options)
	local cosLib = self.Modules.CosmeticLibrary
	if not cosLib or type(cosLib.Cosmetics) ~= "table" then return nil end
	local base = cosLib.Cosmetics[name]
	if type(base) ~= "table" then return nil end

	local data = {}
	for k, v in pairs(base) do
		data[k] = v
	end
	data.Name = name
	data.Type = data.Type or cosmeticType
	data.Seed = (options and tonumber(options.seed)) or math.random(1, 1000000)

	local enumLib = self.Modules.EnumLibrary
	if enumLib and type(enumLib.ToEnum) == "function" then
		pcall(function()
			local enumId = enumLib:ToEnum(name)
			if enumId then
				data.Enum = enumId
				data.ObjectID = enumId
			end
		end)
	end

	if type(options) == "table" then
		if options.inverted ~= nil then data.Inverted = options.inverted == true end
		if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly == true end
	end
	return data
end

function SkinUnlock:SaveConfig()
	if not S.SaveCosmeticJSON or not writefile then return end
	local payload = { equipped = {}, favorites = self.Favorites }
	for weapon, cosmetics in pairs(self.Equipped) do
		if type(cosmetics) == "table" then
			payload.equipped[weapon] = {}
			for cosmeticType, cosmeticData in pairs(cosmetics) do
				if type(cosmeticData) == "table" and cosmeticData.Name then
					payload.equipped[weapon][cosmeticType] = {
						name = cosmeticData.Name,
						seed = tonumber(cosmeticData.Seed) or math.random(1, 1000000),
						inverted = cosmeticData.Inverted == true,
						onlyUseFavorites = cosmeticData.OnlyUseFavorites == true,
					}
				end
			end
		end
	end

	task.spawn(function()
		pcall(function()
			if isfolder and makefolder and not isfolder(self.SaveDir) then
				makefolder(self.SaveDir)
			end
			writefile(self.SaveFile, HttpService:JSONEncode(payload))
		end)
	end)
end

function SkinUnlock:LoadConfig()
	if not readfile or not isfile then return end
	local exists = false
	pcall(function() exists = isfile(self.SaveFile) end)
	if not exists then return end

	pcall(function()
		local raw = readfile(self.SaveFile)
		local decoded = HttpService:JSONDecode(raw)
		if type(decoded) ~= "table" then return end

		self.Favorites = type(decoded.favorites) == "table" and decoded.favorites or {}
		self.Equipped = {}

		if type(decoded.equipped) == "table" then
			for weapon, cosmetics in pairs(decoded.equipped) do
				if type(cosmetics) == "table" then
					self.Equipped[weapon] = {}
					for cosmeticType, item in pairs(cosmetics) do
						if type(item) == "table" and item.name then
							local cloned = self:CloneCosmetic(item.name, cosmeticType, {
								seed = item.seed,
								inverted = item.inverted,
								favoritesOnly = item.onlyUseFavorites,
							})
							if cloned then
								self.Equipped[weapon][cosmeticType] = cloned
							end
						end
					end
				end
			end
		end
	end)
end

function SkinUnlock:RefreshActiveViewModels()
	local cam = workspace.CurrentCamera
	if cam then
		for _, child in ipairs(cam:GetChildren()) do
			if child:IsA("Model") then
				for _, desc in ipairs(child:GetDescendants()) do
					if desc:IsA("BasePart") then
						desc:SetAttribute("SkinSyncedAt", os.clock())
					end
				end
			end
		end
	end
	pcall(function()
		local dataCtrl = self.Modules.DataController
		if dataCtrl and dataCtrl.CurrentData and type(dataCtrl.CurrentData.Replicate) == "function" then
			dataCtrl.CurrentData:Replicate("WeaponInventory")
		end
	end)
end

function SkinUnlock:ApplyLibraryHooks()
	local cosLib = self.Modules.CosmeticLibrary
	local itemLib = self.Modules.ItemLibrary
	local dataCtrl = self.Modules.DataController
	local selfRef = self

	if type(cosLib) == "table" then
		cosLib.OwnsCosmeticNormally = function() return true end
		cosLib.OwnsCosmeticUniversally = function() return true end
		cosLib.OwnsCosmeticForSomething = function() return true end
		cosLib.OwnsCosmeticForWeapon = function() return true end

		if type(cosLib.OwnsCosmetic) == "function" then
			local origOwns = cosLib.OwnsCosmetic
			cosLib.OwnsCosmetic = function(libSelf, inventory, name, weapon)
				if type(name) == "string" and name:find("MISSING_") then
					return origOwns(libSelf, inventory, name, weapon)
				end
				return true
			end
		end
	end

	if type(dataCtrl) == "table" then
		dataCtrl.OwnsAllWeapons = function() return true end
		dataCtrl.GetUnlockedWeapons = function()
			local map = {}
			if itemLib and type(itemLib.Items) == "table" then
				for name in pairs(itemLib.Items) do
					if type(name) == "string" and not name:find("MISSING_") then
						map[name] = true
					end
				end
			end
			return map
		end

		if type(dataCtrl.Get) == "function" then
			local origGet = dataCtrl.Get
			dataCtrl.Get = function(ctrlSelf, key)
				local ok, data = pcall(origGet, ctrlSelf, key)
				local baseData = ok and data or nil
				if key == "CosmeticInventory" then
					return setmetatable({}, { __index = function() return true end })
				end
				if key == "FavoritedCosmetics" then
					local result = {}
					if type(baseData) == "table" then
						for k, v in pairs(baseData) do result[k] = v end
					end
					for weapon, favs in pairs(selfRef.Favorites) do
						if type(favs) == "table" then
							result[weapon] = result[weapon] or {}
							for name, isFav in pairs(favs) do result[weapon][name] = isFav end
						end
					end
					return result
				end
				return baseData
			end
		end

		if type(dataCtrl.GetWeaponData) == "function" then
			local origGetWeaponData = dataCtrl.GetWeaponData
			dataCtrl.GetWeaponData = function(ctrlSelf, weaponName)
				local merged = {
					Unlocked = true,
					Level = 100,
					XP = 99999,
				}
				local ok, origData = pcall(origGetWeaponData, ctrlSelf, weaponName)
				if ok and type(origData) == "table" then
					for k, v in pairs(origData) do
						merged[k] = v
					end
				end
				local eq = weaponName and selfRef.Equipped[weaponName]
				if type(eq) == "table" then
					for cosmeticType, cosmeticData in pairs(eq) do
						merged[cosmeticType] = cosmeticData
					end
				end
				return merged
			end
		end
	end

	if type(itemLib) == "table" and type(itemLib.GetViewModelImageFromWeaponData) == "function" then
		local origImg = itemLib.GetViewModelImageFromWeaponData
		itemLib.GetViewModelImageFromWeaponData = function(libSelf, weaponData, highRes)
			if type(weaponData) == "table" then
				local weaponName = weaponData.Name
				local eq = weaponName and selfRef.Equipped[weaponName]
				local shouldShow = (eq and eq.Skin and weaponData.Skin == eq.Skin)
					or (selfRef.ViewingProfile == LocalPlayer and eq and eq.Skin)
				if shouldShow and eq and eq.Skin and eq.Skin.Name and type(libSelf.ViewModels) == "table" then
					local info = libSelf.ViewModels[eq.Skin.Name]
					if type(info) == "table" then
						return info[highRes and "ImageHighResolution" or "Image"] or info.Image
					end
				end
			end
			return origImg(libSelf, weaponData, highRes)
		end
	end
end

function SkinUnlock:ApplyRemoteAndViewModelHooks()
	local selfRef = self
	local playerScripts = self.Modules.PlayerScripts
	local controllers = self.Modules.Controllers
	local fighterCtrl = nil

	if controllers then
		local fc = controllers:FindFirstChild("FighterController")
		if fc then pcall(function() fighterCtrl = require(fc) end) end
	end

	if not self.HookedNamecall and not _G.__PaoMian67_SkinNamecallHooked and hookmetamethod and getnamecallmethod then
		self.HookedNamecall = true
		_G.__PaoMian67_SkinNamecallHooked = true
		task.spawn(function()
			task.wait(0.5)
			local remotes = ReplicatedStorage:FindFirstChild("Remotes")
			if not remotes then return end
			local dataRemotes = remotes:FindFirstChild("Data")
			local repRemotes = remotes:FindFirstChild("Replication")
			local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
			local favRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
			local fighterRemotes = repRemotes and repRemotes:FindFirstChild("Fighter")
			local useItemRemote = fighterRemotes and fighterRemotes:FindFirstChild("UseItem")
			if not equipRemote then return end

			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", function(selfObj, ...)
				if getnamecallmethod() ~= "FireServer" then return oldNamecall(selfObj, ...) end
				local args = { ... }

				if useItemRemote and selfObj == useItemRemote and fighterCtrl then
					task.spawn(function()
						pcall(function()
							local fighter = fighterCtrl:GetFighter(LocalPlayer)
							if fighter and type(fighter.Items) == "table" then
								for _, item in pairs(fighter.Items) do
									if type(item.Get) == "function" and item:Get("ObjectID") == args[1] then
										selfRef.LastUsedWeapon = item.Name
										break
									end
								end
							end
						end)
					end)
				end

				if selfObj == equipRemote then
					local weaponName, cosmeticType, cosmeticName = args[1], args[2], args[3]
					local options = type(args[4]) == "table" and args[4] or {}
					if weaponName and cosmeticType then
						selfRef.Equipped[weaponName] = selfRef.Equipped[weaponName] or {}
						if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
							selfRef.Equipped[weaponName][cosmeticType] = nil
							if not next(selfRef.Equipped[weaponName]) then selfRef.Equipped[weaponName] = nil end
						else
							local cloned = selfRef:CloneCosmetic(cosmeticName, cosmeticType, {
								inverted = options.IsInverted,
								favoritesOnly = options.OnlyUseFavorites,
							})
							if cloned then selfRef.Equipped[weaponName][cosmeticType] = cloned end
						end
						selfRef:SaveConfig()
						task.spawn(function()
							task.wait(0.08)
							selfRef:RefreshActiveViewModels()
						end)
					end
					return
				end

				if favRemote and selfObj == favRemote then
					if args[1] and args[2] then
						selfRef.Favorites[args[1]] = selfRef.Favorites[args[1]] or {}
						selfRef.Favorites[args[1]][args[2]] = args[3] or nil
						selfRef:SaveConfig()
					end
					return
				end

				return oldNamecall(selfObj, ...)
			end)
		end)
	end

	if not self.HookedClient and not _G.__PaoMian67_SkinClientHooked and playerScripts then
		self.HookedClient = true
		_G.__PaoMian67_SkinClientHooked = true
		task.spawn(function()
			task.wait(1.5)
			pcall(function()
				local clientItemPath = playerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem
				local ClientItem = require(clientItemPath)
				if type(ClientItem._CreateViewModel) == "function" then
					local orig = ClientItem._CreateViewModel
					ClientItem._CreateViewModel = function(itemSelf, viewmodelRef)
						local weaponName = itemSelf.Name
						local weaponPlayer = itemSelf.ClientFighter and itemSelf.ClientFighter.Player
						selfRef.ConstructingWeapon = (weaponPlayer == LocalPlayer) and weaponName or nil
						local eq = weaponName and selfRef.Equipped[weaponName]
						if weaponPlayer == LocalPlayer and eq and eq.Skin and viewmodelRef and type(itemSelf.ToEnum) == "function" then
							pcall(function()
								local dataKey, skinKey, nameKey = itemSelf:ToEnum("Data"), itemSelf:ToEnum("Skin"), itemSelf:ToEnum("Name")
								if viewmodelRef[dataKey] then
									viewmodelRef[dataKey][skinKey] = eq.Skin
									viewmodelRef[dataKey][nameKey] = eq.Skin.Name
								elseif type(viewmodelRef.Data) == "table" then
									viewmodelRef.Data.Skin = eq.Skin
									viewmodelRef.Data.Name = eq.Skin.Name
								end
							end)
						end
						local result = orig(itemSelf, viewmodelRef)
						selfRef.ConstructingWeapon = nil
						return result
					end
				end

				local viewModelModule = clientItemPath:FindFirstChild("ClientViewModel")
				if viewModelModule then
					local ClientViewModel = require(viewModelModule)
					if type(ClientViewModel.GetWrap) == "function" then
						local orig = ClientViewModel.GetWrap
						ClientViewModel.GetWrap = function(vmSelf)
							local weaponName = vmSelf.ClientItem and vmSelf.ClientItem.Name
							local weaponPlayer = vmSelf.ClientItem and vmSelf.ClientItem.ClientFighter and vmSelf.ClientItem.ClientFighter.Player
							if weaponName and weaponPlayer == LocalPlayer and selfRef.Equipped[weaponName] and selfRef.Equipped[weaponName].Wrap then
								return selfRef.Equipped[weaponName].Wrap
							end
							return orig(vmSelf)
						end
					end

					if type(ClientViewModel.new) == "function" then
						local origNew = ClientViewModel.new
						ClientViewModel.new = function(replicatedData, clientItem)
							local weaponPlayer = clientItem and clientItem.ClientFighter and clientItem.ClientFighter.Player
							local weaponName = selfRef.ConstructingWeapon or (clientItem and clientItem.Name)
							local eq = weaponName and selfRef.Equipped[weaponName]
							if weaponPlayer == LocalPlayer and eq and type(replicatedData) == "table" then
								pcall(function()
									local repClassMod = ReplicatedStorage:FindFirstChild("Modules")
										and ReplicatedStorage.Modules:FindFirstChild("ReplicatedClass")
									if repClassMod then
										local ReplicatedClass = require(repClassMod)
										local dataKey = ReplicatedClass:ToEnum("Data")
										replicatedData[dataKey] = replicatedData[dataKey] or {}
										if eq.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = eq.Skin end
										if eq.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = eq.Wrap end
										if eq.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = eq.Charm end
									end
								end)
							end
							local result = origNew(replicatedData, clientItem)
							if weaponPlayer == LocalPlayer and eq and eq.Wrap and result and type(result._UpdateWrap) == "function" then
								task.spawn(function()
									pcall(function() result:_UpdateWrap() end)
									task.wait(0.1)
									if result and not result._destroyed then
										pcall(function() result:_UpdateWrap() end)
									end
								end)
							end
							return result
						end
					end
				end
			end)

			pcall(function()
				local ViewProfile = require(playerScripts.Modules.Pages.ViewProfile)
				if ViewProfile and type(ViewProfile.Fetch) == "function" then
					local orig = ViewProfile.Fetch
					ViewProfile.Fetch = function(vpSelf, targetPlayer)
						selfRef.ViewingProfile = targetPlayer
						return orig(vpSelf, targetPlayer)
					end
				end
			end)

			pcall(function()
				local ClientEntity = require(playerScripts.Modules.ClientReplicatedClasses.ClientEntity)
				if type(ClientEntity.ReplicateFromServer) == "function" then
					local orig = ClientEntity.ReplicateFromServer
					ClientEntity.ReplicateFromServer = function(entSelf, action, ...)
						if action == "FinisherEffect" then
							local args = { ... }
							local killerName = args[3]
							local decodedKiller = killerName
							local enumLib = selfRef.Modules.EnumLibrary
							if type(killerName) == "userdata" and enumLib and type(enumLib.FromEnum) == "function" then
								pcall(function() decodedKiller = enumLib:FromEnum(killerName) end)
							end
							local isOurKill = tostring(decodedKiller):lower() == LocalPlayer.Name:lower()
							if isOurKill and selfRef.LastUsedWeapon and selfRef.Equipped[selfRef.LastUsedWeapon] and selfRef.Equipped[selfRef.LastUsedWeapon].Finisher then
								local finisherData = selfRef.Equipped[selfRef.LastUsedWeapon].Finisher
								local finisherEnum = finisherData.Enum
								if not finisherEnum and enumLib and type(enumLib.ToEnum) == "function" then
									pcall(function() finisherEnum = enumLib:ToEnum(finisherData.Name) end)
								end
								if fEnum then
									args[1] = finisherEnum
									return orig(entSelf, action, table.unpack(args))
								end
							end
						end
						return orig(entSelf, action, ...)
					end
				end
			end)
		end)
	end
end

function SkinUnlock:Init()
	if self.Started then return end
	self.Started = true

	if QueueTeleport then
		pcall(function()
			QueueTeleport([[
				task.wait(1.5)
				if _G.PaoMian67_SkinUnlock and _G.PaoMian67_SkinUnlock.Init then
					_G.PaoMian67_SkinUnlock:Init()
				end
			]])
		end)
	end

	task.spawn(function()
		if not game:IsLoaded() then
			local loaded = false
			local conn = game.Loaded:Connect(function() loaded = true end)
			local t = 0
			while not loaded and t < 20 do
				task.wait(0.25)
				t += 0.25
			end
			if conn then conn:Disconnect() end
		end
		if not LocalPlayer.Character then
			pcall(function() LocalPlayer.CharacterAdded:Wait() end)
		end

		local playerScripts = waitForPath(LocalPlayer, "PlayerScripts", 20, 0.4)
		local controllers = waitForPath(playerScripts, "Controllers", 20, 0.4)
		local modules = waitForPath(ReplicatedStorage, "Modules", 20, 0.4)
		if not playerScripts or not controllers or not modules then return end

		self.Modules.PlayerScripts = playerScripts
		self.Modules.Controllers = controllers
		self.Modules.Modules = modules

		local cosObj = waitForPath(modules, "CosmeticLibrary", 12, 0.3)
		local itemObj = waitForPath(modules, "ItemLibrary", 12, 0.3)
		local dataObj = waitForPath(controllers, "PlayerDataController", 12, 0.3)
		local utilObj = modules:FindFirstChild("PlayerDataUtility")
		local enumObj = modules:FindFirstChild("EnumLibrary")
		if not cosObj or not itemObj or not dataObj then return end

		local okReq = pcall(function()
			self.Modules.CosmeticLibrary = require(cosObj)
			self.Modules.ItemLibrary = require(itemObj)
			self.Modules.DataController = require(dataObj)
			if utilObj then self.Modules.PlayerDataUtility = require(utilObj) end
			if enumObj then
				self.Modules.EnumLibrary = require(enumObj)
				if self.Modules.EnumLibrary and type(self.Modules.EnumLibrary.WaitForEnumBuilder) == "function" then
					task.spawn(function() pcall(function() self.Modules.EnumLibrary:WaitForEnumBuilder() end) end)
				end
			end
		end)
		if not okReq then return end

		self:ApplyLibraryHooks()
		self:LoadConfig()
		self:ApplyRemoteAndViewModelHooks()
		self:RefreshActiveViewModels()
	end)
end

_G.PaoMian67_SkinUnlock = SkinUnlock

-- 主視窗與 8 分頁建立
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.Size = S.expandedSize
MainFrame.BackgroundColor3 = THEME.BgDark
MainFrame.BackgroundTransparency = S.MenuTransparency
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainScale = Instance.new("UIScale")
MainScale.Scale = num(S.uiScale, 1)
MainScale.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new(THEME.BgGradTop, THEME.BgGradBot)
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.AccentCyan
MainStroke.Transparency = 0.35
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = THEME.HeaderBg
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local GlowLine = Instance.new("Frame")
GlowLine.Size = UDim2.new(1, 0, 0, 2)
GlowLine.Position = UDim2.new(0, 0, 1, -2)
GlowLine.BackgroundColor3 = THEME.AccentCyan
GlowLine.BorderSizePixel = 0
GlowLine.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -150, 1, 0)
TitleLabel.Position = UDim2.fromOffset(12, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "泡面67 MENU | DMG:0"
TitleLabel.TextColor3 = THEME.TextMain
TitleLabel.TextSize = 12
TitleLabel.Font = MENU_FONT
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local function refreshTitle()
	local dmg = num(S.totalDamage, 0)
	local combo = num(S.comboCount, 0)
	if S.ComboHUD and combo > 1 then
		TitleLabel.Text = string.format("泡面67 MENU | DMG:%d | %d連擊", dmg, combo)
	else
		TitleLabel.Text = string.format("泡面67 MENU | DMG:%d", dmg)
	end
end

local function makeHeaderBtn(text, offsetX, bgColor)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(26, 24)
	b.Position = UDim2.new(1, offsetX, 0.5, -12)
	b.BackgroundColor3 = bgColor
	b.Text = text
	b.TextColor3 = THEME.TextMain
	b.TextSize = 11
	b.Font = MENU_FONT
	b.AutoButtonColor = false
	b.Parent = TopBar
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local ScaleDownBtn = makeHeaderBtn("A-", -124, Color3.fromRGB(42, 46, 64))
local ScaleUpBtn   = makeHeaderBtn("A+", -94,  Color3.fromRGB(42, 46, 64))
local MinBtn       = makeHeaderBtn("-",  -64,  Color3.fromRGB(52, 58, 80))
local CloseBtn     = makeHeaderBtn("X",  -34,  Color3.fromRGB(195, 55, 65))

local function setScale(val)
	S.uiScale = math.clamp(math.floor(num(val, 1) * 100 + 0.5) / 100, 0.65, 1.45)
	TweenService:Create(MainScale, TweenInfo.new(0.15), { Scale = S.uiScale }):Play()
end
ScaleDownBtn.MouseButton1Click:Connect(function() setScale(S.uiScale - 0.1) end)
ScaleUpBtn.MouseButton1Click:Connect(function() setScale(S.uiScale + 0.1) end)

local function toggleMinimize()
	S.isMinimized = not S.isMinimized
	MinBtn.Text = S.isMinimized and "+" or "-"
	TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
		Size = S.isMinimized and S.minimizedSize or S.expandedSize
	}):Play()
end
MinBtn.MouseButton1Click:Connect(toggleMinimize)

local dragging, dragStart, frameStart = false, nil, nil
TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; frameStart = MainFrame.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Touch) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local TABS = {
	{ key = "Combat",  label = "戰鬥" },
	{ key = "Move",    label = "移動" },
	{ key = "Visual",  label = "視覺" },
	{ key = "Shader",  label = "光影" },
	{ key = "AntiLag", label = "防卡" },
	{ key = "Fun",     label = "娛樂" },
	{ key = "Misc",    label = "雜項" },
	{ key = "Layout",  label = "版面" },
}

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 30)
TabBar.Position = UDim2.fromOffset(8, 42)
TabBar.BackgroundColor3 = THEME.TabBg
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 7)

local TabGrid = Instance.new("UIGridLayout")
TabGrid.FillDirection = Enum.FillDirection.Horizontal
TabGrid.CellPadding = UDim2.fromOffset(2, 0)
TabGrid.CellSize = UDim2.new(1 / #TABS, -2, 1, 0)
TabGrid.SortOrder = Enum.SortOrder.LayoutOrder
TabGrid.Parent = TabBar

local Pages, TabBtns = {}, {}
for i, t in ipairs(TABS) do
	local btn = Instance.new("TextButton")
	btn.LayoutOrder = i
	btn.BackgroundColor3 = (t.key == S.currentTab) and THEME.AccentBlue or Color3.fromRGB(30, 33, 46)
	btn.Text = t.label
	btn.TextColor3 = (t.key == S.currentTab) and Color3.fromRGB(255, 255, 255) or THEME.TextSub
	btn.TextSize = 10
	btn.Font = MENU_FONT
	btn.AutoButtonColor = false
	btn.Parent = TabBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

	local page = Instance.new("ScrollingFrame")
	page.Name = t.key .. "Page"
	page.Size = UDim2.new(1, -14, 1, -100)
	page.Position = UDim2.fromOffset(7, 76)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.ScrollBarImageColor3 = THEME.AccentCyan
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.fromOffset(0, 0)
	page.Visible = (t.key == S.currentTab)
	page.Parent = MainFrame

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 5)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = page

	Pages[t.key] = page
	TabBtns[t.key] = btn

	btn.MouseButton1Click:Connect(function()
		S.currentTab = t.key
		for k, p in pairs(Pages) do
			p.Visible = (k == t.key)
			TabBtns[k].BackgroundColor3 = (k == t.key) and THEME.AccentBlue or Color3.fromRGB(30, 33, 46)
			TabBtns[k].TextColor3 = (k == t.key) and Color3.fromRGB(255, 255, 255) or THEME.TextSub
		end
	end)
end

local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 20)
StatusBar.Position = UDim2.new(0, 0, 1, -20)
StatusBar.BackgroundColor3 = THEME.HeaderBg
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 1, 0)
StatusLabel.Position = UDim2.fromOffset(10, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "FPS:60 | PING:0ms | 人數:1"
StatusLabel.TextColor3 = THEME.TextSub
StatusLabel.TextSize = 10
StatusLabel.Font = MENU_FONT
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

local ToggleSetters = {}

local function addToggle(page, labelText, stateKey, onChanged)
	local initial = S[stateKey] == true
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(1, -4, 0, 30)
	card.BackgroundColor3 = THEME.CardBg
	card.Text = ""
	card.AutoButtonColor = false
	card.Parent = page
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 7)

	local stroke = Instance.new("UIStroke")
	stroke.Color = initial and THEME.OnGreen or THEME.StrokeColor
	stroke.Thickness = 1
	stroke.Parent = card

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -66, 1, 0)
	lbl.Position = UDim2.fromOffset(10, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = initial and THEME.TextMain or THEME.TextSub
	lbl.TextSize = 11
	lbl.Font = MENU_FONT
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = card

	local pill = Instance.new("Frame")
	pill.Size = UDim2.fromOffset(42, 18)
	pill.Position = UDim2.new(1, -50, 0.5, -9)
	pill.BackgroundColor3 = initial and THEME.OnGreen or THEME.OffGray
	pill.BorderSizePixel = 0
	pill.Parent = card
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local pillTxt = Instance.new("TextLabel")
	pillTxt.Size = UDim2.fromScale(1, 1)
	pillTxt.BackgroundTransparency = 1
	pillTxt.Text = initial and "ON" or "OFF"
	pillTxt.TextColor3 = initial and Color3.fromRGB(255, 255, 255) or THEME.TextSub
	pillTxt.TextSize = 10
	pillTxt.Font = MENU_FONT
	pillTxt.Parent = pill

	local function setVal(v, fireCb)
		local b = v == true
		S[stateKey] = b
		pill.BackgroundColor3 = b and THEME.OnGreen or THEME.OffGray
		stroke.Color = b and THEME.OnGreen or THEME.StrokeColor
		lbl.TextColor3 = b and THEME.TextMain or THEME.TextSub
		pillTxt.Text = b and "ON" or "OFF"
		pillTxt.TextColor3 = b and Color3.fromRGB(255, 255, 255) or THEME.TextSub
		if fireCb ~= false and onChanged then onChanged(b) end
	end

	ToggleSetters[stateKey] = setVal
	card.MouseButton1Click:Connect(function() setVal(not S[stateKey], true) end)
	return card
end

local function addAction(page, labelText, bgColor, textColor, onClick)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 30)
	btn.BackgroundColor3 = bgColor or Color3.fromRGB(45, 54, 78)
	btn.Text = labelText
	btn.TextColor3 = textColor or THEME.TextMain
	btn.TextSize = 11
	btn.Font = MENU_FONT
	btn.AutoButtonColor = false
	btn.Parent = page
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
	btn.MouseButton1Click:Connect(function() if onClick then onClick(btn) end end)
	return btn
end

-- 造型解鎖開關與手動同步按鈕（預設關閉，點開才初始化）
addToggle(Pages.Visual, "造型解鎖與外觀同步 (Skin Unlock)", "SkinUnlockEnabled", function(on)
	if on then
		SkinUnlock:Init()
		SkinUnlock:RefreshActiveViewModels()
	end
end)
addAction(Pages.Visual, "立即同步已存造型與視角模型", nil, THEME.AccentCyan, function(btn)
	SkinUnlock:Init()
	SkinUnlock:LoadConfig()
	SkinUnlock:RefreshActiveViewModels()
	btn.Text = "已重新載入並同步造型!"
	task.wait(0.8)
	btn.Text = "立即同步已存造型與視角模型"
end)
-- =====================================================================
-- 泡面67 MENU | 完整繁體中文版 - 第 2 段 (第 1 分頁：戰鬥 Combat 完整邏輯)
-- =====================================================================
local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "PaoMian67_FOV"
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.fromScale(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.ZIndex = 7
FOVFrame.Parent = ScreenGui
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = THEME.AccentCyan
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.4
FOVStroke.Parent = FOVFrame

local CenterDot = Instance.new("Frame")
CenterDot.Name = "PaoMian67_CenterDot"
CenterDot.AnchorPoint = Vector2.new(0.5, 0.5)
CenterDot.Position = UDim2.fromScale(0.5, 0.5)
CenterDot.Size = UDim2.fromOffset(6, 6)
CenterDot.BackgroundColor3 = Color3.fromRGB(255, 70, 95)
CenterDot.BorderSizePixel = 0
CenterDot.ZIndex = 9
CenterDot.Parent = ScreenGui
Instance.new("UICorner", CenterDot).CornerRadius = UDim.new(1, 0)

local TargetHUDFrame = Instance.new("Frame")
TargetHUDFrame.Name = "PaoMian67_TargetHUD"
TargetHUDFrame.AnchorPoint = Vector2.new(0.5, 0)
TargetHUDFrame.Position = UDim2.new(0.5, 0, 0, 56)
TargetHUDFrame.Size = UDim2.fromOffset(220, 44)
TargetHUDFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
TargetHUDFrame.BackgroundTransparency = 0.25
TargetHUDFrame.Visible = false
TargetHUDFrame.ZIndex = 8
TargetHUDFrame.Parent = ScreenGui
Instance.new("UICorner", TargetHUDFrame).CornerRadius = UDim.new(0, 8)

local TargetStroke = Instance.new("UIStroke")
TargetStroke.Color = THEME.AccentCyan
TargetStroke.Thickness = 1
TargetStroke.Parent = TargetHUDFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -12, 0, 18)
TargetLabel.Position = UDim2.fromOffset(6, 4)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "目標：無"
TargetLabel.TextColor3 = THEME.TextMain
TargetLabel.TextSize = 10
TargetLabel.Font = MENU_FONT
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = TargetHUDFrame

local TargetHPBg = Instance.new("Frame")
TargetHPBg.Size = UDim2.new(1, -12, 0, 10)
TargetHPBg.Position = UDim2.fromOffset(6, 26)
TargetHPBg.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
TargetHPBg.BorderSizePixel = 0
TargetHPBg.Parent = TargetHUDFrame
Instance.new("UICorner", TargetHPBg).CornerRadius = UDim.new(1, 0)

local TargetHPFill = Instance.new("Frame")
TargetHPFill.Size = UDim2.fromScale(1, 1)
TargetHPFill.BackgroundColor3 = THEME.OnGreen
TargetHPFill.BorderSizePixel = 0
TargetHPFill.Parent = TargetHPBg
Instance.new("UICorner", TargetHPFill).CornerRadius = UDim.new(1, 0)

local CombatRuntime = {
	CurrentTarget = nil,
	CurrentPart = nil,
	LastTargetSwitchTime = 0,
	LastTriggerFireTime = 0,
	TargetFirstSeenTime = {},
	AimLinePart = nil,
}

local function playCombatAudio(soundId, pitch)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.PlaybackSpeed = num(pitch, 1)
	sound.Volume = 0.75
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		if sound and sound.Parent then sound:Destroy() end
	end)
end

local function triggerHitFeedback(damage, isHeadshot, isKill)
	local now = num(os.clock(), 0)
	if now - num(S.lastComboTime, 0) <= 3.0 then
		S.comboCount = num(S.comboCount, 0) + 1
	else
		S.comboCount = 1
	end
	S.lastComboTime = now
	S.totalDamage = num(S.totalDamage, 0) + num(damage, 0)
	refreshTitle()

	if S.DynamicCross then
		S.crosshairPulse = 1
	end

	if S.HitFX and LocalPlayer.Character then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local p = Instance.new("Part")
			p.Name = "PaoMian67_HitFX"
			p.Size = Vector3.new(0.8, 0.8, 0.8)
			p.Transparency = 1
			p.CanCollide = false
			p.Anchored = true
			p.CFrame = hrp.CFrame * CFrame.new(0, 1, -2)
			p.Parent = workspace

			local em = Instance.new("ParticleEmitter")
			em.Rate = 50
			em.Lifetime = NumberRange.new(0.2, 0.4)
			em.Speed = NumberRange.new(6, 14)
			em.Color = ColorSequence.new(isHeadshot and THEME.AccentPink or THEME.AccentCyan)
			em.Parent = p
			em:Emit(16)
			task.delay(0.5, function()
				if p and p.Parent then p:Destroy() end
			end)
		end
	end

	if isKill and S.KillSound then
		playCombatAudio("rbxassetid://12222225", 1.15)
	elseif isHeadshot and S.HeadshotPing then
		playCombatAudio("rbxassetid://12222208", 1.35)
	elseif S.HitSound then
		playCombatAudio("rbxassetid://12222208", 1.0)
	end
end

local function isPlayerFlashed()
	if not S.DisableOnFlash then return false end
	for _, eff in ipairs(Lighting:GetChildren()) do
		if eff:IsA("ColorCorrectionEffect") and eff.Enabled then
			if num(eff.Brightness, 0) > 0.75 or num(eff.Contrast, 0) < -0.65 then
				return true
			end
		end
	end
	return false
end

local function isCharacterValid(char)
	if not char or char == LocalPlayer.Character then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root or num(hum.Health, 0) <= 0 then return false end

	if S.IgnoreProtected and char:FindFirstChildOfClass("ForceField") then
		return false
	end
	if S.IgnoreKatanaDeflect and (char:GetAttribute("KatanaDeflecting") == true or char:FindFirstChild("KatanaDeflecting")) then
		return false
	end

	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if S.LimitDistance and myRoot then
		local dist = (root.Position - myRoot.Position).Magnitude
		if dist > num(S.MaxAimDistance, 500) then
			return false
		end
	end

	local canSee = true
	if S.VisibleOnly and not S.WallbangAim then
		local origin = Camera.CFrame.Position
		local dir = root.Position - origin
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { LocalPlayer.Character, char }
		local rayHit = workspace:Raycast(origin, dir, params)
		if rayHit then
			canSee = false
		end
	end

	if not canSee and not S.WallbangAim then
		return false
	end

	local now = num(os.clock(), 0)
	if not CombatRuntime.TargetFirstSeenTime[char] then
		CombatRuntime.TargetFirstSeenTime[char] = now
	end
	local seenElapsedMs = (now - num(CombatRuntime.TargetFirstSeenTime[char], now)) * 1000
	if seenElapsedMs < num(S.ReactionTimeMs, 0) then
		return false
	end

	return true
end

local function selectTargetPart(char)
	if S.ClosestPart then
		local screenCenter = Vector2.new(num(Camera.ViewportSize.X, 1280) * 0.5, num(Camera.ViewportSize.Y, 720) * 0.5)
		local bestPart, bestDist = nil, math.huge
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and not (S.PartBlacklist and S.PartBlacklist[part.Name]) then
				local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local d = (Vector2.new(num(sp.X, 0), num(sp.Y, 0)) - screenCenter).Magnitude
					if d < bestDist then
						bestDist = d
						bestPart = part
					end
				end
			end
		end
		if bestPart then return bestPart end
	end

	if S.HeadPriority then
		local head = char:FindFirstChild("Head")
		if head and head:IsA("BasePart") and not (S.PartBlacklist and S.PartBlacklist.Head) then
			return head
		end
	end

	local preferred = char:FindFirstChild(S.TargetPart or "Head")
	if preferred and preferred:IsA("BasePart") and not (S.PartBlacklist and S.PartBlacklist[preferred.Name]) then
		return preferred
	end

	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
end

local function findBestCombatTarget()
	if isPlayerFlashed() then return nil, nil end

	local maxRadius = (S.SilentAim or S.Ragebot)
		and math.min(num(S.SilentFOVRadius, 1000), 550)
		or num(S.FOVRadius, 180)
	local screenCenter = Vector2.new(num(Camera.ViewportSize.X, 1280) * 0.5, num(Camera.ViewportSize.Y, 720) * 0.5)
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

	local candidates = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and isCharacterValid(plr.Character) then
			table.insert(candidates, plr.Character)
		end
	end

	if S.TargetNPC then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and isCharacterValid(obj) then
				table.insert(candidates, obj)
			end
		end
	end

	local bestChar, bestPart, bestScore = nil, nil, math.huge
	for _, char in ipairs(candidates) do
		local part = selectTargetPart(char)
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if part and hum and root then
			local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
			local screenDist = onScreen
				and (Vector2.new(num(sp.X, 0), num(sp.Y, 0)) - screenCenter).Magnitude
				or math.huge
			local worldDist = myRoot and (root.Position - myRoot.Position).Magnitude or math.huge

			if screenDist <= maxRadius or S.Ragebot then
				local score = screenDist
				if S.ClosestPriority then
					score = worldDist
				elseif S.LowestHpPriority then
					score = num(hum.Health, math.huge)
				end
				if num(score, math.huge) < bestScore then
					bestScore = num(score, math.huge)
					bestChar = char
					bestPart = part
				end
			end
		end
	end

	return bestChar, bestPart
end

local function updateVisualizeLine(hasLock, targetPart)
	if not S.VisualizeAim or not hasLock or not targetPart or not LocalPlayer.Character then
		if CombatRuntime.AimLinePart and CombatRuntime.AimLinePart.Parent then
			CombatRuntime.AimLinePart:Destroy()
			CombatRuntime.AimLinePart = nil
		end
		return
	end
	local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	if not CombatRuntime.AimLinePart or not CombatRuntime.AimLinePart.Parent then
		local line = Instance.new("Part")
		line.Name = "PaoMian67_AimLine"
		line.Anchored = true
		line.CanCollide = false
		line.Material = Enum.Material.Neon
		line.Color = THEME.AccentCyan
		line.Transparency = 0.35
		line.Parent = workspace
		CombatRuntime.AimLinePart = line
	end

	local a = myRoot.Position + Vector3.new(0, 1.5, 0)
	local b = targetPart.Position
	local dist = (b - a).Magnitude
	if dist > 0.1 then
		CombatRuntime.AimLinePart.Size = Vector3.new(0.08, 0.08, dist)
		CombatRuntime.AimLinePart.CFrame = CFrame.lookAt((a + b) * 0.5, b)
	end
end

-- 戰鬥開關清單（全部接上 S）
addToggle(Pages.Combat, "擬真輔助 (RMB Aim)", "RealisticAim")
addToggle(Pages.Combat, "自動輔助 (Auto Aim)", "AutoAim")
addToggle(Pages.Combat, "第一人稱滑鼠防卡死", "FPMouseFix", function(on)
	if not on and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end
end)
addToggle(Pages.Combat, "瞄準 NPC", "TargetNPC")
addToggle(Pages.Combat, "瞄準頭部優先", "HeadPriority")
addToggle(Pages.Combat, "鎖定最近距離優先", "ClosestPriority")
addToggle(Pages.Combat, "鎖定最低血量優先", "LowestHpPriority")
addToggle(Pages.Combat, "視野可見優先", "VisibleOnly")
addToggle(Pages.Combat, "透視牆後鎖定", "WallbangAim")
addToggle(Pages.Combat, "子彈穿牆", "BulletPenetration")
addToggle(Pages.Combat, "輔助平滑度強化 (Smooth x1.45)", "SmoothBoost")
addToggle(Pages.Combat, "顯示感應圈 (FOV Ring)", "ShowFOVRing")
addToggle(Pages.Combat, "中心準心點 (Center Dot)", "CenterDot")
addToggle(Pages.Combat, "準心紅點鎖定提示 (Lock Dot)", "LockDot")
addToggle(Pages.Combat, "命中動態縮放準心", "DynamicCross")
addToggle(Pages.Combat, "命中特效 (Hit FX)", "HitFX")
addToggle(Pages.Combat, "清脆命中音 (Hit Sound)", "HitSound")
addToggle(Pages.Combat, "爆頭提示音 (Headshot Ping)", "HeadshotPing")
addToggle(Pages.Combat, "擊殺音效提示 (Kill Sound)", "KillSound")
addToggle(Pages.Combat, "連擊計數顯示 (Combo HUD)", "ComboHUD", refreshTitle)
addToggle(Pages.Combat, "目標血條框 (Target HUD)", "TargetHUD")
addToggle(Pages.Combat, "目標距離顯示 (Dist Meter)", "DistMeter")
addToggle(Pages.Combat, "靜默自瞄 (Silent Aim)", "SilentAim")
addToggle(Pages.Combat, "操作位移自瞄 (Manipulation)", "Manipulation")
addToggle(Pages.Combat, "最近部位鎖定 (Closest Part)", "ClosestPart")
addToggle(Pages.Combat, "視覺化自瞄提示 (Visualize)", "VisualizeAim", function(on)
	if not on then updateVisualizeLine(false, nil) end
end)
addToggle(Pages.Combat, "忽略無敵／受保護目標", "IgnoreProtected")
addToggle(Pages.Combat, "忽略武士刀反彈 (Katana Deflect)", "IgnoreKatanaDeflect")
addToggle(Pages.Combat, "閃光彈致盲時停用", "DisableOnFlash")
addToggle(Pages.Combat, "限制瞄準距離 (Limit Distance)", "LimitDistance")
addToggle(Pages.Combat, "扳機機器人 (Triggerbot)", "Triggerbot")
addToggle(Pages.Combat, "目標切換無延遲", "NoDelayBetweenTargets")
addToggle(Pages.Combat, "無後座散布 (No Spread)", "NoSpread")
addToggle(Pages.Combat, "全自動射擊 (Full Auto)", "FullAuto")
addToggle(Pages.Combat, "必定背刺 (Always Backstab)", "AlwaysBackstab")
addToggle(Pages.Combat, "手榴彈投擲即爆 (Explode on Throw)", "ExplodeOnThrow")
addToggle(Pages.Combat, "移除手榴彈 (Remove Grenade)", "RemoveGrenade")
addToggle(Pages.Combat, "狂暴自瞄 (Ragebot)", "Ragebot")
addToggle(Pages.Combat, "虛空生成／躲避 (Void Span)", "VoidSpan")

addAction(Pages.Combat, "一鍵重置準心與 FOV (Reset Aim UI)", Color3.fromRGB(48, 56, 78), THEME.AccentCyan, function(btn)
	S.FOVRadius = 180
	S.SilentFOVRadius = 1000
	S.aimTrackSpeed = 6.5
	S.crosshairPulse = 0
	if ToggleSetters.ShowFOVRing then ToggleSetters.ShowFOVRing(false, false) end
	if ToggleSetters.CenterDot then ToggleSetters.CenterDot(false, false) end
	if ToggleSetters.LockDot then ToggleSetters.LockDot(false, false) end
	if ToggleSetters.DynamicCross then ToggleSetters.DynamicCross(false, false) end
	btn.Text = "已重置準心與 FOV!"
	task.wait(0.8)
	btn.Text = "一鍵重置準心與 FOV (Reset Aim UI)"
end)

RunService.RenderStepped:Connect(function(dt)
	local safeDt = num(dt, 0.016)
	local now = num(os.clock(), 0)

	local radius = (S.SilentAim or S.Ragebot)
		and math.min(num(S.SilentFOVRadius, 1000), 550)
		or num(S.FOVRadius, 180)
	FOVFrame.Visible = (not S.HideAimUI) and (S.ShowFOVRing == true)
	FOVFrame.Size = UDim2.fromOffset(radius * 2, radius * 2)

	S.crosshairPulse = num(S.crosshairPulse, 0)
	if S.crosshairPulse > 0 then
		S.crosshairPulse = math.max(0, S.crosshairPulse - safeDt * 6)
	end
	local dotSize = 6 + (S.crosshairPulse * 6)
	CenterDot.Visible = (not S.HideAimUI) and (S.CenterDot == true)
	CenterDot.Size = UDim2.fromOffset(dotSize, dotSize)

	if S.FPMouseFix and UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end

	local targetChar, targetPart = findBestCombatTarget()
	if targetChar ~= CombatRuntime.CurrentTarget then
		CombatRuntime.CurrentTarget = targetChar
		CombatRuntime.LastTargetSwitchTime = now
	end
	CombatRuntime.CurrentPart = targetPart

	local hasLock = (targetChar ~= nil and targetPart ~= nil)
	updateVisualizeLine(hasLock, targetPart)

	if S.LockDot then
		CenterDot.BackgroundColor3 = hasLock and Color3.fromRGB(255, 45, 70) or Color3.fromRGB(255, 255, 255)
	else
		CenterDot.BackgroundColor3 = Color3.fromRGB(255, 70, 95)
	end

	if S.TargetHUD and hasLock then
		local hum = targetChar:FindFirstChildOfClass("Humanoid")
		local root = targetChar:FindFirstChild("HumanoidRootPart")
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hum then
			TargetHUDFrame.Visible = true
			local hp = num(hum.Health, 0)
			local maxHp = math.max(num(hum.MaxHealth, 100), 1)
			local hpRatio = math.clamp(hp / maxHp, 0, 1)
			TargetHPFill.Size = UDim2.fromScale(hpRatio, 1)
			local distText = (S.DistMeter and myRoot and root)
				and string.format(" | %.0fm", (root.Position - myRoot.Position).Magnitude)
				or ""
			TargetLabel.Text = string.format("目標：%s (%.0f HP)%s", targetChar.Name, hp, distText)
		end
	else
		TargetHUDFrame.Visible = false
	end

	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	local shouldAim = (S.AutoAim or S.Ragebot) or (S.RealisticAim and S.isRightDown)
	if shouldAim and hasLock and not S.Freecam then
		local aimPos = targetPart.Position
		if S.Manipulation and myRoot then
			aimPos = aimPos + Vector3.new(0, 1.5, 0)
		end
		local desiredCF = CFrame.lookAt(Camera.CFrame.Position, aimPos)
		local speed = num(S.aimTrackSpeed, 6.5) * (S.SmoothBoost and 1.45 or 1.0)
		local alpha = math.clamp(safeDt * speed, 0, 1)
		Camera.CFrame = Camera.CFrame:Lerp(desiredCF, alpha)
	end

	if S.Triggerbot and hasLock then
		local elapsedSinceSwitch = (now - num(CombatRuntime.LastTargetSwitchTime, now)) * 1000
		local requiredDelay = S.NoDelayBetweenTargets and 0 or (num(S.TriggerOffsetMs, 0) + num(S.ShootDelayMs, 0))
		local cooldownOk = (now - num(CombatRuntime.LastTriggerFireTime, 0)) >= 0.08
		if elapsedSinceSwitch >= requiredDelay and cooldownOk then
			CombatRuntime.LastTriggerFireTime = now
			pcall(function()
				if mouse1click then mouse1click() end
			end)
		end
	end
end)
-- =====================================================================
-- 泡面67 MENU | 完整繁體中文版 - 第 3 段 (第 2 分頁：移動 Move 完整邏輯)
-- =====================================================================
local MoveRuntime = {
	AirPadPart = nil,
	JumpCount = 0,
	AnimTrack = nil,
}

local function getCharBundle()
	local char = LocalPlayer.Character
	if not char then return nil, nil, nil end
	return char, char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function updateAirWalkPad(hrp, hum)
	if not S.AirWalk or not hrp or not hum then
		if MoveRuntime.AirPadPart and MoveRuntime.AirPadPart.Parent then
			MoveRuntime.AirPadPart:Destroy()
			MoveRuntime.AirPadPart = nil
		end
		return
	end

	if not MoveRuntime.AirPadPart or not MoveRuntime.AirPadPart.Parent then
		local pad = Instance.new("Part")
		pad.Name = "PaoMian67_AirPad"
		pad.Size = Vector3.new(8, 0.6, 8)
		pad.Anchored = true
		pad.CanCollide = true
		pad.Transparency = 0.65
		pad.Material = Enum.Material.Neon
		pad.Color = THEME.AccentCyan
		pad.Parent = workspace
		MoveRuntime.AirPadPart = pad
	end

	local dropOffset = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -4.2 or -3.2
	MoveRuntime.AirPadPart.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + dropOffset, hrp.Position.Z)
end

local function spawnDoubleJumpPad(hrp)
	if not hrp then return end
	local pad = Instance.new("Part")
	pad.Name = "PaoMian67_DoublePad"
	pad.Size = Vector3.new(6, 0.5, 6)
	pad.Anchored = true
	pad.CanCollide = true
	pad.Transparency = 0.5
	pad.Material = Enum.Material.Neon
	pad.Color = THEME.AccentPink
	pad.Position = hrp.Position - Vector3.new(0, 3.2, 0)
	pad.Parent = workspace
	task.delay(1.5, function()
		if pad and pad.Parent then pad:Destroy() end
	end)
end

local function applyMoveAnimation()
	local _, hum = getCharBundle()
	if MoveRuntime.AnimTrack then
		pcall(function()
			MoveRuntime.AnimTrack:Stop()
			MoveRuntime.AnimTrack:Destroy()
		end)
		MoveRuntime.AnimTrack = nil
	end
	if not S.AnimPlayerEnabled or not hum then return end

	local animId = tostring(S.CustomAnimationId or "")
	if animId == "" and S.SelectedAnimation == "The Worm" then
		animId = "rbxassetid://182789005"
	end
	if animId == "" then return end

	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
	if ok and track then
		track.Looped = true
		track:Play()
		track:AdjustSpeed(num(S.AnimSpeed, 1))
		MoveRuntime.AnimTrack = track
	end
end

-- 移動分頁開關與動作按鈕
addToggle(Pages.Move, "移動加速 (WalkSpeed 50)", "WalkSpeedEnabled")
addToggle(Pages.Move, "移動自動衝刺 (+12 SPD)", "AutoSprint")
addToggle(Pages.Move, "螢幕點擊傳送 (Tap TP)", "TapTP")
addToggle(Pages.Move, "前衝閃現 (Q 鍵)", "QuickDash")
addToggle(Pages.Move, "空中踏板漫步 (Air Walk)", "AirWalk", function(on)
	if not on then updateAirWalkPad(nil, nil) end
end)
addToggle(Pages.Move, "空中二段踏板 (Double Air Pad)", "DoubleAirPad")
addToggle(Pages.Move, "超級跳躍 (Jump 100)", "SuperJump")
addToggle(Pages.Move, "無限連跳 (Inf Jump)", "InfJump")
addToggle(Pages.Move, "按住空白自動跳躍 (Auto Hop)", "AutoHop")
addToggle(Pages.Move, "滑冰慣性滑行 (Ice Skate)", "IceSkate")
addToggle(Pages.Move, "空中 Ctrl 快速下落 (Fast Fall)", "FastFall")
addToggle(Pages.Move, "月球低重力 (Low Grav)", "LowGravity")
addToggle(Pages.Move, "羽毛微重力 (Grav 105)", "FeatherGravity")
addToggle(Pages.Move, "穿牆模式 (Noclip)", "Noclip")
addToggle(Pages.Move, "飛行模式 (Dev Fly)", "DevFly")
addToggle(Pages.Move, "高速飛行倍率 (Fly x2)", "FlySpeedMultiplier", function(on)
	S.FlySpeedMultiplier = on and 2 or 1
end)
addToggle(Pages.Move, "速度增強 (Velocity)", "VelocityEnabled")
addToggle(Pages.Move, "滑行加速 (Slide Boost)", "SlideBoostEnabled")
addToggle(Pages.Move, "二段跳高度 (Double Jump Height)", "DoubleJumpHeightEnabled")
addToggle(Pages.Move, "無限二段跳 (Infinite Double Jump)", "InfiniteDoubleJump")
addToggle(Pages.Move, "第三人稱視角 (Third Person)", "ThirdPerson", function(on)
	if on then
		LocalPlayer.CameraMode = Enum.CameraMode.Classic
		LocalPlayer.CameraMinZoomDistance = 8
		LocalPlayer.CameraMaxZoomDistance = 16
	else
		LocalPlayer.CameraMinZoomDistance = OrigCamMinZoom
		LocalPlayer.CameraMaxZoomDistance = OrigCamMaxZoom
	end
end)
addToggle(Pages.Move, "反自瞄 (Anti-Aim)", "AntiAim")
addToggle(Pages.Move, "延伸隨機角度 (Extended Random)", "ExtendedRandom")
addToggle(Pages.Move, "地底躲藏模式 (Underground)", "Underground")
addToggle(Pages.Move, "動畫播放器 (Animation Player)", "AnimPlayerEnabled", applyMoveAnimation)

addAction(Pages.Move, "瞬移前方 12 格 (Blink Forward)", nil, THEME.AccentCyan, function(btn)
	local _, _, hrp = getCharBundle()
	if hrp then
		local dir = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
		if dir.Magnitude > 0 then
			hrp.CFrame = hrp.CFrame + dir.Unit * num(S.BlinkDistance, 12)
		end
	end
	btn.Text = "已瞬移前方 12 格!"
	task.wait(0.7)
	btn.Text = "瞬移前方 12 格 (Blink Forward)"
end)

addAction(Pages.Move, "紀錄位置 (SAVE)", nil, THEME.AccentCyan, function(btn)
	local _, _, hrp = getCharBundle()
	if hrp then
		S.SavedCFrame = hrp.CFrame
		btn.Text = "已紀錄目前位置!"
		task.wait(0.7)
		btn.Text = "紀錄位置 (SAVE)"
	end
end)

addAction(Pages.Move, "傳送回去 (TP)", nil, THEME.TextMain, function(btn)
	local _, _, hrp = getCharBundle()
	if hrp and S.SavedCFrame then
		hrp.CFrame = S.SavedCFrame
		btn.Text = "已傳送回紀錄點!"
		task.wait(0.7)
		btn.Text = "傳送回去 (TP)"
	end
end)

addAction(Pages.Move, "一鍵回重生點 (Back to Spawn)", nil, THEME.TextMain, function(btn)
	local _, _, hrp = getCharBundle()
	if hrp and S.SpawnCFrame then
		hrp.CFrame = S.SpawnCFrame
		btn.Text = "已回重生點!"
		task.wait(0.7)
		btn.Text = "一鍵回重生點 (Back to Spawn)"
	end
end)

addAction(Pages.Move, "一鍵回上次死亡點 (Back to Death)", nil, THEME.AccentCyan, function(btn)
	local _, _, hrp = getCharBundle()
	if hrp and S.LastDeathCFrame then
		hrp.CFrame = S.LastDeathCFrame
		btn.Text = "已回上次死亡點!"
		task.wait(0.7)
		btn.Text = "一鍵回上次死亡點 (Back to Death)"
	end
end)

addAction(Pages.Move, "隨機傳送其他玩家 (TP Random Player)", nil, THEME.AccentCyan, function(btn)
	local _, _, hrp = getCharBundle()
	if not hrp then return end
	local pool = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			table.insert(pool, plr.Character.HumanoidRootPart)
		end
	end
	if #pool > 0 then
		local picked = pool[math.random(1, #pool)]
		hrp.CFrame = picked.CFrame * CFrame.new(0, 0, -4)
		btn.Text = "已傳送至隨機玩家!"
	else
		btn.Text = "目前沒有其他玩家"
	end
	task.wait(0.7)
	btn.Text = "隨機傳送其他玩家 (TP Random Player)"
end)

UserInputService.JumpRequest:Connect(function()
	local char, hum, hrp = getCharBundle()
	if not char or not hum or not hrp then return end
	MoveRuntime.JumpCount = num(MoveRuntime.JumpCount, 0) + 1

	if S.DoubleAirPad then
		spawnDoubleJumpPad(hrp)
	end

	local boostedJumpVel = 50 * (S.DoubleJumpHeightEnabled and num(S.DoubleJumpMult, 1.5) or 1.0)
	if S.InfJump or S.InfiniteDoubleJump then
		if S.DoubleJumpHeightEnabled then
			local curVel = hrp.AssemblyLinearVelocity
			hrp.AssemblyLinearVelocity = Vector3.new(num(curVel.X, 0), boostedJumpVel, num(curVel.Z, 0))
		end
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	elseif S.DoubleJumpHeightEnabled and MoveRuntime.JumpCount == 2 then
		local curVel = hrp.AssemblyLinearVelocity
		hrp.AssemblyLinearVelocity = Vector3.new(num(curVel.X, 0), boostedJumpVel, num(curVel.Z, 0))
	end
end)

RunService.Stepped:Connect(function()
	local char = LocalPlayer.Character
	if char and (S.Noclip or S.Underground) then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	local safeDt = num(dt, 0.016)
	local char, hum, hrp = getCharBundle()
	if not char or not hum or not hrp then return end

	if hum.FloorMaterial ~= Enum.Material.Air then
		MoveRuntime.JumpCount = 0
	end

	if S.LowGravity then
		workspace.Gravity = 48
	elseif S.FeatherGravity then
		workspace.Gravity = 105
	else
		workspace.Gravity = num(OrigGravity, 196.2)
	end

	hum.UseJumpPower = true
	hum.JumpPower = S.SuperJump and 100 or 50

	local speed = S.WalkSpeedEnabled and num(S.WalkSpeedValue, 50) or 16
	if S.AutoSprint then speed += 12 end
	if S.VelocityEnabled then speed = math.max(speed, num(S.VelocitySpeed, 80)) end
	if S.SlideBoostEnabled
		and (UserInputService:IsKeyDown(Enum.KeyCode.C) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift))
		and hum.MoveDirection.Magnitude > 0 then
		speed *= num(S.SlideBoostMult, 1.9)
	end
	hum.WalkSpeed = speed

	if S.AutoHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.FloorMaterial ~= Enum.Material.Air then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	if S.IceSkate and hum.MoveDirection.Magnitude > 0 then
		local targetVel = hum.MoveDirection.Unit * speed
		local curVel = hrp.AssemblyLinearVelocity
		hrp.AssemblyLinearVelocity = curVel:Lerp(
			Vector3.new(targetVel.X, num(curVel.Y, 0), targetVel.Z),
			math.clamp(safeDt * 2.5, 0, 1)
		)
	end

	if S.DevFly then
		local moveDir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end

		local flyMult = (type(S.FlySpeedMultiplier) == "number") and num(S.FlySpeedMultiplier, 1) or (S.FlySpeedMultiplier and 2 or 1)
		local flyVel = num(S.BaseFlySpeed, 65) * flyMult
		hrp.AssemblyLinearVelocity = moveDir.Magnitude > 0 and (moveDir.Unit * flyVel) or Vector3.zero
	end

	updateAirWalkPad(hrp, hum)

	if S.AntiAim then
		local yawDeg = (num(os.clock(), 0) * 480) % 360
		if S.ExtendedRandom then
			yawDeg = math.random(-180, 180)
		elseif S.YawMode ~= "Spin" then
			yawDeg = num(S.CustomYawAngle, 0)
		end
		local pitchRad = (S.PitchMode == "Down") and -0.4 or 0.4
		hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(pitchRad, math.rad(yawDeg), 0)
	end

	if S.Underground then
		hrp.CFrame = CFrame.new(hrp.Position.X, num(hrp.Position.Y, 0) - 6, hrp.Position.Z)
	end
end)
-- =====================================================================
-- 泡面67 MENU | 完整繁體中文版 - 第 4 段 (第 3 分頁：視覺 Visual 完整邏輯)
-- =====================================================================
local VisualRuntime = {
	EspObjects = {},
	WeatherParts = {},
	CharTrailObj = nil,
	FootAuraPart = nil,
	SavedTransparencies = {},
}

local function clearVisualWorldObjects()
	for char, entry in pairs(VisualRuntime.EspObjects) do
		if type(entry) == "table" then
			if entry.Billboard and entry.Billboard.Parent then entry.Billboard:Destroy() end
			if entry.Highlight and entry.Highlight.Parent then entry.Highlight:Destroy() end
			if entry.Box3D and entry.Box3D.Parent then entry.Box3D:Destroy() end
		end
		VisualRuntime.EspObjects[char] = nil
	end
	for _, p in ipairs(VisualRuntime.WeatherParts) do
		if p and p.Parent then p:Destroy() end
	end
	table.clear(VisualRuntime.WeatherParts)
	if VisualRuntime.CharTrailObj and VisualRuntime.CharTrailObj.Parent then
		VisualRuntime.CharTrailObj:Destroy()
		VisualRuntime.CharTrailObj = nil
	end
	if VisualRuntime.FootAuraPart and VisualRuntime.FootAuraPart.Parent then
		VisualRuntime.FootAuraPart:Destroy()
		VisualRuntime.FootAuraPart = nil
	end
end

local function ensureEspEntry(char)
	if VisualRuntime.EspObjects[char] then
		return VisualRuntime.EspObjects[char]
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local bb = Instance.new("BillboardGui")
	bb.Name = "PaoMian67_Visual"
	bb.Adornee = hrp
	bb.Size = UDim2.fromOffset(120, 48)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = ScreenGui

	local tagLbl = Instance.new("TextLabel")
	tagLbl.Size = UDim2.fromScale(1, 0.55)
	tagLbl.BackgroundTransparency = 1
	tagLbl.TextColor3 = THEME.TextMain
	tagLbl.TextStrokeTransparency = 0.2
	tagLbl.TextSize = 10
	tagLbl.Font = MENU_FONT
	tagLbl.Parent = bb

	local hpBarBg = Instance.new("Frame")
	hpBarBg.Size = UDim2.new(0.8, 0, 0, 5)
	hpBarBg.Position = UDim2.new(0.1, 0, 0.65, 0)
	hpBarBg.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
	hpBarBg.BorderSizePixel = 0
	hpBarBg.Parent = bb
	Instance.new("UICorner", hpBarBg).CornerRadius = UDim.new(1, 0)

	local hpBarFill = Instance.new("Frame")
	hpBarFill.Size = UDim2.fromScale(1, 1)
	hpBarFill.BackgroundColor3 = THEME.OnGreen
	hpBarFill.BorderSizePixel = 0
	hpBarFill.Parent = hpBarBg
	Instance.new("UICorner", hpBarFill).CornerRadius = UDim.new(1, 0)

	local hl = Instance.new("Highlight")
	hl.Name = "PaoMian67_Visual"
	hl.Adornee = char
	hl.FillColor = S.OverrideAppearance and S.OverrideColor or THEME.AccentPink
	hl.OutlineColor = THEME.AccentCyan
	hl.FillTransparency = S.OverrideAppearance and math.clamp(num(S.OverrideTransparency, 0), 0, 1) or 0.55
	hl.OutlineTransparency = 0
	hl.DepthMode = S.ChamsThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
	hl.Parent = ScreenGui

	local box3d = Instance.new("SelectionBox")
	box3d.Name = "PaoMian67_Visual"
	box3d.Adornee = hrp
	box3d.Color3 = THEME.AccentCyan
	box3d.LineThickness = math.clamp(num(S.OutlineThickness, 1) * 0.04, 0.01, 0.25)
	box3d.Parent = ScreenGui

	local entry = {
		Billboard = bb,
		TagLabel = tagLbl,
		HPBarBg = hpBarBg,
		HPBarFill = hpBarFill,
		Highlight = hl,
		Box3D = box3d,
	}
	VisualRuntime.EspObjects[char] = entry
	return entry
end

local function updateCharacterVisuals(char, now)
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp or num(hum.Health, 0) <= 0 then
		if VisualRuntime.EspObjects[char] then
			for _, v in pairs(VisualRuntime.EspObjects[char]) do
				if typeof(v) == "Instance" and v.Parent then v:Destroy() end
			end
			VisualRuntime.EspObjects[char] = nil
		end
		return
	end

	local showAny = S.BoxESP or S.Snaplines or S.EnemyHPTag or S.ESP or S.Box3D
		or S.SkeletonESP or S.HighlightEnabled or S.ChamsEnabled or S.OverrideAppearance
		or S.ShowName or S.ShowDistance or S.Healthbar
	if not showAny then
		if VisualRuntime.EspObjects[char] then
			VisualRuntime.EspObjects[char].Billboard.Visible = false
			VisualRuntime.EspObjects[char].Highlight.Enabled = false
			VisualRuntime.EspObjects[char].Box3D.Visible = false
		end
		return
	end

	local entry = ensureEspEntry(char)
	if not entry then return end

	local distText = (S.ShowDistance and myRoot)
		and string.format(" [%.0fm]", (hrp.Position - myRoot.Position).Magnitude)
		or ""
	local plr = Players:GetPlayerFromCharacter(char)
	local nameText = S.ShowName
		and (S.NameType == "DisplayName" and (plr and plr.DisplayName or char.Name) or char.Name)
		or ""
	local hpVal = num(hum.Health, 0)
	local hpText = S.EnemyHPTag and string.format(" %.0fHP", hpVal) or ""

	entry.Billboard.Visible = (S.EnemyHPTag or S.ShowName or S.ShowDistance or S.BoxESP or S.Healthbar)
	entry.TagLabel.Text = nameText .. hpText .. distText
	if S.MovingRotation then
		entry.TagLabel.Rotation = (now * num(S.RotationSpeed, 0.1) * 360) % 360
	else
		entry.TagLabel.Rotation = num(S.NameRotation, 0)
	end

	entry.HPBarBg.Visible = S.Healthbar == true
	local ratio = math.clamp(hpVal / math.max(num(hum.MaxHealth, 100), 1), 0, 1)
	entry.HPBarFill.Size = UDim2.fromScale(ratio, 1)
	entry.HPBarFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - ratio), 220 * ratio, 90)

	entry.Highlight.Enabled = (S.ESP or S.HighlightEnabled or S.ChamsEnabled or S.OverrideAppearance) == true
	entry.Highlight.FillColor = S.OverrideAppearance and S.OverrideColor or THEME.AccentPink
	entry.Highlight.FillTransparency = S.ChamsEnabled
		and math.clamp(num(S.ChamsTransparency, 0.25) + 0.55, 0.1, 0.9)
		or (S.OverrideAppearance and math.clamp(num(S.OverrideTransparency, 0), 0, 1) or 0.55)
	entry.Highlight.DepthMode = (S.ChamsThroughWalls or S.ESP)
		and Enum.HighlightDepthMode.AlwaysOnTop
		or Enum.HighlightDepthMode.Occluded

	entry.Box3D.Visible = (S.Box3D or S.BoxESP) == true
end

local function updateLocalCharVisualFX(char, now)
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local rainbow = Color3.fromHSV((now * 0.35) % 1, 0.9, 1)
	local fxColor = S.TrailRGB and rainbow or THEME.AccentCyan

	if S.CharTrail then
		if not VisualRuntime.CharTrailObj or not VisualRuntime.CharTrailObj.Parent then
			local a0 = Instance.new("Attachment", hrp); a0.Position = Vector3.new(0, 1.5, 0)
			local a1 = Instance.new("Attachment", hrp); a1.Position = Vector3.new(0, -1.5, 0)
			local tr = Instance.new("Trail")
			tr.Name = "PaoMian67_Visual"
			tr.Attachment0 = a0; tr.Attachment1 = a1
			tr.Lifetime = 0.45
			tr.Parent = hrp
			VisualRuntime.CharTrailObj = tr
		end
		VisualRuntime.CharTrailObj.Color = ColorSequence.new(fxColor)
	elseif VisualRuntime.CharTrailObj and VisualRuntime.CharTrailObj.Parent then
		VisualRuntime.CharTrailObj:Destroy()
		VisualRuntime.CharTrailObj = nil
	end

	if S.FootAura then
		if not VisualRuntime.FootAuraPart or not VisualRuntime.FootAuraPart.Parent then
			local ring = Instance.new("Part")
			ring.Name = "PaoMian67_Visual"
			ring.Shape = Enum.PartType.Cylinder
			ring.Size = Vector3.new(0.2, 6, 6)
			ring.Material = Enum.Material.Neon
			ring.CanCollide = false
			ring.Anchored = true
			ring.Transparency = 0.45
			ring.Color = THEME.AccentCyan
			ring.Parent = workspace
			VisualRuntime.FootAuraPart = ring
		end
		VisualRuntime.FootAuraPart.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 2.8, 0))
			* CFrame.Angles(0, now * 2.5, math.rad(90))
		VisualRuntime.FootAuraPart.Color = S.TrailRGB and rainbow or THEME.AccentCyan
	elseif VisualRuntime.FootAuraPart and VisualRuntime.FootAuraPart.Parent then
		VisualRuntime.FootAuraPart:Destroy()
		VisualRuntime.FootAuraPart = nil
	end

	if S.GhostGun then
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") then
				for _, p in ipairs(tool:GetDescendants()) do
					if p:IsA("BasePart") then
						if VisualRuntime.SavedTransparencies[p] == nil then
							VisualRuntime.SavedTransparencies[p] = num(p.Transparency, 0)
						end
						p.Transparency = 0.65
					end
				end
			end
		end
	end
end

local function updateWeatherParticles(hrp)
	if not hrp or S.WeatherMode == "Off" then
		for _, p in ipairs(VisualRuntime.WeatherParts) do
			if p and p.Parent then p:Destroy() end
		end
		table.clear(VisualRuntime.WeatherParts)
		return
	end

	if #VisualRuntime.WeatherParts == 0 then
		local anchor = Instance.new("Part")
		anchor.Name = "PaoMian67_Visual"
		anchor.Size = Vector3.new(40, 1, 40)
		anchor.Transparency = 1
		anchor.CanCollide = false
		anchor.Anchored = true
		anchor.Parent = workspace

		local em = Instance.new("ParticleEmitter")
		em.Rate = (S.WeatherMode == "Rain") and 140 or 65
		em.Lifetime = NumberRange.new(1.5, 2.5)
		em.Speed = (S.WeatherMode == "Rain") and NumberRange.new(35, 50) or NumberRange.new(6, 12)
		em.Acceleration = (S.WeatherMode == "Rain") and Vector3.new(0, -60, 0) or Vector3.new(2, -10, 0)
		em.Size = (S.WeatherMode == "Rain") and NumberSequence.new(0.12) or NumberSequence.new(0.28)
		em.Color = ColorSequence.new(Color3.fromRGB(225, 240, 255))
		em.Parent = anchor

		table.insert(VisualRuntime.WeatherParts, anchor)
	end

	local anchor = VisualRuntime.WeatherParts[1]
	if anchor then
		anchor.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 22, 0))
	end
end

-- 視覺分頁開關與按鈕
addToggle(Pages.Visual, "2D 方框標記 (Box ESP)", "BoxESP")
addToggle(Pages.Visual, "目標連線指示 (Snaplines)", "Snaplines")
addToggle(Pages.Visual, "敵方頭頂血量標記 (Enemy HP Tag)", "EnemyHPTag")
addToggle(Pages.Visual, "敵方輪廓 (ESP)", "ESP")
addToggle(Pages.Visual, "空間框標記 (3D Box)", "Box3D")
addToggle(Pages.Visual, "畫面變扁 (Stretched Res)", "StretchedRes")
addToggle(Pages.Visual, "自由靈魂視角 (Freecam)", "Freecam", function(on)
	if on then
		S.freecamCF = Camera.CFrame
		Camera.CameraType = Enum.CameraType.Scriptable
	else
		Camera.CameraType = OrigCamType
	end
end)
addToggle(Pages.Visual, "超廣角視野 (FOV 110)", "FOV110", function(on)
	if not on and not S.FOVChanger then
		Camera.FieldOfView = num(OrigFOV, 70)
	end
end)
addToggle(Pages.Visual, "第三人稱拉遠視野 (Far Cam)", "FarCam", function(on)
	LocalPlayer.CameraMinZoomDistance = on and 12 or num(OrigCamMinZoom, 0.5)
	LocalPlayer.CameraMaxZoomDistance = on and 45 or num(OrigCamMaxZoom, 400)
end)
addToggle(Pages.Visual, "武器半透明化 (Ghost Gun)", "GhostGun", function(on)
	if not on then
		for part, origT in pairs(VisualRuntime.SavedTransparencies) do
			if part and part.Parent then part.Transparency = num(origT, 0) end
		end
		table.clear(VisualRuntime.SavedTransparencies)
	end
end)
addToggle(Pages.Visual, "全亮夜視 (Fullbright)", "Fullbright", function(on)
	Lighting.Brightness = on and 2.5 or num(OrigLighting.Brightness, 2)
	Lighting.GlobalShadows = on and false or OrigLighting.GlobalShadows
end)
addToggle(Pages.Visual, "超清去霧夜視 (Ultra FB)", "UltraFB", function(on)
	Lighting.FogEnd = on and 100000 or num(OrigLighting.FogEnd, 100000)
end)
addToggle(Pages.Visual, "高對比夜視模式 (Contrast FB)", "ContrastFB", function(on)
	Lighting.ExposureCompensation = on and 0.45 or num(OrigLighting.ExposureCompensation, 0)
end)
addToggle(Pages.Visual, "Blender 算圖特效 / 景深鏡頭", "BlenderFX", function(on)
	local dof = Lighting:FindFirstChild("PaoMian67_DOF") or Instance.new("DepthOfFieldEffect", Lighting)
	dof.Name = "PaoMian67_DOF"
	dof.Enabled = on
	dof.FocusDistance = 24
	dof.InFocusRadius = 18
	dof.FarIntensity = 0.35
end)
addToggle(Pages.Visual, "角色霓虹拖尾 (Char Trail)", "CharTrail")
addToggle(Pages.Visual, "霓虹拖尾／光環彩虹流光", "TrailRGB")
addToggle(Pages.Visual, "腳下能量光環 (Foot Aura)", "FootAura")
addToggle(Pages.Visual, "旋轉準心 (Spin Crosshair)", "SpinCrosshair")
addToggle(Pages.Visual, "準心彩虹流光 (RGB Crosshair)", "RGBCrosshair")
addToggle(Pages.Visual, "全局 MC 字體 (MC Font)", "MCFont", function(on)
	for _, g in ipairs(PlayerGui:GetDescendants()) do
		if g ~= ScreenGui and (g:IsA("TextLabel") or g:IsA("TextButton") or g:IsA("TextBox")) then
			g.Font = on and MENU_FONT or Enum.Font.SourceSans
		end
	end
end)
addToggle(Pages.Visual, "方框旋轉 / 填充 / 骨架透視", "SkeletonESP")
addToggle(Pages.Visual, "血條顯示 (Healthbar) / 動態血條", "Healthbar")
addToggle(Pages.Visual, "外觀覆蓋 (Override Appearance)", "OverrideAppearance")
addToggle(Pages.Visual, "第一人稱模型覆蓋 (Viewmodel Override)", "ViewmodelOverride")
addToggle(Pages.Visual, "角色透視材質 (Chams) / 穿牆顯示", "ChamsEnabled")
addToggle(Pages.Visual, "自訂彈道軌跡 (Custom Tracers)", "CustomTracers")
addToggle(Pages.Visual, "命中特效 (Hit Effects)", "HitEffectsEnabled")
addToggle(Pages.Visual, "目標資訊框 / 指示器 / 彈藥顯示", "IndicatorsEnabled")

addAction(Pages.Visual, "切換天氣特效 (目前：關閉)", nil, THEME.AccentCyan, function(btn)
	local order = { "Off", "Rain", "Snow" }
	local labels = { Off = "關閉", Rain = "細雨", Snow = "飄雪" }
	local idx = table.find(order, S.WeatherMode) or 1
	S.WeatherMode = order[(idx % #order) + 1]
	btn.Text = "切換天氣特效 (目前：" .. labels[S.WeatherMode] .. ")"
	if S.WeatherMode == "Off" then updateWeatherParticles(nil) end
end)

addAction(Pages.Visual, "切換畫面變扁比例 (16:10 微扁 / 4:3 扁)", nil, THEME.AccentCyan, function(btn)
	S.StretchedRes = true
	S.StretchRatioY = (num(S.StretchRatioY, 0.75) > 0.68) and 0.60 or 0.75
	btn.Text = string.format("變扁比例 Y: %.2f", num(S.StretchRatioY, 0.75))
end)

addAction(Pages.Visual, "一鍵清除所有視覺標記 (Clear Visuals)", Color3.fromRGB(55, 62, 85), THEME.AccentCyan, function(btn)
	clearVisualWorldObjects()
	btn.Text = "已清除所有視覺標記!"
	task.wait(0.8)
	btn.Text = "一鍵清除所有視覺標記 (Clear Visuals)"
end)

RunService.RenderStepped:Connect(function(dt)
	local safeDt = num(dt, 0.016)
	local now = num(os.clock(), 0)
	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

	if S.Freecam then
		local moveVec = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= Vector3.new(0, 1, 0) end
		S.freecamCF = CFrame.new(S.freecamCF.Position + moveVec * (65 * safeDt)) * Camera.CFrame.Rotation
		Camera.CFrame = S.freecamCF
	end

	if S.FOV110 then
		Camera.FieldOfView = 110
	elseif S.FOVChanger then
		Camera.FieldOfView = math.clamp(num(S.CustomFOV, 90), 30, 120)
	end

	if CenterDot then
		if S.SpinCrosshair then
			CenterDot.Rotation = (now * 360) % 360
		else
			CenterDot.Rotation = 0
		end
		if S.RGBCrosshair then
			CenterDot.BackgroundColor3 = Color3.fromHSV((now * 0.4) % 1, 0.9, 1)
		end
	end

	updateLocalCharVisualFX(myChar, now)
	updateWeatherParticles(myHrp)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			updateCharacterVisuals(plr.Character, now)
		end
	end

	if S.StretchedRes then
		Camera.CFrame = Camera.CFrame * CFrame.fromMatrix(
			Vector3.zero,
			Vector3.new(1, 0, 0),
			Vector3.new(0, num(S.StretchRatioY, 0.75), 0),
			Vector3.new(0, 0, 1)
		)
	end
end)
-- =====================================================================
-- 泡面67 MENU | 完整繁體中文版 - 第 5 段 (第 4 分頁：光影 Shader 完整邏輯)
-- =====================================================================
local ShaderRuntime = {
	PresetNames = {
		"預設原版", "暖陽逆光", "賽博霓虹", "深海藍光", "血月緋紅",
		"極光翠綠", "粉櫻柔光", "黃金黃昏", "冷冽冰霜", "紫羅蘭幻影"
	},
	SkyboxList = {
		"Red Dusk", "Neon Void", "Deep Ocean", "Crimson Eclipse", "Aurora Sky"
	},
	SkyboxIndex = 1,
	CustomSkyObj = nil,
}

local function ensurePostEffects()
	local cc = Lighting:FindFirstChild("PaoMian67_CC") or Instance.new("ColorCorrectionEffect")
	cc.Name = "PaoMian67_CC"
	cc.Parent = Lighting

	local bloom = Lighting:FindFirstChild("PaoMian67_Bloom") or Instance.new("BloomEffect")
	bloom.Name = "PaoMian67_Bloom"
	bloom.Parent = Lighting

	local sunRays = Lighting:FindFirstChild("PaoMian67_SunRays") or Instance.new("SunRaysEffect")
	sunRays.Name = "PaoMian67_SunRays"
	sunRays.Parent = Lighting

	local blur = Lighting:FindFirstChild("PaoMian67_Blur") or Instance.new("BlurEffect")
	blur.Name = "PaoMian67_Blur"
	blur.Parent = Lighting

	local atmo = Lighting:FindFirstChild("PaoMian67_Atmo") or Instance.new("Atmosphere")
	atmo.Name = "PaoMian67_Atmo"
	atmo.Parent = Lighting

	return cc, bloom, sunRays, blur, atmo
end

local function applyCustomSkybox(skyName)
	S.SkyboxSelection = tostring(skyName or "Red Dusk")
	if not ShaderRuntime.CustomSkyObj or not ShaderRuntime.CustomSkyObj.Parent then
		local sky = Instance.new("Sky")
		sky.Name = "PaoMian67_Sky"
		sky.Parent = Lighting
		ShaderRuntime.CustomSkyObj = sky
	end

	local sky = ShaderRuntime.CustomSkyObj
	if skyName == "Red Dusk" then
		sky.SkyboxBk = "rbxassetid://401664839"
		sky.SkyboxDn = "rbxassetid://401664862"
		sky.SkyboxFt = "rbxassetid://401664960"
		sky.SkyboxLf = "rbxassetid://401664881"
		sky.SkyboxRt = "rbxassetid://401664901"
		sky.SkyboxUp = "rbxassetid://401664936"
	elseif skyName == "Neon Void" then
		sky.SkyboxBk = "rbxassetid://149397692"
		sky.SkyboxDn = "rbxassetid://149397686"
		sky.SkyboxFt = "rbxassetid://149397705"
		sky.SkyboxLf = "rbxassetid://149397657"
		sky.SkyboxRt = "rbxassetid://149397678"
		sky.SkyboxUp = "rbxassetid://149397718"
	else
		sky.SkyboxBk = "rbxassetid://159454299"
		sky.SkyboxDn = "rbxassetid://159454296"
		sky.SkyboxFt = "rbxassetid://159454300"
		sky.SkyboxLf = "rbxassetid://159454286"
		sky.SkyboxRt = "rbxassetid://159454302"
		sky.SkyboxUp = "rbxassetid://159454294"
	end
end

local function applyFullShaderState(presetIdx)
	local idx = math.clamp(math.floor(num(presetIdx, S.ShaderPresetIndex)), 1, #ShaderRuntime.PresetNames)
	S.ShaderPresetIndex = idx

	local cc, bloom, sunRays, blur, atmo = ensurePostEffects()
	local boost = S.ShaderBoost and 1.35 or 1.0
	local brightBonus = S.BrightBoost and 1.25 or 0

	cc.Enabled = true
	bloom.Enabled = (S.BloomEnabled == true) or (idx > 1)
	sunRays.Enabled = (S.SunRaysEnabled == true) or (idx > 1)

	if idx == 1 then
		Lighting.ClockTime = num(S.ClockTime, OrigLighting.ClockTime)
		cc.TintColor = Color3.fromRGB(255, 255, 255)
		cc.Saturation = S.VividColor and 0.35 or num(S.Saturation, 0)
		cc.Contrast = num(S.Contrast, 0)
		cc.Brightness = num(S.Brightness, 0)
		bloom.Intensity = S.BloomEnabled and (num(S.BloomIntensity, 1) * boost) or 0.5
	elseif idx == 2 then
		Lighting.ClockTime = 17.5
		cc.TintColor = Color3.fromRGB(255, 215, 165)
		cc.Saturation = (S.VividColor and 0.45 or 0.2) * boost
		cc.Contrast = 0.12 * boost
		bloom.Intensity = 0.9 * boost
	elseif idx == 3 then
		Lighting.ClockTime = 21
		cc.TintColor = Color3.fromRGB(185, 220, 255)
		cc.Saturation = 0.4 * boost
		cc.Contrast = 0.25 * boost
		bloom.Intensity = 1.6 * boost
	elseif idx == 4 then
		Lighting.ClockTime = 13
		cc.TintColor = Color3.fromRGB(150, 205, 255)
		cc.Saturation = 0.15 * boost
		cc.Contrast = 0.08
		bloom.Intensity = 0.75 * boost
	elseif idx == 5 then
		Lighting.ClockTime = 0.5
		cc.TintColor = Color3.fromRGB(255, 140, 150)
		cc.Saturation = 0.25 * boost
		cc.Contrast = 0.3 * boost
		bloom.Intensity = 1.35 * boost
	elseif idx == 6 then
		Lighting.ClockTime = 22.5
		cc.TintColor = Color3.fromRGB(150, 255, 210)
		cc.Saturation = 0.35 * boost
		cc.Contrast = 0.15 * boost
		bloom.Intensity = 1.2 * boost
	elseif idx == 7 then
		Lighting.ClockTime = 16
		cc.TintColor = Color3.fromRGB(255, 195, 225)
		cc.Saturation = 0.28 * boost
		cc.Contrast = 0.05
		bloom.Intensity = 1.0 * boost
	elseif idx == 8 then
		Lighting.ClockTime = 18.2
		cc.TintColor = Color3.fromRGB(255, 190, 110)
		cc.Saturation = 0.25 * boost
		cc.Contrast = 0.18 * boost
		bloom.Intensity = 1.15 * boost
	elseif idx == 9 then
		Lighting.ClockTime = 10
		cc.TintColor = Color3.fromRGB(205, 235, 255)
		cc.Saturation = -0.15
		cc.Contrast = 0.1 * boost
		bloom.Intensity = 0.8 * boost
	elseif idx == 10 then
		Lighting.ClockTime = 20
		cc.TintColor = Color3.fromRGB(215, 175, 255)
		cc.Saturation = 0.35 * boost
		cc.Contrast = 0.22 * boost
		bloom.Intensity = 1.45 * boost
	end

	if S.ColorCorrection then
		cc.Enabled = true
		cc.Saturation = num(S.Saturation, 0)
		cc.Contrast = num(S.Contrast, 0)
		cc.Brightness = num(S.Brightness, 0)
	end

	if S.BloomEnabled then
		bloom.Enabled = true
		bloom.Intensity = num(S.BloomIntensity, 1) * boost
		bloom.Size = math.clamp(num(S.BloomSize, 24), 1, 56)
		bloom.Threshold = math.clamp(num(S.BloomThreshold, 0.9), 0, 5)
	end

	sunRays.Intensity = (S.SunRaysEnabled or idx > 1) and (0.25 * boost) or 0

	local blurVal = math.clamp(num(S.BlurAmount, 0), 0, 56)
	blur.Enabled = (blurVal > 0)
	blur.Size = blurVal

	atmo.Enabled = S.AtmosphereEnabled == true
	Lighting.Brightness = num(OrigLighting.Brightness, 2) + brightBonus + num(S.Brightness, 0)
	Lighting.ExposureCompensation = num(S.ExposureCompensation, 0)
	Lighting.GlobalShadows = S.GlobalShadows == true
	Lighting.Ambient = S.AmbientColor or OrigLighting.Ambient
	Lighting.ColorShift_Bottom = S.ColorShiftBottom or OrigLighting.OutdoorAmbient
	Lighting.ColorShift_Top = S.ColorShiftTop or OrigLighting.Ambient
	Lighting.FogColor = S.FogColor or OrigLighting.FogColor
	Lighting.FogStart = math.max(num(S.FogStart, 0), 0)
	Lighting.FogEnd = S.NoFog and 100000 or math.max(num(S.FogEnd, OrigLighting.FogEnd), 0)
end

local CycleShaderBtn = addAction(Pages.Shader, "切換光影 (1/10：預設原版)", Color3.fromRGB(42, 58, 86), THEME.AccentCyan)
CycleShaderBtn.MouseButton1Click:Connect(function()
	local nextIdx = (math.floor(num(S.ShaderPresetIndex, 1)) % #ShaderRuntime.PresetNames) + 1
	applyFullShaderState(nextIdx)
	CycleShaderBtn.Text = string.format("切換光影 (%d/10：%s)", nextIdx, ShaderRuntime.PresetNames[nextIdx])
end)

addToggle(Pages.Shader, "光影流光強化 (Shader x1.35)", "ShaderBoost", function() applyFullShaderState(S.ShaderPresetIndex) end)
addToggle(Pages.Shader, "光影亮度微調 (+Bright)", "BrightBoost", function() applyFullShaderState(S.ShaderPresetIndex) end)
addToggle(Pages.Shader, "光影色彩濃郁 (Vivid Color)", "VividColor", function() applyFullShaderState(S.ShaderPresetIndex) end)
addToggle(Pages.Shader, "自動時間流動 (Time Cycle)", "TimeCycle")
addToggle(Pages.Shader, "色彩校正 (Color Correction)", "ColorCorrection", function() applyFullShaderState(S.ShaderPresetIndex) end)
addToggle(Pages.Shader, "大氣效果 (Atmosphere)", "AtmosphereEnabled", function() applyFullShaderState(S.ShaderPresetIndex) end)
addToggle(Pages.Shader, "光暈效果 (Bloom)", "BloomEnabled", function() applyFullShaderState(S.ShaderPresetIndex) end)
addToggle(Pages.Shader, "太陽光線 (Sun Rays)", "SunRaysEnabled", function() applyFullShaderState(S.ShaderPresetIndex) end)
addToggle(Pages.Shader, "防閃光彈 (Anti Flashbang)", "AntiFlashbang", function(on)
	if on then
		for _, eff in ipairs(Lighting:GetChildren()) do
			if eff:IsA("ColorCorrectionEffect") and eff.Name ~= "PaoMian67_CC" then
				if num(eff.Brightness, 0) > 0.7 or num(eff.Contrast, 0) < -0.6 then
					eff.Enabled = false
				end
			end
		end
	end
end)
addToggle(Pages.Shader, "視野修改器 (FOV Changer)", "FOVChanger", function(on)
	if not on and not S.FOV110 then
		Camera.FieldOfView = num(OrigFOV, 70)
	end
end)

local SkyboxBtn = addAction(Pages.Shader, "天空盒選擇 (目前：Red Dusk)", nil, THEME.AccentCyan, function(btn)
	ShaderRuntime.SkyboxIndex = (math.floor(num(ShaderRuntime.SkyboxIndex, 1)) % #ShaderRuntime.SkyboxList) + 1
	local chosen = ShaderRuntime.SkyboxList[ShaderRuntime.SkyboxIndex]
	applyCustomSkybox(chosen)
	btn.Text = "天空盒選擇 (目前：" .. chosen .. ")"
end)

local BlurStepBtn = addAction(Pages.Shader, "調整景深模糊強度 (目前：0)", nil, THEME.TextMain, function(btn)
	S.BlurAmount = (math.floor(num(S.BlurAmount, 0)) + 4) % 24
	applyFullShaderState(S.ShaderPresetIndex)
	btn.Text = string.format("調整景深模糊強度 (目前：%d)", math.floor(num(S.BlurAmount, 0)))
end)

addAction(Pages.Shader, "一鍵還原預設光影 (Reset Light)", Color3.fromRGB(55, 62, 85), THEME.TextMain, function(btn)
	S.TimeCycle = false
	S.ShaderBoost = false
	S.BrightBoost = false
	S.VividColor = false
	S.ColorCorrection = false
	S.AtmosphereEnabled = false
	S.BloomEnabled = false
	S.SunRaysEnabled = false
	S.BlurAmount = 0
	S.Saturation = 0
	S.Contrast = 0
	S.Brightness = 0
	S.ExposureCompensation = num(OrigLighting.ExposureCompensation, 0)
	S.ClockTime = num(OrigLighting.ClockTime, 14)
	S.GlobalShadows = OrigLighting.GlobalShadows
	S.AmbientColor = OrigLighting.Ambient
	S.FogColor = OrigLighting.FogColor
	S.FogEnd = num(OrigLighting.FogEnd, 100000)

	for _, key in ipairs({
		"ShaderBoost", "BrightBoost", "VividColor", "TimeCycle",
		"ColorCorrection", "AtmosphereEnabled", "BloomEnabled", "SunRaysEnabled"
	}) do
		if ToggleSetters[key] then ToggleSetters[key](false, false) end
	end

	if ShaderRuntime.CustomSkyObj and ShaderRuntime.CustomSkyObj.Parent then
		ShaderRuntime.CustomSkyObj:Destroy()
		ShaderRuntime.CustomSkyObj = nil
	end

	Lighting.ClockTime = num(OrigLighting.ClockTime, 14)
	Lighting.Brightness = num(OrigLighting.Brightness, 2)
	Lighting.Ambient = OrigLighting.Ambient
	Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient
	Lighting.GlobalShadows = OrigLighting.GlobalShadows
	Lighting.FogColor = OrigLighting.FogColor
	Lighting.FogEnd = num(OrigLighting.FogEnd, 100000)
	Lighting.ExposureCompensation = num(OrigLighting.ExposureCompensation, 0)

	applyFullShaderState(1)
	CycleShaderBtn.Text = "切換光影 (1/10：預設原版)"
	SkyboxBtn.Text = "天空盒選擇 (目前：Red Dusk)"
	BlurStepBtn.Text = "調整景深模糊強度 (目前：0)"
	btn.Text = "光影已還原!"
	task.wait(0.8)
	btn.Text = "一鍵還原預設光影 (Reset Light)"
end)

for i, name in ipairs(ShaderRuntime.PresetNames) do
	addAction(Pages.Shader, i .. ". " .. name, THEME.CardBg, THEME.TextMain, function()
		applyFullShaderState(i)
		CycleShaderBtn.Text = string.format("切換光影 (%d/10：%s)", i, name)
	end)
end

RunService.RenderStepped:Connect(function(dt)
	local safeDt = num(dt, 0.016)
	if S.TimeCycle then
		Lighting.ClockTime = (num(Lighting.ClockTime, 14) + safeDt * 0.6) % 24
	end
	if S.AntiFlashbang then
		for _, eff in ipairs(Lighting:GetChildren()) do
			if eff:IsA("ColorCorrectionEffect") and eff.Name ~= "PaoMian67_CC" then
				if num(eff.Brightness, 0) > 0.7 or num(eff.Contrast, 0) < -0.6 then
					eff.Enabled = false
				end
			end
		end
	end
end)
-- =====================================================================
-- 泡面67 MENU | 完整繁體中文版 - 第 6 段 (防卡/娛樂/雜項/版面 + 清理收尾)
-- =====================================================================
local MiscRuntime = {
	LastAntiLagScan = 0,
	LastStatusTick = 0,
	LastAntiAFKTick = 0,
	LastChatSpamTick = 0,
	FrameCounter = 0,
	FpsAccum = 0,
	CurrentFps = 60,
	DisguiseBillboard = nil,
}

local function runAntiLagSweep(force)
	local now = num(os.clock(), 0)
	if not force and (now - num(MiscRuntime.LastAntiLagScan, 0)) < 2.0 then
		return
	end
	MiscRuntime.LastAntiLagScan = now

	if S.NoFog or S.UltraAntiLag then
		Lighting.FogEnd = 100000
		Lighting.FogStart = 0
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("Atmosphere") and not child.Name:find("PaoMian67") then
				child.Density = 0
			end
		end
	end

	if S.NoAmbientOcclusion or S.UltraAntiLag then
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("PostEffect") and not child.Name:find("PaoMian67") then
				if child:IsA("DepthOfFieldEffect") or child:IsA("BloomEffect") or child:IsA("SunRaysEffect") then
					child.Enabled = false
				end
			end
		end
	end

	if S.ClearParticles or S.UltraAntiLag then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
				if not tostring(obj.Name):find("PaoMian67") then
					obj.Enabled = false
				end
			elseif obj:IsA("Explosion") then
				obj:Destroy()
			end
		end
	end

	if S.SimpleMaterial or S.UltraAntiLag then
		for _, part in ipairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character or ScreenGui) then
				if part.Material ~= Enum.Material.SmoothPlastic and part.Material ~= Enum.Material.Plastic then
					part.Material = Enum.Material.SmoothPlastic
				end
				if S.UltraAntiLag then
					part.CastShadow = false
				end
			end
		end
	end

	if S.NoTerrainDeco or S.UltraAntiLag then
		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			terrain.Decoration = false
		end
	end

	if S.MuteOtherFX or S.UltraAntiLag then
		for _, snd in ipairs(workspace:GetDescendants()) do
			if snd:IsA("Sound") and snd.Parent ~= SoundService then
				snd.Volume = 0
			end
		end
	end
end

local function updateDisguiseVisual()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not S.disguiseActive or not hrp then
		if MiscRuntime.DisguiseBillboard and MiscRuntime.DisguiseBillboard.Parent then
			MiscRuntime.DisguiseBillboard:Destroy()
			MiscRuntime.DisguiseBillboard = nil
		end
		return
	end

	if not MiscRuntime.DisguiseBillboard or not MiscRuntime.DisguiseBillboard.Parent then
		local bb = Instance.new("BillboardGui")
		bb.Name = "PaoMian67_DisguiseTag"
		bb.Adornee = hrp
		bb.Size = UDim2.fromOffset(150, 28)
		bb.StudsOffset = Vector3.new(0, 3.8, 0)
		bb.AlwaysOnTop = true
		bb.Parent = ScreenGui

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.fromScale(1, 1)
		lbl.BackgroundTransparency = 1
		lbl.TextStrokeTransparency = 0.2
		lbl.TextSize = 11
		lbl.Font = MENU_FONT
		lbl.Parent = bb
		MiscRuntime.DisguiseBillboard = bb
	end

	local lbl = MiscRuntime.DisguiseBillboard:FindFirstChildOfClass("TextLabel")
	if lbl then
		local display = tostring(S.disguiseTargetName or "")
		if display == "" then display = LocalPlayer.DisplayName end
		lbl.Text = "偽裝：" .. display
		if S.FakeNameplateRGB then
			lbl.TextColor3 = Color3.fromHSV((num(os.clock(), 0) * 0.45) % 1, 0.9, 1)
		else
			lbl.TextColor3 = THEME.AccentCyan
		end
	end
end

local function applyCharScale()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local targetScale = 1
	if S.GiantVisual then
		targetScale = 1.65
	elseif S.MiniVisual then
		targetScale = 0.55
	end
	for _, propName in ipairs({ "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }) do
		local valObj = hum:FindFirstChild(propName)
		if valObj and valObj:IsA("NumberValue") then
			valObj.Value = targetScale
		end
	end
end

local function applyLayoutPreset(presetName)
	S.LayoutPreset = tostring(presetName or "Center")
	local p = S.LayoutPreset
	if p == "Left" then
		MainFrame.AnchorPoint = Vector2.new(0, 0.5)
		MainFrame.Position = UDim2.new(0, 24, 0.5, 0)
	elseif p == "Right" then
		MainFrame.AnchorPoint = Vector2.new(1, 0.5)
		MainFrame.Position = UDim2.new(1, -24, 0.5, 0)
	elseif p == "TopLeft" then
		MainFrame.AnchorPoint = Vector2.new(0, 0)
		MainFrame.Position = UDim2.new(0, 20, 0, 24)
	else
		MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	end
end

-- =====================================================================
-- 5. 防卡分頁 (10 項)
-- =====================================================================
addToggle(Pages.AntiLag, "1. 清除特效粒子 (Clear Particles)", "ClearParticles", function(on) if on then runAntiLagSweep(true) end end)
addToggle(Pages.AntiLag, "2. 移除濃霧 (No Fog)", "NoFog", function(on) if on then runAntiLagSweep(true) end end)
addToggle(Pages.AntiLag, "3. 簡化材質 (Simple Material)", "SimpleMaterial", function(on) if on then runAntiLagSweep(true) end end)
addToggle(Pages.AntiLag, "4. 移除地形裝飾 (No Terrain Deco)", "NoTerrainDeco", function(on) if on then runAntiLagSweep(true) end end)
addToggle(Pages.AntiLag, "5. 關閉環境光遮蔽 (No AO)", "NoAmbientOcclusion", function(on) if on then runAntiLagSweep(true) end end)
addToggle(Pages.AntiLag, "6. 降低視覺刷新率 (Low Visual Rate)", "LowVisualRate")
addToggle(Pages.AntiLag, "7. 鎖定 60 FPS 上限 (Cap 60 FPS)", "Cap60FPS", function(on)
	pcall(function()
		if setfpscap then
			setfpscap(on and 60 or 144)
		end
	end)
end)
addToggle(Pages.AntiLag, "8. 靜音其他音效 (Mute Other FX)", "MuteOtherFX", function(on) if on then runAntiLagSweep(true) end end)
addToggle(Pages.AntiLag, "9. 終極防卡模式 (Ultra Anti-Lag)", "UltraAntiLag", function(on) if on then runAntiLagSweep(true) end end)
addAction(Pages.AntiLag, "10. 立即執行一次全場防卡清理 (Sweep Now)", Color3.fromRGB(45, 62, 82), THEME.AccentCyan, function(btn)
	runAntiLagSweep(true)
	btn.Text = "已執行全場防卡清理!"
	task.wait(0.8)
	btn.Text = "10. 立即執行一次全場防卡清理 (Sweep Now)"
end)

-- =====================================================================
-- 6. 娛樂分頁
-- =====================================================================
addToggle(Pages.Fun, "啟用假名牌／偽裝 (Disguise)", "disguiseActive", updateDisguiseVisual)
addToggle(Pages.Fun, "假名牌彩虹流光 (Fake Nameplate RGB)", "FakeNameplateRGB", updateDisguiseVisual)
addToggle(Pages.Fun, "視覺巨大化 (Giant Visual)", "GiantVisual", function(on)
	if on and S.MiniVisual and ToggleSetters.MiniVisual then
		ToggleSetters.MiniVisual(false, false)
	end
	applyCharScale()
end)
addToggle(Pages.Fun, "視覺迷你化 (Mini Visual)", "MiniVisual", function(on)
	if on and S.GiantVisual and ToggleSetters.GiantVisual then
		ToggleSetters.GiantVisual(false, false)
	end
	applyCharScale()
end)
addToggle(Pages.Fun, "彈跳舞蹈 (Bounce Dance)", "BounceDance")
addToggle(Pages.Fun, "搖擺舞蹈 (Sway Dance)", "SwayDance")
addToggle(Pages.Fun, "鏡頭震動特效 (Cam Shake)", "CamShake")
addAction(Pages.Fun, "切換偽裝對象 (隨機線上玩家)", nil, THEME.AccentCyan, function(btn)
	local pool = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then table.insert(pool, plr) end
	end
	if #pool > 0 then
		local picked = pool[math.random(1, #pool)]
		S.disguiseTargetName = picked.DisplayName .. " (" .. picked.Name .. ")"
		S.disguiseTargetUserId = picked.UserId
		S.disguiseActive = true
		if ToggleSetters.disguiseActive then ToggleSetters.disguiseActive(true, false) end
		updateDisguiseVisual()
		btn.Text = "偽裝目標：" .. picked.DisplayName
	else
		S.disguiseTargetName = "VIP_Guest_67"
		btn.Text = "偽裝目標：VIP_Guest_67"
	end
end)

-- =====================================================================
-- 7. 雜項分頁
-- =====================================================================
addToggle(Pages.Misc, "介面彩虹邊框 (RGB UI)", "RGBUI")
addToggle(Pages.Misc, "面板半透明強化 (Panel Alpha)", "PanelAlpha", function(on)
	MainFrame.BackgroundTransparency = on and 0.35 or num(S.MenuTransparency, 0.08)
end)
addToggle(Pages.Misc, "FPS 效能加速 (FPS Boost)", "FPSBoost", function(on)
	if on then runAntiLagSweep(true) end
end)
addToggle(Pages.Misc, "防掛機踢出 (Anti-AFK)", "AntiAFK")
addToggle(Pages.Misc, "角色旋轉 (Spin Char)", "SpinChar")
addToggle(Pages.Misc, "重生自動回原位 (Auto Back on Death)", "AutoBackOnDeath")
addToggle(Pages.Misc, "角色彩虹流光 (RGB Char)", "RGBChar")
addToggle(Pages.Misc, "自動重新排隊 (Auto Queue)", "AutoQueue")
addToggle(Pages.Misc, "自動重生 (Auto Respawn)", "AutoRespawn")
addToggle(Pages.Misc, "聊天室循環喊話 (Chat Spam)", "ChatSpam")
addToggle(Pages.Misc, "命中提示通知 (Notify Hit)", "NotifyHit")

addAction(Pages.Misc, "複製 Discord 邀請連結", nil, THEME.AccentCyan, function(btn)
	pcall(function()
		if setclipboard then setclipboard(tostring(S.DiscordInvite or "")) end
	end)
	btn.Text = "已複製 Discord 連結!"
	task.wait(0.8)
	btn.Text = "複製 Discord 邀請連結"
end)

-- =====================================================================
-- 8. 版面與設定分頁
-- =====================================================================
addToggle(Pages.Layout, "隱藏底部狀態列 (Hide Status Bar)", "HideStatusBar", function(on)
	StatusBar.Visible = not on
end)
addToggle(Pages.Layout, "隱藏準心／FOV 覆蓋層 (Hide Aim UI)", "HideAimUI")
addToggle(Pages.Layout, "啟用通知提示 (Notifications)", "NotificationsEnabled")

addAction(Pages.Layout, "切換視窗位置 (目前：Center)", nil, THEME.AccentCyan, function(btn)
	local order = { "Center", "Left", "Right", "TopLeft" }
	local idx = table.find(order, S.LayoutPreset) or 1
	local nextPreset = order[(idx % #order) + 1]
	applyLayoutPreset(nextPreset)
	btn.Text = "切換視窗位置 (目前：" .. nextPreset .. ")"
end)

addAction(Pages.Layout, "儲存目前設定到記憶體 (Save Config)", nil, THEME.OnGreen, function(btn)
	local copy = {}
	for k, v in pairs(S) do
		if type(v) ~= "function" and type(v) ~= "userdata" then
			copy[k] = v
		end
	end
	S.Configs[S.CurrentConfigName or "default"] = copy
	btn.Text = "已儲存設定 (" .. tostring(S.CurrentConfigName or "default") .. ")!"
	task.wait(0.8)
	btn.Text = "儲存目前設定到記憶體 (Save Config)"
end)

-- =====================================================================
-- 角色重生接續、輸入互動、關閉清理與主迴圈
-- =====================================================================
local function hookCharacter(char)
	if not char then return end
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if hrp and not S.SpawnCFrame then
		S.SpawnCFrame = hrp.CFrame
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Died:Connect(function()
			local curRoot = char:FindFirstChild("HumanoidRootPart")
			if curRoot then
				S.LastDeathCFrame = curRoot.CFrame
			end
			if S.AutoRespawn then
				task.delay(0.4, function()
					pcall(function() LocalPlayer:LoadCharacter() end)
				end)
			end
		end)
	end
	task.defer(function()
		applyCharScale()
		applyMoveAnimation()
		updateDisguiseVisual()
		if S.AutoBackOnDeath and S.LastDeathCFrame and hrp then
			task.wait(0.25)
			hrp.CFrame = S.LastDeathCFrame
		end
	end)
end

if LocalPlayer.Character then
	task.spawn(hookCharacter, LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
	task.spawn(hookCharacter, char)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == (S.MenuBind or Enum.KeyCode.RightShift) then
		ScreenGui.Enabled = not ScreenGui.Enabled
		return
	end
	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		S.isLeftDown = true
		if S.TapTP and LocalPlayer.Character then
			local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local mouse = LocalPlayer:GetMouse()
			if hrp and mouse and mouse.Hit then
				hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
			end
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		S.isRightDown = true
	elseif input.KeyCode == Enum.KeyCode.Q and S.QuickDash and LocalPlayer.Character then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local look = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
			if look.Magnitude > 0 then
				hrp.CFrame = hrp.CFrame + look.Unit * num(S.BlinkDistance, 12)
			end
		end
	elseif input.KeyCode == Enum.KeyCode.LeftControl and S.FastFall and LocalPlayer.Character then
		local char, hum, hrp = getCharBundle()
		if char and hum and hrp and hum.FloorMaterial == Enum.Material.Air then
			local vel = hrp.AssemblyLinearVelocity
			hrp.AssemblyLinearVelocity = Vector3.new(num(vel.X, 0), -95, num(vel.Z, 0))
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		S.isLeftDown = false
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		S.isRightDown = false
	end
end)

LocalPlayer.Idled:Connect(function()
	if S.AntiAFK then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	pcall(function()
		if clearVisualWorldObjects then clearVisualWorldObjects() end
		if updateAirWalkPad then
			S.AirWalk = false
			updateAirWalkPad(nil, nil)
		end
		workspace.Gravity = num(OrigGravity, 196.2)
		Camera.FieldOfView = num(OrigFOV, 70)
		Camera.CameraType = OrigCamType
		LocalPlayer.CameraMinZoomDistance = num(OrigCamMinZoom, 0.5)
		LocalPlayer.CameraMaxZoomDistance = num(OrigCamMaxZoom, 400)
		Lighting.Brightness = num(OrigLighting.Brightness, 2)
		Lighting.ClockTime = num(OrigLighting.ClockTime, 14)
		Lighting.Ambient = OrigLighting.Ambient
		Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient
		Lighting.GlobalShadows = OrigLighting.GlobalShadows
		Lighting.FogColor = OrigLighting.FogColor
		Lighting.FogEnd = num(OrigLighting.FogEnd, 100000)
		Lighting.ExposureCompensation = num(OrigLighting.ExposureCompensation, 0)
		for _, inst in ipairs(workspace:GetDescendants()) do
			if tostring(inst.Name):find("PaoMian67") then
				inst:Destroy()
			end
		end
		for _, inst in ipairs(Lighting:GetChildren()) do
			if tostring(inst.Name):find("PaoMian67") then
				inst:Destroy()
			end
		end
	end)
	ScreenGui:Destroy()
end)

RunService.Heartbeat:Connect(function(dt)
	local safeDt = num(dt, 0.016)
	local now = num(os.clock(), 0)

	MiscRuntime.FrameCounter += 1
	MiscRuntime.FpsAccum += safeDt
	if MiscRuntime.FpsAccum >= 0.5 then
		MiscRuntime.CurrentFps = math.floor((MiscRuntime.FrameCounter / MiscRuntime.FpsAccum) + 0.5)
		MiscRuntime.FrameCounter = 0
		MiscRuntime.FpsAccum = 0
	end

	if (now - num(MiscRuntime.LastStatusTick, 0)) >= 0.4 then
		MiscRuntime.LastStatusTick = now
		local pingMs = 0
		pcall(function()
			local netItem = Stats.Network and Stats.Network.ServerStatsItem and Stats.Network.ServerStatsItem["Data Ping"]
			if netItem then pingMs = math.floor(num(netItem:GetValue(), 0) + 0.5) end
		end)
		StatusLabel.Text = string.format(
			"FPS:%d | PING:%dms | 人數:%d",
			num(MiscRuntime.CurrentFps, 60),
			num(pingMs, 0),
			#Players:GetPlayers()
		)
	end

	if S.RGBUI then
		local hue = (now * 0.25) % 1
		local rgbCol = Color3.fromHSV(hue, 0.85, 1)
		MainStroke.Color = rgbCol
		GlowLine.BackgroundColor3 = rgbCol
	else
		MainStroke.Color = THEME.AccentCyan
		GlowLine.BackgroundColor3 = THEME.AccentCyan
	end

	local char, _, hrp = getCharBundle()
	if char and hrp then
		if S.SpinChar then
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(360 * safeDt), 0)
		end
		if S.RGBChar then
			local c = Color3.fromHSV((now * 0.35) % 1, 0.9, 1)
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
					p.Color = c
				end
			end
		end
		if S.BounceDance then
			hrp.CFrame = hrp.CFrame + Vector3.new(0, math.sin(now * 10) * 0.14, 0)
		end
		if S.SwayDance then
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.sin(now * 6) * 0.12)
		end
	end

	if S.CamShake and not S.Freecam then
		Camera.CFrame = Camera.CFrame * CFrame.new(
			math.sin(now * 28) * 0.06,
			math.cos(now * 34) * 0.06,
			0
		)
	end

	if S.disguiseActive then
		updateDisguiseVisual()
	end

	if S.ClearParticles or S.NoFog or S.SimpleMaterial or S.NoTerrainDeco
		or S.NoAmbientOcclusion or S.MuteOtherFX or S.UltraAntiLag or S.FPSBoost then
		runAntiLagSweep(false)
	end

	if S.AntiAFK and (now - num(MiscRuntime.LastAntiAFKTick, 0)) >= 45 then
		MiscRuntime.LastAntiAFKTick = now
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end

	if S.ChatSpam and (now - num(MiscRuntime.LastChatSpamTick, 0)) >= 3.5 then
		MiscRuntime.LastChatSpamTick = now
		local list = S.ChatSpamMessages
		if type(list) == "table" and #list > 0 then
			local msg = tostring(list[math.random(1, #list)] or "泡面67 MENU")
			pcall(function()
				local textChat = game:GetService("TextChatService")
				local general = textChat and textChat:FindFirstChild("TextChannels") and textChat.TextChannels:FindFirstChild("RBXGeneral")
				if general and general.SendAsync then
					general:SendAsync(msg)
				end
			end)
		end
	end
end)
