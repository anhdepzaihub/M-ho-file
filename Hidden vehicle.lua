gg.clearList()
gg.clearResults()
gg.setVisible(false)

-- Kiểm tra game đã chạy chưa
if gg.getTargetInfo() == nil then
    gg.alert("Vui lòng mở game Hill Climb Racing 2 trước!\nPlease open Hill Climb Racing 2 first!")
    os.exit()
end

-- Kiểm tra kiến trúc
local arch = gg.getTargetInfo().x64 and "arm64-v8a" or "armeabi-v7a"
if not gg.getTargetInfo().x64 then
    gg.alert("Script chỉ hỗ trợ arm64-v8a!\nScript only supports arm64-v8a!\n\nThiết bị của bạn: " .. arch)
    os.exit()
end

-- Hiển thị thông tin
gg.toast("Hidden Vehicle Replacement\nby: anhdepzai")

-- ==================== CẤU HÌNH ====================
local Config = {
    language = true,  -- true = Tiếng Việt, false = English
    baseRegion = 4,   -- Vùng nhớ mặc định
    garageReady = false
}

-- Hàm ngôn ngữ (Việt/Anh)
function L(vi, en)
    return Config.language and vi or en
end

-- ==================== THƯ VIỆN HỖ TRỢ ====================

-- Đọc chuỗi từ bộ nhớ
function getString(addr)
    local bytes = {}
    for i = 0, 255 do
        local v = gg.getValues({{address = addr + i, flags = 1}})[1].value
        if v == 0 then break end
        if v < 0 then v = v + 256 end
        table.insert(bytes, string.char(v))
    end
    return table.concat(bytes)
end

-- Tìm địa chỉ từ giá trị
function searchAddress(value, flags)
    gg.clearResults()
    gg.setRanges(Config.baseRegion)
    gg.searchNumber(value, flags)
    if gg.getResultsCount() == 0 then
        return nil
    end
    return gg.getResults(1)[1].address
end

-- ==================== KIỂM TRA GARAGE ====================

-- Kiểm tra người dùng đã vào Garage chưa
-- (Garage có chuỗi "hill_climb_cup" hoặc "garage" trong bộ nhớ)
function checkGarage()
    gg.clearResults()
    gg.setRanges(Config.baseRegion)
    gg.searchNumber("h 14 62 67 6D 5F 67 61 72 61 67 65 00", 1)  -- "bgm_garage"
    
    if gg.getResultsCount() > 0 then
        gg.clearResults()
        return true
    end
    
    -- Thử tìm pattern khác
    gg.clearResults()
    gg.searchNumber("h 0E 53 43 4F 4F 54 45 52", 1)  -- "SCOOTER"
    local found = gg.getResultsCount() > 0
    gg.clearResults()
    return found
end

-- ==================== MENU CHÍNH ====================

function MainMenu()
    gg.clearResults()
    
    -- Kiểm tra garage
    local inGarage = checkGarage()
    Config.garageReady = inGarage
    
    local status = inGarage 
        and L("✅ Đã phát hiện Garage", "✅ Garage detected")
        or L("⚠️ Chưa vào Garage - Hãy vào Garage trước!", "⚠️ Not in Garage - Please enter Garage first!")
    
    local menuItems = {
        L("1. Ván trượt tuyết (Skis) → Jeep", "1. Skis → Jeep"),
        L("2. Xe trượt tuyết (Sled) → Jeep", "2. Sled → Jeep"),
        L("3. Lốp tuyết (Snow Tires) → Jeep", "3. Snow Tires → Jeep"),
        L("───────────────────────────", "───────────────────────────"),
        L("4. 🔄 Khôi phục Jeep gốc", "4. 🔄 Restore Original Jeep"),
        L("5. 🔍 Kiểm tra Garage", "5. 🔍 Check Garage"),
        L("6. 🌐 Đổi ngôn ngữ (Việt/Anh)", "6. 🌐 Change Language"),
        L("7. ❌ Thoát", "7. ❌ Exit")
    }
    
    local title = L(
        "╔══════════════════════════╗\n║  THAY THẾ XE ẨN + by: ANHDEPZAI          ║\n╚══════════════════════════╝\n" .. status,
        "╔══════════════════════════╗\n║  HIDDEN VEHICLE REPLACE  ║\n╚══════════════════════════╝\n" .. status
    )
    
    local choice = gg.choice(menuItems, 2025, title)
    
    if choice == nil then
        return
    elseif choice == 1 then
        ReplaceHiddenVehicle("SKIS")
    elseif choice == 2 then
        ReplaceHiddenVehicle("SLED")
    elseif choice == 3 then
        ReplaceHiddenVehicle("TIRES")
    elseif choice == 4 then
        RestoreJeep()
    elseif choice == 5 then
        CheckGarageDetail()
    elseif choice == 6 then
        Config.language = not Config.language
        gg.toast(Config.language and "Đã chuyển sang Tiếng Việt" or "Switched to English")
        MainMenu()
    elseif choice == 7 then
        gg.toast(L("Tạm biệt!", "Goodbye!"))
        os.exit()
    end
