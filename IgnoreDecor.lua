-- IgnoreDecor
-- A World of Warcraft addon

local addonName, ns = ...

-- Saved variables table
IgnoreDecorDB = IgnoreDecorDB or {}

-- Create main addon frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("START_LOOT_ROLL")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == addonName then
            -- Initialize saved variables
            IgnoreDecorDB = IgnoreDecorDB or {}
            print("|cff00ff00IgnoreDecor|r loaded.")
        end
    elseif event == "START_LOOT_ROLL" then
        for rollID = 1, GetNumLootItems() do
            local itemName, _, _, _, _, _, _, _, _, _ = GetLootRollItemInfo(rollID)
            if C_Item.IsDecorItem(itemName) then
                -- Check if the item is decor and should be ignored
                if IgnoreDecorDB[itemName] then
                    print("|cff00ff00IgnoreDecor|r: Ignoring decor item " .. itemName)
                    -- Logic to pass on the item
                    RollOnLoot(rollID, 0)
                end
            end
        end
    end
end)
