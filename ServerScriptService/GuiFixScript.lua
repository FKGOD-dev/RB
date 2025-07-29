-- GUIFixScript.lua
-- Script temporal en ServerScriptService para arreglar la GUI
-- EJECUTAR UNA VEZ PARA DIAGNOSTICAR, LUEGO ELIMINAR

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local Players = game:GetService("Players")

print("🔧 INICIANDO DIAGNÓSTICO DE GUI...")
print("================================")

-- Verificar estructura de carpetas
local starterPlayerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
if not starterPlayerScripts then
	starterPlayerScripts = Instance.new("Folder")
	starterPlayerScripts.Name = "StarterPlayerScripts"
	starterPlayerScripts.Parent = StarterPlayer
	print("➕ Creada carpeta StarterPlayerScripts")
else
	print("✅ StarterPlayerScripts encontrada")
end

-- Verificar si existe el script de GUI
local guiScript = starterPlayerScripts:FindFirstChild("EnhancedGUISystem")
if guiScript then
	print("✅ EnhancedGUISystem encontrado en StarterPlayerScripts")
else
	-- Buscar en otros lugares
	local starterCharacterScripts = StarterPlayer:FindFirstChild("StarterCharacterScripts")
	if starterCharacterScripts then
		local misplacedGUI = starterCharacterScripts:FindFirstChild("EnhancedGUISystem")
		if misplacedGUI then
			print("⚠️ EnhancedGUISystem encontrado en StarterCharacterScripts (ubicación incorrecta)")
			print("🔧 Necesitas moverlo a StarterPlayerScripts")
		end
	end

	if not guiScript then
		print("❌ EnhancedGUISystem NO encontrado - necesitas agregarlo")
	end
end

-- Verificar RemoteEvents necesarios
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
	print("➕ Creada carpeta Remotes")
end

local requiredRemotes = {"BasicAttack", "KiBlast", "Meditation"}
local createdRemotes = 0

for _, remoteName in pairs(requiredRemotes) do
	if not remotes:FindFirstChild(remoteName) then
		local remote = Instance.new("RemoteEvent")
		remote.Name = remoteName
		remote.Parent = remotes
		print("➕ Creado RemoteEvent:", remoteName)
		createdRemotes = createdRemotes + 1
	else
		print("✅ RemoteEvent existe:", remoteName)
	end
end

-- Verificar jugadores conectados y sus stats
print("\n👥 VERIFICANDO JUGADORES:")
for _, player in pairs(Players:GetPlayers()) do
	print("👤 Jugador:", player.Name)

	if player.Character then
		local stats = player.Character:FindFirstChild("PlayerStats")
		if stats then
			print("  ✅ PlayerStats encontrado")

			-- Verificar stats clave para la GUI
			local statsToCheck = {"Ki", "MaxKi", "Level", "XP", "MartialStyle"}
			for _, statName in pairs(statsToCheck) do
				local stat = stats:FindFirstChild(statName)
				if stat then
					print("    ✅", statName .. ":", stat.Value)
				else
					print("    ❌", statName, "FALTANTE")
				end
			end
		else
			print("  ❌ PlayerStats NO encontrado")
		end

		-- Verificar GUI del jugador
		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui then
			local martialGui = playerGui:FindFirstChild("MartialArtsGUI")
			if martialGui then
				print("  ✅ GUI cargada correctamente")
			else
				print("  ❌ GUI NO cargada")
			end
		end
	else
		print("  ⚠️ Sin personaje spawneado")
	end
end

print("\n🎯 INSTRUCCIONES:")
print("1. Mueve EnhancedGUISystem.lua de StarterCharacterScripts a StarterPlayerScripts")
print("2. Asegúrate de que sea un LocalScript")
print("3. Reinicia el servidor de test")
print("4. La GUI debería aparecer automáticamente")

print("\n📋 UBICACIÓN CORRECTA:")
print("StarterPlayer/")
print("└── StarterPlayerScripts/")
print("    └── EnhancedGUISystem (LocalScript)")

-- Auto-destruir después de 10 segundos
spawn(function()
	wait(10)
	print("🗑️ Auto-eliminando script de diagnóstico...")
	script:Destroy()
end)