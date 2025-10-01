-- DebugAssets.server.luau
-- Debug script to test asset loading directly
-- DISABLED for production

--[[ DISABLED
local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🔍 ====== ASSET DEBUG TEST ======")

-- Wait for AssetIds to be available
ReplicatedStorage.Shared:WaitForChild("AssetIds")
local AssetIds = require(ReplicatedStorage.Shared.AssetIds)

print("📋 Testing direct asset loading...")

-- Test each bunny asset directly
for bunnyName, assetId in pairs(AssetIds.Bunnies) do
    print("\n🐰 Testing", bunnyName, "with ID:", assetId)
    
    local success, result = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    
    if success and result then
        local model = result:GetChildren()[1]
        if model and model:IsA("Model") then
            print("✅", bunnyName, "loaded successfully!")
            print("   - Model name:", model.Name)
            print("   - Children count:", #model:GetChildren())
            
            -- Check for essential parts
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local rootPart = model:FindFirstChild("HumanoidRootPart")
            
            if humanoid then
                print("   - ✅ Has Humanoid")
            else
                print("   - ❌ Missing Humanoid")
            end
            
            if rootPart then
                print("   - ✅ Has HumanoidRootPart")
            else
                print("   - ❌ Missing HumanoidRootPart")
            end
            
            -- Clean up
            result:Destroy()
        else
            warn("❌", bunnyName, "- Invalid model structure")
        end
    else
        warn("❌", bunnyName, "failed to load:", result)
    end
    
    task.wait(0.5)
end

print("\n🏁 Asset debug test complete!")
print("If assets failed to load, check:")
print("• Asset IDs are correct")
print("• Assets are published to Roblox")
print("• Assets are not private/restricted")
print("• You have permission to access the assets")
--]]
