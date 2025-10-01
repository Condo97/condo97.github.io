-- TestBunnySystem.server.luau
-- DISABLED for production

--[[ DISABLED
-- Test script to verify the bunny system works properly

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for dependencies
task.wait(3) -- Give time for other scripts to initialize

-- Wait for shared modules
ReplicatedStorage.Shared:WaitForChild("AssetIds")
ReplicatedStorage.Shared:WaitForChild("AnimalConfig")
ReplicatedStorage.Shared:WaitForChild("BunnyReference")

local AssetIds = require(ReplicatedStorage.Shared.AssetIds)
local AnimalConfig = require(ReplicatedStorage.Shared.AnimalConfig)
local BunnyReference = require(ReplicatedStorage.Shared.BunnyReference)

print("🐰 ====== BUNNY SYSTEM TEST ======")

-- Test 1: Verify all asset IDs are loaded
print("\n📋 Asset IDs Test:")
for bunnyName, assetId in pairs(AssetIds.Bunnies) do
    print("✅", bunnyName, "→", assetId)
end

-- Test 2: Verify all tags are configured
print("\n🏷️  Tags Test:")
for bunnyName, tag in pairs(BunnyReference.TAG_MAPPING) do
    print("✅", bunnyName, "→", tag)
end

-- Test 3: Verify counter system is working
print("\n📊 Counter System Test:")
local countersFolder = ReplicatedStorage:FindFirstChild("AnimalCounters")
if countersFolder then
    print("✅ AnimalCounters folder exists")
    
    -- Check if counters are initialized for each bunny type
    for _, tag in pairs(BunnyReference.TAG_MAPPING) do
        local totalKey = AnimalConfig.CounterKeys.Total(tag)
        local infectedKey = AnimalConfig.CounterKeys.Infected(tag)
        local curedKey = AnimalConfig.CounterKeys.Cured(tag)
        
        local total = countersFolder:GetAttribute(totalKey)
        local infected = countersFolder:GetAttribute(infectedKey)
        local cured = countersFolder:GetAttribute(curedKey)
        
        print("✅", tag, "counters:", total, infected, cured)
    end
else
    print("❌ AnimalCounters folder not found")
end

-- Test 4: Verify AssetLoader can access all bunnies
print("\n🔄 AssetLoader Test:")
local success, AssetLoader = pcall(function()
    return require(script.Parent.AssetLoader)
end)

if success and AssetLoader then
    local availableBunnies = AssetLoader.getAllBunnyTypes()
    print("✅ Available bunny types:", table.concat(availableBunnies, ", "))
    
    if AssetLoader.isReady() then
        print("✅ AssetLoader is ready")
    else
        print("⚠️  AssetLoader not ready yet")
    end
else
    warn("❌ Failed to load AssetLoader")
end

print("\n🎉 Bunny system test complete!")

-- Uncomment to test spawning:
-- print("\n🚀 Testing bunny spawning in 5 seconds...")
-- wait(5)
-- local BunnySpawner = require(script.Parent.BunnySpawner)
-- BunnySpawner.spawnAllBunnyTypes()
--]]
