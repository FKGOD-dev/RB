-- AnimationsModule.lua
-- ModuleScript en ReplicatedStorage
-- Contiene todas las IDs de animaciones del juego

local AnimationsModule = {}

-- IDs de animaciones (puedes cambiar estos por tus propias animaciones)
AnimationsModule = {
	-- Ataques básicos
	Punch = "rbxassetid://507777826",           -- Puñetazo básico
	Kick = "rbxassetid://457598621",            -- Patada
	SwordSlash = "rbxassetid://434830170",      -- Corte de espada (para estilos más elegantes)

	-- Poses y stances
	CombatIdle = "rbxassetid://507766666",      -- Pose de combate idle
	MartialStance = "rbxassetid://656118852",   -- Stance de artes marciales

	-- Habilidades especiales
	KiCharging = "rbxassetid://5700794974",     -- Cargando Ki/energía

	-- Animaciones adicionales para futuros estilos
	TigerClaw = "rbxassetid://507777826",       -- Garra de tigre
	CraneDance = "rbxassetid://656118852",      -- Danza de grulla
	DragonFist = "rbxassetid://434830170",      -- Puño de dragón

	-- Animaciones de movimiento especial
	Dash = "rbxassetid://507777826",            -- Dash rápido
	Block = "rbxassetid://507766666",           -- Bloqueo
	Dodge = "rbxassetid://457598621",           -- Esquivar

	-- Animaciones de victoria/derrota
	Victory = "rbxassetid://656118852",         -- Pose de victoria
	Defeat = "rbxassetid://507766666",          -- Animación de derrota

	-- Animaciones de técnicas avanzadas (para futuras expansiones)
	TechniquE = "rbxassetid://434830170",       -- Técnica especial E
	TechniquR = "rbxassetid://507777826",       -- Técnica especial R
	Ultimate = "rbxassetid://5700794974",       -- Técnica definitiva

	-- Animaciones de meditación y entrenamiento
	Meditation = "rbxassetid://507766666",      -- Meditación para regenerar Ki
	Training = "rbxassetid://457598621",        -- Entrenamiento básico

	-- Animaciones reactivas
	HitReaction = "rbxassetid://507777826",     -- Reacción al recibir daño
	KnockBack = "rbxassetid://457598621",       -- Ser empujado hacia atrás
	Recovery = "rbxassetid://507766666",        -- Recuperación después de ataque
}

-- Función helper para verificar si una animación existe
function AnimationsModule:GetAnimation(animationName)
	local animationId = self[animationName]
	if animationId then
		return animationId
	else
		warn("⚠️ Animación no encontrada: " .. tostring(animationName))
		return self.Punch -- Fallback a animación básica
	end
end

-- Función para obtener animaciones por estilo marcial
function AnimationsModule:GetStyleAnimations(martialStyle)
	local styleAnimations = {
		TIGER = {
			basic = {"Punch", "TigerClaw", "Kick"},
			special = {"KiCharging", "Dash"},
			stance = "CombatIdle"
		},
		CRANE = {
			basic = {"MartialStance", "CraneDance", "SwordSlash"},
			special = {"KiCharging", "Dodge"},
			stance = "MartialStance"
		},
		DRAGON = {
			basic = {"DragonFist", "SwordSlash", "Ultimate"},
			special = {"KiCharging", "TechniquE"},
			stance = "Victory"
		}
	}

	return styleAnimations[martialStyle] or styleAnimations.TIGER
end

-- Función para obtener una animación aleatoria de un estilo
function AnimationsModule:GetRandomStyleAnimation(martialStyle, category)
	local styleAnimations = self:GetStyleAnimations(martialStyle)
	local categoryAnimations = styleAnimations[category or "basic"]

	if categoryAnimations and #categoryAnimations > 0 then
		local randomIndex = math.random(1, #categoryAnimations)
		local animationName = categoryAnimations[randomIndex]
		return self:GetAnimation(animationName)
	end

	return self:GetAnimation("Punch") -- Fallback
end

return AnimationsModule