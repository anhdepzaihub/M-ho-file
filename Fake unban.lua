-- ====================================
-- Script by ANHDEPZAI HUB 🇻🇳
-- ====================================

-- Hàm hỗ trợ in thông tin an toàn
local function showPrint(stepName, results)
    if not results then
        print("====================================")
        print("[" .. stepName .. "] Không có kết quả trả về.")
        gg.toast(stepName .. ": Không tìm thấy!")
        return
    end
    
    local count = #results
    print("====================================")
    print("[" .. stepName .. "] Số kết quả tìm thấy: " .. count)
    if count > 0 then
        for i, v in ipairs(results) do
            print(string.format("  #%d | Địa chỉ: 0x%X | Giá trị gốc: %s", i, v.address, tostring(v.value)))
        end
        gg.toast(stepName .. ": Đã sửa " .. count .. " kết quả")
    else
        print("  -> Không tìm thấy dữ liệu phù hợp!")
        gg.toast(stepName .. ": Không tìm thấy!")
    end
end

print("=== [ ANHDEPZAI HUB 🇻🇳 ] Bắt đầu chạy script ===")

-- Bước 1
gg.clearResults()
gg.setRanges(8)
gg.searchNumber('h F7 03 13 AA 0A 75 0F 39', 1)
local count1 = gg.getResultsCount()
if count1 and count1 > 0 then
    local results1 = gg.getResults(count1)
    showPrint("Bước 1", results1)
    gg.editAll('h F7 03 13 AA 1F 75 0F 39', 1)
else
    showPrint("Bước 1", nil)
end
gg.clearResults()

-- Bước 2
gg.setRanges(8)
gg.searchNumber('h 80 00 00 54 20 00 80 52 06 00 00 14 88 00 00 B4 08 A5 4C 39 00 7D 07 53', 1)
local count2 = gg.getResultsCount()
if count2 and count2 > 0 then
    local results2 = gg.getResults(count2)
    showPrint("Bước 2", results2)
    gg.editAll('h 80 00 00 54 00 00 80 52 06 00 00 14 88 00 00 B4 08 A5 4C 39 00 00 80 52', 1)
else
    showPrint("Bước 2", nil)
end
gg.clearResults()

print("====================================")
print("Hoàn tất thực thi script - ANHDEPZAI HUB 🇻🇳")
gg.toast("Hoàn tất! - ANHDEPZAI HUB 🇻🇳")
