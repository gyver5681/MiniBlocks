Add-Type -AssemblyName System.Drawing

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
$OutputRPFolder = "$($OutputProjectRoot)\resource_packs\mini-blocks"

# Output Behavior Pack Folders
$OutputBpBlocksFolder = "$($OutputBPFolder)\blocks"
$OutputBpItemsFolder = "$($OutputBPFolder)\items"
$OutputBpBlocksLootTableFolder = "$($OutputBPFolder)\loot_tables\blocks"
$OutputBpRecipesFolder = "$($OutputBPFolder)\recipes"

# Output Resource Pack Folders
$OutputRpBaseTexturesFolder = "$($OutputRPFolder)\textures\base"
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

$BlockIdDisparity = @{
  'minecraft:bricks'                  = 'minecraft:brick_block'
  'minecraft:end_stone_bricks'        = 'minecraft:end_bricks'
  'minecraft:flowering_azalea_leaves' = 'minecraft:flowering_azalea'
  'minecraft:magma_block'             = 'minecraft:magma'
  'minecraft:nether_bricks'           = 'minecraft:nether_brick'
  'minecraft:nether_quartz_ore'       = 'minecraft:quartz_ore'
  'minecraft:red_nether_bricks'       = 'minecraft:red_nether_brick'
  'minecraft:slime_block'             = 'minecraft:slime'
  'minecraft:snow_block'              = 'minecraft:snow'
  'minecraft:terracotta'              = 'minecraft:hardened_clay'
}

function CleanTexture {
  param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = $InputPath
  )

  try {
    $image = [System.Drawing.Image]::FromFile($InputPath)

    # Create a new bitmap with the desired dimensions.
    $croppedImage = New-Object System.Drawing.Bitmap 32, 16

    # Create a graphics object to draw the cropped portion onto the new bitmap.
    $graphics = [System.Drawing.Graphics]::FromImage($croppedImage)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceCopy

    # Draw the cropped portion of the original image onto the new bitmap.
    $graphics.DrawImage($image, 8, 0, (new-object System.Drawing.Rectangle(8, 0, 16, 8)), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.DrawImage($image, 0, 8, (new-object System.Drawing.Rectangle(0, 8, 32, 8)), [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    $image.Dispose()

    # Save the cropped image to the specified output path.
    $croppedImage.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Clean up resources
    $croppedImage.Dispose()

    # Write-Host "Image successfully cropped and saved to $($OutputPath)"
  }
  catch {
    Write-Error "Error cropping image: $($_.Exception.Message)"
  }
}

function BuildItemSet {
  param(
    $ItemName,
    $Ingredient
  )
  $BedrockIngredient = ""
  $CleanedItemName = ($ItemName).Replace(" ", "_").Replace("(", "").Replace(")", "").ToLower()
  if ($BlockIdDisparity.ContainsKey($Ingredient)) {
    $BedrockIngredient = $BlockIdDisparity[$Ingredient]
  }
  else {
    $BedrockIngredient = $Ingredient
  }
  
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
  ForEach-Object { ($_).replace($ReplaceLitFormatVersion, $FormatVersionRecipe).replace($ReplaceLitItemName, $CleanedItemName).replace($ReplaceLitIngredient, $BedrockIngredient) } |
  Set-Content -Path "$($OutputBpRecipesFolder)\$($CleanedItemName)_stonecutting.json"

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
  $OutFilePath = "$($OutputRpBaseTexturesFolder)\$($ItemFileName)" 
  Invoke-WebRequest -Uri $url -Method Get -OutFile $OutFilePath 
  CleanTexture -InputPath $OutFilePath -OutputPath "$($OutputRpAttachableTexturesFolder)\$($ItemFileName)" 
  BuildItemSet -ItemName $TrimmedItemName -Ingredient $ingredient

}

Add-Content -Path $OutputRpBlocks -Value "}"
Add-Content -Path $OutputRpTerrainTextures -Value "  }`n}"

Get-Content -Path $OutputItemLangFile | Set-Content -Path $OutputRpTexts
Add-Content -Path $OutputRpTexts -Value "`n"
Get-Content -Path $OutputTileLangFile | Add-Content -Path $OutputRpTexts
