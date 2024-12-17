
# Path to the entity loot table folder from Vanilla Tweaks' Mini Blocks mod download.
# Changes to original folder
$SourceEntitiesFolder = "C:\Projects\MCAddons\stable\sources\mini blocks v1.1.0 (MC 1.21-1.21.4)\data\mini_blocks\recipe"
# Path to the root of this project.
$OutputProjectRoot = "C:\Projects\MCAddons\stable\MiniBlocks"
$OutputLogFile = "$($OutputProjectRoot)\output.log"
$TemplatesFolder = "$($OutputProjectRoot)\templates"

# Template Paths
$BlockStandardTemplateFile = "$($TemplatesFolder)\blocks-standard.txt"
# $BlockFacingTemplateFile = "$($TemplatesFolder)\blocks-facing.txt"
$AttachableTemplateFile = "$($TemplatesFolder)\rp-attachable.txt"
$PlacerTemplateFile = "$($TemplatesFolder)\bp-placer-item.txt"
$RecipeStonecuttingTemplateFile = "$($TemplatesFolder)\bp-recipe-stonecutting.txt"
$RecipeAfromBTemplateFile = "$($TemplatesFolder)\bp-recipe-attachable-from-block.txt"
$RecipeBfromATemplateFile = "$($TemplatesFolder)\bp-recipe-block-from-attachable.txt"

$OutputItemLangFile = "$($OutputProjectRoot)\tempItemLang.txt"
$OutputTileLangFile = "$($OutputProjectRoot)\tempTileLang.txt"

$OutputBPFolder = "$($OutputProjectRoot)\behavior_packs\mini-blocks"
$OutputRPFolder = "$($OutputProjectRoot)\\resource_packs\mini-blocks"

# Output Behavior Pack Folders
$OutputBpBlocksFolder = "$($OutputBPFolder)\blocks"
$OutputBpItemsFolder = "$($OutputBPFolder)\items"
$OutputBpBlocksLootTableFolder = "$($OutputBPFolder)\loot_tables\blocks"
$OutputBpRecipesFolder = "$($OutputBPFolder)\recipes"

# Output Resource Pack Folders
$OutputRpAttachablesFolder = "$($OutputRPFolder)\attachables"
$OutputRpBlockTexturesFolder = "$($OutputRPFolder)\textures\blocks"
$OutputRpAttachableTexturesFolder = "$($OutputRPFolder)\textures\entity\attachable"

# Specific files to update/append
$OutputRpTexts = "$($OutputRPFolder)\texts\en_US.lang"
$OutputRpTerrainTextures = "$($OutputRPFolder)\textures\terrain_texture.json"
$OutputRpBlocks = "$($OutputRPFolder)\blocks.json"

# Schema Format Versions
$FormatVersionBlocks = "1.21.40"
$FormatVersionAttachable = "1.10.0"
$FormatVersionItem = "1.21.40"
$FormatVersionRecipe = "1.20.10"

$ReplaceLitFormatVersion = "FMT_VER"
$ReplaceLitItemName = "ITEM_NAME"
$ReplaceLitIngredient = "INGREDIENT"

# JSON Snippits
$BlocksJsonHeader = "{`n  ""format_version"": ""$($FormatVersionBlocks)"","

$TerrainTexturesHeader = "{`n  ""resource_pack_name"": ""vanilla"",`n  ""texture_name"": ""atlas.terrain"",`n  ""padding"": 8,`n  ""num_mip_levels"": 4,`n  ""texture_data"": {"

