-- AssetLoaderInit.server.luau
-- Initializes the AssetLoader module at server startup

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for shared modules to load
ReplicatedStorage.Shared:WaitForChild("AssetIds")

-- Get the AssetLoader module
local AssetLoader = require(script.Parent.AssetLoader)

print("AssetLoaderInit: Starting asset preloading...")

-- Initialize the AssetLoader
AssetLoader.preloadAnimals()

print("AssetLoaderInit: Asset preloading complete!")
