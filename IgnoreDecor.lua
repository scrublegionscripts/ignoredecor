-- IgnoreDecor
-- A World of Warcraft addon

local addonName, ns = ...

-- Saved variables table
IgnoreDecorDB = IgnoreDecorDB or {}

local defaults = {
    debug = false,
}

local function Debug(msg)
    if IgnoreDecorDB.debug then
        print("|cff00ff00IgnoreDecor|r [DEBUG] " .. msg)
    end
end

-- Settings panel (ESC → Options → AddOns → IgnoreDecor)
local function InitSettings()
    local category = Settings.RegisterVerticalLayoutCategory("IgnoreDecor")

    local variable = "IgnoreDecor_Debug"
    local name = "Enable Debug Output"
    local tooltip = "Print detailed debug messages to chat when processing loot rolls."

    local setting = Settings.RegisterAddOnSetting(category, variable, "debug", IgnoreDecorDB, Settings.VarType.Boolean, name, defaults.debug)
    Settings.CreateCheckbox(category, setting, tooltip)

    Settings.RegisterAddOnCategory(category)
end

-- Create main addon frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("START_LOOT_ROLL")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            -- Initialize saved variables
            IgnoreDecorDB = IgnoreDecorDB or {}
            for key, value in pairs(defaults) do
                if IgnoreDecorDB[key] == nil then
                    IgnoreDecorDB[key] = value
                end
            end
            InitSettings()
            print("|cff00ff00IgnoreDecor|r successfully loaded.")
        end
    end

    if event == "START_LOOT_ROLL" then
        local rollID = ...
        Debug("START_LOOT_ROLL fired, rollID=" .. tostring(rollID))

        local rollName, texture, count, quality, bindOnPickUp, canNeed, canGreed, canDisenchant, reasonNeed, reasonGreed, reasonDisenchant, canPass = GetLootRollItemInfo(rollID)
        Debug("RollItemInfo: name=" .. tostring(rollName) .. " quality=" .. tostring(quality) .. " canPass=" .. tostring(canPass))

        local itemLink = GetLootRollItemLink(rollID)
        Debug("itemLink=" .. tostring(itemLink))
        if not itemLink then
            Debug("itemLink is nil, aborting roll")
            return
        end

        local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID = C_Item.GetItemInfoInstant(itemLink)
        Debug("GetItemInfoInstant: itemID=" .. tostring(itemID) .. " classID=" .. tostring(classID) .. " subClassID=" .. tostring(subClassID) .. " itemType=" .. tostring(itemType) .. " itemSubType=" .. tostring(itemSubType))

        local hasIsDecor = (C_Item.IsDecorItem ~= nil)
        Debug("C_Item.IsDecorItem exists=" .. tostring(hasIsDecor))

        if itemID and hasIsDecor then
            local isDecor = C_Item.IsDecorItem(itemID)
            Debug("IsDecorItem(" .. tostring(itemID) .. ")=" .. tostring(isDecor))
            if isDecor then
                RollOnLoot(rollID, 0) -- 0 = Pass
                print("|cff00ff00IgnoreDecor|r: Passed on decor " .. itemLink)
            else
                Debug("Not a decor item, skipping")
            end
        else
            Debug("Cannot check decor: itemID=" .. tostring(itemID) .. " hasIsDecor=" .. tostring(hasIsDecor))
        end
    end
end)
