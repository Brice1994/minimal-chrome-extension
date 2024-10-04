# Check if package.json already exists
if (-Not (Test-Path "./package.json")) {
    Write-Host "Initializing npm to create package.json..."
    npm init -y
    Write-Host "package.json created successfully."
} else {
    Write-Host "package.json already exists. Skipping npm init."
}

$rootPath = (Get-Location).Path
$publicDirPath = Join-Path $rootPath "public"
$srcDirPath = Join-Path $rootPath "src"
$iconPath = Join-Path $publicDirPath "icon.png"

if (-Not (Test-Path $srcDirPath)) {
    Write-Host "Creating 'public' directory..."
    New-Item -ItemType Directory -Path $srcDirPath
}


# Ensure 'public' directory exists before creating 'icon.png'
if (-Not (Test-Path $publicDirPath)) {
    Write-Host "Creating 'public' directory..."
    New-Item -ItemType Directory -Path $publicDirPath
}
# Check if the necessary dependencies are installed
$dependencies = @("vite", "react", "react-dom", "typescript")
$missingDependencies = @()

# Get the contents of package.json
$packageJson = Get-Content "./package.json" -Raw | ConvertFrom-Json

# Check if dependencies and devDependencies exist in package.json
$installedDependencies = @()
if ($packageJson.dependencies) {
    $installedDependencies += $packageJson.dependencies.PSObject.Properties.Name
}
if ($packageJson.devDependencies) {
    $installedDependencies += $packageJson.devDependencies.PSObject.Properties.Name
}

Write-Host "Installed dependencies: $installedDependencies"

foreach ($dependency in $dependencies) {
    if (-Not ($installedDependencies -contains $dependency)) {
        $missingDependencies += $dependency
    }
}

Write-Host "Missing dependencies: $missingDependencies"

if ($missingDependencies.Count -gt 0) {
    Write-Host "Installing missing dependencies: $($missingDependencies -join ', ')..."
    npm install $missingDependencies
    Write-Host "Dependencies installed successfully."
} else {
    Write-Host "All necessary dependencies are already installed. Skipping installation."
}
# Create a basic 'manifest.json' for the Chrome extension in the 'public' folder if it doesn't exist
$manifestPath = "./public/manifest.json"
if (-Not (Test-Path $manifestPath)) {
    Write-Host "Creating manifest.json..."
    @"
{
    "manifest_version": 3,
    "name": "My Chrome Extension",
    "version": "1.0.0",
    "description": "A simple Chrome extension.",
    "action": {
        "default_popup": "index.html",
        "default_icon": "icon.png"
    },
    "permissions": []
}
"@ | Out-File -FilePath $manifestPath -Encoding ascii
    Write-Host "manifest.json created successfully."
} else {
    Write-Host "manifest.json already exists. Skipping creation."
}

# Create 'index.html' in the 'public' directory if it doesn't exist
$indexHtmlPath = "./public/index.html"
if (-Not (Test-Path $indexHtmlPath)) {
    Write-Host "Creating index.html..."
    @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Chrome Extension</title>
</head>
<body>
    <div id="root"></div>
    <script type="module" src="../src/index.tsx"></script>
</body>
</html>
"@ | Out-File -FilePath $indexHtmlPath -Encoding ascii
    Write-Host "index.html created successfully."
} else {
    Write-Host "index.html already exists. Skipping creation."
}

# Create 'index.tsx' in the 'src' directory if it doesn't exist
$indexTsxPath = "./src/index.tsx"
if (-Not (Test-Path $indexTsxPath)) {
    Write-Host "Creating index.tsx..."
    @"
import React from 'react';
import ReactDOM from 'react-dom';

const App = () => {
    return <h1>Hello, Chrome Extension!</h1>;
};

ReactDOM.render(<App />, document.getElementById('root'));
"@ | Out-File -FilePath $indexTsxPath -Encoding ascii
    Write-Host "index.tsx created successfully."
} else {
    Write-Host "index.tsx already exists. Skipping creation."
}

