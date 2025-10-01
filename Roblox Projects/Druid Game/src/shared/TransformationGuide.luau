-- TransformationGuide.luau  
-- Guide for the Evil Bunny Transformation System

--[[

💀 EVIL BUNNY TRANSFORMATION SYSTEM:
====================================

Evil bunnies have a special ability - when they die, they transform into 
a random normal bunny type instead of just disappearing!

🔄 HOW IT WORKS:
===============
1. Evil bunny takes damage and dies
2. TurnOnDeath script activates
3. Records position and infection status  
4. Removes evil bunny (decrements counters)
5. Spawns random normal bunny at same location
6. Preserves infection status
7. Adds new bunny to counters

🎯 TRANSFORMATION TARGETS:
=========================
Evil bunnies can transform into any of these normal types:
• BrownBunny
• TanBunny  
• WhiteBunny
• WhiteAndBlackBunny

The transformation is completely random each time!

⚙️ TECHNICAL DETAILS:
====================
• Script: TurnOnDeath.server.luau
• Only attached to EvilBunny spawns
• Triggers on Humanoid.Died event
• Uses BunnySpawner for clean integration
• Preserves infection status (infected evil → infected normal)
• Automatic counter management via AnimalCounter system

🎮 GAMEPLAY IMPLICATIONS:
========================
• Evil bunnies can't be permanently eliminated
• They always leave behind a "normal" bunny
• Infection status is preserved through transformation
• Creates interesting gameplay dynamics
• Population balance is maintained

📊 COUNTER EFFECTS:
==================
Before transformation:
- animalEvilBunny_Total: 1
- animalEvilBunny_Infected: 1 (if infected)

After transformation (example: → TanBunny):
- animalEvilBunny_Total: 0
- animalEvilBunny_Infected: 0  
- animalTanBunny_Total: 1
- animalTanBunny_Infected: 1 (if was infected)

🔧 AUTOMATIC INTEGRATION:
========================
The system works automatically:
• BunnySpawner adds TurnOnDeath script to evil bunnies
• No manual intervention needed
• Error handling included
• Logging for debugging

🧪 TESTING:
==========
Use TestEvilBunnyTransformation.server.luau to test:
• Spawns an evil bunny
• Kills it after a delay
• Monitors counter changes
• Verifies transformation works correctly

💡 CUSTOMIZATION:
================
To modify transformation targets, edit NORMAL_BUNNY_TYPES in TurnOnDeath.server.luau:

local NORMAL_BUNNY_TYPES = {
    "BrownBunny",
    "TanBunny", 
    "WhiteBunny",
    "WhiteAndBlackBunny"
    -- Add more normal types here if needed
}

--]]

local TransformationGuide = {}

return TransformationGuide
