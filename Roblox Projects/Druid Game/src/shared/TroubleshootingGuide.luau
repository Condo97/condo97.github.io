-- TroubleshootingGuide.luau
-- Common issues and solutions for the bunny system

--[[

🚨 TROUBLESHOOTING GUIDE:
========================

ISSUE: "No bunnies spawning at evilBunnySpawner tagged blocks"
SOLUTION: 
1. Check that AssetLoaderInit.server.luau ran successfully
2. Verify asset IDs are correct in AssetIds.luau
3. Make sure the blocks are tagged with "evilBunnySpawner" (case-sensitive)
4. Check console for asset loading errors

ISSUE: "Failed to load asset: [ID]"
SOLUTIONS:
• Verify asset ID is correct (copy from Toolbox URL)
• Ensure asset is published to Roblox (not just saved locally)
• Check asset is not private/restricted
• Try republishing the model to Toolbox

ISSUE: "Attempted to call require with invalid argument(s)"
SOLUTION: AssetLoader should be a ModuleScript (.luau), not server script (.server.luau)

ISSUE: "Infinite yield possible on 'ServerScriptService.Server:WaitForChild("Humanoid")'"
SOLUTION: BunnyAI and TurnOnDeath scripts should only run when parented to bunny models, not in ServerScriptService

ISSUE: "BunnyAI: Missing essential components, exiting"
SOLUTIONS:
• Check that bunny models have Humanoid, Animator, and HumanoidRootPart
• Verify models are properly structured (R15 or R6 format)
• Try re-publishing models with correct hierarchy

🔍 DEBUG SCRIPTS:
================

DebugAssets.server.luau - Tests asset loading directly
TestBunnySystem.server.luau - Comprehensive system test
TestEvilBunnyTransformation.server.luau - Tests evil bunny mechanics

Run these to identify specific issues!

📋 CHECKLIST FOR SPAWNING ISSUES:
=================================

□ AssetIds.luau has correct asset IDs (not 0000000000)
□ Assets are published and accessible on Roblox
□ Blocks are tagged with "evilBunnySpawner" (exact spelling)  
□ AssetLoaderInit.server.luau completed successfully
□ No error messages in server console
□ EvilBunnyAutoSpawner found tagged blocks (check console log)

⚡ QUICK FIXES:
==============

1. RESTART THE SERVER - Many issues resolve with a fresh start
2. Run DebugAssets.server.luau to test asset loading
3. Check server console for detailed error messages
4. Verify asset IDs by visiting: roblox.com/library/[ASSET_ID]

🆘 STILL NOT WORKING?
====================

1. Run DebugAssets.server.luau
2. Copy the console output 
3. Check which specific assets are failing
4. Verify those asset IDs on Roblox website
5. Re-publish problematic models if needed

--]]

local TroubleshootingGuide = {}

-- Helper function to validate asset IDs
function TroubleshootingGuide.validateAssetIds()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local AssetIds = require(ReplicatedStorage.Shared.AssetIds)
    
    print("🔍 Validating Asset IDs...")
    
    for name, id in pairs(AssetIds.Bunnies) do
        if id == 0 or id == 0000000000 then
            warn("❌ Invalid asset ID for", name, "- still set to default value")
        else
            print("✅", name, "has valid asset ID:", id)
        end
    end
end

return TroubleshootingGuide