# Create 'vite.config.ts' in the root directory if it doesn't exist
$viteConfigPath = "./vite.config.ts"
if (-Not (Test-Path $viteConfigPath)) {
    Write-Host "Creating vite.config.ts..."
    @"
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    build: {
        outDir: 'dist',
    },
    resolve: {
        alias: {
            '@': '/src',
        },
    },
});
"@ | Out-File -FilePath $viteConfigPath -Encoding ascii
    Write-Host "vite.config.ts created successfully."
} else {
    Write-Host "vite.config.ts already exists. Skipping creation."
}

# Update 'package.json' with scripts for Vite
$packageJsonPath = "./package.json"
$packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json

# Ensure the 'scripts' section exists
if (-Not $packageJson.PSObject.Properties['scripts']) {
    Write-Host "Creating 'scripts' section in package.json..."
    $packageJson | Add-Member -MemberType NoteProperty -Name scripts -Value @{}
}

# Convert 'scripts' to a hashtable if needed
if (-Not ($packageJson.scripts -is [hashtable])) {
    $newScripts = @{}
    foreach ($script in $packageJson.scripts.PSObject.Properties) {
        $newScripts[$script.Name] = $script.Value
    }
    $packageJson.scripts = $newScripts
}

# Add missing scripts
if (-Not $packageJson.scripts['build']) {
    Write-Host "Adding build script to package.json..."
    $packageJson.scripts['build'] = "vite build"
}
if (-Not $packageJson.scripts['dev']) {
    Write-Host "Adding dev script to package.json..."
    $packageJson.scripts['dev'] = "vite"
}

# Write updated package.json back to file
$packageJson | ConvertTo-Json -Compress | Out-File -FilePath $packageJsonPath -Encoding ascii
Write-Host "package.json updated with Vite scripts."

$tsconfigPath = "./tsconfig.json"
if (-Not (Test-Path $tsconfigPath)) {
    Write-Host "Creating tsconfig.json..."
    @"
{
    "compilerOptions": {
        "target": "esnext",
        "lib": ["dom", "esnext"],
        "jsx": "react",
        "module": "esnext",
        "moduleResolution": "node",
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "baseUrl": "./src"
    },
    "include": ["src"]
}
"@ | Out-File -FilePath $tsconfigPath -Encoding ascii
    Write-Host "tsconfig.json created successfully."
} else {
    Write-Host "tsconfig.json already exists. Skipping creation."
}

# Create 'popup.html' in the 'public' directory if it doesn't exist
$popupHtmlPath = "./public/popup.html"
if (-Not (Test-Path $popupHtmlPath)) {
    Write-Host "Creating popup.html..."
    @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Popup</title>
</head>
<body>
    <div id="popup-root"></div>
    <script type="module" src="../src/popup.tsx"></script>
</body>
</html>
"@ | Out-File -FilePath $popupHtmlPath -Encoding ascii
    Write-Host "popup.html created successfully."
} else {
    Write-Host "popup.html already exists. Skipping creation."
}

# Create 'popup.tsx' in the 'src' directory if it doesn't exist
$popupTsxPath = "./src/popup.tsx"
if (-Not (Test-Path $popupTsxPath)) {
    Write-Host "Creating popup.tsx..."
    @"
import React from 'react';
import ReactDOM from 'react-dom';

const Popup = () => {
    return <h1>Hello from Popup!</h1>;
};

ReactDOM.render(<Popup />, document.getElementById('popup-root'));
"@ | Out-File -FilePath $popupTsxPath -Encoding ascii
    Write-Host "popup.tsx created successfully."
} else {
    Write-Host "popup.tsx already exists. Skipping creation."
}

$manifestPath = "./public/manifest.json"
$manifestJson = Get-Content $manifestPath -Raw | ConvertFrom-Json

# Ensure the 'action' section exists and update the default popup
if (-Not $manifestJson.action) {
    Write-Host "Adding 'action' section to manifest.json..."
    $manifestJson.action = @{
        default_popup = "popup.html"
        default_icon  = "icon.png"
    }
} else {
    Write-Host "Updating 'action' section in manifest.json..."
    $manifestJson.action.default_popup = "popup.html"
}

