-- AssetIds.luau
-- Asset IDs for models stored in Toolbox/Roblox assets

local AssetIds = {}

-- Bunny Model IDs (actual asset IDs from Toolbox)
AssetIds.Bunnies = {
    BrownBunny = 108926147840538,         -- DruidGame_BrownBunny
    TanBunny = 90853430245161,            -- DruidGame_TanBunny
    WhiteBunny = 133760653915447,         -- DruidGame_WhiteBunny
    WhiteAndBlackBunny = 76392463700624,  -- DruidGame_BlackAndWhiteBunny
    EvilBunny = 93731493729779,           -- DruidGame_EvilBunny
}

-- Other Animal Model IDs (replace with your actual asset IDs)
AssetIds.Animals = {
    Dog = 0000000000,    -- Replace with your dog model ID  
    Cat = 0000000000,    -- Replace with your cat model ID
}

-- Get all asset IDs combined
function AssetIds.getAllAnimalIds()
    local allIds = table.clone(AssetIds.Bunnies)
    
    -- Add other animal IDs
    for name, id in pairs(AssetIds.Animals) do
        allIds[name] = id
    end
    
    return allIds
end

-- Usage example:
-- local model = game:GetService("InsertService"):LoadAsset(AssetIds.Bunnies.BrownBunny)

return AssetIds
