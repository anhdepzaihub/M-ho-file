local function showPrint(stepName, status)
    print("====================================")
    print("ANHDEPZAI HUB 🇻🇳 | [" .. stepName .. "] Trạng thái: " .. status)
    gg.toast(stepName .. ": " .. status)
end

local LIB_BASE = nil

-- Lấy địa chỉ cơ sở của libcocos2dcpp.so
local function getLib()
    local libs = gg.getRangesList("libcocos2dcpp.so")
    if #libs == 0 then return false end
    LIB_BASE = libs[1].start
    return true
end

-- Thực hiện patch Fake VIP không hiển thị địa chỉ (by ANHDEPZAI HUB 🇻🇳)
local function autoApplyFakeVIP()
    local info = gg.getTargetInfo()
    local libDir = info and info.nativeLibraryDir:lower() or ""
    if not (libDir:find("arm64") or libDir:find("aarch64")) then
        print("⛔ ANHDEPZAI HUB 🇻🇳 Lỗi: Fake VIP chỉ hỗ trợ kiến trúc ARM64!")
        gg.alert("❗ Fake VIP chỉ hỗ trợ ARM64!")
        return
    end

    if not getLib() then
        print("⛔ ANHDEPZAI HUB 🇻🇳 Lỗi: Không tìm thấy libcocos2dcpp.so!")
        gg.alert("❌ Không tìm thấy libcocos2dcpp.so!")
        return
    end

    -- Offset Fake VIP (HCR2 auto update)
    local targetAddr = LIB_BASE + 0x16AA504
    
    -- Thực hiện patch
    local success = pcall(function()
        gg.setValues({{address = targetAddr, flags = gg.TYPE_DWORD, value = "20008052r"}})
    end)

    if success then
        showPrint("Fake VIP Patch", "Thành công")
        print("====================================")
        print("ANHDEPZAI HUB 🇻🇳 - Hoàn tất kích hoạt Fake VIP!")
    else
        print("⛔ ANHDEPZAI HUB 🇻🇳 Lỗi: Không thể ghi dữ liệu vào lib!")
        gg.alert("❌ Patch lib thất bại!")
    end
end

-- Chạy chương trình
gg.clearResults()
gg.clearList()
autoApplyFakeVIP()
