--[[
╔══════════════════════════════════════════════════════════════╗
║            ▓▓▓  AɴнDᴇᴘZᴀı SCRIPT V3.2  ▓▓▓                   ║
║      HCR2 Cheat Menu         ║
║                                                              ║
║    📢 Discord  :: Andepzai DALI®                                   ║
║    📢 Telegram :: @Andepzai DALI®                                  ║
║    📢 Youtube  :: @Andepza DALI®i                                  ║
╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════
--  BIẾN TOÀN CỤC
-- ═══════════════════════════════════════════════════════════
local ShowPrint = [[
╔══════════════════════════════════════════════════════════════╗
║            ▓▓▓  AɴнDᴇᴘZᴀı SCRIPT V3.2  ▓▓▓                   ║
║                  Thanks for using!                           ║
║                                                              ║
║    📢 Discord  :: Andepzai DALI®                                   ║
║    📢 Telegram :: @Andepzai DALI®                                  ║
║    📢 Youtube  :: @Andepzai DALI®                                  ║
╚══════════════════════════════════════════════════════════════╝
]]

local LIB_BASE = nil
local archType = 0
local currentRange = nil
local RANGE_VALUE = nil
local gameVersion = nil
local BaseGameStatus = nil
local BaseGameStatusRaw = nil
local BaseRegion = nil

-- ═══════════════════════════════════════════════════════════
--  YJ HELPERS (từ Android)
-- ═══════════════════════════════════════════════════════════
yj = {}
function yj.getString(addr)
    local bytes = {}
    for i = 0, 255 do
        local v = gg.getValues({{address = addr + i, flags = 1}})[1].value
        if v == 0 then break end
        if v < 0 then v = v + 256 end
        bytes[#bytes + 1] = string.char(v)
    end
    return table.concat(bytes)
end

function yj.stringBytes(str)
    local bytes = {}
    for i = 1, #str do bytes[i] = string.byte(str, i) end
    return bytes
end

function yj.Csearchcalculatestheoffset(value, flags)
    gg.clearResults()
    gg.setRanges(flags)
    gg.searchNumber(value, 1)
    if gg.getResultsCount() == 0 then return nil end
    return gg.getResults(1)[1].address
end

function yj.CsetValuesoffset(offset, flags, value)
    gg.setValues({{address = offset, flags = flags, value = value}})
end

function yj.Allzeropages()
    gg.clearList()
    gg.clearResults()
    gg.setRanges(gg.REGION_STACK)
    gg.searchNumber("0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0::253", 4, false, gg.SIGN_EQUAL, 0, -1, 2048)
    local r = gg.getResults(1)
    if r and #r > 0 and r[1].address then
        gg.clearResults()
        return r[1].address + 0x18
    end
    gg.toast("Không tìm thấy vùng nhớ trang 0")
    return nil
end

-- ═══════════════════════════════════════════════════════════
--  GAME DATA
-- ═══════════════════════════════════════════════════════════
local game_data = {
    rarityValue = { 15, 10, 7, 4, 3 },
    rarityLabel = { "Common", "Rare", "Epic", "Legendary", "Mythic" },
    gameStatusVehicles = {
        "HILL CLIMBER", "SCOOTER", "BUS", "HILL CLIMBER MK 2", "TRACTOR", "MOTOCROSS",
        "DUNE BUGGY", "SPORTS CAR", "MONSTER TRUCK", "ROTATOR", "SUPER DIESEL", "CHOPPER",
        "TANK", "LOWRIDER", "SNOWMOBILE", "MONOWHEEL", "BEAST", "RALLY CAR", "FORMULA",
        "MUSCLE CAR", "RACING TRUCK", "HOT ROD", "CC-EV", "SUPERBIKE", "SUPERCAR",
        "MOONLANDER", "ROCK BOUNCER", "HOVERBIKE", "RAIDER", "GLIDER", "BOLT", "ATV",
        "OFFROADER", "STOCKER", "HAVOC"
    },
    gameStatusTunesParts = {
        [1]  = {
            {"magnetTune","heavyweight","glideWings","helmetRollcage","ControlAir","TiresOfWinter"},
            {"startBoost","BoostWheelie","FumeBoost","FlipBoost","JumpStockNotShock"},
            {"Spoiler","PerfectLandingBoost","TurboBoost","AfterBurner"},
            {"Thrusters","FuelBoost","CoinBoost","NitroBoost"},
            {"Amplifier","Echo"}
        },
    },
    vehicles = {
        UnlockGameStatusVehicles = { "SCOOTER","BUS","HILL CLIMBER MK 2","TRACTOR","MOTOCROSS","DUNE BUGGY","SPORTS CAR","MONSTER TRUCK","ROTATOR","SUPER DIESEL","CHOPPER","TANK","LOWRIDER","SNOWMOBILE","MONOWHEEL","BEAST","RALLY CAR","FORMULA","MUSCLE CAR","RACING TRUCK","HOT ROD","CC-EV","SUPERBIKE","SUPERCAR","MOONLANDER","ROCK BOUNCER","HOVERBIKE","RAIDER","GLIDER","BOLT","ATV","OFFROADER","STOCKER","HAVOC" },
        UnlockCupsVehicles = { "HILL CLIMBER MK 2","SPORTS CAR","DUNE BUGGY","SUPER DIESEL","SUPERBIKE","SUPERCAR","RALLY CAR","LOWRIDER","BEAST","HOT ROD","RACING TRUCK","FORMULA","MUSCLE CAR" },
        UnlockAdventureVehicles = { "MONSTER TRUCK","ROTATOR","CHOPPER","TANK","CC-EV" },
        UnlockEventVehicles = { "ATV","OFFROADER","STOCKER","BUS","MOONLANDER","HOVERBIKE","ROCK BOUNCER","RAIDER","BOLT" },
        UnlockOtherVehicles = { "GLIDER","HAVOC" },
        UnlockBluePrintVehicles = { "SCOOTER","MOTOCROSS","TRACTOR","SNOWMOBILE","MONOWHEEL" },
        UnlockMasteryVehicles = { "STOCKER","HAVOC" }
    }
}

local function gd_allVehicles()
    local out = {}
    for _, v in ipairs(game_data.gameStatusVehicles) do out[#out+1] = v end
    return out
end
local function gd_indexOf(name)
    for i, v in ipairs(game_data.gameStatusVehicles) do
        if v == name then return i end
    end
    return nil
end
local function gd_unlockMethod(name)
    local methods = {}
    for k, list in pairs(game_data.vehicles) do
        for _, v in ipairs(list) do
            if v == name then
                methods[#methods+1] = k:gsub("^Unlock",""):gsub("Vehicles$","")
            end
        end
    end
    return methods
end

local gd_tuneGroupNames = {
    "🔩 Chassis / Body","⚡ Boost / Jump","🏎️ Aero / Afterburner","💠 Power-ups","🎵 Special"
}

-- ═══════════════════════════════════════════════════════════
--  KIỂM TRA BAN ĐẦU
-- ═══════════════════════════════════════════════════════════
local blockedApps = {
    "com.gushi.gtpcanary", "com.packagesniffer.frtparlak",
    "com.rhmsoft.edit", "app.greyshirts.sslcapture",
    "frtparlak.rootsniffer", "com.minhui.wifianalyzer",
    "io.neoterm", "com.foxcyber.gg", "sstool.only.com.sstool"
}
local function checkBlocked()
    gg.setVisible(false)
    for _, pkg in ipairs(blockedApps) do
        if gg.isPackageInstalled(pkg) then
            gg.alert("⛔ Detected forbidden app!\n\n📦 " .. pkg)
            os.exit()
        end
    end
end
local function checkGG()
    gg.setVisible(false)
    local ok = pcall(function() gg.require("101.1", 16142) end)
    if not ok then gg.alert("❌ Please use original Game Guardian 101.1!"); os.exit() end
end
local function checkHCR2()
    gg.setVisible(false)
    if gg.getTargetPackage() ~= "com.fingersoft.hcr2" then
        gg.alert("❗ Please select HCR2 on top of Game Guardian!")
        os.exit()
    end
end
local function getHCR2Version()
    local info = gg.getTargetInfo()
    if info and info.versionName then return tostring(info.versionName) end
    return "Unknown"
end
local function detectArch()
    local info = gg.getTargetInfo()
    local libDir = info.nativeLibraryDir:lower()
    if libDir:find("arm64") or libDir:find("aarch64") then return 1
    elseif libDir:find("armeabi") or libDir:find("v7a") then return 2
    elseif libDir:find("x86_64") then return 3
    elseif libDir:find("x86") then return 4 end
    return 0
end
local function getLib()
    local libs = gg.getRangesList("libcocos2dcpp.so")
    if #libs == 0 then
        local c = gg.choice({"⏩ Continue", "❌ Exit"}, nil, "❗ Couldn't find libcocos2dcpp.so!")
        if c ~= 1 then os.exit() end
        return false
    end
    LIB_BASE = libs[1].start
    return true
end
local function selectRange()
    gg.setVisible(false)
    local ranges = {
        { name = "C alloc", value = gg.REGION_C_ALLOC },
        { name = "C data",  value = gg.REGION_C_DATA },
        { name = "Other",   value = gg.REGION_OTHER }
    }
    local labels = {}
    for _, r in ipairs(ranges) do table.insert(labels, r.name) end
    local pick = gg.choice(labels, 0, "🧭 Chọn vùng nhớ (khuyến nghị C alloc)")
    if not pick then os.exit() end
    if pick ~= 1 then gg.alert("⚠️ Range này có thể không hoạt động tốt!\nVui lòng dùng C alloc.") end
    RANGE_VALUE = ranges[pick].value
    currentRange = ranges[pick].name
    gg.setRanges(RANGE_VALUE)
    gg.toast("✅ Range: " .. currentRange)
    gg.sleep(500)
end

-- ═══════════════════════════════════════════════════════════
--  TÌM GAMESTATUS
-- ═══════════════════════════════════════════════════════════
local function findGameStatus()
    local SEARCH_REGIONS = { gg.REGION_C_ALLOC, gg.REGION_OTHER }
    for _, region in ipairs(SEARCH_REGIONS) do
        gg.clearResults()
        gg.setRanges(region)
        gg.searchNumber("h 73 74 61 72 74 75 70 5F 63 6F 75 6E 74", gg.TYPE_BYTE)
        gg.refineNumber("h 73", gg.TYPE_BYTE)
        local scan_results = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        for _, d in ipairs(scan_results) do
            local ptr = gg.getValues({{ address = d.address + 0x1F, flags = gg.TYPE_QWORD }})[1]
            if ptr and ptr.value and ptr.value >= 0x10000 and ptr.value < 0x7FFFFFFFFFFF then
                local ver = gg.getValues({{ address = ptr.value + 0x10, flags = gg.TYPE_DWORD }})[1]
                local v = ver and tonumber(ver.value)
                if v == 65792 or v == 65793 or v == 16843008 or v == 16843009 then
                    local tp = gg.getValues({{ address = ptr.value + 0x80, flags = gg.TYPE_QWORD }})[1]
                    if tp and tp.value and tp.value ~= 0 then
                        local td = gg.getValues({{ address = tp.value, flags = gg.TYPE_DWORD }})[1]
                        if td and td.value and td.value ~= 0 then
                            BaseRegion = region
                            BaseGameStatusRaw = ver.address
                            BaseGameStatus = td.address
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
--  HELPER
-- ═══════════════════════════════════════════════════════════
local function readStringAt(addr, maxLen)
    maxLen = maxLen or 64
    local reads = {}
    for i = 0, maxLen - 1 do reads[#reads + 1] = { address = addr + i, flags = gg.TYPE_BYTE } end
    local result = gg.getValues(reads)
    local bytes = {}
    for _, v in ipairs(result) do
        if v.value == 0 then break end
        local b = v.value < 0 and v.value + 256 or v.value
        bytes[#bytes + 1] = string.char(b)
    end
    return table.concat(bytes)
end

local PART_CAPS = {
    ["_magnet"] = 15, ["_heavyweight"] = 15, ["_glide"] = 15,
    ["_rollcage"] = 15, ["_air_control"] = 15, ["_winter_tyres"] = 15,
    ["_start_boost"] = 10, ["_jump"] = 10, ["_wheelie_boost"] = 10,
    ["_fume_boost"] = 10, ["_flip_speed_boost"] = 10,
    ["_afterburner"] = 7, ["_turbo_boost"] = 7, ["_spoiler"] = 7,
    ["_perfect_landing_boost"] = 7,
    ["_thrusters"] = 4, ["_nitro"] = 4, ["_fuel_boost"] = 4, ["_coin_boost"] = 4,
}
local function partMaxLevel(name)
    name = tostring(name or "")
    for suffix, cap in pairs(PART_CAPS) do
        if name:find(suffix .. "$") then return cap end
    end
    return 3
end
local function checkGameStatus()
    if not BaseGameStatus or BaseGameStatus == 0 then
        gg.alert("❌ Chưa scan được GameStatus!\n\n💡 Vào Garage (bấm 1 xe) rồi chạy lại script.")
        return false
    end
    return true
end

local VERSION_OFFSETS = {
    ["1.74"] = { freezeDiamond = 0x21CC3F4, vnpStats = 0x1FBE5A0 },
    ["1.75"] = { freezeDiamond = 0x22049C4, vnpStats = 0x2060CA0 },
}
local function getOffsets()
    local v = gameVersion and gameVersion:match("^(%d+%.%d+)")
    return VERSION_OFFSETS[v] or VERSION_OFFSETS["1.75"]
end

-- ═══════════════════════════════════════════════════════════
--  VEHICLE SPEED (từ Android)
-- ═══════════════════════════════════════════════════════════
local Vehiclespeedchangeoffset = nil
local Vehiclegearshiftvalue = nil

local function VehicleSpeedSet(value)
    yj.CsetValuesoffset(Vehiclespeedchangeoffset + 0x8, 16, value)
    gg.toast("✅ Đã đặt tốc độ: " .. value)
end

local function VehicleSpeedCustom()
    local inp = gg.prompt({"Nhập tốc độ [-1.3 đến -0.6]:\n(-1.3 chậm nhất, -0.6 nhanh nhất)"},
        {tostring(Vehiclegearshiftvalue)}, {"number"})
    if not inp then return false end
    local v = tonumber(inp[1])
    if not v or v < -1.3 or v > -0.6 then
        gg.alert("❌ Tốc độ phải nằm trong khoảng -1.3 đến -0.6")
        return false
    end
    VehicleSpeedSet(v)
    return true
end

local function VehicleSpeedMenu()
    Vehiclespeedchangeoffset = Vehiclespeedchangeoffset or yj.Csearchcalculatestheoffset("h 11 11 91 3F 00 00 00 20", 8)
    if not Vehiclespeedchangeoffset then
        gg.alert("❌ Không tìm thấy địa chỉ bộ nhớ\n💡 Vào garage bấm 1 xe rồi thử lại.")
        return MainMenu()
    end
    gg.clearResults()
    Vehiclegearshiftvalue = gg.getValues({{address = Vehiclespeedchangeoffset + 0x8, flags = 16}})[1].value
    local items = {
        "✏️ Tự đặt tốc độ xe",
        "🚗 Đặt tốc độ: -1.05",
        "🚗 Đặt tốc độ: -1.00",
        "🚗 Đặt tốc độ: -0.95",
        "🚗 Đặt tốc độ: -0.90",
        "🚗 Đặt tốc độ: -0.85",
        "🚗 Đặt tốc độ: -0.80",
        "🔴 Tắt chỉnh tốc độ xe",
        "⬅️ Quay lại"
    }
    local c = gg.choice(items, nil, "🚗 Tốc độ hiện tại: " .. tostring(Vehiclegearshiftvalue))
    if not c or c == 9 then return MainMenu() end
    if c == 1 then
        VehicleSpeedCustom()
    elseif c >= 2 and c <= 7 then
        VehicleSpeedSet(0.05 * c - 1.15)
    elseif c == 8 then
        VehicleSpeedSet(-1.13333332539)
    end
    return VehicleSpeedMenu()
end

-- ═══════════════════════════════════════════════════════════
--  GLOBAL VISION (từ Android)
-- ═══════════════════════════════════════════════════════════
local Globalvisionoffset = nil
local Globalvisionoffsetvalue = nil

local function GlobalVisionSet(value)
    yj.CsetValuesoffset(Globalvisionoffset + 0x1C, 16, value)
    yj.CsetValuesoffset(Globalvisionoffset + 0x20, 16, value)
    gg.toast("✅ Đã đặt tầm nhìn: " .. value)
end

local function GlobalVisionCustom()
    local inp = gg.prompt({"Nhập tầm nhìn:"}, {tostring(Globalvisionoffsetvalue)}, {"number"})
    if not inp then return end
    local v = tonumber(inp[1])
    if not v then return end
    GlobalVisionSet(v)
end

local function GlobalVisionMenu()
    Globalvisionoffset = Globalvisionoffset or yj.Csearchcalculatestheoffset("h 0A D7 A3 3D 00 00 A0 41", 16)
    if not Globalvisionoffset then
        gg.alert("❌ Không tìm thấy địa chỉ bộ nhớ")
        return MainMenu()
    end
    gg.clearResults()
    Globalvisionoffsetvalue = gg.getValues({{address = Globalvisionoffset + 0x1C, flags = 16}})[1].value
    local items = {
        "✏️ Tự đặt tầm nhìn",
        "Tầm nhìn 20", "Tầm nhìn 40", "Tầm nhìn 60", "Tầm nhìn 80",
        "Tầm nhìn 100", "Tầm nhìn 120", "Tầm nhìn 140", "Tầm nhìn 160",
        "Tầm nhìn 180", "Tầm nhìn 200", "Tầm nhìn 220", "Tầm nhìn 240",
        "Tầm nhìn 260", "Tầm nhìn 280", "Tầm nhìn 300",
        "🔴 Tắt tầm nhìn toàn cục",
        "⬅️ Quay lại"
    }
    local c = gg.choice(items, nil, "👁️ Tầm nhìn hiện tại: " .. tostring(Globalvisionoffsetvalue))
    if not c or c == 18 then return MainMenu() end
    if c == 1 then
        GlobalVisionCustom()
    elseif c >= 2 and c <= 16 then
        GlobalVisionSet(c * 20 - 20)
    elseif c == 17 then
        yj.CsetValuesoffset(Globalvisionoffset + 0x1C, 16, 20)
        yj.CsetValuesoffset(Globalvisionoffset + 0x20, 16, 50)
        gg.toast("🔴 Đã tắt tầm nhìn toàn cục")
    end
    return GlobalVisionMenu()
end

-- ═══════════════════════════════════════════════════════════
--  TERRAIN FLAT (từ Android)
-- ═══════════════════════════════════════════════════════════
local TerrainFlatMenu

local function Terrain_Modify(searchPattern, replaceValue, msg, refinePattern)
    gg.clearResults()
    gg.setRanges(RANGE_VALUE)
    gg.searchNumber(searchPattern, 4)
    if refinePattern then gg.refineNumber(refinePattern, 4) end
    gg.getResults(100)
    gg.editAll(replaceValue, 4)
    gg.toast("✅ " .. msg)
    gg.clearResults()
    TerrainFlatMenu()
end

local function Terrain_EnableGlobalFlat()
    gg.clearResults(); gg.setRanges(8)
    gg.searchNumber("0.3", 16); gg.getResults(100)
    gg.editAll("999.762", 16)
    gg.toast("✅ Đã làm phẳng toàn bộ địa hình")
    gg.clearResults(); TerrainFlatMenu()
end
local function Terrain_DisableGlobalFlat()
    gg.clearResults(); gg.setRanges(8)
    gg.searchNumber("999.762", 16); gg.getResults(100)
    gg.editAll("0.3", 16)
    gg.toast("🔴 Đã tắt làm phẳng toàn bộ")
    gg.clearResults(); TerrainFlatMenu()
end

local function Terrain_Pastoralland()
    Terrain_Modify('1;1,116,471,296;1,106,247,680::9', '1,185,782,784', "Đồng quê phẳng", '1;1,116,471,296')
end
local function Terrain_Inthegarden()
    Terrain_Modify('2;1,101,004,800;1,084,227,584:9', '1,160,708,096', "Đồng quê trận 145", '1,101,004,800')
end
local function Terrain_Flatlandofspringwaterfall()
    Terrain_Modify('1;1,112,014,848;1,103,626,240::9', '1,185,782,784', "Thung lũng Thác Xuân phẳng", '1;1,112,014,848')
end
local function Terrain_ForestFlat()
    Terrain_Modify('1;1,117,126,656;1,108,082,688::9', '1,185,782,784', "Rừng phẳng", '1;1,117,126,656')
end
local function Terrain_ForestFlatBureau()
    Terrain_Modify('1,110,072,150', '1,259,902,592', "Rừng trận 180")
end
local function Terrain_Urbanflatland()
    Terrain_Modify('1;1,113,063,424;1,106,247,680::9', '1,185,782,784', "Thành phố phẳng", '1;1,113,063,424')
end
local function Terrain_InsidetheUrbanFlatLandBureau()
    Terrain_Modify('1,108,186,462', '1,259,902,592', "Thành phố trận 271")
end
local function Terrain_HighlandFlat()
    Terrain_Modify('1;1,119,092,736;1,117,782,016::9', '1,185,782,784', "Núi cao phẳng", '1;1,119,092,736')
end
local function Terrain_RustBucketFlat()
    Terrain_Modify('1;1,101,004,800;0;-1,082,130,432;-1,082,130,432:17', '1,185,782,784', "Rạn san hô phẳng", '1;1,101,004,800')
end
local function Terrain_WinterFlat()
    Terrain_Modify('1;1,112,014,848;1,106,247,680::9', '1,185,782,784', "Mùa đông phẳng", '1;1,112,014,848')
end
local function Terrain_MineFlat()
    Terrain_Modify('1;1,108,082,688;1,097,859,072::9', '1,185,782,784', "Mỏ phẳng", '1;1,108,082,688')
end
local function Terrain_DesertFlat()
    Terrain_Modify('1;1,116,471,296;1,106,247,680::9', '1,185,782,784', "Sa mạc phẳng", '1;1,116,471,296')
end
local function Terrain_BureauofDesertLand()
    Terrain_Modify('1,120,279,308', '1,259,902,592', "Sa mạc trận 764")
end

TerrainFlatMenu = function()
    local configs = {
        {name = "🌍 Làm phẳng toàn bộ địa hình", func = Terrain_EnableGlobalFlat},
        {name = "🔴 Tắt làm phẳng toàn bộ", func = Terrain_DisableGlobalFlat},
        {name = "🏡 Đồng quê", func = Terrain_Pastoralland},
        {name = "🏡 Đồng quê (trận 145)", func = Terrain_Inthegarden},
        {name = "🏞️ Thung lũng Thác Xuân", func = Terrain_Flatlandofspringwaterfall},
        {name = "🌲 Rừng", func = Terrain_ForestFlat},
        {name = "🌲 Rừng (trận 180)", func = Terrain_ForestFlatBureau},
        {name = "🏙️ Thành phố", func = Terrain_Urbanflatland},
        {name = "🏙️ Thành phố (trận 271)", func = Terrain_InsidetheUrbanFlatLandBureau},
        {name = "⛰️ Núi cao", func = Terrain_HighlandFlat},
        {name = "🪨 Rạn san hô", func = Terrain_RustBucketFlat},
        {name = "❄️ Mùa đông", func = Terrain_WinterFlat},
        {name = "⛏️ Mỏ", func = Terrain_MineFlat},
        {name = "🏜️ Sa mạc", func = Terrain_DesertFlat},
        {name = "🏜️ Sa mạc (trận 764)", func = Terrain_BureauofDesertLand},
        {name = "⬅️ Quay lại", func = function() MainMenu() end}
    }
    local labels = {}
    for i, c in ipairs(configs) do labels[i] = c.name end
    local c = gg.choice(labels, nil, "➖ Chỉnh địa hình phẳng (Advanced)")
    if c and configs[c] then configs[c].func() end
end

-- ═══════════════════════════════════════════════════════════
--  MAP MODIFICATION (từ Android)
-- ═══════════════════════════════════════════════════════════
local Allmappointersadd = nil
local ListofallmapsnamesandaddressesOptionsData = nil

local function AllmappointersaddObtain()
    gg.clearResults()
    gg.setRanges(RANGE_VALUE)
    gg.searchNumber("h 16 43 6F 75 6E 74 72 79 73 69 64 65", 1)
    local Countryside = gg.getResults(gg.getResultsCount())
    if #Countryside > 0 then
        for i, Characteristictype in ipairs(Countryside) do
            local Countryside2 = gg.getValues({{address = Characteristictype.address + 0x18, flags = 4}})[1].value
            if Countryside2 == 1970225942 then
                Allmappointersadd = Characteristictype.address
                break
            end
        end
    else
        return nil
    end
    if not Allmappointersadd then
        gg.alert("❌ Không tìm thấy địa chỉ bộ nhớ")
        return nil
    end
    gg.clearResults()
    gg.searchNumber(Allmappointersadd - 0x48, 32)
    local CountrysidePointers = gg.getResults(gg.getResultsCount())
    if #CountrysidePointers > 0 then
        for i, pointer in ipairs(CountrysidePointers) do
            if (pointer.address % 0x100) == 0 then
                Allmappointersadd = pointer.address
                break
            end
        end
    end
    return Allmappointersadd
end

local function Allmapnamesandaddressesgenerationtable()
    Allmappointersadd = Allmappointersadd or AllmappointersaddObtain()
    if not Allmappointersadd then return nil end
    local tbl = {}
    local offset = 0x0
    while offset < 0x1000 do
        local code = gg.getValues({{address = Allmappointersadd + offset, flags = 32}})[1].value
        if not code or code == 0 then break end
        local name = yj.getString(code + 0x49)
        if name == '' then
            local backupAddress = gg.getValues({{address = code + 0x58, flags = 32}})[1].value
            name = yj.getString(backupAddress)
        end
        if name == "" then break end
        tbl[#tbl + 1] = {name = name, address = code}
        offset = offset + 0x8
    end
    return tbl
end

-- Forward declarations
local SingleMapModificationfunction
local MapModificationArea

local function MapSceneReplace(sourceIdx)
    local items = {}
    for i, m in ipairs(ListofallmapsnamesandaddressesOptionsData) do items[i] = m.name end
    items[#items + 1] = "⬅️ Quay lại"
    local c = gg.choice(items, nil, "Chọn cảnh muốn thay vào " .. ListofallmapsnamesandaddressesOptionsData[sourceIdx].name)
    if not c or c == #items then return SingleMapModificationfunction(sourceIdx) end
    local srcAddr = ListofallmapsnamesandaddressesOptionsData[sourceIdx].address + 0x2C0
    local tgtAddr = ListofallmapsnamesandaddressesOptionsData[c].address + 0x2C0
    local vals = {}
    for i = 0, 11 do vals[i + 1] = gg.getValues({{address = tgtAddr + i * 4, flags = 4}})[1].value end
    local edits = {}
    for i = 1, 12 do edits[i] = {address = srcAddr + (i - 1) * 4, flags = 4, value = vals[i]} end
    gg.setValues(edits)
    gg.toast("✅ Đã thay cảnh")
    SingleMapModificationfunction(sourceIdx)
end

local function MapTerrainReplace(sourceIdx)
    local items = {}
    for i, m in ipairs(ListofallmapsnamesandaddressesOptionsData) do items[i] = m.name end
    items[#items + 1] = "⬅️ Quay lại"
    local c = gg.choice(items, nil, "Chọn địa hình muốn thay vào " .. ListofallmapsnamesandaddressesOptionsData[sourceIdx].name)
    if not c or c == #items then return SingleMapModificationfunction(sourceIdx) end
    local srcAddr = ListofallmapsnamesandaddressesOptionsData[sourceIdx].address + 0x1F0
    local tgtAddr = ListofallmapsnamesandaddressesOptionsData[c].address + 0x1F0
    local vals = {}
    for i = 0, 5 do vals[i + 1] = gg.getValues({{address = tgtAddr + i * 4, flags = 4}})[1].value end
    local edits = {}
    for i = 1, 6 do edits[i] = {address = srcAddr + (i - 1) * 4, flags = 4, value = vals[i]} end
    gg.setValues(edits)
    gg.toast("✅ Đã thay địa hình")
    SingleMapModificationfunction(sourceIdx)
end

SingleMapModificationfunction = function(sourceIdx)
    local mapName = ListofallmapsnamesandaddressesOptionsData[sourceIdx].name
    local items = {
        "🎬 Thay cảnh bản đồ: " .. mapName,
        "🏞️ Thay địa hình bản đồ: " .. mapName,
        "⬅️ Quay lại"
    }
    local c = gg.choice(items, nil, mapName .. " - Chỉnh sửa")
    if not c or c == 3 then
        local opts = {}
        for i, m in ipairs(ListofallmapsnamesandaddressesOptionsData) do opts[i] = m.name end
        opts[#opts + 1] = "🔄 Tải lại danh sách"
        opts[#opts + 1] = "⬅️ Quay lại"
        local cc = gg.choice(opts, nil, "🗺️ Chọn bản đồ")
        if not cc then return end
        if cc == #opts then return MapModificationArea()
        elseif cc == #opts - 1 then
            ListofallmapsnamesandaddressesOptionsData = Allmapnamesandaddressesgenerationtable()
            if ListofallmapsnamesandaddressesOptionsData then
                return SingleMapModificationfunction(1)
            end
            return MapModificationArea()
        else
            return SingleMapModificationfunction(cc)
        end
    end
    if c == 1 then MapSceneReplace(sourceIdx)
    elseif c == 2 then MapTerrainReplace(sourceIdx) end
end

local function AllMapThrust()
    local inp = gg.prompt({"Lực đẩy cho tất cả bản đồ:"}, {"10"}, {"number"})
    if not inp then return MapModificationArea() end
    local val = tonumber(inp[1])
    if not val then return MapModificationArea() end
    local edits = {}
    local off = 0
    while true do
        local code = gg.getValues({{address = Allmappointersadd + off, flags = 32}})[1].value
        if not code or code == 0 then break end
        edits[#edits + 1] = {address = code + 0x120, flags = 16, value = val}
        off = off + 8
    end
    if #edits > 0 then gg.setValues(edits) end
    gg.clearResults()
    gg.toast("✅ Đã đặt lực đẩy: " .. val)
    MapModificationArea()
end

local function AllMapDownforce()
    local items = {
        "✏️ Tự đặt lực ép",
        "Lực ép -20", "Lực ép -30", "Lực ép -40", "Lực ép -50",
        "Lực ép -60", "Lực ép -70", "Lực ép -80", "Lực ép -90",
        "Lực ép -100", "Lực ép -110", "Lực ép -120",
        "🔄 Khôi phục (-10)",
        "⬅️ Quay lại"
    }
    local c = gg.choice(items, nil, "⬇️ Chỉnh lực ép")
    if not c or c == 14 then return MapModificationArea() end
    local val
    if c == 1 then
        local inp = gg.prompt({"Lực ép:"}, {"-10"}, {"number"})
        if not inp then return AllMapDownforce() end
        val = tonumber(inp[1])
    elseif c >= 2 and c <= 12 then
        val = -c * 10
    elseif c == 13 then
        val = -10
    end
    if not val then return AllMapDownforce() end
    local edits = {}
    local off = 0
    while true do
        local code = gg.getValues({{address = Allmappointersadd + off, flags = 32}})[1].value
        if not code or code == 0 then break end
        edits[#edits + 1] = {address = code + 0x124, flags = 16, value = val}
        off = off + 8
    end
    if #edits > 0 then gg.setValues(edits) end
    gg.clearResults()
    gg.toast("✅ Đã đặt lực ép: " .. val)
    AllMapDownforce()
end

local function Thedistancebetweenthefuelandthegold()
    local inp = gg.prompt({"Khoảng cách nhiên liệu và vàng [5-50]:"}, {"10"}, {"number"})
    if not inp then return MapModificationArea() end
    local val = tonumber(inp[1])
    if not val then return MapModificationArea() end
    local edits = {}
    local off = 0
    while true do
        local code = gg.getValues({{address = Allmappointersadd + off, flags = 32}})[1].value
        if not code or code == 0 then break end
        edits[#edits + 1] = {address = code + 0x138, flags = 16, value = val}
        off = off + 8
    end
    if #edits > 0 then gg.setValues(edits) end
    gg.clearResults()
    gg.toast("✅ Đã đặt khoảng cách: " .. val)
    MapModificationArea()
end

MapModificationArea = function()
    ListofallmapsnamesandaddressesOptionsData = ListofallmapsnamesandaddressesOptionsData or Allmapnamesandaddressesgenerationtable()
    if not ListofallmapsnamesandaddressesOptionsData then
        gg.alert("❌ Không tìm thấy địa chỉ bộ nhớ")
        return MainMenu()
    end
    local items = {
        "✏️ Chỉnh sửa một bản đồ",
        "💨 Lực đẩy tất cả bản đồ",
        "⬇️ Lực ép tất cả bản đồ",
        "📏 Khoảng cách nhiên liệu và vàng",
        "⬅️ Quay lại"
    }
    local c = gg.choice(items, nil, "🗺️ Khu vực chỉnh sửa bản đồ")
    if not c or c == 5 then return MainMenu() end
    if c == 1 then
        local opts = {}
        for i, m in ipairs(ListofallmapsnamesandaddressesOptionsData) do opts[i] = m.name end
        opts[#opts + 1] = "🔄 Tải lại danh sách"
        opts[#opts + 1] = "⬅️ Quay lại"
        local cc = gg.choice(opts, nil, "🗺️ Chọn bản đồ")
        if not cc then return MapModificationArea() end
        if cc == #opts then return MapModificationArea()
        elseif cc == #opts - 1 then
            ListofallmapsnamesandaddressesOptionsData = Allmapnamesandaddressesgenerationtable()
            return MapModificationArea()
        else
            SingleMapModificationfunction(cc)
        end
    elseif c == 2 then AllMapThrust()
    elseif c == 3 then AllMapDownforce()
    elseif c == 4 then Thedistancebetweenthefuelandthegold() end
end

-- ═══════════════════════════════════════════════════════════
--  HACK CƠ BẢN
-- ═══════════════════════════════════════════════════════════
local noScrapState = false
local function upgradeWithoutScrap()
    local choice = gg.choice({
        "🟢 Bật Upgrade Without Scrap","🔴 Tắt Upgrade Without Scrap","⬅️ Quay lại"
    }, nil, "Trạng thái: " .. (noScrapState and "🟢 ON" or "🔴 OFF"))
    if not choice or choice == 3 then return MainMenu() end
    if choice == 1 then
        gg.clearResults(); gg.setRanges(RANGE_VALUE)
        gg.searchNumber("2139095039D;-0.6F::17", gg.TYPE_FLOAT)
        gg.refineNumber("-0.6", gg.TYPE_FLOAT)
        local res = gg.getResults(gg.getResultsCount())
        if #res == 0 then gg.alert("❌ Không tìm thấy! Vào garage trước."); return end
        gg.editAll("-999", gg.TYPE_FLOAT)
        gg.clearResults(); noScrapState = true
        gg.alert("✅ Đã bật!")
    elseif choice == 2 then
        if not noScrapState then gg.alert("❌ Chưa bật!"); return end
        gg.clearResults(); gg.setRanges(RANGE_VALUE)
        gg.searchNumber("2139095039D;-999F::17", gg.TYPE_FLOAT)
        gg.refineNumber("-999", gg.TYPE_FLOAT)
        if gg.getResultsCount() > 0 then
            gg.editAll("-0.60000002384", gg.TYPE_FLOAT)
            noScrapState = false
            gg.alert("❌ Đã tắt!")
        end
    end
end

local flyState = false
local function flyHack()
    local choice = gg.choice({
        "🟢 Bật Fly Hack","🔴 Tắt Fly Hack","⬅️ Quay lại"
    }, nil, "Trạng thái: " .. (flyState and "🟢 ON" or "🔴 OFF"))
    if not choice or choice == 3 then return MainMenu() end
    if choice == 1 then
        gg.clearResults(); gg.setRanges(gg.REGION_C_BSS)
        for _, v in ipairs({"-0.75", "-0.55", "-0.25", "-0.15"}) do
            gg.searchNumber(v, gg.TYPE_FLOAT)
            gg.getResults(2)
            gg.editAll("0.08", gg.TYPE_FLOAT)
            gg.clearResults()
        end
        gg.searchNumber("0.08", gg.TYPE_FLOAT)
        local res = gg.getResults(2)
        if #res > 0 then
            gg.editAll("-1.2", gg.TYPE_FLOAT)
            flyState = true
            gg.alert("✅ Đã bật!")
        else gg.alert("❌ Không tìm thấy!") end
        gg.setRanges(RANGE_VALUE)
    elseif choice == 2 then
        if not flyState then gg.alert("❌ Chưa bật!"); return end
        gg.clearResults(); gg.setRanges(gg.REGION_C_BSS)
        gg.searchNumber("-1.2", gg.TYPE_FLOAT)
        if gg.getResultsCount() > 0 then
            gg.editAll("0.08", gg.TYPE_FLOAT)
            flyState = false
            gg.alert("❌ Đã tắt!")
        end
        gg.setRanges(RANGE_VALUE)
    end
end

-- ═══════════════════════════════════════════════════════════
--  UNLOCK VEHICLE
-- ═══════════════════════════════════════════════════════════
local VEHICLES = {
    "ALL","HILL CLIMBER","HILL CLIMBER Mk2","SPORTS CAR","DUNE BUGGY","SUPER DIESEL","SUPERBIKE","SUPERCAR","RALLY CAR","LOWRIDER","BEAST","HOT ROD","RACING TRUCK","FORMULA","MUSCLE CAR","MONSTER TRUCK","ROTATOR","CHOPPER","TANK","CC-EV","STOCKER","HAVOC","BUS","MOONLANDER","HOVERBIKE","ROCK BOUNCER","RAIDER","BOLT","ATV","OFFROADER","SCOOTER","MOTOCROSS","TRACTOR","SNOWMOBILE","MONOWHEEL","GLIDER"
}
local function unlockVehicleByName(name)
    if not name or name == "" then return false end
    gg.clearResults(); gg.setRanges(RANGE_VALUE)
    gg.searchNumber(":" .. name, gg.TYPE_BYTE)
    local getRes = gg.getResults(gg.getResultsCount())
    if #getRes == 0 then return false end
    local tbl = {}
    for _, v in ipairs(getRes) do table.insert(tbl, {address = v.address + 0xEF, flags = gg.TYPE_DWORD}) end
    gg.clearResults(); gg.loadResults(tbl)
    gg.refineNumber("1~5", gg.TYPE_DWORD)
    local unlocked = gg.getResults(gg.getResultsCount())
    if #unlocked == 0 then return false end
    gg.editAll("1", gg.TYPE_DWORD)
    local edits = {}
    for _, v in ipairs(unlocked) do
        table.insert(edits, {address = v.address + 0x38, flags = gg.TYPE_DWORD, value = 0})
        for i = 1, 13 do
            table.insert(edits, {address = v.address + (i * 4), flags = gg.TYPE_DWORD, value = 0})
        end
    end
    gg.setValues(edits); gg.clearResults()
    return true
end
local function unlockAnyVehicle()
    local menu = {}
    for _, v in ipairs(VEHICLES) do table.insert(menu, "🚗 " .. v) end
    table.insert(menu, "⬅️ Quay lại")
    local pick = gg.multiChoice(menu, nil, "☑️ Chọn nhiều xe để mở khóa")
    if not pick then return MainMenu() end
    local count = 0
    for i, sel in pairs(pick) do
        if sel and i <= #VEHICLES then
            if unlockVehicleByName(VEHICLES[i]) then count = count + 1 end
        end
    end
    if count > 0 then gg.alert("✅ Đã mở khóa " .. count .. " xe!")
    else gg.alert("❌ Không mở khóa được xe nào!") end
end

-- ═══════════════════════════════════════════════════════════
--  TRACKS EDITOR
-- ═══════════════════════════════════════════════════════════
local function tracksEditor()
    local input = gg.prompt({
        "🗺️ Tên Map (VD: Countryside):","📏 Độ dài hiện tại (m):","📐 Độ dài mới (m):","✅ Enable Verify"
    }, {"", "", "", true}, {"text", "number", "number", "checkbox"})
    if not input then return MainMenu() end
    local mapName = input[1]; local curLength = tonumber(input[2])
    local newLength = tonumber(input[3]); local doVerify = input[4]
    if not mapName or mapName == "" or not curLength or not newLength then
        gg.alert("❌ Nhập thiếu thông tin!"); return
    end
    gg.clearResults(); gg.setRanges(RANGE_VALUE)
    gg.searchNumber(":" .. mapName, gg.TYPE_BYTE)
    if gg.getResultsCount() == 0 then gg.alert("❌ Không tìm thấy map: " .. mapName); return end
    gg.refineNumber(string.byte(mapName:sub(1, 1)), gg.TYPE_BYTE)
    local results = gg.getResults(30)
    if #results == 0 then gg.alert("⚠️ Refine thất bại!"); return end
    local patched = 0
    for _, r in ipairs(results) do
        gg.clearResults(); gg.searchNumber(r.address - 1, 32)
        local ptrs = gg.getResults(100)
        for _, p in ipairs(ptrs) do
            local lengthAddr = p.address + 0x20
            local verifyAddr = p.address + 0x34
            local curVal = gg.getValues({{address = lengthAddr, flags = gg.TYPE_DWORD}})[1].value
            if curVal == curLength then
                gg.setValues({{address = lengthAddr, flags = gg.TYPE_DWORD, value = newLength}})
                if doVerify then
                    gg.setValues({{address = verifyAddr, flags = gg.TYPE_DWORD, value = 1}})
                end
                patched = patched + 1
            end
        end
    end
    if patched > 0 then gg.alert("✅ Đã patch " .. patched .. " entries!")
    else gg.alert("❌ Không match!") end
end

-- ═══════════════════════════════════════════════════════════
--  VEHICLE HACKS
-- ═══════════════════════════════════════════════════════════
local VehicleHacks = {
    f1  = { name = "Lowrider - Super Jumpshocks", search = 'Q 00 00 A0 "A" 00 80 40 66 66 06 41', replace = 'Q 00 00 A0 "A" 00 80 "@" 00 C8 41', state = false, results = nil },
    f2  = { name = "Hot Rod - Boost Hack", search = "4620693218774745088", replace = "4620693218877722624", state = false, results = nil },
    f3  = { name = "CC-EV - Super Boost", search = 'Q 00 00 A0 "A" 00 08 "A" 00 48 41', replace = 'Q 00 00 A0 "A" 00 08 "A" 00 C8 42', state = false, results = nil },
    f4  = { name = "Glider - Infinite Propeller", search = 'Q 00 00 A0 "A" 00 C0 "?" 00 40 40', replace = 'Q 00 00 A0 "A" 00 C0 3F 28 6B EE 4E', state = false, results = nil },
    f5  = { name = "Muscle Car - Engine Hack", search = '20f;34f;44f:9', refine = '44', replace = '220', state = false, results = nil },
    f6  = { name = "Glider - Infinite Wing", search = 'Q 00 00 A0 "A" 00 A0 "@" 00 20 41', replace = 'Q 00 00 A0 "A" 00 A0 40 66 7F E2 4E', state = false, results = nil },
    f7  = { name = "Muscle Car - Super Burn-Out", search = 'Q 00 00 A0 "A" 00 60 "@" 00 D0 40', replace = 'Q 00 00 A0 "A" 00 60 "@" 00 FA 43', state = false, results = nil },
    f8  = { name = "Rally Car - Grip Hack", search = '0.8;1.2:5', refine = '1.2', replace = '999', state = false, results = nil },
    f9  = { name = "Formula - Super Grip", search = 'Q 00 00 A0 41 CD CC CC ">" 00 C0 3F', replace = 'Q 00 00 A0 41 CD CC CC ">" 00 70 41', state = false, results = nil },
    f10 = { name = "Supercar - Super Air Brake", search = 'Q 00 00 A0 "A" 00 A0 C0 00 00 A0 C1', replace = 'Q 00 00 A0 "A" 00 A0 C0 00 00 C8 C2', state = false, results = nil },
    f11 = { name = "Supercar - Reverse Air Brake", search = 'Q 00 00 A0 "A" 00 A0 C0 00 00 A0 C1', replace = 'Q 00 00 A0 "A" 00 A0 C0 00 00 8C 42', state = false, results = nil },
    f12 = { name = "Rally Car - Engine Hack", search = '10;25:5', refine = '25', replace = '999', state = false, results = nil },
    f13 = { name = "Muscle Car - Downforce + Fuel", search = '43.0;1.27999997139;2.0;0.69999998808;25.0:49', refine = '43', replace = '1000', state = false, results = nil }
}
local function toggleVehicleHack(key)
    local data = VehicleHacks[key]
    if not data then return end
    local choice = gg.choice({"🟢 BẬT","🔴 TẮT","⬅️ Quay lại"}, nil,
        "🔧 " .. data.name .. "\nTrạng thái: " .. (data.state and "🟢 ON" or "🔴 OFF"))
    if not choice or choice == 3 then return end
    local vType = gg.TYPE_FLOAT
    local s = tostring(data.search)
    if s:sub(1,2) == "Q " then vType = gg.TYPE_BYTE
    elseif s:find(";") then vType = gg.TYPE_FLOAT
    elseif not s:find("%.") then
        if #s > 10 then vType = gg.TYPE_QWORD else vType = gg.TYPE_DWORD end
    end
    if choice == 1 then
        gg.clearResults(); gg.setRanges(RANGE_VALUE)
        gg.searchNumber(data.search, vType)
        if data.refine and gg.getResultsCount() > 0 then gg.refineNumber(data.refine, vType) end
        local count = gg.getResultsCount()
        if count == 0 then gg.alert("❌ Không tìm thấy! Vào xe này trước.")
        else
            local results = gg.getResults(count)
            data.results = gg.getValues(results)
            gg.editAll(data.replace, vType)
            data.state = true; gg.clearResults()
            gg.toast("✅ Đã bật: " .. data.name)
        end
    elseif choice == 2 then
        if data.results then
            gg.setValues(data.results)
            data.state = false
            gg.toast("❌ Đã tắt: " .. data.name)
        else gg.alert("❌ Chưa bật!") end
    end
end
local function vehicleHacksMenu()
    local keys = {}
    for k in pairs(VehicleHacks) do table.insert(keys, k) end
    table.sort(keys, function(a, b) return tonumber(a:match("%d+")) < tonumber(b:match("%d+")) end)
    local labels = {}
    local n = 1
    for _, k in ipairs(keys) do
        local v = VehicleHacks[k]
        table.insert(labels, (v.state and "🟢" or "⚫") .. " " .. n .. ". " .. v.name)
        n = n + 1
    end
    table.insert(labels, "⬅️ Quay lại")
    local pick = gg.choice(labels, nil, nil)
    if not pick or pick == #labels then return MainMenu() end
    toggleVehicleHack(keys[pick])
    return vehicleHacksMenu()
end

-- ═══════════════════════════════════════════════════════════
--  SHOP / CHEST
-- ═══════════════════════════════════════════════════════════
local freeChestsFound = false
local freeChestsOriginal = {}
local function freeChests()
    local choice = gg.choice({"🟢 Bật Free Chests","🔴 Tắt Free Chests","⬅️ Quay lại"},
        nil, "Trạng thái: " .. (freeChestsFound and "🟢 ON" or "🔴 OFF"))
    if not choice or choice == 3 then return MainMenu() end
    if choice == 1 then
        if not freeChestsFound then
            gg.clearResults(); gg.setRanges(gg.REGION_C_DATA)
            gg.searchNumber("0.1", gg.TYPE_FLOAT)
            local count = gg.getResultCount()
            if count == 0 then gg.alert("❌ Không tìm thấy!"); gg.setRanges(RANGE_VALUE); return end
            local res = gg.getResults(count)
            freeChestsOriginal = gg.getValues(res)
            local nv = {}
            for i, v in ipairs(res) do nv[i] = {address = v.address, flags = v.flags, value = "0"} end
            gg.setValues(nv); freeChestsFound = true
            gg.setRanges(RANGE_VALUE); gg.alert("✅ Đã bật!")
        else gg.toast("✅ Đã bật rồi!") end
    elseif choice == 2 then
        if freeChestsFound and #freeChestsOriginal > 0 then
            gg.setValues(freeChestsOriginal); freeChestsFound = false
            gg.setRanges(RANGE_VALUE); gg.alert("❌ Đã tắt!")
        else gg.alert("❌ Chưa bật!") end
    end
end

local function freePurchases()
    local c = gg.choice({"▶️ TIẾP TỤC","⬅️ Quay lại"}, nil, "⚠️ Cần kết nối Google Play!\nĐang ở Shop của game?")
    if c ~= 1 then return MainMenu() end
    gg.clearResults(); gg.setRanges(RANGE_VALUE)
    gg.searchNumber("7,234,820", gg.TYPE_DWORD)
    local results = gg.getResults(100)
    if #results == 0 then gg.alert("❌ Không tìm thấy! Vào Shop trước."); return end
    for _, v in ipairs(results) do
        gg.clearResults(); gg.searchNumber(v.address, gg.TYPE_QWORD)
        local ptrs = gg.getResults(100)
        for _, vv in ipairs(ptrs) do
            local val = gg.getValues({{address = vv.address + 0x18, flags = 4}})[1].value
            if val > 0 and val < 100 then
                local edits = {}
                for off = 0x18, 0x2C, 4 do
                    table.insert(edits, {address = vv.address + off, flags = 4, value = 0})
                end
                gg.setValues(edits)
            end
        end
    end
    gg.alert("✅ Đã bật Free Purchases!")
end

local function partsDropLegendary()
    gg.clearResults(); gg.setRanges(RANGE_VALUE)
    gg.searchNumber("1000;9::5", gg.TYPE_DWORD)
    gg.refineNumber("9", gg.TYPE_DWORD)
    gg.getResults(gg.getResultsCount()); gg.editAll(7, gg.TYPE_DWORD)
    gg.clearResults(); gg.setRanges(RANGE_VALUE)
    gg.searchNumber("1;1;1;1;60;0;1036831949::25", gg.TYPE_DWORD)
    gg.refineNumber("60", gg.TYPE_DWORD)
    if gg.getResultCount() == 0 then gg.alert("❌ Không tìm thấy!"); return end
    local results = gg.getResults(1)
    local baseAddr = results[1].address
    local scanTbl = {}
    for i = -32, 32 do table.insert(scanTbl, {address = baseAddr + (i * 4), flags = gg.TYPE_DWORD}) end
    local values = gg.getValues(scanTbl)
    local final = {}
    for _, v in ipairs(values) do
        if v.value >= 1 and v.value <= 50 then v.value = 9999; table.insert(final, v) end
    end
    if #final > 0 then gg.setValues(final); gg.clearResults(); gg.alert("✅ Đã bật!\nMở Legendary Chest!")
    else gg.alert("❌ Không có giá trị hợp lệ!") end
end

-- ═══════════════════════════════════════════════════════════
--  ADVENTURE
-- ═══════════════════════════════════════════════════════════
local advChestV1Found = false
local advChestV1Original = nil
local function advChestHackV1()
    local choice = gg.choice({"🟢 Bật Rising Chest Levels","🔴 Tắt Rising Chest Levels","⬅️ Quay lại"},
        nil, "Trạng thái: " .. (advChestV1Found and "🟢 ON" or "🔴 OFF"))
    if not choice or choice == 3 then return MainMenu() end
    if choice == 1 then
        if not advChestV1Found then
            gg.clearResults(); gg.setRanges(RANGE_VALUE)
            gg.searchNumber("500;500::5", gg.TYPE_DWORD)
            local count = gg.getResultsCount()
            if count == 0 then gg.alert("❌ Không tìm thấy!"); return end
            local res = gg.getResults(count)
            advChestV1Original = gg.getValues(res)
            local edits = {}
            for i, v in ipairs(res) do edits[i] = {address = v.address, flags = v.flags, value = -1} end
            gg.setValues(edits); advChestV1Found = true; gg.alert("✅ Đã bật!")
        else gg.alert("✅ Đã bật rồi!") end
    elseif choice == 2 then
        if advChestV1Found then
            gg.setRanges(RANGE_VALUE); gg.setValues(advChestV1Original)
            advChestV1Found = false; gg.alert("❌ Đã tắt!")
        else gg.alert("❌ Chưa bật!") end
    end
end

local function flatGroundAdventure()
    local choice = gg.choice({
        "1. Adventure Maps (General)","2. City","3. Forest","4. Winter",
        "5. Savanna","6. Beach","7. Gloomvale","⬅️ Quay lại"
    }, nil, "➖ Flat Ground for Adventure")
    if not choice or choice == 8 then return MainMenu() end
    local function toggle(search, enableVal, disableVal, ranges)
        gg.clearResults()
        if ranges then gg.setRanges(ranges) else gg.setRanges(RANGE_VALUE) end
        gg.searchNumber(search, gg.TYPE_DWORD)
        if gg.getResultsCount() == 0 then gg.alert("❌ Không tìm thấy!"); return end
        local val = gg.choice({"✅ Enable","❌ Disable"}, nil, "Toggle Flat Ground")
        if val == 1 then gg.editAll(enableVal, gg.TYPE_DWORD); gg.alert("✅ Đã bật!")
        elseif val == 2 then gg.editAll(disableVal, gg.TYPE_DWORD); gg.alert("❌ Đã tắt!") end
        gg.setRanges(RANGE_VALUE)
    end
    if choice == 1 then
        gg.clearResults(); gg.setRanges(gg.REGION_C_DATA)
        gg.searchNumber("0.7", gg.TYPE_FLOAT)
        if gg.getResultsCount() == 0 then gg.alert("❌ Không tìm thấy!"); gg.setRanges(RANGE_VALUE); return end
        local opt = gg.choice({"✅ Enable","❌ Disable"}, nil, "Flat Ground General")
        if opt == 1 then gg.editAll(9999, gg.TYPE_FLOAT); gg.alert("✅ Đã bật!")
        elseif opt == 2 then gg.editAll(0.7, gg.TYPE_FLOAT); gg.alert("❌ Đã tắt!") end
        gg.setRanges(RANGE_VALUE)
    elseif choice == 2 then toggle("1123132079", 1206423683, 1123132079, gg.REGION_C_ALLOC | gg.REGION_C_DATA | gg.REGION_C_BSS)
    elseif choice == 3 then toggle("1109006215", 1223132079, 1109006215, gg.REGION_C_ALLOC | gg.REGION_C_BSS)
    elseif choice == 4 then toggle("1120232603", 1197191296, 1120232603, gg.REGION_C_ALLOC | gg.REGION_C_DATA | gg.REGION_C_BSS)
    elseif choice == 5 then toggle("1116330252", 1148436480, 1116330252, gg.REGION_C_ALLOC | gg.REGION_C_DATA | gg.REGION_C_BSS)
    elseif choice == 6 then toggle("1125450835", 1142292480, 1125450835, gg.REGION_C_ALLOC | gg.REGION_C_DATA | gg.REGION_C_BSS)
    elseif choice == 7 then toggle("1113060784", 1144750080, 1113060784, RANGE_VALUE) end
end

-- ═══════════════════════════════════════════════════════════
--  LIB PATCH
-- ═══════════════════════════════════════════════════════════
local libOffsets = {
    ["arm64-v8a"] = {
        [1] = { name = "Auto Win", edits = {
            {0x10F1844, "55008052r"}, {0x10F1A60, "0990321Er"},
            {0x1AC541C, "00008052r"}, {0x2234EA8, "00000000r"}
        }},
        [2] = { name = "Fake Unlock", edits = {{0x15180D0, "20008052r"}} },
        [3] = { name = "Free Upgrade", edits = {{0xEC2F6C, "0090641Er"},{0xEC2F88, "0090641Er"}} },
    }
}
local function getArchKey()
    if archType == 1 then return "arm64-v8a"
    elseif archType == 2 then return "armeabi-v7a"
    elseif archType == 3 then return "x86_64"
    elseif archType == 4 then return "x86" end
    return nil
end
local function applyLibEdits(entry, backupTable, enable)
    if not entry or not entry.edits or #entry.edits == 0 then return false end
    if not LIB_BASE then gg.alert("❌ LIB_BASE chưa có!"); return false end
    if enable then
        for i, e in ipairs(entry.edits) do
            local off = e[1]; local strV = tostring(e[2])
            local isRel = strV:sub(-1) == "r"
            local addr = isRel and (LIB_BASE + off) or off
            local orig = gg.getValues({{address = addr, flags = gg.TYPE_DWORD}})
            if orig and orig[1] then backupTable[i] = {address = addr, value = orig[1].value} end
            if not pcall(function() gg.setValues({{address = addr, flags = gg.TYPE_DWORD, value = strV}}) end) then
                return false
            end
        end
        return true
    else
        if not backupTable or not next(backupTable) then return false end
        local restore = {}
        for _, b in pairs(backupTable) do
            restore[#restore + 1] = {address = b.address, flags = gg.TYPE_DWORD, value = b.value}
        end
        if #restore > 0 then gg.setValues(restore) end
        return true
    end
end

local autoWinState, autoWinBackup = false, nil
local fakeUnlockState, fakeUnlockBackup = false, nil
local freeUpgradeState, freeUpgradeBackup = false, nil

local function autoWin()
    if archType == 3 or archType == 4 then gg.alert("❗ Chỉ ARM (ARMV8)!"); return end
    local archKey = getArchKey()
    if not archKey or not libOffsets[archKey] then gg.alert("❌ Không có offset cho arch!"); return end
    local entry = libOffsets[archKey][1]
    if not entry then gg.alert("❌ Entry trống!"); return end
    local choice = gg.choice({"🟢 Bật Auto Win","🔴 Tắt Auto Win","⬅️ Quay lại"}, nil,
        "🔥 " .. entry.name .. "\n📦 " .. #entry.edits .. " patches | " .. archKey ..
        "\nTrạng thái: " .. (autoWinState and "🟢 ON" or "🔴 OFF"))
    if not choice or choice == 3 then return MainMenu() end
    if choice == 1 then
        if autoWinState then gg.toast("✅ Đã bật rồi!"); return end
        autoWinBackup = {}
        if applyLibEdits(entry, autoWinBackup, true) then autoWinState = true; gg.toast("✅ Auto Win BẬT")
        else autoWinBackup = nil; gg.alert("❌ Bật thất bại!") end
    elseif choice == 2 then
        if not autoWinState then gg.alert("❌ Chưa bật!"); return end
        if applyLibEdits(entry, autoWinBackup, false) then autoWinState = false; autoWinBackup = nil; gg.toast("❌ Auto Win TẮT")
        else gg.alert("❌ Tắt thất bại!") end
    end
end

local function fakeUnlock()
    if archType == 3 or archType == 4 then gg.alert("❗ Chỉ ARM!"); return end
    local archKey = getArchKey()
    if not archKey or not libOffsets[archKey] then gg.alert("❌ Không có offset!"); return end
    local entry = libOffsets[archKey][2]
    if not entry then gg.alert("❌ Entry trống!"); return end
    local choice = gg.choice({"🟢 Bật Fake Unlock","🔴 Tắt Fake Unlock","⬅️ Quay lại"}, nil,
        "🎭 " .. entry.name .. "\n📦 " .. #entry.edits .. " patches\n⚠️ KHÔNG mở khóa thật!")
    if not choice or choice == 3 then return MainMenu() end
    if choice == 1 then
        if fakeUnlockState then gg.toast("✅ Đã bật rồi!"); return end
        fakeUnlockBackup = {}
        if applyLibEdits(entry, fakeUnlockBackup, true) then fakeUnlockState = true; gg.toast("✅ Fake Unlock BẬT")
        else fakeUnlockBackup = nil; gg.alert("❌ Bật thất bại!") end
    elseif choice == 2 then
        if not fakeUnlockState then gg.alert("❌ Chưa bật!"); return end
        if applyLibEdits(entry, fakeUnlockBackup, false) then fakeUnlockState = false; fakeUnlockBackup = nil; gg.toast("❌ TẮT")
        else gg.alert("❌ Tắt thất bại!") end
    end
end

local function freeUpgrade()
    if archType == 3 or archType == 4 then gg.alert("❗ Chỉ ARM!"); return end
    local archKey = getArchKey()
    if not archKey or not libOffsets[archKey] then gg.alert("❌ Không có offset!"); return end
    local entry = libOffsets[archKey][3]
    if not entry then gg.alert("❌ Entry trống!"); return end
    local choice = gg.choice({"🟢 Bật Free Upgrade","🔴 Tắt Free Upgrade","⬅️ Quay lại"}, nil,
        "🔧 " .. entry.name .. "\n📦 " .. #entry.edits .. " patches")
    if not choice or choice == 3 then return MainMenu() end
    if choice == 1 then
        if freeUpgradeState then gg.toast("✅ Đã bật rồi!"); return end
        freeUpgradeBackup = {}
        if applyLibEdits(entry, freeUpgradeBackup, true) then freeUpgradeState = true; gg.toast("✅ Free Upgrade BẬT")
        else freeUpgradeBackup = nil; gg.alert("❌ Bật thất bại!") end
    elseif choice == 2 then
        if not freeUpgradeState then gg.alert("❌ Chưa bật!"); return end
        if applyLibEdits(entry, freeUpgradeBackup, false) then freeUpgradeState = false; freeUpgradeBackup = nil; gg.toast("❌ TẮT")
        else gg.alert("❌ Tắt thất bại!") end
    end
end

-- ═══════════════════════════════════════════════════════════
--  DEBUG MODE
-- ═══════════════════════════════════════════════════════════
local function debugMode()
    local choice = gg.choice({"🟢 Bật Debug Mode","🔴 Tắt Debug Mode","⬅️ Quay lại"}, nil, "💎 Play Hidden Maps")
    if not choice or choice == 3 then return MainMenu() end
    gg.clearResults(); gg.setRanges(gg.REGION_C_ALLOC | gg.REGION_C_DATA)
    gg.searchNumber("h 24 64 65 62 75 67 5F 6D 6F 64 65 5F 65 6E 61 62 6C 65 64", gg.TYPE_BYTE)
    if gg.getResultCount() == 0 then gg.alert("❌ Không tìm thấy!"); gg.setRanges(RANGE_VALUE); return end
    local res = gg.getResults(1)
    local ptrData = gg.getValues({{address = res[1].address + 0x20, flags = gg.TYPE_QWORD}})
    if not ptrData[1] or ptrData[1].value == 0 then gg.alert("❌ Không tìm thấy pointer!"); gg.setRanges(RANGE_VALUE); return end
    local flagAddr = ptrData[1].value
    if choice == 1 then gg.setValues({{address = flagAddr, flags = gg.TYPE_BYTE, value = 1}}); gg.alert("✅ Đã bật!")
    elseif choice == 2 then gg.setValues({{address = flagAddr, flags = gg.TYPE_BYTE, value = 0}}); gg.alert("❌ Đã tắt!") end
    gg.setRanges(RANGE_VALUE)
end

-- ═══════════════════════════════════════════════════════════
--  VIP PASS
-- ═══════════════════════════════════════════════════════════
local VIPM = {}
function VIPM.readPtr(a) local v = gg.getValues({{address = a, flags = gg.TYPE_QWORD}}); return (v and v[1]) and v[1].value or 0 end
VIPM._main = nil
function VIPM.mainStatus()
    if VIPM._main then return VIPM._main end
    gg.setVisible(false); gg.clearResults(); gg.clearList()
    gg.setRanges(gg.REGION_C_ALLOC)
    gg.searchNumber("Q 1A 73 74 61 72 74 75 70 5F 63 6F 75", gg.TYPE_BYTE)
    gg.refineNumber("26", gg.TYPE_BYTE)
    local results = gg.getResults(gg.getResultCount()); gg.clearResults()
    if not results or #results == 0 then return nil end
    for _, v in ipairs(results) do
        local p20 = VIPM.readPtr(v.address + 0x20)
        if p20 ~= 0 then
            local p80 = VIPM.readPtr(p20 + 0x80)
            if p80 ~= 0 then VIPM._main = p80; return p80 end
        end
    end
    return nil
end
local function vipPassFunc()
    local res = gg.prompt({"⭐ Nhập số ngày VIP [1-30]:"}, {30}, {"number"})
    if not res then return end
    local days = math.max(1, math.min(30, tonumber(res[1]) or 30))
    local base = VIPM.mainStatus()
    if not base then gg.toast("❌ Không tìm thấy Base Status!"); return end
    local vipPtr = VIPM.readPtr(base + 0x3A8)
    if vipPtr == 0 then gg.toast("❌ Lỗi Pointer VIP!"); return end
    local vip = vipPtr + 0x10
    local now = os.time(os.date("!*t"))
    gg.setValues({
        {address = vip, flags = gg.TYPE_DWORD, value = 130559},
        {address = vip + 0x4, flags = gg.TYPE_DWORD, value = 81},
        {address = vip + 0x8, flags = gg.TYPE_DWORD, value = now + 86400 * days},
        {address = vip + 0xC, flags = gg.TYPE_DWORD, value = 6},
        {address = vip + 0x10, flags = gg.TYPE_DWORD, value = now},
        {address = vip + 0x14, flags = gg.TYPE_DWORD, value = now},
        {address = vip + 0x18, flags = gg.TYPE_DWORD, value = now},
        {address = vip + 0x1C, flags = gg.TYPE_DWORD, value = 65793},
    })
    local p = VIPM.readPtr(base + 0x2E0)
    if p ~= 0 then
        local it = {address = p + 0x2C, flags = gg.TYPE_DWORD, value = 0, freeze = true}
        gg.setValues({it}); gg.addListItems({it})
    end
    gg.clearResults(); gg.toast("⭐ VIP " .. days .. " ngày!")
end

-- ═══════════════════════════════════════════════════════════
--  DIAMONDS (SR)
-- ═══════════════════════════════════════════════════════════
local SR = {}
function SR.readPtr(a) return gg.getValues({{address = a, flags = gg.TYPE_QWORD}})[1].value end
function SR.getBase()
    local r = gg.getRangesList("libcocos2dcpp.so")
    return #r > 0 and r[1].start or nil
end
local function diamondsSR()
    gg.setVisible(false)
    local p = gg.prompt({"💎 Số Diamonds (Max 1000000):","🛡️ Bật Bypass?"}, {"15000", true}, {"number","checkbox"})
    if not p then return end
    local val = tonumber(p[1]) or 15000
    local bypass = p[2]
    local base = SR.getBase()
    if not base then gg.toast("lib not found"); return end
    local freezeOff = getOffsets().freezeDiamond
    if not freezeOff then gg.alert("⚠️ Version chưa có freezeDiamond!"); return end
    gg.clearResults(); gg.clearList(); gg.setRanges(gg.REGION_C_BSS)
    gg.searchNumber("1126191955", gg.TYPE_DWORD)
    local results = gg.getResults(gg.getResultCount()); gg.clearResults()
    if #results == 0 then gg.toast("base not found"); return end
    local edits = {}
    for _, v in ipairs(results) do
        local pF8 = SR.readPtr(v.address + 0xF8)
        if pF8 ~= 0 then
            local p48 = SR.readPtr(pF8 + 0x48)
            if p48 ~= 0 then
                local v138 = SR.readPtr(p48 + 0x138)
                local v140 = SR.readPtr(p48 + 0x140)
                local v148 = SR.readPtr(p48 + 0x148)
                if v138 ~= 0 then edits[#edits+1] = {address = v138, flags = gg.TYPE_DWORD, value = val} end
                for o = 0x0, 0xA0, 0x8 do
                    local ptr = SR.readPtr(pF8 + o)
                    if ptr ~= 0 then
                        edits[#edits+1] = {address = ptr + 0x138, flags = gg.TYPE_QWORD, value = v138}
                        edits[#edits+1] = {address = ptr + 0x140, flags = gg.TYPE_QWORD, value = v140}
                        edits[#edits+1] = {address = ptr + 0x148, flags = gg.TYPE_QWORD, value = v148}
                        edits[#edits+1] = {address = ptr + 0x10C, flags = gg.TYPE_FLOAT, value = 1}
                    end
                end
            end
        end
    end
    if #edits == 0 then gg.toast("NOT WORK"); return end
    if bypass then
        gg.addListItems({{address = base + freezeOff, flags = gg.TYPE_DWORD, value = 0, freeze = true}})
    end
    gg.setValues(edits)
    gg.toast(bypass and "💎 [OK] + BYPASS" or "💎 [OK]")
end

-- ═══════════════════════════════════════════════════════════
--  MAX VEHICLES / MASTERY / PARTS
-- ═══════════════════════════════════════════════════════════
local function MaxVehicles()
    if not checkGameStatus() then return end
    gg.alert("⚠️ Vào garage trước rồi bấm OK")
    local vehicleListPtr = gg.getValues({{address = BaseGameStatus + 0xB8, flags = gg.TYPE_QWORD}})[1].value
    local totalVehicles = gg.getValues({{address = BaseGameStatus + 0xC0, flags = gg.TYPE_DWORD}})[1].value
    if not vehicleListPtr or vehicleListPtr == 0 or not totalVehicles or totalVehicles == 0 then
        gg.alert("❌ Không đọc được vehicle list!"); return
    end
    local reads = {}
    for i = 0, totalVehicles - 1 do
        reads[#reads + 1] = {address = vehicleListPtr + i * 8, flags = gg.TYPE_QWORD}
    end
    local vPtrs = gg.getValues(reads)
    local vehicles = {}
    for _, v in ipairs(vPtrs) do if v.value and v.value ~= 0 then vehicles[#vehicles + 1] = v.value end end
    local meta = {}
    for _, vp in ipairs(vehicles) do
        meta[#meta + 1] = {address = vp + 0x18, flags = gg.TYPE_QWORD}
        meta[#meta + 1] = {address = vp + 0x20, flags = gg.TYPE_QWORD}
    end
    local metaVals = gg.getValues(meta)
    local upReads = {}
    for k, vp in ipairs(vehicles) do
        local namePtr = metaVals[(k - 1) * 2 + 1] and metaVals[(k - 1) * 2 + 1].value
        local upgradeListPtr = metaVals[(k - 1) * 2 + 2] and metaVals[(k - 1) * 2 + 2].value
        local vehicleName = (namePtr and namePtr ~= 0) and readStringAt(namePtr + 1) or "unknown"
        local slots = vehicleName:find("lowrider") and 5 or 4
        if upgradeListPtr and upgradeListPtr ~= 0 then
            for j = 0, slots - 1 do
                upReads[#upReads + 1] = {address = upgradeListPtr + j * 8, flags = gg.TYPE_QWORD}
            end
        end
    end
    local upPtrs = gg.getValues(upReads)
    local edits = {}
    for _, p in ipairs(upPtrs) do
        if p.value and p.value ~= 0 then
            edits[#edits + 1] = {address = p.value + 0x20, flags = gg.TYPE_DWORD, value = 19}
            edits[#edits + 1] = {address = p.value + 0x24, flags = gg.TYPE_DWORD, value = 19}
        end
    end
    if #edits > 0 then gg.setValues(edits); gg.alert("✅ Đã max " .. #vehicles .. " vehicles!")
    else gg.alert("❌ Không có gì để max!") end
end

local function MaxMastery()
    if not checkGameStatus() then return end
    gg.alert("⚠️ Dùng Max Vehicles TRƯỚC!")
    local ts = os.time()
    local vehicleListPtr = gg.getValues({{address = BaseGameStatus + 0xB8, flags = gg.TYPE_QWORD}})[1].value
    local totalVehicles = gg.getValues({{address = BaseGameStatus + 0xC0, flags = gg.TYPE_DWORD}})[1].value
    if not vehicleListPtr or vehicleListPtr == 0 then gg.alert("❌ Không đọc được vehicle list!"); return end
    local reads = {}
    for i = 0, totalVehicles - 1 do
        reads[#reads + 1] = {address = vehicleListPtr + i * 8, flags = gg.TYPE_QWORD}
    end
    local vPtrs = gg.getValues(reads)
    local vehicles = {}
    for _, v in ipairs(vPtrs) do if v.value and v.value ~= 0 then vehicles[#vehicles + 1] = v.value end end
    local mReads = {}
    for _, vp in ipairs(vehicles) do mReads[#mReads + 1] = {address = vp + 0x120, flags = gg.TYPE_QWORD} end
    local mVals = gg.getValues(mReads)
    local active, caReads = {}, {}
    for k, vp in ipairs(vehicles) do
        local mPtr = mVals[k] and mVals[k].value
        if mPtr and mPtr ~= 0 then
            active[#active + 1] = {vehiclePtr = vp, masteryPtr = mPtr}
            for j = 0, 3 do caReads[#caReads + 1] = {address = mPtr + j * 8, flags = gg.TYPE_QWORD} end
        end
    end
    local caVals = gg.getValues(caReads)
    local writes = {}; local successCount = 0
    for a = 1, #active do
        local entry = active[a]; local base = (a - 1) * 4
        for j = 1, 4 do
            local p = caVals[base + j]
            if p and p.value and p.value ~= 0 then
                writes[#writes + 1] = {address = p.value + 0x18, flags = gg.TYPE_DWORD, value = 65793}
                writes[#writes + 1] = {address = p.value + 0x1C, flags = gg.TYPE_DWORD, value = ts}
            end
        end
        writes[#writes + 1] = {address = entry.vehiclePtr + 0x120, flags = gg.TYPE_QWORD, value = entry.masteryPtr}
        writes[#writes + 1] = {address = entry.vehiclePtr + 0x128, flags = gg.TYPE_DWORD, value = 4}
        writes[#writes + 1] = {address = entry.vehiclePtr + 0x12C, flags = gg.TYPE_DWORD, value = 4}
        writes[#writes + 1] = {address = entry.vehiclePtr + 0x130, flags = gg.TYPE_DWORD, value = 4}
        successCount = successCount + 1
    end
        if #writes > 0 then gg.setValues(writes); gg.alert("✅ Đã max " .. successCount .. " masteries!")
    else gg.alert("❌ Không có gì để max!") end
end

local function MaxParts()
    if not checkGameStatus() then return end
    gg.alert("⚠️ Dùng Max Vehicles TRƯỚC!")
    local vehicleListPtr = gg.getValues({{address = BaseGameStatus + 0xB8, flags = gg.TYPE_QWORD}})[1].value
    local totalVehicles = gg.getValues({{address = BaseGameStatus + 0xC0, flags = gg.TYPE_DWORD}})[1].value
    if not vehicleListPtr or vehicleListPtr == 0 then gg.alert("❌ Không đọc được vehicle list!"); return end
    local reads = {}
    for i = 0, totalVehicles - 1 do
        reads[#reads + 1] = {address = vehicleListPtr + i * 8, flags = gg.TYPE_QWORD}
    end
    local vPtrs = gg.getValues(reads)
    local vehicles = {}
    for _, v in ipairs(vPtrs) do if v.value and v.value ~= 0 then vehicles[#vehicles + 1] = v.value end end
    local meta = {}
    for _, vp in ipairs(vehicles) do
        meta[#meta + 1] = {address = vp + 0x58, flags = gg.TYPE_QWORD}
        meta[#meta + 1] = {address = vp + 0x60, flags = gg.TYPE_DWORD}
    end
    local metaVals = gg.getValues(meta)
    local upgradeList = {}
    for k, vp in ipairs(vehicles) do
        local partsListPtr = metaVals[(k - 1) * 2 + 1] and metaVals[(k - 1) * 2 + 1].value
        local totalParts = metaVals[(k - 1) * 2 + 2] and metaVals[(k - 1) * 2 + 2].value
        if partsListPtr and partsListPtr ~= 0 and totalParts and totalParts > 0 then
            local pReads = {}
            for j = 0, totalParts - 1 do
                pReads[#pReads + 1] = {address = partsListPtr + j * 8, flags = gg.TYPE_QWORD}
            end
            local partPtrs = gg.getValues(pReads)
            for _, pp in ipairs(partPtrs) do
                local partPtr = pp.value
                if partPtr and partPtr ~= 0 then
                    local namePtr = gg.getValues({{address = partPtr + 0x18, flags = gg.TYPE_QWORD}})[1].value
                    local partName = "unknown"
                    if namePtr and namePtr ~= 0 then
                        local header = gg.getValues({{address = namePtr, flags = gg.TYPE_DWORD}})[1].value
                        if header == 49 then
                            local namePtr2 = gg.getValues({{address = namePtr + 0x10, flags = gg.TYPE_QWORD}})[1].value
                            partName = namePtr2 ~= 0 and readStringAt(namePtr2) or "unknown"
                        else
                            partName = readStringAt(namePtr + 1)
                        end
                    end
                    local lvl = partMaxLevel(partName)
                    upgradeList[#upgradeList + 1] = {address = partPtr + 0x20, flags = gg.TYPE_DWORD, value = lvl}
                    upgradeList[#upgradeList + 1] = {address = partPtr + 0x34, flags = gg.TYPE_DWORD, value = lvl}
                end
            end
        end
    end
    if #upgradeList > 0 then
        gg.setValues(upgradeList)
        gg.alert("✅ Đã max " .. math.floor(#upgradeList / 2) .. " parts!")
    else
        gg.alert("❌ Không có parts để max!")
    end
end

-- ═══════════════════════════════════════════════════════════
--  SET FUEL & COINS
-- ═══════════════════════════════════════════════════════════
local FandResults, FandFound = {}, false
local function ApplyFand(val)
    if not FandFound then
        gg.clearResults(); gg.setRanges(RANGE_VALUE)
        gg.searchNumber("-1082130432~-1054867456;1~1500F;1~5;1~1500F::21", gg.TYPE_DWORD)
        gg.refineNumber("1~1500", gg.TYPE_FLOAT)
        local c = gg.getResultCount()
        if c == 0 then gg.alert("❌ Không tìm thấy!"); return end
        FandResults = gg.getResults(c); FandFound = true
    end
    local nv = {}
    for i, r in ipairs(FandResults) do
        nv[i] = {address = r.address, flags = gg.TYPE_FLOAT, value = val}
    end
    gg.setValues(nv); gg.alert("✅ Đã áp dụng: " .. tostring(val))
end
local function SetFuelCoins()
    local presets = {
        [1]         = "⚡ Default Radius",
        [10]        = "⚡ Short Radius (10m)",
        [500]       = "⚡ Big Radius (500m)",
        [100000000] = "⚡ Remove Fuel & Coins"
    }
    local keys = {}
    for k in pairs(presets) do keys[#keys+1] = k end
    table.sort(keys)
    local labels = {}
    for _, k in ipairs(keys) do labels[#labels+1] = presets[k] end
    labels[#labels+1] = "✏️ Custom Radius"
    labels[#labels+1] = "⬅️ Quay lại"
    local choice = gg.choice(labels, nil, nil)
    if choice == nil or choice == #labels then return end
    if choice == #labels - 1 then
        local inp = gg.prompt({"Radius (m):"}, {67}, {"number"})
        if not inp then return SetFuelCoins() end
        ApplyFand(tonumber(inp[1]))
        return SetFuelCoins()
    end
    ApplyFand(keys[choice])
    return SetFuelCoins()
end

-- ═══════════════════════════════════════════════════════════
--  EVENT MENU
-- ═══════════════════════════════════════════════════════════
local function EventMenu()
    if not checkGameStatus() then return end
    local choice = gg.choice({
        "🛒 Free Purchases (Event)",
        "💎 Add Currency (Coins/Gems)",
        "⬅️ Quay lại"
    }, nil, "🎉 Làm việc trong Event tab của game")
    if not choice or choice == 3 then return end
    if choice == 1 then
        gg.clearResults(); gg.setRanges(gg.REGION_C_ALLOC)
        gg.searchNumber("60;600;150", gg.TYPE_FLOAT)
        if gg.getResultsCount() == 0 then gg.alert("❌ Vào Event tab trong game trước!"); return end
        gg.editAll(0, gg.TYPE_FLOAT)
        gg.clearResults()
        gg.alert("✅ Đã bật!\nThoát Event tab rồi vào lại.")
    elseif choice == 2 then
        local cur = gg.prompt({"Chọn (1=Coins, 2=Gems):","Số lượng:"}, {1, 50000}, {"number","number"})
        if not cur then return end
        local ctype = tonumber(cur[1]) or 1
        local amount = tonumber(cur[2]) or 50000
        local addr = BaseGameStatus + 0x4F4
        if ctype == 2 then addr = BaseGameStatus + 0x4F8 end
        gg.setValues({{address = addr, flags = gg.TYPE_DWORD, value = amount}})
        gg.alert("✅ Đã set currency " .. ctype .. " = " .. amount)
    end
end

-- ═══════════════════════════════════════════════════════════
--  TEAM EVENT MODULE
-- ═══════════════════════════════════════════════════════════
local TE = {
    VerifyRetryCount=0x11F, VerifyMatchmakingReq=0x123, VerifyUnknown3=0x127,
    StartServerTimestamp=0x12B, StartClientTimestamp=0x12F, EndEventTimestamp=0x133,
    VerifyTeamTicketJoin=0x13F, VerifyTicketRefillBase=0x147, VerifyUnknown6=0x14B,
    VerifyRetryLimit=0x14F, VerifyRetryDisableFlag=0x153,
    VerifyTeamDurationStart=0x1FB, VerifyTeamDurationEnd=0x1FF,
    EditMatchmakingReq=0x123, EditTeamTicketJoin=0x13F, EditTicketRefill=0x147,
    EditRetryDisable=0x157, EditTeamDurationStart=0x1FB, EditTeamDurationEnd=0x1FF,
    SetVehicleLimit1=0x437, SetVehicleLimit2=0x43F, SetVehicleLimit3=0x447,
    AllowVehicleList1=0x44F, AllowVehicleList2=0x457, AllowVehicleList3=0x45F,
    AnalyzeGameMode=0x4DF,
    EventScoreCheck1=0x1B0, EventScoreCheck2=0x1C8, EventScoreCheck3=0x1E0,
}
local TE_VerifyPatterns = {
    {offset=TE.VerifyRetryCount, expected=10},
    {offset=TE.VerifyMatchmakingReq, expected=5},
    {offset=TE.VerifyUnknown3, expected=3},
    {offset=TE.VerifyTeamTicketJoin, expected=1},
    {offset=TE.VerifyTicketRefillBase, expected=14400},
    {offset=TE.VerifyUnknown6, expected=2},
    {offset=TE.VerifyRetryLimit, expected=50},
    {offset=TE.VerifyRetryDisableFlag, expected=1},
    {offset=TE.VerifyTeamDurationStart, expected=172800},
    {offset=TE.VerifyTeamDurationEnd, expected=172800},
}
local TE_History = {}
local TE_DurationInput = nil
local function TE_readOne(addr, flags)
    if not addr or type(addr) ~= "number" then return nil end
    local v = gg.getValues({{address = addr, flags = flags}})
    return (v and v[1]) and v[1].value or nil
end
local function TE_verifyBase(base)
    for _, pat in ipairs(TE_VerifyPatterns) do
        local cur = TE_readOne(base + pat.offset, gg.TYPE_DWORD)
        if cur == nil or cur ~= pat.expected then return false end
    end
    return true
end
local function TE_searchEvent()
    local input = gg.prompt({"Tên Event (VD: :Hooked on a Wheelin'):"}, {""}, {"text"})
    if not input or input[1] == "" then gg.toast("⚠️ Trống!"); return end
    local label = input[1]
    local len = #label
    local word = label:match("^(%S+)") or label
    local firstChar = label:sub(1, 1)
    gg.clearResults(); gg.setRanges(RANGE_VALUE)
    gg.searchNumber(":" .. label, gg.TYPE_BYTE)
    gg.refineNumber(":" .. word, gg.TYPE_BYTE)
    gg.refineNumber(":" .. firstChar, gg.TYPE_BYTE)
    local cnt = gg.getResultsCount()
    local refineResults = gg.getResults(cnt)
    TE_History[label] = TE_History[label] or {results={}, verified={}, is_enabled=false}
    local added = 0
    if cnt == 0 then gg.toast("❌ Không tìm thấy!"); return end
    if len <= 23 then
        for _, r in ipairs(refineResults) do
            if not TE_History[label].verified[r.address] then
                if TE_verifyBase(r.address) then
                    TE_History[label].verified[r.address] = true
                    TE_History[label].results[#TE_History[label].results+1] = r
                    added = added + 1
                end
            end
        end
        gg.clearResults()
        gg.toast("✅ Added " .. added .. " cho: " .. label)
        return
    end
    for _, rr in ipairs(refineResults) do
        local stringAddress = rr.address
        gg.clearResults(); gg.setRanges(RANGE_VALUE)
        gg.searchNumber(stringAddress, gg.TYPE_QWORD)
        local pCount = gg.getResultsCount()
        if pCount > 0 then
            for _, p in ipairs(gg.getResults(pCount)) do
                local base = p.address - 0xF
                local checkAddr = p.address - 0x10
                local v = gg.getValues({{address = checkAddr, flags = gg.TYPE_DWORD}})
                if v and v[1] and v[1].value >= 0 and v[1].value <= 100 then
                    if not TE_History[label].verified[base] then
                        if TE_verifyBase(base) then
                            TE_History[label].verified[base] = true
                            TE_History[label].results[#TE_History[label].results+1] = {address = base}
                            added = added + 1
                        end
                    end
                end
            end
        end
    end
    gg.toast("✅ Pointer-verified " .. added .. " cho: " .. label)
    gg.clearResults()
end
local function TE_applyEdits(base, selectedEdits)
    local batch = {}
    for _, idx in ipairs(selectedEdits) do
        if idx == 1 then
            batch[#batch+1] = {address=base+TE.EditMatchmakingReq, flags=gg.TYPE_DWORD, value=1}
        elseif idx == 2 then
            batch[#batch+1] = {address=base+TE.EditTeamTicketJoin, flags=gg.TYPE_DWORD, value=0}
        elseif idx == 3 then
            local orig = TE_readOne(base + TE.EditTicketRefill, gg.TYPE_DWORD)
            if orig then
                gg.setValues({{address=base+TE.EditTicketRefill, flags=gg.TYPE_DWORD, value=0}})
                gg.sleep(300)
                gg.setValues({{address=base+TE.EditTicketRefill, flags=gg.TYPE_DWORD, value=orig}})
            end
        elseif idx == 4 then
            batch[#batch+1] = {address=base+TE.EditRetryDisable, flags=gg.TYPE_DWORD, value=-1}
        elseif idx == 5 then
            if not TE_DurationInput then
                local ui = gg.prompt({"Duration (HOURS) [1;48]:"}, {"1"}, {"number"})
                if not ui then return false end
                TE_DurationInput = tonumber(ui[1]) or 1
            end
            local fv = 3600 * TE_DurationInput
            batch[#batch+1] = {address=base+TE.EditTeamDurationStart, flags=gg.TYPE_DWORD, value=fv}
            batch[#batch+1] = {address=base+TE.EditTeamDurationEnd, flags=gg.TYPE_DWORD, value=fv}
        end
    end
    if #batch > 0 then
        if not pcall(function() gg.setValues(batch) end) then return false end
    end
    return true
end
local function TE_enableEvent()
    if not next(TE_History) then gg.toast("⚠️ Chưa search event!"); return end
    local labels = {}
    for label, _ in pairs(TE_History) do labels[#labels+1] = label end
    local eventPrompt = gg.prompt(labels, {}, (function()
        local t = {}; for _ = 1, #labels do t[#t+1] = "checkbox" end; return t
    end)())
    if not eventPrompt then return end
    local editNames = {"Matchmaking (1 player)","Team ticket unlimited","Refill Tickets [T-E]","Retry Disable","Duration [Leaders]"}
    local editPrompt = gg.prompt(editNames, {}, {"checkbox","checkbox","checkbox","checkbox","checkbox"})
    if not editPrompt then return end
    local sel = {}
    for k, v in pairs(editPrompt) do if v then sel[#sel+1] = k end end
    if #sel == 0 then gg.toast("⚠️ Không chọn edits!"); return end
    for i, isSelected in ipairs(eventPrompt) do
        if isSelected then
            local label = labels[i]
            local hist = TE_History[label]
            local cnt = 0
            for _, r in ipairs(hist.results) do
                if TE_applyEdits(r.address, sel) then cnt = cnt + 1 end
            end
            hist.is_enabled = cnt > 0
            gg.toast(string.format("✅ Enabled %d/%d cho \"%s\"", cnt, #hist.results, label))
        end
    end
    gg.clearResults(); gg.clearList()
end
local function TE_disableEvent()
    if not next(TE_History) then gg.toast("⚠️ Chưa search event!"); return end
    local labels = {}
    for label, entry in pairs(TE_History) do
        if entry.is_enabled then labels[#labels+1] = label end
    end
    if #labels == 0 then gg.toast("❌ Không có event nào bật!"); return end
    local sel = gg.prompt(labels, {}, (function()
        local t = {}; for _ = 1, #labels do t[#t+1] = "checkbox" end; return t
    end)())
    if not sel then return end
    for i, isSelected in ipairs(sel) do
        if isSelected then
            local label = labels[i]
            local hist = TE_History[label]
            for _, r in ipairs(hist.results) do
                gg.setValues({
                    {address=r.address+TE.EditMatchmakingReq,    flags=gg.TYPE_DWORD, value=5},
                    {address=r.address+TE.EditTeamTicketJoin,    flags=gg.TYPE_DWORD, value=1},
                    {address=r.address+TE.EditRetryDisable,      flags=gg.TYPE_DWORD, value=1},
                    {address=r.address+TE.EditTeamDurationStart, flags=gg.TYPE_DWORD, value=172800},
                    {address=r.address+TE.EditTeamDurationEnd,   flags=gg.TYPE_DWORD, value=172800},
                })
            end
            hist.is_enabled = false
            gg.toast("⚠️ Disabled " .. label)
        end
    end
end
local function TE_showLogs()
    if not next(TE_History) then gg.alert("⚠️ Chưa có history!"); return end
    local lines = {}
    for label, h in pairs(TE_History) do
        lines[#lines+1] = string.format("%s: %d entry [%s]", label, #h.results, h.is_enabled and "✅" or "❌")
    end
    gg.alert(table.concat(lines, "\n"))
end
local function TE_setVehicleLimit()
    if not next(TE_History) then gg.toast("⚠️ Chưa search event!"); return end
    local labels = {}
    for label, _ in pairs(TE_History) do labels[#labels+1] = label end
    local sel = gg.prompt(labels, {}, (function()
        local t = {}; for _ = 1, #labels do t[#t+1] = "checkbox" end; return t
    end)())
    if not sel then return end
    local inp = gg.prompt({"Limit:"}, {"1"}, {"number"})
    if not inp then return end
    local limitVal = tonumber(inp[1]) or 1
    for i, isSelected in ipairs(sel) do
        if isSelected then
            local hist = TE_History[labels[i]]
            for addr, _ in pairs(hist.verified) do
                local lStart = TE_readOne(addr + TE.SetVehicleLimit1, gg.TYPE_QWORD)
                local lEnd   = TE_readOne(addr + TE.SetVehicleLimit2, gg.TYPE_QWORD)
                if lStart and lEnd and lStart ~= 0 then
                    local count = math.floor((lEnd - lStart) / 4)
                    local batch = {}
                    for j = 0, count-1 do
                        batch[#batch+1] = {address=lStart + j*4, flags=gg.TYPE_DWORD, value=limitVal}
                    end
                    gg.setValues(batch)
                end
            end
            gg.toast("✅ Updated: " .. labels[i])
        end
    end
end
local function TE_analyzeGameMode()
    if not next(TE_History) then gg.toast("⚠️ Chưa search!"); return end
    local labels = {}
    for label, _ in pairs(TE_History) do labels[#labels+1] = label end
    local ch = gg.choice(labels, nil, "Event để phân tích:")
    if not ch then return end
    local label = labels[ch]
    local hist = TE_History[label]
    local inp = gg.prompt({"Total Modes [1-5]:"}, {"1"}, {"number"})
    if not inp then return end
    local jumps = math.min(math.max(math.floor(tonumber(inp[1]) or 1), 1), 5)
    local jumpOffsets = {0, 0x8, 0x10, 0x18, 0x20}
    local modeInfo = {}
    for _, entry in ipairs(hist.results) do
        if entry and entry.address then
            local basePtr = TE_readOne(entry.address + TE.AnalyzeGameMode, gg.TYPE_QWORD)
            if basePtr and basePtr ~= 0 then
                for i = 1, jumps do
                    local jumpPtr = TE_readOne(basePtr + jumpOffsets[i], gg.TYPE_QWORD)
                    if jumpPtr and jumpPtr ~= 0 then
                        local function readF(o)
                            local p = TE_readOne(jumpPtr + o, gg.TYPE_QWORD)
                            if not p or p == 0 then return 0 end
                            return TE_readOne(p, gg.TYPE_FLOAT) or 0
                        end
                        local v198, v1B0, v1C8 = readF(TE.EventScoreCheck1), readF(TE.EventScoreCheck2), readF(TE.EventScoreCheck3)
                        if not (v198 == 0 and v1B0 == 0 and v1C8 == 0) then
                            modeInfo[#modeInfo+1] = {
                                jump=i, mode=(v1B0 == 0) and "Distance Mode" or "Time Attack Mode",
                                t198=v198, t1B0=v1B0, t1C8=v1C8,
                            }
                        end
                    end
                end
            end
        end
    end
    if #modeInfo == 0 then gg.toast("❌ Không có mode hợp lệ!"); return end
    local msg = "📌 Game Mode Analysis\nEvent: " .. label .. "\n\n"
    for _, m in ipairs(modeInfo) do
        msg = msg .. string.format("Mode %d (%s)\n", m.jump, m.mode)
        if m.mode == "Distance Mode" then
            msg = msg .. string.format("Distance → %.2f\nMax Points → %.2f\n\n", m.t198, m.t1C8)
        else
            msg = msg .. string.format("Min → %.2f\nMax → %.2f\nMax Points → %.2f\n\n", m.t198, m.t1B0, m.t1C8)
        end
    end
    gg.alert(msg)
end
local function TeamEventMenu()
    local menu = {
        "🔍 SEARCH EVENT (BƯỚC 1)","✅ ENABLE TEAM EVENT","❌ DISABLE TEAM EVENT",
        "📝 SHOW LOGS","🥀 Set Vehicle Limit","🔬 GAME MODES INFO","⬅️ Quay lại"
    }
    local choice = gg.choice(menu, nil, nil)
    if choice == nil or choice == 7 then return MainMenu() end
    if choice == 1 then TE_searchEvent()
    elseif choice == 2 then TE_enableEvent()
    elseif choice == 3 then TE_disableEvent()
    elseif choice == 4 then TE_showLogs()
    elseif choice == 5 then TE_setVehicleLimit()
    elseif choice == 6 then TE_analyzeGameMode() end
    return TeamEventMenu()
end

-- ═══════════════════════════════════════════════════════════
--  GAME DATA BROWSER
-- ═══════════════════════════════════════════════════════════
local function gd_showVehicleInfo(name)
    local idx = gd_indexOf(name)
    if not idx then gg.alert("❌ Không tìm thấy xe: " .. tostring(name)); return end
    local methods = gd_unlockMethod(name)
    local msg = "🚗 " .. name .. "\n"
    msg = msg .. "📇 Index: [" .. idx .. "]\n"
    msg = msg .. "🔓 Unlock: " .. (#methods > 0 and table.concat(methods, ", ") or "?") .. "\n\n"
    local tunes = game_data.gameStatusTunesParts[idx]
    if tunes then
        for gi = 1, math.min(#gd_tuneGroupNames, #tunes) do
            local list = tunes[gi]
            if list and #list > 0 then
                msg = msg .. gd_tuneGroupNames[gi] .. " (" .. #list .. ")\n"
                for _, t in ipairs(list) do msg = msg .. "   • " .. tostring(t) .. "\n" end
                msg = msg .. "\n"
            end
        end
    end
    gg.alert(msg, "OK")
end
local function gd_vehiclePicker()
    local list = gd_allVehicles()
    local labels = {}
    for i, v in ipairs(list) do labels[i] = string.format("%2d. %s", i, v) end
    local pick = gg.choice(labels, nil, "🚗 Chọn xe để xem chi tiết")
    if not pick then return end
    gd_showVehicleInfo(list[pick])
    return gd_vehiclePicker()
end
local function gd_showByRarity()
    local msg = "📊 DANH SÁCH XE (" .. #game_data.gameStatusVehicles .. ")\n\n"
    for i, v in ipairs(game_data.gameStatusVehicles) do
        local methods = gd_unlockMethod(v)
        msg = msg .. string.format("[%2d] %s\n     → %s\n", i, v, table.concat(methods, ", "))
    end
    gg.alert(msg, "OK")
end
local function gd_showUnlockByMethod()
    local labels = {}
    local keys = {}
    for k, _ in pairs(game_data.vehicles) do keys[#keys+1] = k end
    table.sort(keys)
    for i, k in ipairs(keys) do
        labels[i] = string.format("%s (%d xe)", k:gsub("^Unlock",""):gsub("Vehicles$",""), #game_data.vehicles[k])
    end
    labels[#labels+1] = "⬅️ Quay lại"
    local pick = gg.choice(labels, nil, "🔓 Xe theo cách mở khóa")
    if not pick or pick == #labels then return end
    local key = keys[pick]
    local list = game_data.vehicles[key]
    local msg = "🔓 " .. key .. " (" .. #list .. ")\n\n"
    for i, v in ipairs(list) do msg = msg .. string.format("%2d. %s\n", i, v) end
    gg.alert(msg, "OK")
end
local function gd_searchByName()
    local inp = gg.prompt({"🔎 Nhập tên xe (VD: DUNE):"}, {""}, {"text"})
    if not inp or inp[1] == "" then return end
    local q = inp[1]:upper()
    local hits = {}
    for i, v in ipairs(game_data.gameStatusVehicles) do
        if v:upper():find(q, 1, true) then hits[#hits+1] = string.format("[%2d] %s", i, v) end
    end
    if #hits == 0 then gg.alert("❌ Không có xe nào khớp: " .. q)
    else gg.alert("🔎 Kết quả (" .. #hits .. "):\n\n" .. table.concat(hits, "\n"), "OK") end
end
local function gd_stats()
    local totalVehicles = #game_data.gameStatusVehicles
    local totalTuneEntries = 0
    for _, tunes in pairs(game_data.gameStatusTunesParts) do
        for _, list in ipairs(tunes) do totalTuneEntries = totalTuneEntries + #list end
    end
    local msg = string.format(
        "📊 GAME DATA STATS\n\n🚗 Total vehicles: %d\n🎵 Tune entries:   %d\n📇 Vehicle table entries: %d\n\n" ..
        "Rarity values: %s\nRarity labels: %s",
        totalVehicles, totalTuneEntries,
        (function() local c=0; for _ in pairs(game_data.gameStatusTunesParts) do c=c+1 end; return c end)(),
        table.concat(game_data.rarityValue, ", "), table.concat(game_data.rarityLabel, ", ")
    )
    gg.alert(msg, "OK")
end
local function GameDataMenu()
    local menu = {"🚗 Xem chi tiết 1 xe","📊 Danh sách toàn bộ xe","🔓 Xe theo cách mở khóa","🔎 Tìm xe theo tên","📈 Stats Game Data","⬅️ Quay lại"}
    local pick = gg.choice(menu, nil, "📚 GAME DATA BROWSER")
    if not pick or pick == 6 then return MainMenu() end
    if pick == 1 then gd_vehiclePicker()
    elseif pick == 2 then gd_showByRarity()
    elseif pick == 3 then gd_showUnlockByMethod()
    elseif pick == 4 then gd_searchByName()
    elseif pick == 5 then gd_stats() end
    return GameDataMenu()
end

-- ═══════════════════════════════════════════════════════════
--  ABOUT
-- ═══════════════════════════════════════════════════════════
local function About()
    local info = [[
╔══════════════════════════════════╗
║      ꧁AɴнDᴇᴘZᴀı꧂ SCRIPT V3.2      ║
╚══════════════════════════════════╝

📌 Version: V3.2 (anhdepzai)
🎮 Game: Hill Climb Racing 2
⚙️ GG: 101.1

📢 Contact:
   💬 Discord  :: Andepzai
   ✈️ Telegram :: @Andepzai
   📺 Youtube  :: @Andepzai

⚡ FEATURES (29):
   ✅ Auto Win (ARMV8)
   ✅ Fake Unlock
   ✅ Free Upgrade
   ✅ Upgrade Parts Without Scrap
   ✅ Fly Hack
   ✅ Unlock Any Vehicle
   ✅ Tracks Editor
   ✅ Vehicle Hacks (13 xe)
   ✅ Free Chests
   ✅ Free Purchases
   ✅ Parts Drop (Legendary)
   ✅ Adventure Chest Hack V1
   ✅ Flat Ground for Adventure
   ✅ Debug Mode
   ✅ VIP Pass
   ✅ Diamonds (SR) + Bypass
   ✅ Max Vehicles
   ✅ Max Mastery
   ✅ Max Parts
   ✅ Set Fuel & Coins
   ✅ Team Event Menu
   ✅ Event Menu
   ✅ Game Data Browser
   ✅ Vehicle Speed 
   ✅ Global Vision 
   ✅ Terrain Flat Advanced 
   ✅ Map Modification     
   ✅ About
   ✅ Exit

⚠️ Tôi không chịu trách nhiệm
]]
    gg.alert(info, "OK")
    return MainMenu()
end

-- ═══════════════════════════════════════════════════════════
--  MENU CHÍNH
-- ═══════════════════════════════════════════════════════════
function MainMenu()
    gg.setVisible(false)
    local menu = {
        "🔥 Auto Win (ARMV8)",
        "🎭 Fake Unlock",
        "🔧 Free Upgrade",
        "⚡ Upgrade Parts Without Scrap",
        "🚀 Fly Hack",
        "🚗 Unlock Any Vehicle",
        "🛣️ Tracks Editor",
        "🏎️ Vehicle Hacks",
        "⚡ Free Chests",
        "💳 Free Purchases",
        "🔧 Parts Drop (Legendary)",
        "🧰 Adventure Chest Hack V1",
        "➖ Flat Ground for Adventure",
        "💎 Debug Mode",
        "⭐ VIP Pass",
        "💎 Diamonds (SR) + Bypass",
        "🚀 Max Vehicles",
        "⭐ Max Mastery",
        "🔩 Max Parts",
        "💰 Set Fuel & Coins",
        "🎯 Team Event Menu",
        "🎉 Event Menu",
        "📚 Game Data Browser",
        "🚗 Vehicle Speed ",
        "👁️ Global Vision ",
        "➖ Terrain Flat Advanced",
        "🗺️ Map Modification",
        "ℹ️ About",
        "❌ Exit"
    }
    local choice = gg.choice(menu, nil, nil)
    if not choice then return end
    if choice == 1 then autoWin()
    elseif choice == 2 then fakeUnlock()
    elseif choice == 3 then freeUpgrade()
    elseif choice == 4 then upgradeWithoutScrap()
    elseif choice == 5 then flyHack()
    elseif choice == 6 then unlockAnyVehicle()
    elseif choice == 7 then tracksEditor()
    elseif choice == 8 then vehicleHacksMenu()
    elseif choice == 9 then freeChests()
    elseif choice == 10 then freePurchases()
    elseif choice == 11 then partsDropLegendary()
    elseif choice == 12 then advChestHackV1()
    elseif choice == 13 then flatGroundAdventure()
    elseif choice == 14 then debugMode()
    elseif choice == 15 then vipPassFunc()
    elseif choice == 16 then diamondsSR()
    elseif choice == 17 then MaxVehicles()
    elseif choice == 18 then MaxMastery()
    elseif choice == 19 then MaxParts()
    elseif choice == 20 then SetFuelCoins()
    elseif choice == 21 then TeamEventMenu()
    elseif choice == 22 then EventMenu()
    elseif choice == 23 then GameDataMenu()
    elseif choice == 24 then VehicleSpeedMenu()
    elseif choice == 25 then GlobalVisionMenu()
    elseif choice == 26 then TerrainFlatMenu()
    elseif choice == 27 then MapModificationArea()
    elseif choice == 28 then About()
    elseif choice == 29 then
        gg.setVisible(true)
        print(ShowPrint)
        os.exit()
    end
end

-- ═══════════════════════════════════════════════════════════
--  KHỞI ĐỘNG
-- ═══════════════════════════════════════════════════════════
checkBlocked()
checkGG()
checkHCR2()
getLib()
archType = detectArch()
gameVersion = getHCR2Version()

if archType == 3 or archType == 4 then
    gg.alert("⚠️ Phát hiện Emulator!\nAuto Win / Fake Unlock / Free Upgrade sẽ không hoạt động.")
end

selectRange()
gg.clearResults()
gg.clearList()
gg.setRanges(RANGE_VALUE)
gg.toast("🚀 Starting AɴнDᴇᴘZᴀ+DALI®ı V3.2 ( Merged)...")
gg.sleep(800)

if not findGameStatus() then
    gg.toast("⚠️ Chưa tìm thấy GameStatus (vào Garage để fix)")
end

MainMenu()

while true do
    if gg.isVisible(true) then
        gg.setVisible(false)
        MainMenu()
    end
    gg.sleep(100)
end
