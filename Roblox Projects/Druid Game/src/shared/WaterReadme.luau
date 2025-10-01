-- How to use custom Water volumes that behave exactly like Roblox Terrain water:
-- 1) Create a `Part` for your water volume. Name it exactly "Water" or add the tag "Water" via CollectionService.
-- 2) Set any visual you want (Color, Material, Transparency, textures, SurfaceAppearance, etc.). 
-- 3) The system automatically detects when players enter/exit water volumes and applies:
--    - Default Roblox swimming physics and controls
--    - Natural buoyancy that floats you toward the surface
--    - Camera-relative WASD movement + Space/Ctrl for up/down
--    - Proper swimming animations and state management
-- 4) No additional configuration needed - works just like terrain water!

return true


