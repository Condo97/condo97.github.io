-- BunnyGuide.luau
-- Quick reference guide for using the bunny system

--[[

🐰 FIVE BUNNY TYPES AVAILABLE:
- BrownBunny          (Tag: "animalBrownBunny")
- TanBunny            (Tag: "animalTanBunny") 
- WhiteBunny          (Tag: "animalWhiteBunny")
- WhiteAndBlackBunny  (Tag: "animalWhiteAndBlackBunny")
- EvilBunny           (Tag: "animalEvilBunny") ⚡ TRANSFORMS ON DEATH!

🔧 SETUP COMPLETE! ✅
Your bunny models are already configured:
   AssetIds.Bunnies = {
       BrownBunny = 108926147840538,         -- DruidGame_BrownBunny
       TanBunny = 90853430245161,            -- DruidGame_TanBunny
       WhiteBunny = 133760653915447,         -- DruidGame_WhiteBunny
       WhiteAndBlackBunny = 76392463700624,  -- DruidGame_BlackAndWhiteBunny
       EvilBunny = 93731493729779,           -- DruidGame_EvilBunny
   }

📊 TRACKING SYSTEM:
The AnimalCounter automatically tracks:
- Total count per bunny type
- Infected count per bunny type  
- Cured count per bunny type

Access from client via:
local counters = ReplicatedStorage.AnimalCounters
local brownTotal = counters:GetAttribute("animalBrownBunny_Total")
local brownInfected = counters:GetAttribute("animalBrownBunny_Infected")

🎮 SPAWNING BUNNIES:
local BunnySpawner = require(ServerScriptService.Server.BunnySpawner)

-- Spawn a specific bunny type
BunnySpawner.spawnBunny("BrownBunny", Vector3.new(0, 5, 0), false) -- not infected

-- Spawn a random bunny
BunnySpawner.spawnRandomBunny(Vector3.new(10, 5, 0), 0.3) -- 30% infection chance

-- Test all bunny types
BunnySpawner.spawnAllBunnyTypes()

🏷️ TAGS USED:
Species Tags: "animalBrownBunny", "animalTanBunny", etc.  
Status Tag: "animalInfected" (for infected animals)

The system automatically applies the correct tags when spawning!

💀 SPECIAL FEATURES:

EVIL BUNNY TRANSFORMATION:
When an Evil Bunny dies, it transforms into a random normal bunny type!
• Preserves position and infection status
• Maintains population balance  
• Creates interesting gameplay dynamics
• Uses TurnOnDeath script (automatically added to evil bunnies)

AUTO-SPAWNING EVIL BUNNIES:
Evil bunnies automatically spawn at server start on tagged blocks!
• Tag any block with "evilBunnySpawner"
• 5 evil bunnies spawn above each tagged block
• 40% chance each bunny is infected
• See EvilSpawnerGuide.luau for setup instructions

--]]

local BunnyGuide = {}

-- This is just a reference file, no actual functionality
return BunnyGuide
