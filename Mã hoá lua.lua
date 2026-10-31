-- ===================================================================
-- TOOL MÃ HÓA LUA CHO GAMEGUARDIAN - V2
-- Nâng cấp: khóa ngẫu nhiên mỗi lần, payload dạng chuỗi (không tràn
-- hằng số), kiểm tra toàn vẹn, tự kiểm thử trước khi ghi file.
-- ===================================================================

if not gg then
    print("❌ Lỗi: Script này phải chạy bên trong GameGuardian!")
    return
end

local loadFn = loadstring or load
local KEY_LEN = 16

-- ---------- Tiện ích ----------
local function getAutoOutputPath(inputPath)
    if not inputPath or inputPath == "" then
        return "/sdcard/Download/Script_Protected.lua"
    end
    if inputPath:sub(-4):lower() == ".lua" then
        return inputPath:sub(1, -5) .. "_✅.lua"
    end
    return inputPath .. "_✅.lua"
end

-- XOR cho số 0..255, tương thích mọi phiên bản Lua
local function bxor(a, b)
    if bit32 and bit32.bxor then return bit32.bxor(a, b) end
    if bit and bit.bxor then return bit.bxor(a, b) end
    local r = 0
    for i = 0, 7 do
        local p = 2 ^ i
        if ((a / p) % 2 >= 1) ~= ((b / p) % 2 >= 1) then r = r + p end
    end
    return r
end

local function randomBytes(n)
    math.randomseed(os.time() + math.floor(os.clock() * 100000))
    for _ = 1, 5 do math.random() end
    local t = {}
    for i = 1, n do t[i] = math.random(1, 255) end
    return t
end

local function toEscaped(bytes)
    local parts = {}
    for i = 1, #bytes do
        parts[i] = string.format("\\%03d", bytes[i])
    end
    return table.concat(parts)
end

-- Giải mã dùng chung (cùng công thức với loader) để tự kiểm thử
local function decryptBytes(keyBytes, encBytes, salt)
    local n = #keyBytes
    local out, h = {}, 0
    for i = 1, #encBytes do
        local k = bxor(keyBytes[(i - 1) % n + 1], (i * 17 + salt) % 256)
        local c = bxor(encBytes[i], k)
        out[i] = c
        h = (h * 131 + c) % 2147483629
    end
    return out, h
end

