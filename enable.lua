--[[
    enable.lua
    Auto-activates SellerHelper features when running standalone (no BigFoot).
    When BigFoot is present it already controls these switches, so we do
    nothing in order to respect the user's BigFoot settings.

    Also provides slash commands for standalone configuration:
        /sh enable | disable   - toggle the whole addon
        /sh gray               - toggle auto-sell gray items
        /sh announce           - toggle sell/buy cost announcement
        /sh autobuy            - toggle auto-recharge confirmation
]]

--------------------------------------------------------------------
-- Saved Variables  (SellerHelperSV)
--------------------------------------------------------------------
local function InitSV()
    if not SellerHelperSV then
        SellerHelperSV = {}
    end
    if SellerHelperSV.enabled == nil then
        SellerHelperSV.enabled = true
    end
    if SellerHelperSV.sellGray == nil then
        SellerHelperSV.sellGray = true
    end
    if SellerHelperSV.announce == nil then
        SellerHelperSV.announce = true
    end
    if SellerHelperSV.autoBuy == nil then
        SellerHelperSV.autoBuy = true
    end
end

local function ApplySettings()
    InitSV()
    if SellHelper_EnableToggle then
        SellHelper_EnableToggle(SellerHelperSV.enabled and 1 or nil)
    end
    if SellHelper_SellGrayToggle then
        SellHelper_SellGrayToggle(SellerHelperSV.sellGray and 1 or nil)
    end
    if SellHelper_SellAnnounceToggle then
        SellHelper_SellAnnounceToggle(SellerHelperSV.announce and 1 or nil)
    end
    if AR_AcceptToggle then
        AR_AcceptToggle(SellerHelperSV.autoBuy and 1 or nil)
    end
end

--------------------------------------------------------------------
-- Localization for chat feedback
--------------------------------------------------------------------
local locale = GetLocale()
local L = {}
if locale == "zhCN" then
    L.ON          = "开启"
    L.OFF         = "关闭"
    L.ENABLED     = "售卖助手已启用"
    L.DISABLED    = "售卖助手已禁用"
    L.GRAY_ON     = "自动出售灰色物品：开启"
    L.GRAY_OFF    = "自动出售灰色物品：关闭"
    L.ANN_ON      = "交易金额通报：开启"
    L.ANN_OFF     = "交易金额通报：关闭"
    L.BUY_ON      = "自动购买确认：开启"
    L.BUY_OFF     = "自动购买确认：关闭"
    L.USAGE       = "用法: /sh <enable|disable|gray|announce|autobuy>"
elseif locale == "zhTW" then
    L.ON          = "開啟"
    L.OFF         = "關閉"
    L.ENABLED     = "售賣助手已啟用"
    L.DISABLED    = "售賣助手已禁用"
    L.GRAY_ON     = "自動出售灰色物品：開啟"
    L.GRAY_OFF    = "自動出售灰色物品：關閉"
    L.ANN_ON      = "交易金額通報：開啟"
    L.ANN_OFF     = "交易金額通報：關閉"
    L.BUY_ON      = "自動購買確認：開啟"
    L.BUY_OFF     = "自動購買確認：關閉"
    L.USAGE       = "用法: /sh <enable|disable|gray|announce|autobuy>"
else
    L.ON          = "ON"
    L.OFF         = "OFF"
    L.ENABLED     = "SellerHelper enabled"
    L.DISABLED    = "SellerHelper disabled"
    L.GRAY_ON     = "Auto-sell gray items: ON"
    L.GRAY_OFF    = "Auto-sell gray items: OFF"
    L.ANN_ON      = "Trade cost announcement: ON"
    L.ANN_OFF     = "Trade cost announcement: OFF"
    L.BUY_ON      = "Auto-recharge confirmation: ON"
    L.BUY_OFF     = "Auto-recharge confirmation: OFF"
    L.USAGE       = "Usage: /sh <enable|disable|gray|announce|autobuy>"
end

local function Print(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SellerHelper|r: " .. msg, 1, 1, 0)
    end
end

--------------------------------------------------------------------
-- Slash command:  /sh  or  /sellerhelper
--------------------------------------------------------------------
SLASH_SELLERHELPER1 = "/sh"
SLASH_SELLERHELPER2 = "/sellerhelper"
SlashCmdList["SELLERHELPER"] = function(msg)
    InitSV()
    msg = strtrim(msg:lower())
    if msg == "enable" or msg == "on" then
        SellerHelperSV.enabled = true
        ApplySettings()
        Print(L.ENABLED)
    elseif msg == "disable" or msg == "off" then
        SellerHelperSV.enabled = false
        ApplySettings()
        Print(L.DISABLED)
    elseif msg == "gray" then
        SellerHelperSV.sellGray = not SellerHelperSV.sellGray
        ApplySettings()
        Print(SellerHelperSV.sellGray and L.GRAY_ON or L.GRAY_OFF)
    elseif msg == "announce" then
        SellerHelperSV.announce = not SellerHelperSV.announce
        ApplySettings()
        Print(SellerHelperSV.announce and L.ANN_ON or L.ANN_OFF)
    elseif msg == "autobuy" then
        SellerHelperSV.autoBuy = not SellerHelperSV.autoBuy
        ApplySettings()
        Print(SellerHelperSV.autoBuy and L.BUY_ON or L.BUY_OFF)
    else
        Print(L.USAGE)
    end
end

--------------------------------------------------------------------
-- Auto-enable on login (only when BigFoot is absent)
--------------------------------------------------------------------
local function IsAddonLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(name)
    end
    return IsAddOnLoaded(name)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    if IsAddonLoaded("BigFoot") then
        return
    end
    ApplySettings()
end)