# Write updated manifest.json back to file
$manifestJson | ConvertTo-Json -Compress | Out-File -FilePath $manifestPath -Encoding ascii
Write-Host "manifest.json updated with popup information."

# Check if @vitejs/plugin-react is installed; if not, install it
if (-Not (npm list @vitejs/plugin-react --depth=0 2>&1 | Select-String "@vitejs/plugin-react")) {
    Write-Host "Installing Vite React plugin..."
    npm install @vitejs/plugin-react
    Write-Host "Vite React plugin installed successfully."
} else {
    Write-Host "Vite React plugin is already installed. Skipping installation."
}

# Update 'vite.config.ts' to specify the correct root
$viteConfigPath = "./vite.config.ts"
$viteConfigContent = Get-Content $viteConfigPath -Raw

# Update the root property in the Vite configuration
if (-Not ($viteConfigContent -match "root:")) {
    Write-Host "Updating Vite configuration to set the correct root..."
    $viteConfigContent = $viteConfigContent -replace "(export default defineConfig\({)", "`$1`n    root: './public',"
    $viteConfigContent | Out-File -FilePath $viteConfigPath -Encoding ascii
    Write-Host "vite.config.ts updated with correct root."
} else {
    Write-Host "Vite configuration already specifies the root. Skipping update."
}


# Correct the path to 'public' directory within 'ChromeExtension'

# Create a simple placeholder 'icon.png' in the 'public' directory if it doesn't exist
if (-Not (Test-Path $iconPath)) {
    Write-Host "Creating placeholder icon.png..."
    $bytes = [System.Convert]::FromBase64String(
        "iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsSAAALEgHS3X78AAAA" +
        "B3RJTUUH5QgSBjkmHgZjRQAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAIJS" +
        "URBVHja7JhPK0xRHIe/ZTbGEBPT2EAEEQHEQlEQtoC9RIu7RJcKGiAdUKiyk8lJcFS+wst8XEVQIp" +
        "tRBtk1YQIQETuB/GgiOhDR9tSftze7M5iJ6Yyky3M++beZ7zT3O3PmnKIpEIhEIhEIhEIhEIhEIhE" +
        "IhEIhEIhEIhEIjEL38By/2F6DwC99m+80B2ofAn1/wPcKe+B5UwIAfUHgBWv4IFh+pDaAn7AM3Cug" +
        "QBysd9wAjV4SB2F6oTXgcwvgAGF+oDWgu8MA1t8PB7mA7AO17Q7UCem7GOAY0HtCVtsDsAajbODFg" +
        "X/gMLRB7wECi7YCDc6QBvFBp2HoA+gHVp6G2JQlcXNAZ4Agul3drOGwPoB36jfUeFbCUHrXjUFwuk" +
        "BXYBUmn4DmlaxPUw+zUg6pkF9gaP0oU2gugzfghVS32tmkV0QYET3T7zoXSDipWnc+AfJ6U2gs8Gr" +
        "VOmTNUHGFG6TwNfN6FJo/qxb0mGOs9B03rETMtv4HWyg4zpRB3OT4nU4EcRt+l3VvhXAbdfBNd9TY" +
        "ODeFgPbOA2pLg9cwAPyYBPymwHTGATUpYH+CQD3iQB5XYER+LgYDb4HQMwDFIDdR6OsAI6D25jBfx" +
        "QD8pAbcjE4DDwxLY0gPzWBdswtAxh/Ab8vUMaUsZ4Fm+GGcIVBv4NvL0LWEHQTmjAQtewLxlN1naE" +
        "IzlGxQZqxBPcMo1IH+3BQblQO2jwUrwzgu6Q3Qgr8NrsMQiEWi4A5QJ/FfTi4V4I0V0Q8KL2gqwFO" +
        "FkgAAAABJRU5ErkJggg=="
    )
    [System.IO.File]::WriteAllBytes($iconPath, $bytes)
    Write-Host "icon.png created successfully."
} else {
    Write-Host "icon.png already exists. Skipping creation."
}