end

-- ==================== KIỂM TRA GARAGE CHI TIẾT ====================

function CheckGarageDetail()
    local inGarage = checkGarage()
    
    if inGarage then
        -- Đếm số xe có thể thấy
        gg.clearResults()
        gg.setRanges(Config.baseRegion)
        gg.searchNumber("h 9A 99 09 40 00 00 00 00 0E 53 43 4F 4F 54 45 52", 1)  -- float 2.4 + "SCOOTER"
        local jeepCount = gg.getResultsCount()
        gg.clearResults()
        
        gg.alert(
            L(
                "✅ Đã phát hiện Garage!\n\n" ..
                "• Số Jeep tìm thấy: " .. jeepCount .. "\n" ..
                "• Vùng nhớ: " .. Config.baseRegion .. "\n" ..
                "• Kiến trúc: arm64-v8a\n\n" ..
                "Bạn có thể sử dụng các chức năng thay thế xe!",
                "✅ Garage detected!\n\n" ..
                "• Jeep found: " .. jeepCount .. "\n" ..
                "• Memory region: " .. Config.baseRegion .. "\n" ..
                "• Arch: arm64-v8a\n\n" ..
                "You can use replacement features!"
            ),
            L("OK", "OK")
        )
    else
        local answer = gg.alert(
            L(
                "⚠️ Không tìm thấy Garage!\n\n" ..
                "Hướng dẫn:\n" ..
                "1. Vào game Hill Climb Racing 2\n" ..
                "2. Mở Garage (biểu tượng xe)\n" ..
                "3. Chạy lại script\n\n" ..
                "Nếu vẫn lỗi:\n" ..
                "• Settings → Advanced → Bật 'Traditional vehicle sorting'\n" ..
                "• Khởi động lại game",
                "⚠️ Garage not found!\n\n" ..
                "Guide:\n" ..
                "1. Open Hill Climb Racing 2\n" ..
                "2. Open Garage (car icon)\n" ..
                "3. Rerun script\n\n" ..
                "If still fails:\n" ..
                "• Settings → Advanced → Enable 'Traditional vehicle sorting'\n" ..
                "• Restart game"
            ),
            L("Thử lại", "Retry"),
            L("Quay lại", "Back")
        )
        
        if answer == 1 then
            MainMenu()
        end
    end
    
    MainMenu()
end

-- ==================== HÀM CHÍNH: THAY THẾ XE ====================

