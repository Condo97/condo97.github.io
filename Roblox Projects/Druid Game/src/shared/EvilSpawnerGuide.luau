-- EvilSpawnerGuide.luau
-- Guide for setting up automatic evil bunny spawn points

--[[

👹 EVIL BUNNY AUTO-SPAWNER SYSTEM:
==================================

Automatically spawns 5 evil bunnies at server startup on blocks tagged with "evilBunnySpawner"

🏗️ SETUP INSTRUCTIONS:
======================

1. **Create Spawn Points:**
   • Place any part/block in your workspace where you want evil bunnies to spawn
   • Can be any size, shape, or material
   • Recommended: Use distinctive blocks so you can identify spawn points

2. **Tag the Spawn Points:**
   • Select your spawn block in Studio
   • In the Properties panel, find the "Tags" section
   • Add the tag: evilBunnySpawner
   • The tag is case-sensitive!

3. **Automatic Spawning:**
   • When the server starts, the system will find all tagged blocks
   • 5 evil bunnies will spawn above each spawn point
   • Bunnies are arranged in a circle pattern around the spawn point
   • 40% chance each bunny will be infected

⚙️ CONFIGURATION:
=================

You can modify these settings in EvilBunnyAutoSpawner.server.luau:

• EVIL_BUNNIES_PER_SPAWNER = 5     -- How many bunnies per spawn point
• SPAWN_HEIGHT_OFFSET = 5          -- How high above the block to spawn
• SPAWN_DELAY = 0.5                -- Delay between each bunny spawn
• INFECTION_CHANCE = 0.4           -- Chance for bunnies to be infected (40%)

📍 SPAWN BEHAVIOR:
==================

• Bunnies spawn 5 units above the tagged block
• Arranged in a circle pattern (radius: 3 units)
• Each gets random infection status based on INFECTION_CHANCE
• Includes AI movement script and TurnOnDeath transformation
• All standard bunny counter tracking applies

🔄 DYNAMIC SPAWNING:
===================

• If you add new tagged blocks during runtime, they will automatically spawn evil bunnies
• No need to restart the server
• Perfect for dynamic gameplay where new spawn points appear

📊 MONITORING:
==============

The system provides detailed logging:
• Lists all found spawn points on startup
• Shows spawning progress for each point
• Reports total evil bunnies spawned
• Warns if no spawn points are found

Example output:
```
🔥 ====== EVIL BUNNY AUTO-SPAWNER INITIALIZED ======
📍 Found 2 evil bunny spawn points:
   1 - Workspace.EvilSpawner1
   2 - Workspace.EvilSpawner2
👹 Spawning 5 evil bunnies at: EvilSpawner1
✅ Spawned evil bunny 1 at (10, 15, 5) (infected)
✅ Spawned evil bunny 2 at (13, 15, 5) (healthy)
🏁 Evil bunny spawning complete!
👹 Total evil bunnies spawned: 10
```

⚠️  TROUBLESHOOTING:
====================

**No bunnies spawning?**
• Check that your block has the exact tag: "evilBunnySpawner" (case-sensitive)
• Ensure the block is in Workspace (not ServerStorage/ReplicatedStorage)
• Check the server console for error messages

**Bunnies spawning in wrong place?**
• Make sure your spawn block is positioned where you want them
• Bunnies spawn 5 units above the block's center
• Adjust SPAWN_HEIGHT_OFFSET if needed

**Want different spawn amounts?**
• Change EVIL_BUNNIES_PER_SPAWNER in the script
• Remember: more bunnies = more server load

💡 BEST PRACTICES:
==================

• Use clearly labeled spawn blocks (name them "EvilSpawner1", "EvilSpawner2", etc.)
• Don't place spawn points too close together (bunnies might overlap)
• Consider placing spawn points away from player spawn areas
• Test with a few spawn points before adding many

🎮 GAMEPLAY TIPS:
=================

• Evil bunnies will start their AI movement immediately after spawning
• They may move away from spawn points quickly
• Remember: evil bunnies transform into normal bunnies when killed
• Great for creating "evil bunny lairs" or "corruption zones"

--]]

local EvilSpawnerGuide = {}

-- Helper function to check if a part is properly tagged
function EvilSpawnerGuide.checkSpawnPoint(part)
    local CollectionService = game:GetService("CollectionService")
    return CollectionService:HasTag(part, "evilBunnySpawner")
end

return EvilSpawnerGuide
