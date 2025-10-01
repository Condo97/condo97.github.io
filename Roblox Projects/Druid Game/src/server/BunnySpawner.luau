-- BunnySpawner.luau
-- ModuleScript for spawning and managing different bunny types

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for dependencies
local AssetLoader = require(script.Parent.AssetLoader)
local AnimalConfig = require(ReplicatedStorage.Shared.AnimalConfig)

-- Get reference to the BunnyAI script for cloning
local bunnyAIScript = script.Parent:WaitForChild("BunnyAI")
-- Get reference to the TurnOnDeath script for evil bunnies
local turnOnDeathScript = script.Parent:WaitForChild("TurnOnDeath")
-- Get reference to the EvilBunnyHealthBar script
local healthBarScript = script.Parent:WaitForChild("EvilBunnyHealthBar")

local BunnySpawner = {}

-- Spawn positions for different bunny types
local SPAWN_POSITIONS = {
    BrownBunny = Vector3.new(0, 5, 0),
    TanBunny = Vector3.new(10, 5, 0), 
    WhiteBunny = Vector3.new(20, 5, 0),
    WhiteAndBlackBunny = Vector3.new(30, 5, 0),
    EvilBunny = Vector3.new(40, 5, 0)
}

-- Create a bunny with proper tags
function BunnySpawner.spawnBunny(bunnyType: string, position: Vector3?, isInfected: boolean?)
    local bunnyModel = AssetLoader.getBunny(bunnyType)
    if not bunnyModel then
        warn("Could not spawn bunny of type:", bunnyType)
        return nil
    end
    
    -- Unanchor all parts so the bunny can move and be affected by gravity
    for _, part in ipairs(bunnyModel:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
    
    -- Set position
    local spawnPos = position or SPAWN_POSITIONS[bunnyType] or Vector3.new(0, 5, 0)
    if bunnyModel.PrimaryPart then
        bunnyModel:SetPrimaryPartCFrame(CFrame.new(spawnPos))
    elseif bunnyModel:FindFirstChild("HumanoidRootPart") then
        bunnyModel.HumanoidRootPart.CFrame = CFrame.new(spawnPos)
    end
    
    -- Add species tag based on bunny type
    local speciesTag = nil
    if bunnyType == "BrownBunny" then
        speciesTag = AnimalConfig.BunnySpecies.BROWN_BUNNY
    elseif bunnyType == "TanBunny" then
        speciesTag = AnimalConfig.BunnySpecies.TAN_BUNNY
    elseif bunnyType == "WhiteBunny" then
        speciesTag = AnimalConfig.BunnySpecies.WHITE_BUNNY
    elseif bunnyType == "WhiteAndBlackBunny" then
        speciesTag = AnimalConfig.BunnySpecies.WHITE_BLACK_BUNNY
    elseif bunnyType == "EvilBunny" then
        speciesTag = AnimalConfig.BunnySpecies.EVIL_BUNNY
    end
    
    if speciesTag then
        CollectionService:AddTag(bunnyModel, speciesTag)
        print("Added species tag:", speciesTag, "to", bunnyType)
    end
    
    -- Add infection tag if specified
    if isInfected then
        CollectionService:AddTag(bunnyModel, AnimalConfig.StatusTags.INFECTED)
        print("Added infection tag to", bunnyType)
    end
    
    -- Set bunny type for AI configuration
    local bunnyTypeValue = Instance.new("StringValue")
    bunnyTypeValue.Name = "BunnyType"
    bunnyTypeValue.Value = bunnyType
    bunnyTypeValue.Parent = bunnyModel
    
    -- Add AI script to the bunny for movement and animations
    local aiScript = bunnyAIScript:Clone()
    aiScript.Parent = bunnyModel
    aiScript.Enabled = true
    print("Added AI script to", bunnyType, "with custom configuration")
    
    -- Add TurnOnDeath script and health bar only to evil bunnies
    if bunnyType == "EvilBunny" then
        local deathScript = turnOnDeathScript:Clone()
        deathScript.Parent = bunnyModel
        deathScript.Enabled = true
        print("Added TurnOnDeath script to", bunnyType, "- will transform into normal bunny on death")
        
        local healthBar = healthBarScript:Clone()
        healthBar.Parent = bunnyModel
        healthBar.Enabled = true
        print("Added HealthBar script to", bunnyType)
    end
    
    -- Parent to workspace
    bunnyModel.Parent = workspace
    
    print("Spawned", bunnyType, "at position", spawnPos)
    return bunnyModel
end

-- Spawn all bunny types for testing
function BunnySpawner.spawnAllBunnyTypes()
    local bunnyTypes = AssetLoader.getAllBunnyTypes()
    
    print("Spawning all bunny types...")
    for i, bunnyType in ipairs(bunnyTypes) do
        -- Make every other bunny infected for testing
        local isInfected = (i % 2 == 0)
        BunnySpawner.spawnBunny(bunnyType, nil, isInfected)
        wait(1) -- Small delay between spawns
    end
    
    print("All bunnies spawned!")
end

-- Example: Spawn a random bunny
function BunnySpawner.spawnRandomBunny(position: Vector3?, infectionChance: number?)
    local bunnyTypes = AssetLoader.getAllBunnyTypes()
    local randomType = bunnyTypes[math.random(1, #bunnyTypes)]
    
    local chance = infectionChance or 0.3 -- 30% chance by default
    local isInfected = math.random() < chance
    
    return BunnySpawner.spawnBunny(randomType, position, isInfected)
end

-- Uncomment to test spawning all bunnies when server starts:
-- wait(3) -- Give time for assets to load
-- BunnySpawner.spawnAllBunnyTypes()

return BunnySpawner
