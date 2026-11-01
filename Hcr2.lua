-- ========== CẤU HÌNH ==========
local CONFIG = {
    Title       = "꧁AɴнDᴇᴘZᴀı꧂",
    Message     = "Script đang cập nhật, vui lòng chờ...",
    UpdateText  = "UPDATE",
    Telegram    = "t.me/anhdepzai3",

    -- Toast nhấp nháy
    BlinkCount  = 10,      -- Số lần nhấp nháy toast
    BlinkDelay  = 500,     -- Thời gian mỗi lần (ms)

    -- Auto copy
    AutoCopy    = true,
    CopyDelay   = 800      -- Chờ sau khi đóng alert (ms)
}
-- ================================

-- Hàm copy clipboard (2 lớp fallback)
local function copyToClipboard(text)
    local ok = false

    -- Lớp 1: gg.copyText (GG bản mới)
    if gg.copyText then
        pcall(function()
            gg.copyText(text)
            ok = true
        end)
    end

    -- Lớp 2: am broadcast clipper.set
    if not ok then
        local ok2, result = pcall(function()
            return os.execute(string.format(
                "am broadcast -a clipper.set -e text '%s' > /dev/null 2>&1",
                text
            ))
        end)
        if ok2 and result == 0 then ok = true end
    end

    return ok
end

-- Hàm toast nhấp nháy
local function blinkToast()
    gg.setVisible(false)
    for i = 1, CONFIG.BlinkCount do
        local prefix = (i % 2 == 0) and "⏳" or "🔄"
        gg.toast(string.format(
            "%s %s\n📢 %s",
            prefix, CONFIG.Message, CONFIG.Telegram
        ))
        gg.sleep(CONFIG.BlinkDelay)
    end
end

-- Hàm alert chính
local function showMainAlert()
    local fullMessage = string.format(
        "⚡ %s ⚡\n\n%s\n\n[ %s ]\n\n📢 Theo dõi cập nhật tại:\n👉 %s\n\n(Nhấn OK để tiếp tục)",
        CONFIG.Title,
        CONFIG.Message,
        CONFIG.UpdateText,
        CONFIG.Telegram
    )
    pcall(function() gg.alert(fullMessage) end)
end

-- ========== CHẠY SCRIPT ==========
print(string.format("[%s] Bắt đầu...", CONFIG.Title))

-- BƯỚC 1: Toast nhấp nháy
print(string.format("[%s] Đang cập nhật script...", CONFIG.Title))
blinkToast()

-- BƯỚC 2: Alert chính
print(string.format("[%s] 0334741203", CONFIG.Title))
showMainAlert()

-- BƯỚC 3: Copy link sau khi đóng alert
if CONFIG.AutoCopy then
    gg.sleep(CONFIG.CopyDelay)

    if copyToClipboard(CONFIG.Telegram) then
        print(string.format("[%s] %s", CONFIG.Title, CONFIG.Telegram))
        gg.toast(string.format(
            "📋 Đã copy link:\n%s\n\nDán vào Telegram để theo dõi!",
            CONFIG.Telegram
        ))
    else
        print(string.format("[%s] ⚠️ Copy thất bại. Link: %s", CONFIG.Title, CONFIG.Telegram))
        gg.toast(string.format("⚠️ Copy thủ công:\n%s", CONFIG.Telegram))
    end
end

print(string.format("[%s] Hoàn tất!", CONFIG.Title))
