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