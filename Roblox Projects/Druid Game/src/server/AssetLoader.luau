-- AssetLoader.luau - ModuleScript
-- Service for loading and managing game assets

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local AssetIds = require(ReplicatedStorage.Shared.AssetIds)

local AssetLoader = {}

-- Cache for loaded models to avoid repeated loading
local modelCache = {}
local isInitialized = false

-- Load a model from asset ID with caching
function AssetLoader.loadModel(assetId: number): Model?
    if modelCache[assetId] then
        return modelCache[assetId]:Clone()
    end
    
    local success, result = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    
    if success and result then
        local model = result:GetChildren()[1]
        if model and model:IsA("Model") then
            -- Cache the model
            modelCache[assetId] = model
            model.Parent = nil -- Remove from the asset container
            result:Destroy() -- Clean up the container
            
            return model:Clone()
        end
    end
    
    warn("AssetLoader: Failed to load asset:", assetId)
    return nil
end

-- Load all animal models from Roblox asset IDs into ServerStorage for quick access
function AssetLoader.preloadAnimals()
    local animalsFolder = ServerStorage:FindFirstChild("Animals")
    if not animalsFolder then
        animalsFolder = Instance.new("Folder")
        animalsFolder.Name = "Animals" 
        animalsFolder.Parent = ServerStorage
    end
    
    -- Clear existing animals to avoid duplicates
    for _, child in ipairs(animalsFolder:GetChildren()) do
        child:Destroy()
    end
    
    print("AssetLoader: Preloading animals from Roblox asset IDs...")
    
    -- Load all bunnies from asset IDs
    for bunnyName, assetId in pairs(AssetIds.Bunnies) do
        if assetId > 0 then
            local model = AssetLoader.loadModel(assetId)
            if model then
                model.Name = bunnyName -- Use the code name (no spaces)
                model.Parent = animalsFolder
                print("AssetLoader: Preloaded bunny:", bunnyName, "from asset ID:", assetId)
            else
                warn("AssetLoader: Failed to preload bunny:", bunnyName, "with asset ID:", assetId)
            end
        else
            warn("AssetLoader: Invalid asset ID for bunny:", bunnyName)
        end
    end
    
    -- Load other animals from asset IDs
    for animalName, assetId in pairs(AssetIds.Animals) do
        if assetId > 0 then
            local model = AssetLoader.loadModel(assetId)
            if model then
                model.Name = animalName
                model.Parent = animalsFolder
                print("AssetLoader: Preloaded animal:", animalName, "from asset ID:", assetId)
            else
                warn("AssetLoader: Failed to preload animal:", animalName, "with asset ID:", assetId)
            end
        end
    end
    
    isInitialized = true
    print("AssetLoader: Preloading complete!")
end

-- Get a preloaded animal model
function AssetLoader.getAnimal(animalName: string): Model?
    if not isInitialized then
        warn("AssetLoader: Not initialized yet, call preloadAnimals() first")
        return nil
    end
    
    local animalsFolder = ServerStorage:FindFirstChild("Animals")
    if animalsFolder then
        local animalModel = animalsFolder:FindFirstChild(animalName)
        if animalModel then
            return animalModel:Clone()
        end
    end
    
    -- Fallback: try to load directly from asset ID
    local assetId = AssetIds.Bunnies[animalName] or AssetIds.Animals[animalName]
    if assetId and assetId > 0 then
        warn("AssetLoader: Animal not preloaded, attempting direct load:", animalName)
        local model = AssetLoader.loadModel(assetId)
        if model then
            model.Name = animalName
            return model
        end
    end
    
    warn("AssetLoader: Animal not found:", animalName)
    warn("Available animals in ServerStorage:")
    if animalsFolder then
        for _, child in ipairs(animalsFolder:GetChildren()) do
            warn("  -", child.Name)
        end
    end
    return nil
end

-- Get a specific bunny model
function AssetLoader.getBunny(bunnyName: string): Model?
    return AssetLoader.getAnimal(bunnyName)
end

-- Get all available bunny types
function AssetLoader.getAllBunnyTypes(): {string}
    local bunnyTypes = {}
    for bunnyName, _ in pairs(AssetIds.Bunnies) do
        table.insert(bunnyTypes, bunnyName)
    end
    return bunnyTypes
end

-- Get all available animal types (including bunnies)
function AssetLoader.getAllAnimalTypes(): {string}
    local animalTypes = {}
    
    -- Add bunny types
    for bunnyName, _ in pairs(AssetIds.Bunnies) do
        table.insert(animalTypes, bunnyName)
    end
    
    -- Add other animal types
    for animalName, _ in pairs(AssetIds.Animals) do
        table.insert(animalTypes, animalName)
    end
    
    return animalTypes
end

-- Check if AssetLoader is ready
function AssetLoader.isReady(): boolean
    return isInitialized
end

return AssetLoader