-- ---------- Mã hóa chính ----------
-- bytecodeLoader = true: loader cũng được biên dịch (khó đọc hơn,
-- nhưng gắn với phiên bản Lua). false: loader dạng text (portable).
local function encryptLuaScript(sourceCode, outputPath, bytecodeLoader)
    -- Bỏ BOM UTF-8 nếu có
    if sourceCode:sub(1, 3) == "\239\187\191" then
        sourceCode = sourceCode:sub(4)
    end

    -- 1. Kiểm tra cú pháp
    local func, syntaxErr = loadFn(sourceCode)
    if not func then
        gg.alert("❌ Code gốc bị lỗi cú pháp:\n\n" .. tostring(syntaxErr))
        return false
    end

    -- 2. Biên dịch + strip debug
    local ok, raw = pcall(string.dump, func, true)
    if not ok or not raw then ok, raw = pcall(string.dump, func) end
    if not ok or not raw then
        gg.alert("❌ Không thể biên dịch sang Bytecode!")
        return false
    end

    -- 3. Khóa ngẫu nhiên + salt, mã hóa
    local key = randomBytes(KEY_LEN)
    local salt = math.random(1, 255)
    local n = #key
    local rawBytes, enc, hash = {}, {}, 0
    for i = 1, #raw do
        local b = raw:byte(i)
        rawBytes[i] = b
        local k = bxor(key[(i - 1) % n + 1], (i * 17 + salt) % 256)
        enc[i] = bxor(b, k)
        hash = (hash * 131 + b) % 2147483629
    end

    -- 4. Tự kiểm thử: giải mã lại phải khớp 100%
    local back, backHash = decryptBytes(key, enc, salt)
    if backHash ~= hash then
        gg.alert("❌ Tự kiểm thử thất bại, hủy ghi file.")
        return false
    end
    for i = 1, #rawBytes do
        if back[i] ~= rawBytes[i] then
            gg.alert("❌ Tự kiểm thử thất bại tại byte " .. i)
            return false
        end
    end

    -- 5. Tạo loader (payload là 1 chuỗi -> chỉ 1 hằng số)
    local header = "local _K,_B,_S,_C=\"" .. toEscaped(key) .. "\",\""
        .. toEscaped(enc) .. "\"," .. salt .. "," .. hash .. "\n"
    local body = [[
local _x=function(a,b)
if bit32 and bit32.bxor then return bit32.bxor(a,b) end
if bit and bit.bxor then return bit.bxor(a,b) end
local r=0
for i=0,7 do local p=2^i
if ((a/p)%2>=1)~=((b/p)%2>=1) then r=r+p end end
return r end
local _n,_o,_h=#_K,{},0
for i=1,#_B do
local k=_x(_K:byte((i-1)%_n+1),(i*17+_S)%256)
local c=_x(_B:byte(i),k)
_o[i]=string.char(c)
_h=(_h*131+c)%2147483629
end
if _h~=_C then error("Script bi loi hoac bi sua doi") end
local _f,_e=(loadstring or load)(table.concat(_o))
if not _f then error(tostring(_e)) end
return _f(...)
]]
    local loaderCode = header .. body

    -- Kiểm tra loader hợp lệ
    local loaderFunc, lerr = loadFn(loaderCode)
    if not loaderFunc then
        gg.alert("❌ Loader bị lỗi:\n" .. tostring(lerr))
        return false
    end

    local content = loaderCode
    if bytecodeLoader then
        local dok, dres = pcall(string.dump, loaderFunc, true)
        if dok and dres then content = dres end
    end

    -- 6. Ghi file
    local out, err = io.open(outputPath, "wb")
    if not out then
        gg.alert("❌ Lỗi tạo file:\n" .. tostring(err))
        return false
    end
    out:write(content)
    out:close()

    gg.alert("✅ MÃ HÓA THÀNH CÔNG!\n\n📁 " .. outputPath
        .. "\n📦 Kích thước: " .. #content .. " byte"
        .. "\n🔑 Khóa ngẫu nhiên " .. KEY_LEN .. " byte (đổi mỗi lần)"
        .. "\n✔️ Đã tự kiểm thử giải mã + kiểm tra toàn vẹn"
        .. "\n\n⚠️ cút."
        .. "\n\n—꧁ by @anhdepzai ꧂—")
    return true
end

-- ---------- Giao diện ----------
local function encryptFromFile(bytecodeLoader)
    local p = gg.prompt({"Chọn File .lua gốc:"},
        {"/sdcard/Download/by @anhdepzai.lua"}, {"file"})
    if not p or p[1] == "" then return end
    local f, err = io.open(p[1], "rb")
    if not f then
        gg.alert("❌ Không mở được file gốc: " .. tostring(err))
        return
    end
    local src = f:read("*a")
    f:close()
    encryptLuaScript(src, getAutoOutputPath(p[1]), bytecodeLoader)
end

local function main()
    while true do
        if gg.isVisible() then gg.setVisible(false) end
        local c = gg.choice({
            "1. 🔒 Mã hóa file .lua",
            "2. 🔓 Mã hóa file .lua ",
            "3. 📝 Mã hóa code dán trực tiếp",
            "4. ❌ Thoát"
        }, nil, "=== MÃ HÓA LUA V2 ===")

        if c == 1 then
            encryptFromFile(true)
        elseif c == 2 then
            encryptFromFile(false)
        elseif c == 3 then
            local p = gg.prompt({"Dán code thô vào đây:"},
                {"gg.toast('anhdepzai code!')"}, {"text"})
            if p and p[1] ~= "" then
                encryptLuaScript(p[1], "/sdcard/Download/Script_Protected.lua", true)
            end
        else
            gg.alert("Đã thoát rồi à, sớm thế ku.\n\n— by @anhdepzai —")
            gg.toast("꧁ by @anhdepzai ꧂")
            print("꧁ by @anhdepzai ꧂")
            break
        end
    end
end

main()
print("=== Script kết thúc |꧁ by @anhdepzai ꧂ ===")
