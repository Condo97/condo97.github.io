-- EvilBunnyAutoSpawner.server.luau
-- Automatically spawns evil bunnies at blocks tagged with "evilBunnySpawner" on server start

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local EVIL_BUNNY_SPAWN_TAG = "evilBunnySpawner"
local EVIL_BUNNIES_PER_SPAWNER = 5
local SPAWN_HEIGHT_OFFSET = 5 -- Units above the spawn block
local SPAWN_DELAY = 0.5 -- Delay between each bunny spawn (seconds)
local INFECTION_CHANCE = 0.4 -- 40% chance for evil bunnies to be infected

-- Wait for dependencies to load
task.wait(3)

-- Wait for AssetLoader to be ready
local AssetLoader = require(script.Parent.AssetLoader)
while not AssetLoader.isReady() do
    task.wait(1)
    print("EvilBunnyAutoSpawner: Waiting for AssetLoader to be ready...")
end

local BunnySpawner = require(script.Parent.BunnySpawner)

print("🔥 ====== EVIL BUNNY AUTO-SPAWNER INITIALIZED ======")

-- Function to get spawn position above a part
local function getSpawnPosition(spawnPart)
    local partSize = spawnPart.Size
    local partPosition = spawnPart.Position
    
    -- Spawn above the part
    return Vector3.new(
        partPosition.X,
        partPosition.Y + (partSize.Y / 2) + SPAWN_HEIGHT_OFFSET,
        partPosition.Z
    )
end

-- Function to spawn evil bunnies around a spawn point
local function spawnEvilBunniesAtSpawner(spawnPart)
    print("👹 Spawning", EVIL_BUNNIES_PER_SPAWNER, "evil bunnies at:", spawnPart.Name)
    
    local basePosition = getSpawnPosition(spawnPart)
    
    for i = 1, EVIL_BUNNIES_PER_SPAWNER do
        -- Create slight position variation so bunnies don't all spawn on top of each other
        local angle = (math.pi * 2 / EVIL_BUNNIES_PER_SPAWNER) * (i - 1)
        local radius = 3 -- Small radius around spawn point
        
        local spawnPosition = Vector3.new(
            basePosition.X + math.cos(angle) * radius,
            basePosition.Y,
            basePosition.Z + math.sin(angle) * radius
        )
        
        -- Determine if this evil bunny should be infected
        local isInfected = math.random() < INFECTION_CHANCE
        
        -- Spawn the evil bunny
        local success, evilBunny = pcall(function()
            return BunnySpawner.spawnBunny("EvilBunny", spawnPosition, isInfected)
        end)
        
        if success and evilBunny then
            local statusText = isInfected and "infected" or "healthy"
            print("✅ Spawned evil bunny", i, "at", spawnPosition, "(" .. statusText .. ")")
        else
            warn("❌ Failed to spawn evil bunny", i, ":", evilBunny)
        end
        
        -- Small delay between spawns
        if i < EVIL_BUNNIES_PER_SPAWNER then
            task.wait(SPAWN_DELAY)
        end
    end
    
    print("🎉 Completed spawning evil bunnies at:", spawnPart.Name)
end

-- Function to handle when new spawn points are added
local function onEvilSpawnerAdded(spawnPart)
    print("🆕 New evil bunny spawner detected:", spawnPart:GetFullName())
    
    -- Small delay to ensure the part is fully loaded
    task.wait(0.1)
    
    spawnEvilBunniesAtSpawner(spawnPart)
end

-- Function to spawn evil bunnies at all existing spawn points
local function spawnAtExistingSpawners()
    local spawnParts = CollectionService:GetTagged(EVIL_BUNNY_SPAWN_TAG)
    
    if #spawnParts == 0 then
        print("⚠️  No parts found with tag '" .. EVIL_BUNNY_SPAWN_TAG .. "'")
        print("💡 To create spawn points:")
        print("   1. Place a part in your workspace")
        print("   2. Add the tag '" .. EVIL_BUNNY_SPAWN_TAG .. "' to it")
        print("   3. Evil bunnies will spawn above it automatically!")
        return
    end
    
    print("📍 Found", #spawnParts, "evil bunny spawn points:")
    for i, part in ipairs(spawnParts) do
        print("  ", i, "-", part:GetFullName())
    end
    
    print("\n🚀 Starting evil bunny spawning...")
    
    -- Spawn evil bunnies at each spawn point
    for _, spawnPart in ipairs(spawnParts) do
        spawnEvilBunniesAtSpawner(spawnPart)
        
        -- Delay between different spawn points
        task.wait(1)
    end
    
    local totalBunnies = #spawnParts * EVIL_BUNNIES_PER_SPAWNER
    print("\n🏁 Evil bunny spawning complete!")
    print("👹 Total evil bunnies spawned:", totalBunnies)
end

-- Connect to future spawn point additions
CollectionService:GetInstanceAddedSignal(EVIL_BUNNY_SPAWN_TAG):Connect(onEvilSpawnerAdded)

-- Handle existing spawn points
print("🔍 Searching for existing evil bunny spawn points...")
spawnAtExistingSpawners()

-- Also update the AnimalConfig to include the spawn tag for reference
task.spawn(function()
    local AnimalConfig = require(ReplicatedStorage.Shared.AnimalConfig)
    if not AnimalConfig.SpawnTags then
        AnimalConfig.SpawnTags = {}
    end
    AnimalConfig.SpawnTags.EVIL_BUNNY_SPAWNER = EVIL_BUNNY_SPAWN_TAG
end)