function BuildItemSet {
  param(
    $ItemName,
    $Ingredient
  )
  $CleanedItemName = ($ItemName).Replace(" ", "_").Replace("(", "").Replace(")", "").ToLower()

  
  ## Resource Pack
  $ItemFileName = "$($CleanedItemName).png"
  Copy-Item -Path "$($OutputRpAttachableTexturesFolder)\$($ItemFileName)" -Destination "$($OutputRpBlockTexturesFolder)\$($ItemFileName)"
  if ($CleanedItemName -eq "mini_yellow_concrete") {
    Add-Content -Path $OutputRpBlocks -Value "  ""$($CleanedItemName)_block"": { ""sound"": ""stone"", ""textures"": ""$($CleanedItemName)"" }"
    Add-Content -Path $OutputRpTerrainTextures -Value "    ""$($CleanedItemName)"": { ""textures"": ""textures/blocks/$($CleanedItemName)"" }"
  }
  else {
    Add-Content -Path $OutputRpBlocks -Value "  ""$($CleanedItemName)_block"": { ""sound"": ""stone"", ""textures"": ""$($CleanedItemName)"" },"
    Add-Content -Path $OutputRpTerrainTextures -Value "    ""$($CleanedItemName)"": { ""textures"": ""textures/blocks/$($CleanedItemName)"" },"
  }
  Add-Content -Path $OutputItemLangFile -Value "item.miniblocks:$($CleanedItemName)=$($ItemName)"
  Add-Content -Path $OutputTileLangFile -Value "tile.miniblocks:$($CleanedItemName)_block.name=$($ItemName) Block"

  # Attachables
  (Get-Content -Path $AttachableTemplateFile) |
  ForEach-Object { ($_).replace($ReplaceLitFormatVersion, $FormatVersionAttachable).replace($ReplaceLitItemName, $CleanedItemName) } |
  Set-Content -Path "$($OutputRpAttachablesFolder)\$($CleanedItemName).attachable.json"
  # Set-Content -Path "$($OutputRpAttachablesFolder)\$($CleanedItemName).attachable.json" -Value "{`n  ""format_version"": ""$($FormatVersionAttachable)"",`n  ""minecraft:attachable"": {`n    ""description"": {`n      ""identifier"": ""miniblocks:$($CleanedItemName)"",`n      ""render_controllers"": [""controller.render.armor""],`n      ""materials"": {`n        ""default"": ""entity_alphatest"",`n        ""enchanted"": ""entity_alphatest_glint""`n      },`n      ""textures"": {`n        ""default"": ""textures/entity/attachable/$($CleanedItemName)"",`n        ""enchanted"": ""textures/misc/enchanted_item_glint""`n      },`n      ""geometry"": {`n        ""default"": ""geometry.mini_blocks""`n      }`n    }`n  }`n}"
  
  ## Behavior Pack
  # Blocks
  
  # (Get-Content -Path $BlockFacingTemplateFile) |
  # ForEach-Object { ($_).replace($ReplaceLitFormatVersion, $FormatVersionBlocks).replace($ReplaceLitItemName, $CleanedItemName) } |
  # Set-Content -Path "$($OutputBpBlocksFolder)\$($CleanedItemName).json"
  
  (Get-Content -Path $BlockStandardTemplateFile) |
  ForEach-Object { ($_).replace($ReplaceLitFormatVersion, $FormatVersionBlocks).replace($ReplaceLitItemName, $CleanedItemName) } |
  Set-Content -Path "$($OutputBpBlocksFolder)\$($CleanedItemName).json"
  

  # Items
  (Get-Content -Path $PlacerTemplateFile) |
  ForEach-Object { ($_).replace($ReplaceLitFormatVersion, $FormatVersionItem).replace($ReplaceLitItemName, $CleanedItemName) } |
  Set-Content -Path "$($OutputBpItemsFolder)\$($CleanedItemName).item.json"

  # Set-Content -Path "$($OutputBpItemsFolder)\$($CleanedItemName).item.json" -Value "{`n  ""format_version"": ""$($FormatVersionItem)"",`n  ""minecraft:item"": {`n    ""description"": {`n      ""identifier"": ""miniblocks:$($CleanedItemName)"",`n      ""menu_category"": {`n        ""category"": ""items""`n      }`n    },`n    ""components"": {`n      ""minecraft:max_stack_size"": 1,`n      ""minecraft:wearable"": {`n        ""slot"": ""slot.armor.head"",`n        ""protection"": 0`n      },`n      ""minecraft:block_placer"": { ""block"": ""miniblocks:$($CleanedItemName)_block"" }`n    }`n  }`n}"

  # Loot Tables
  Set-Content -Path "$($OutputBpBlocksLootTableFolder)\$($CleanedItemName).json" -Value "{`n  ""pools"": [{ ""rolls"": 1, ""entries"": [{ ""type"": ""item"", ""name"": ""miniblocks:$($CleanedItemName)_block"" }] }]`n}"

  # Recipes  
  (Get-Content -Path $RecipeAfromBTemplateFile) |
  ForEach-Object { ($_).replace($ReplaceLitFormatVersion, $FormatVersionRecipe).replace($ReplaceLitItemName, $CleanedItemName) } |
  Set-Content -Path "$($OutputBpRecipesFolder)\$($CleanedItemName)_attachable_from_block.json"

  (Get-Content -Path $RecipeBfromATemplateFile) |
  ForEach-Object { ($_).replace($ReplaceLitFormatVersion, $FormatVersionRecipe).replace($ReplaceLitItemName, $CleanedItemName) } |
  Set-Content -Path "$($OutputBpRecipesFolder)\$($CleanedItemName)_block_from_attachable.json"

  (Get-Content -Path $RecipeStonecuttingTemplateFile) |
  ForEach-Object { ($_).replace($ReplaceLitFormatVersion, $FormatVersionRecipe).replace($ReplaceLitItemName, $CleanedItemName).replace($ReplaceLitIngredient, $Ingredient) } |
  Set-Content -Path "$($OutputBpRecipesFolder)\$($CleanedItemName)_stonecutting.json"

  # $recipeString = "{`n    ""format_version"": ""1.20.10"",`n    ""minecraft:recipe_shapeless"": {`n        ""description"": {`n            ""identifier"": ""miniblocks:$($CleanedItemName)_stonecutting""`n        },`n        ""ingredients"": [`n            {`n                ""item"": ""$($Ingredient)""`n            }`n        ],`n        ""priority"": 0,`n        ""result"": {`n            ""count"": 8,`n            ""item"": ""miniblocks:$($CleanedItemName)""`n        },`n        ""tags"": [`n            ""stonecutter""`n        ]`n    }`n}"
  # Set-Content -Path "$($OutputBpRecipesFolder)\$($CleanedItemName)_miniblock_stonecutting.json" -Value $recipeString
}