function ReplaceHiddenVehicle(vehicleType)
    -- Bước 1: Xác định pattern theo loại xe
    local vehicleConfig = {
        SKIS = {
            pattern = 'h 12 53 4E 4F 57 42 4F 41 52 44 00',  -- "SNOWBOARD"
            checkValue = 1077936128,  -- float 3.0
            name = L("Ván trượt tuyết", "Skis"),
            searchTerm = "SNOWBOARD"
        },
        SLED = {
            pattern = 'h 08 53 4C 45 44 00',  -- "SLED"
            checkValue = 1077936128,
            name = L("Xe trượt tuyết", "Sled"),
            searchTerm = "SLED"
        },
        TIRES = {
            pattern = 'h 10 44 4F 55 47 48 4E 55 54 00',  -- "DOUGHNUT"
            checkValue = 1077936128,
            name = L("Lốp tuyết", "Snow Tires"),
            searchTerm = "DOUGHNUT"
        }
    }
    
    local cfg = vehicleConfig[vehicleType]
    if not cfg then
        gg.alert(L("Loại xe không hợp lệ!", "Invalid vehicle type!"))
        return MainMenu()
    end
    
    gg.toast(L("Đang tìm " .. cfg.name .. "...", "Searching for " .. cfg.name .. "..."))
    
    -- Bước 2: Tìm struct xe ẩn
    gg.clearResults()
    gg.setRanges(Config.baseRegion)
    gg.searchNumber(cfg.pattern, 1)
    local structResults = gg.getResults(gg.getResultsCount())
    
    if #structResults == 0 then
        gg.alert(
            L(
                "❌ Không tìm thấy " .. cfg.name .. " trong bộ nhớ!\n\n" ..
                "Nguyên nhân có thể:\n" ..
                "• Chưa vào Garage\n" ..
                "• Game version khác\n" ..
                "• Xe ẩn chưa được load\n\n" ..
                "Thử: Vào Garage → cuộn xuống cuối → quay lại chạy script",
                "❌ Cannot find " .. cfg.name .. " in memory!\n\n" ..
                "Possible reasons:\n" ..
                "• Not in Garage\n" ..
                "• Different game version\n" ..
                "• Hidden vehicle not loaded\n\n" ..
                "Try: Enter Garage → scroll to bottom → rerun script"
            ),
            L("OK", "OK")
        )
        return MainMenu()
    end
    
    -- Bước 3: Xác định pointer của xe ẩn
    local hiddenVehiclePointer = nil
    for i, v in ipairs(structResults) do
        local checkVal = gg.getValues({{address = v.address - 0x8, flags = 4}})[1].value
        if checkVal == cfg.checkValue then
            hiddenVehiclePointer = v.address - 0x20
            break
        end
    end
    
    if not hiddenVehiclePointer then
        gg.alert(
            L(
                "❌ Không tìm thấy pointer của " .. cfg.name .. "!\n" ..
                "Đã tìm thấy chuỗi nhưng không khớp cấu trúc.\n" ..
                "Có thể game version không tương thích.",
                "❌ Cannot find " .. cfg.name .. " pointer!\n" ..
                "Found string but structure mismatch.\n" ..
                "Game version may be incompatible."
            ),
            L("OK", "OK")
        )
        return MainMenu()
    end
    
    gg.toast(L("✅ Đã tìm thấy pointer xe ẩn: 0x" .. string.format("%X", hiddenVehiclePointer), 
                "✅ Hidden vehicle pointer: 0x" .. string.format("%X", hiddenVehiclePointer)))
    
    -- Bước 4: Tìm pointer Jeep gốc
    gg.clearResults()
    gg.setRanges(Config.baseRegion)
    gg.searchNumber("h 9A 99 09 40 00 00 00 00 0E 53 43 4F 4F 54 45 52", 1)
    local jeepResults = gg.getResults(1)
    
    if #jeepResults == 0 then
        gg.alert(
            L(
                "❌ Không tìm thấy Jeep gốc!\n" ..
                "Hãy chắc chắn bạn đã mở khóa Jeep.",
                "❌ Cannot find original Jeep!\n" ..
                "Make sure you've unlocked Jeep."
            ),
            L("OK", "OK")
        )
        return MainMenu()
    end
    
    local jeepBaseAddress = jeepResults[1].address
    
    -- Bước 5: Tìm mảng pointer xe
    gg.clearResults()
    gg.setRanges(Config.baseRegion)
    gg.searchNumber(jeepBaseAddress - 0x18, 32)
    local pointerArrayResults = gg.getResults(gg.getResultsCount())
    
    local vehicleArrayPointer = nil
    for i, p in ipairs(pointerArrayResults) do
        local ptrAddr = p.address - 0x8
        if (ptrAddr % 0x100) == 0 then
            vehicleArrayPointer = ptrAddr
            break
        end
    end
    
    if not vehicleArrayPointer then
        local answer = gg.alert(
            L(
                "❌ Không tìm thấy mảng pointer xe!\n\n" ..
                "GIẢI PHÁP:\n" ..
                "1. Vào Settings game (bánh răng góc trên phải)\n" ..
                "2. Chọn Advanced Settings\n" ..
                "3. BẬT 'Traditional vehicle sorting'\n" ..
                "4. Khởi động lại game\n" ..
                "5. Mở Garage → chạy lại script",
                "❌ Cannot find vehicle pointer array!\n\n" ..
                "SOLUTION:\n" ..
                "1. Open game Settings (gear icon)\n" ..
                "2. Choose Advanced Settings\n" ..
                "3. ENABLE 'Traditional vehicle sorting'\n" ..
                "4. Restart game\n" ..
                "5. Open Garage → rerun script"
            ),
            L("Đã hiểu", "Got it"),
            L("Thử lại", "Retry")
        )
        
        if answer == 2 then
            ReplaceHiddenVehicle(vehicleType)
        else
            MainMenu()
        end
        return
    end
    
    -- Bước 6: Đọc giá trị pointer Jeep
    local jeepPointerValue = gg.getValues({{address = vehicleArrayPointer, flags = 4}})[1].value
    
    -- Bước 7: Tìm TẤT CẢ vị trí có giá trị này
    gg.clearResults()
    gg.setRanges(Config.baseRegion)
    gg.searchNumber(jeepPointerValue, 4)
    local allPointers = gg.getResults(gg.getResultsCount())
    
    if #allPointers == 0 then
        gg.alert(L("❌ Không tìm thấy pointer Jeep nào!", "❌ No Jeep pointers found!"))
        return MainMenu()
    end
    
    -- Bước 8: Hiển thị xác nhận
    local confirm = gg.alert(
        L(
            "🔄 XÁC NHẬN THAY THẾ\n\n" ..
            "Xe ẩn: " .. cfg.name .. "\n" ..
            "Thay thế: Jeep (Little Jeep)\n" ..
            "Số pointer sẽ sửa: " .. #allPointers .. "\n\n" ..
            "⚠️ LƯU Ý:\n" ..
            "• Chỉ dùng offline/adventure\n" ..
            "• Không đua online với xe này\n" ..
            "• Thoát game để khôi phục",
            "🔄 CONFIRM REPLACEMENT\n\n" ..
            "Hidden vehicle: " .. cfg.name .. "\n" ..
            "Replace: Jeep (Little Jeep)\n" ..
            "Pointers to modify: " .. #allPointers .. "\n\n" ..
            "⚠️ NOTES:\n" ..
            "• Use offline/adventure only\n" ..
            "• Don't race online with this vehicle\n" ..
            "• Exit game to restore"
        ),
        L("✅ Thay thế", "✅ Replace"),
        L("❌ Hủy", "❌ Cancel")
    )
    
    if confirm ~= 1 then
        return MainMenu()
    end
    
    -- Bước 9: Ghi đè pointer
    local modifyTable = {}
    for i, ptr in ipairs(allPointers) do
        table.insert(modifyTable, {
            address = ptr.address,
            flags = 32,
            value = hiddenVehiclePointer
        })
    end
    
    local success = pcall(gg.setValues, modifyTable)
    
    gg.clearResults()
    
    if success then
        gg.alert(
            L(
                "✅ THÀNH CÔNG!\n\n" ..
                "Đã thay Jeep bằng: " .. cfg.name .. "\n" ..
                "Số pointer đã sửa: " .. #modifyTable .. "\n\n" ..
                "👉 Bây giờ:\n" ..
                "1. Đóng menu này\n" ..
                "2. Chọn Jeep trong Garage\n" ..
                "3. Xe sẽ hiện hình " .. cfg.name .. "!\n\n" ..
                "💡 Để khôi phục: Thoát game hoàn toàn",
                "✅ SUCCESS!\n\n" ..
                "Replaced Jeep with: " .. cfg.name .. "\n" ..
                "Pointers modified: " .. #modifyTable .. "\n\n" ..
                "👉 Now:\n" ..
                "1. Close this menu\n" ..
                "2. Select Jeep in Garage\n" ..
                "3. Vehicle will appear as " .. cfg.name .. "!\n\n" ..
                "💡 To restore: Force stop game"
            ),
            L("OK", "OK")
        )
    else
        gg.alert(
            L("❌ Ghi bộ nhớ thất bại!\nCó thể do quyền root hoặc game chặn.", 
                "❌ Memory write failed!\nRoot permission or game protection issue."),
            L("OK", "OK")
        )
    end
    
    MainMenu()
