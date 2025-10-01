-- BunnyReference.luau
-- Complete reference for all bunny types with their IDs and tags

--[[
🐰 COMPLETE BUNNY SYSTEM REFERENCE:

BUNNY TYPE           ASSET ID          COLLECTION TAG
==========           ========          ==============
BrownBunny          108926147840538    animalBrownBunny
TanBunny            90853430245161     animalTanBunny  
WhiteBunny          133760653915447    animalWhiteBunny
WhiteAndBlackBunny  76392463700624     animalWhiteAndBlackBunny
EvilBunny           93731493729779     animalEvilBunny

STATUS TAG:
===========
animalInfected (for infected bunnies)

COUNTER KEYS GENERATED:
======================
For each bunny type, the system tracks:
- {species}_Total     (e.g., "animalBrownBunny_Total")
- {species}_Infected  (e.g., "animalBrownBunny_Infected")  
- {species}_Cured     (e.g., "animalBrownBunny_Cured")

ACCESS FROM CLIENT:
===================
local counters = ReplicatedStorage:WaitForChild("AnimalCounters")
local brownTotal = counters:GetAttribute("animalBrownBunny_Total")
local evilInfected = counters:GetAttribute("animalEvilBunny_Infected")

SPAWNING EXAMPLES:
==================
local BunnySpawner = require(ServerScriptService.Server.BunnySpawner)

-- Spawn specific bunny types
BunnySpawner.spawnBunny("BrownBunny", Vector3.new(0, 5, 0), false)
BunnySpawner.spawnBunny("EvilBunny", Vector3.new(10, 5, 0), true) -- infected

-- Spawn random bunny
BunnySpawner.spawnRandomBunny(Vector3.new(20, 5, 0), 0.5) -- 50% infection chance

-- Test all bunnies
BunnySpawner.spawnAllBunnyTypes()
--]]

local BunnyReference = {}

-- Mapping of bunny names to their asset IDs (for quick reference)
BunnyReference.ASSET_MAPPING = {
    BrownBunny = 108926147840538,
    TanBunny = 90853430245161,
    WhiteBunny = 133760653915447,
    WhiteAndBlackBunny = 76392463700624,
    EvilBunny = 93731493729779
}

-- Mapping of bunny names to their collection tags
BunnyReference.TAG_MAPPING = {
    BrownBunny = "animalBrownBunny",
    TanBunny = "animalTanBunny", 
    WhiteBunny = "animalWhiteBunny",
    WhiteAndBlackBunny = "animalWhiteAndBlackBunny",
    EvilBunny = "animalEvilBunny"
}

-- Get the tag for a bunny type
function BunnyReference.getTagForBunny(bunnyType: string): string?
    return BunnyReference.TAG_MAPPING[bunnyType]
end

-- Get the asset ID for a bunny type
function BunnyReference.getAssetIdForBunny(bunnyType: string): number?
    return BunnyReference.ASSET_MAPPING[bunnyType]
end

return BunnyReference