## Main Script
Set-Content -Path $OutputItemLangFile -Value ""
Set-Content -Path $OutputTileLangFile -Value ""
Set-Content -Path $OutputRpTexts -Value ""
Set-Content -Path $OutputRpBlocks -Value $BlocksJsonHeader
Set-Content -Path $OutputRpTerrainTextures -Value $TerrainTexturesHeader

Get-ChildItem -Path $SourceEntitiesFolder -Filter "*.json" | 
ForEach-Object { 
  $_.FullName | Out-File -FilePath $OutputLogFile -Append
  $jsonObject = (Get-Content -Raw $_.FullName | ConvertFrom-Json );
  # Extract the ingredient name
  $ingredient = $jsonObject.ingredient
  # Decode the Base64-encoded value
  $encodedValue = $jsonObject.result.components.'minecraft:profile'.properties[0].value
  # Calculate the number of '=' characters needed
  if ($encodedValue.Length % 4) {
    $paddingLength = 4 - ($encodedValue.Length % 4)
    # Append the '=' characters to the encoded value
    $paddedValue = $encodedValue + ('=' * $paddingLength)
  }
  else {
    $paddedValue = $encodedValue
  }
  try {
    $decodedValue = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($paddedValue))    
  }
  catch {
    $paddedValue | Out-File -FilePath $OutputLogFile -Append
    break
  }
  # Extract the decoded URL
  $decodedObject = $decodedValue | ConvertFrom-Json
  $url = $decodedObject.textures.SKIN.url
  # Extract the item name
  $itemName = $jsonObject.result.components.'minecraft:item_name'

  $TrimmedItemName = $itemName.Trim('`"')
  $CleanedItemName = ($TrimmedItemName).Replace(" ", "_").Replace("(", "").Replace(")", "").ToLower()
  $ItemFileName = "$($CleanedItemName).png"
  $OutFilePath = "$($OutputRpAttachableTexturesFolder)\$($ItemFileName)" 
  Invoke-WebRequest -Uri $url -Method Get -OutFile $OutFilePath 
  BuildItemSet -ItemName $TrimmedItemName -Ingredient $ingredient

}

Add-Content -Path $OutputRpBlocks -Value "}"
Add-Content -Path $OutputRpTerrainTextures -Value "  }`n}"

Get-Content -Path $OutputItemLangFile | Set-Content -Path $OutputRpTexts
Add-Content -Path $OutputRpTexts -Value "`n"
Get-Content -Path $OutputTileLangFile | Add-Content -Path $OutputRpTexts