end

-- ==================== KHÔI PHỤC JEEP GỐC ====================

function RestoreJeep()
    local confirm = gg.alert(
        L(
            "🔄 KHÔI PHỤC JEEP GỐC\n\n" ..
            "Cách 1 (KHUYẾN NGHỊ - An toàn 100%):\n" ..
            "• Thoát game hoàn toàn (Force Stop)\n" ..
            "• Mở lại game → Jeep tự khôi phục\n\n" ..
            "Cách 2 (Tự động - Có thể lỗi):\n" ..
            "• Script sẽ tìm và reset pointer Jeep\n" ..
            "• Có thể không hoạt động nếu pointer đã bị đổi\n\n" ..
            "Bạn muốn làm gì?",
            "🔄 RESTORE ORIGINAL JEEP\n\n" ..
            "Method 1 (RECOMMENDED - 100% safe):\n" ..
            "• Force stop game completely\n" ..
            "• Reopen game → Jeep auto-restores\n\n" ..
            "Method 2 (Auto - may fail):\n" ..
            "• Script will find and reset Jeep pointer\n" ..
            "• May not work if pointer was changed\n\n" ..
            "What do you want?"
        ),
        L("Cách 1 (Thoát game)", "Method 1 (Exit game)"),
        L("Cách 2 (Tự động)", "Method 2 (Auto)"),
        L("Quay lại", "Back")
    )
    
    if confirm == 1 then
        gg.alert(
            L(
                "👉 Hướng dẫn:\n" ..
                "1. Nhấn nút Home\n" ..
                "2. Mở Recent Apps\n" ..
                "3. Vuốt tắt Hill Climb Racing 2\n" ..
                "4. Mở lại game\n" ..
                "5. Jeep đã khôi phục!",
                "👉 Guide:\n" ..
                "1. Press Home\n" ..
                "2. Open Recent Apps\n" ..
                "3. Swipe to close Hill Climb Racing 2\n" ..
                "4. Reopen game\n" ..
                "5. Jeep restored!"
            ),
            L("OK", "OK")
        )
        os.exit()
    elseif confirm == 2 then
        -- Tự động khôi phục: tìm tất cả struct xe ẩn và tìm Jeep gốc
        gg.toast(L("Đang tìm Jeep gốc...", "Searching for original Jeep..."))
        
        gg.clearResults()
        gg.setRanges(Config.baseRegion)
        gg.searchNumber("h 9A 99 09 40 00 00 00 00 0E 53 43 4F 4F 54 45 52", 1)
        local jeepResults = gg.getResults(1)
        
        if #jeepResults == 0 then
            gg.alert(
                L(
                    "❌ Không tìm thấy Jeep gốc!\n" ..
                    "Vui lòng dùng Cách 1 (thoát game).",
                    "❌ Cannot find original Jeep!\n" ..
                    "Please use Method 1 (exit game)."
                ),
                L("OK", "OK")
            )
            return MainMenu()
        end
        
        local jeepBaseAddress = jeepResults[1].address
        
        gg.clearResults()
        gg.searchNumber(jeepBaseAddress - 0x18, 32)
        local pointerArrayResults = gg.getResults(gg.getResultsCount())
        
        local vehicleArrayPointer = nil
        for i, p in ipairs(pointerArrayResults) do
            local ptrAddr = p.address - 0x8
            if (ptrAddr % 0x100) == 0 then
                vehicleArrayPointer = ptrAddr
                break
            end
        end
        
        if not vehicleArrayPointer then
            gg.alert(
                L(
                    "❌ Không tìm thấy mảng pointer!\n" ..
                    "Vui lòng dùng Cách 1 (thoát game).",
                    "❌ Cannot find pointer array!\n" ..
                    "Please use Method 1 (exit game)."
                ),
                L("OK", "OK")
            )
            return MainMenu()
        end
        
        -- Ghi lại pointer Jeep gốc
        local jeepPointerValue = gg.getValues({{address = vehicleArrayPointer, flags = 4}})[1].value
        
        -- Nếu giá trị đã bị đổi, tìm struct Jeep
        gg.clearResults()
        gg.searchNumber(jeepBaseAddress - 0x18, 32)
        local jeepStructPointers = gg.getResults(gg.getResultsCount())
        
        if #jeepStructPointers == 0 then
            gg.alert(
                L(
                    "❌ Không tìm thấy struct Jeep!\n" ..
                    "Vui lòng dùng Cách 1 (thoát game).",
                    "❌ Cannot find Jeep struct!\n" ..
                    "Please use Method 1 (exit game)."
                ),
                L("OK", "OK")
            )
            return MainMenu()
        end
        
        -- Khôi phục: ghi đè pointer về Jeep gốc
        local restoreTable = {}
        for i, p in ipairs(jeepStructPointers) do
            local ptrAddr = p.address - 0x8
            if (ptrAddr % 0x100) == 0 then
                table.insert(restoreTable, {
                    address = ptrAddr,
                    flags = 32,
                    value = jeepBaseAddress - 0x18
                })
            end
        end
        
        if #restoreTable > 0 then
            local success = pcall(gg.setValues, restoreTable)
            if success then
                gg.alert(
                    L(
                        "✅ Đã khôi phục " .. #restoreTable .. " pointer!\n\n" ..
                        "Tuy nhiên, để an toàn nhất:\n" ..
                        "👉 Thoát game và mở lại",
                        "✅ Restored " .. #restoreTable .. " pointers!\n\n" ..
                        "However, for maximum safety:\n" ..
                        "👉 Force stop game and reopen"
                    ),
                    L("OK", "OK")
                )
            else
                gg.alert(
                    L("❌ Khôi phục thất bại!\nVui lòng thoát game.", 
                        "❌ Restore failed!\nPlease exit game."),
                    L("OK", "OK")
                )
            end
        else
            gg.alert(
                L("⚠️ Không có gì để khôi phục.", "⚠️ Nothing to restore."),
                L("OK", "OK")
            )
        end
        
        gg.clearResults()
        MainMenu()
    else
        MainMenu()
    end
end

-- ==================== CHẠY SCRIPT ====================

-- Kiểm tra game version (cảnh báo nhẹ)
local versionName = gg.getTargetInfo().versionName or "Unknown"
if versionName ~= "1.76.0" then
    local answer = gg.alert(
        L(
            "⚠️ Phiên bản game: " .. versionName .. "\n" ..
            "Script được test trên: 1.76.0\n\n" ..
            "Có thể không hoạt động đúng!\n" ..
            "Tiếp tục?",
            "⚠️ Game version: " .. versionName .. "\n" ..
            "Script tested on: 1.76.0\n\n" ..
            "May not work correctly!\n" ..
            "Continue?"
        ),
        L("Tiếp tục", "Continue"),
        L("Thoát", "Exit")
    )
    if answer ~= 1 then
        os.exit()
    end
end

-- Chạy menu chính
MainMenu()
