--[[
    BigFootShim.lua
    Lightweight standalone replacements for the BigFoot library functions
    that SellerHelper relies on, so the addon can run without BigFoot core.

    If another addon (e.g. BFGadgets) already defined a partial BLibrary,
    we WRAP it: BEvent gets a proper event dispatcher, everything else
    falls through to the previous implementation.
]]

local _prevBLibrary = BLibrary  -- may be nil or another addon's shim

local registry = {}

function BLibrary(name, kind, title)
    --------------------------------------------------------
    -- BEvent: frame-backed event dispatcher
    -- Each call creates a NEW instance so SellerHelper.lua
    -- and AutoRecharge.lua get independent dispatchers.
    --------------------------------------------------------
    if name == "BEvent" then
        local obj      = {}
        local frame    = CreateFrame("Frame")
        local handlers = {}

        frame:SetScript("OnEvent", function(_, event, ...)
            local h = handlers[event]
            if h then h(event, ...) end
        end)

        function obj:RegisterEvent(event, handler)
            handlers[event] = handler
            frame:RegisterEvent(event)
        end

        function obj:UnregisterEvent(event)
            handlers[event] = nil
            frame:UnregisterEvent(event)
        end

        function obj:UnregisterAllEvent()
            for evt in pairs(handlers) do
                frame:UnregisterEvent(evt)
            end
            handlers = {}
        end

        return obj
    end

    --------------------------------------------------------
    -- Everything else: delegate to previous BLibrary if it
    -- exists (e.g. BFGadgets' shim handles "BInfo").
    --------------------------------------------------------
    if _prevBLibrary then
        return _prevBLibrary(name, kind, title)
    end

    --------------------------------------------------------
    -- Fallback: generic chat-output singleton per name
    --------------------------------------------------------
    name = name or "default"
    if not registry[name] then
        local obj  = {}
        obj.name   = title or name
        function obj:Print(msg)
            if DEFAULT_CHAT_FRAME then
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cff00ff00" .. tostring(self.name) .. "|r: " .. tostring(msg))
            end
        end
        registry[name] = obj
    end
    return registry[name]
end


--------------------------------------------------------------------
-- BigFoot_DelayCall(func, delay)
-- BigFoot's deferred-call helper.  C_Timer.After is the modern
-- equivalent and has been available since WoD (6.x).
--------------------------------------------------------------------
if not BigFoot_DelayCall then
    function BigFoot_DelayCall(func, delay)
        C_Timer.After(delay or 0, func)
    end
end


--[[
    ------------------------------------------------------------------
    WoW Forever (Interface 16001 / modern Mainline) compatibility layer
    ------------------------------------------------------------------
    The client no longer ships the classic 1.x - 11.x global helpers that
    this addon was written against.  Every shim below restores the OLD
    call signature on top of the new C_* namespace so the original addon
    logic can run unchanged.  The `if not <name>` guards keep the shims
    inert if the client (or another addon) still provides the global.
]]

--------------------------------------------------------------------
-- GetItemInfo -> C_Item.GetItemInfo
-- Same multi-return order (name, link, quality, itemLevel, ... , icon,
-- sellPrice, ...).  Returns nil while the item is not cached yet.
--------------------------------------------------------------------
if not GetItemInfo and C_Item and C_Item.GetItemInfo then
    function GetItemInfo(item)
        return C_Item.GetItemInfo(item)
    end
end

--------------------------------------------------------------------
-- C_Container wrappers.
-- NOTE: C_Container.GetContainerItemInfo returns a table; the classic
-- 10-value signature is rebuilt below because the addon destructures it.
--------------------------------------------------------------------
if not GetContainerNumSlots and C_Container then
    function GetContainerNumSlots(bagID)
        return C_Container.GetContainerNumSlots(bagID) or 0
    end
end

if not GetContainerItemLink and C_Container then
    function GetContainerItemLink(bagID, slot)
        return C_Container.GetContainerItemLink(bagID, slot)
    end
end

if not GetContainerItemID and C_Container then
    function GetContainerItemID(bagID, slot)
        return C_Container.GetContainerItemID(bagID, slot)
    end
end

if not UseContainerItem and C_Container then
    function UseContainerItem(bagID, slot, onSelf)
        return C_Container.UseContainerItem(bagID, slot, onSelf)
    end
end

if not GetContainerItemInfo and C_Container then
    function GetContainerItemInfo(bagID, slot)
        local info = C_Container.GetContainerItemInfo(bagID, slot)
        if not info then return nil end
        -- iconFileID is a number (not the old texture path); SetTexture()
        -- accepts file IDs, so callers keep working.
        return info.iconFileID,      -- 1 texture
               info.stackCount,      -- 2 count
               info.isLocked,        -- 3 locked
               info.quality,         -- 4 quality
               info.isReadable,      -- 5 readable
               info.hasLootable,     -- 6 lootable
               info.hyperlink,       -- 7 item link
               info.isFiltered,      -- 8 filtered
               info.hasNoValue,      -- 9 noValue
               info.itemID           -- 10 itemID
    end
end

--------------------------------------------------------------------
-- Merchant API -> C_MerchantFrame.GetItemInfo() (table based).
--------------------------------------------------------------------
if not GetMerchantNumItems and C_MerchantFrame then
    function GetMerchantNumItems()
        return C_MerchantFrame.GetNumItems()
    end
end

if not GetMerchantItemInfo and C_MerchantFrame then
    function GetMerchantItemInfo(index)
        local info = C_MerchantFrame.GetItemInfo(index)
        if not info then return nil end
        -- classic order: name, texture, price, quantity, numAvailable,
        -- isPurchasable, isUsable
        return info.name, info.texture, info.price, info.quantity,
               info.numAvailable, info.isPurchasable, info.isUsable
    end
end

if not GetMerchantItemLink and C_MerchantFrame then
    function GetMerchantItemLink(index)
        local info = C_MerchantFrame.GetItemInfo(index)
        if not info then return nil end
        return info.hyperlink or info.link
    end
end

if not GetMerchantItemMaxStack and C_MerchantFrame then
    function GetMerchantItemMaxStack(index)
        local info = C_MerchantFrame.GetItemInfo(index)
        -- numAvailable is the closest modern equivalent; never return 0/nil
        -- because the caller divides by this value.
        local n = info and info.numAvailable
        if not n or n < 1 then n = 1 end
        return n
    end
end