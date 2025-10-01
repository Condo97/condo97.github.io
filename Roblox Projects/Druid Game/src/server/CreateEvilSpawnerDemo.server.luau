-- CreateEvilSpawnerDemo.server.luau
-- Demo script that creates example evil bunny spawn points
-- Run this once to set up test spawn points, then disable it
-- DISABLED: Manually tag blocks with "evilBunnySpawner" instead

--[[ DISABLED
local CollectionService = game:GetService("CollectionService")

-- Configuration for demo spawn points
local SPAWN_POINTS = {
    {name = "EvilLair1", position = Vector3.new(0, 5, 0), size = Vector3.new(8, 1, 8)},
    {name = "EvilLair2", position = Vector3.new(50, 5, 50), size = Vector3.new(6, 1, 6)},
    {name = "CorruptionZone", position = Vector3.new(-30, 5, 30), size = Vector3.new(10, 1, 10)}
}

local function createEvilSpawnPoint(config)
    -- Create the spawn block
    local spawnBlock = Instance.new("Part")
    spawnBlock.Name = config.name
    spawnBlock.Size = config.size
    spawnBlock.Position = config.position
    spawnBlock.Anchored = true
    spawnBlock.CanCollide = true
    
    -- Make it look evil/distinctive
    spawnBlock.Material = Enum.Material.Cobblestone
    spawnBlock.Color = Color3.fromRGB(80, 20, 20) -- Dark red
    
    -- Add the evil bunny spawner tag
    CollectionService:AddTag(spawnBlock, "evilBunnySpawner")
    
    -- Parent to workspace
    spawnBlock.Parent = workspace
    
    -- Add a visual indicator (optional)
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Parent = spawnBlock
    surfaceGui.Face = Enum.NormalId.Top
    
    local label = Instance.new("TextLabel")
    label.Parent = surfaceGui
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.Text = "👹 EVIL SPAWN"
    label.TextColor3 = Color3.fromRGB(255, 50, 50)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    
    print("✅ Created evil spawn point:", config.name, "at", config.position)
    
    return spawnBlock
end

print("🏗️  ====== CREATING DEMO EVIL SPAWN POINTS ======")

-- Create all demo spawn points
for _, config in ipairs(SPAWN_POINTS) do
    createEvilSpawnPoint(config)
    task.wait(0.1) -- Small delay between creations
end

print("🎉 Demo spawn points created!")
print("👹 Evil bunnies will spawn at these locations when EvilBunnyAutoSpawner runs")
print("💡 You can move, resize, or delete these blocks as needed")
print("⚠️  Disable this script after running once to avoid duplicate spawn points")

-- Auto-disable this script after creating the spawn points
script.Enabled = false
--]]
