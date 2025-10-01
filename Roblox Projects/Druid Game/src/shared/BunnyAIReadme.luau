-- BunnyAIReadme.luau
-- Complete guide for the Bunny AI System

--[[

🤖 BUNNY AI SYSTEM OVERVIEW:
============================

The Bunny AI system automatically adds intelligent movement and animation 
to all spawned bunnies with customizable behavior per bunny type.

📁 FILES:
=========
• BunnyAI.server.luau - Main AI script (gets cloned to each bunny)
• BunnyAIConfig.luau - Configuration for different bunny behaviors  
• BunnySpawner.server.luau - Automatically adds AI to spawned bunnies

🎛️ BUNNY BEHAVIORS:
===================
Each bunny type has unique movement characteristics:

BrownBunny:      Normal speed, balanced movement
TanBunny:        Slightly faster, more active
WhiteBunny:      Slower, more cautious, pauses more
WhiteAndBlackBunny: Fast and energetic
EvilBunny:       Very fast, rarely pauses, aggressive movement

⚙️ CONFIGURATION:
=================
Customize behavior in BunnyAIConfig.luau:
• WALK_SPEED - How fast the bunny moves
• MOVE_INTERVAL - Time between movements  
• MIN/MAX_DISTANCE - Movement range
• PAUSE_CHANCE - Probability of pausing instead of moving
• ROTATION_OFFSET - Initial rotation on spawn

🚀 AUTOMATIC OPERATION:
======================
When you spawn a bunny using BunnySpawner:
1. ✅ Bunny model is loaded from Toolbox
2. ✅ Species and infection tags are applied
3. ✅ BunnyType value is set for AI configuration
4. ✅ AI script is cloned and added to the bunny
5. ✅ Bunny begins intelligent movement automatically

🎮 FEATURES:
============
• Hop animation synchronized with movement
• Random movement patterns within configurable range
• Pause behavior for realistic animal movement  
• Automatic cleanup when bunny is destroyed
• Error handling and recovery
• Per-bunny-type speed and behavior customization
• Efficient event-driven movement (no polling loops)

📊 MONITORING:
==============
The AI system logs its initialization:
"🐰 Bunny AI initialized for: EvilBunny - Speed: 12 Pause chance: 0.05"

🔧 USAGE:
=========
Just use the normal BunnySpawner - AI is added automatically!

local BunnySpawner = require(ServerScriptService.Server.BunnySpawner)
BunnySpawner.spawnBunny("EvilBunny", Vector3.new(0, 5, 0), false)
-- AI behavior starts immediately!

--]]

local BunnyAIReadme = {}

return BunnyAIReadme
