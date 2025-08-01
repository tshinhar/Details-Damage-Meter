
local Details = _G.Details
local Loc = LibStub("AceLocale-3.0"):GetLocale("Details")
local SharedMedia = LibStub:GetLibrary("LibSharedMedia-3.0")
local segmentos = Details.segmentos


---@type detailsframework
local gump = Details.gump
local DF = gump
local _

---@type detailsframework
local detailsFramework = DetailsFramework

--lua locals
local ceil = math.ceil
local floor = math.floor
local ipairs = ipairs
local pairs = pairs
local abs = _G.abs
local unpack = unpack
--api locals
local CreateFrame = CreateFrame
local GetTime = GetTime
local _GetCursorPosition = GetCursorPosition
local UIParent = UIParent
local _IsAltKeyDown = IsAltKeyDown
local _IsShiftKeyDown = IsShiftKeyDown
local _IsControlKeyDown = IsControlKeyDown
local modo_raid = Details._detalhes_props["MODO_RAID"]
local modo_alone = Details._detalhes_props["MODO_ALONE"]
local IsInInstance = _G.IsInInstance

local tokFunctions = Details.ToKFunctions

local _, Details222 = ...
_ = nil

--constants
local baseframe_strata = "LOW"
local defaultBackdropSt = {
	bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 12,
	insets = {left = 0, right = 0, top = 0, bottom = 0}}

local CONST_ROWFRAME_ALPHA = 0.975036
local parseRowFrameAlpha = function(value)
	return math.min(value, CONST_ROWFRAME_ALPHA)
end

function Details:ScheduleUpdate(instancia)
	instancia.barraS = {nil, nil}
	instancia.update = true
	if (instancia.showing) then
		instancia.atributo = instancia.atributo or 1
		if (not instancia.showing[instancia.atributo]) then
			instancia.showing = Details.tabela_vigente
		end
		instancia.showing[instancia.atributo].need_refresh = true
	end
end

local GetSpellLink = GetSpellLink or C_Spell.GetSpellLink --api local
local GetSpellInfo = Details222.GetSpellInfo --api local
local _GetSpellInfo = Details.getspellinfo --details api

--skins TCoords
	local DEFAULT_SKIN = [[Interface\AddOns\Details\images\skins\classic_skin]]
	local COORDS_LEFT_BALL = {0.15625, 0.2802734375, 0.08203125, 0.2060546875} -- 160 287 84 211
	local COORDS_LEFT_CONNECTOR = {0.294921875, 0.3017578125, 0.08203125, 0.2060546875} --302 84 309 211 (updated)
	local COORDS_LEFT_CONNECTOR_NO_ICON = {0.587890625+0.00048828125, 0.5947265625, 0.08203125, 0.2060546875} -- 602 609 x 84 211
	local COORDS_TOP_BACKGROUND = {0.15625, 0.6552734375, 0.22265625, 0.3466796875} -- 160 671 x 228 355
	local COORDS_RIGHT_BALL = {0.3154296875, 0.439453125, 0.08203125, 0.2060546875} -- 323 450 x 84 211
	local COORDS_LEFT_BALL_NO_ICON = {0.44921875, 0.5732421875, 0.08203125, 0.2060546875} -- 460 587 84 211
	local COORDS_LEFT_SIDE_BAR = {0.765625, 0.828125, 0.001953125, 0.501953125} -- 784 2 848 514 (updated)
	local COORDS_RIGHT_SIDE_BAR = {0.7001953125, 0.7626953125, 0.001953125, 0.501953125} -- --717 2 781 513
	local COORDS_BOTTOM_SIDE_BAR = {0.32861328125, 0.82666015625, 0.50537109375, 0.56494140625} -- 336 517 847 579 (updated)
	local COORDS_SLIDER_TOP = {0.00146484375, 0.03076171875, 0.00244140625, 0.03173828125} -- 1 2 32 33 -ok
	local COORDS_SLIDER_MIDDLE = {0.00146484375, 0.03076171875, 0.03955078125, 0.10009765625} -- 1 40 32 103 -ok
	local COORDS_SLIDER_DOWN = {0.00146484375, 0.03076171875, 0.10986328125, 0.13916015625} -- 1 112 32 143 -ok
	local COORDS_STRETCH = {0.0009765625, 0.03125, 0.2138671875, 0.228515625} -- 1 32 219 234
	local COORDS_RESIZE_RIGHT = {0.00146484375, 0.01513671875, 0.24560546875, 0.25927734375} -- 1 251 16 266 -ok
	local COORDS_RESIZE_LEFT = {0.02001953125, 0.03173828125, 0.24560546875, 0.25927734375} -- 20 251 33 266 -ok
	local COORDS_UNLOCK_BUTTON = {0.00146484375, 0.01513671875, 0.27197265625, 0.28564453125} -- 1 278 16 293 -ok
	local COORDS_BOTTOM_BACKGROUND = {0.15673828125, 0.65478515625, 0.35400390625, 0.47705078125} -- 160 362 671 489 -ok
	local COORDS_PIN_LEFT = {0.00146484375, 0.03076171875, 0.30126953125, 0.33056640625} -- 1 308 32 339 -ok
	local COORDS_PIN_RIGHT = {0.03564453125, 0.06494140625, 0.30126953125, 0.33056640625} -- 36 308 67 339 -ok

	local menus_backdrop = {
		edgeFile = [[Interface\Buttons\WHITE8X8]],
		edgeSize=1,
		bgFile = [[Interface\AddOns\Details\images\background]],
		tileSize=16,
		tile=true,
		insets = {top=0, right=0, left=0, bottom=0}
	}

	local menus_backdropcolor = {.2, .2, .2, 0.85}
	local menus_backdropcolor_sec = {.2, .2, .2, 0.90}
	local menus_bordercolor = {0, 0, 0, .25}

	local authorInfo = detailsFramework.AuthorInfo

	--menus are ignoring the value set on the profile
	Details.menu_backdrop_config = {
		menus_backdrop = menus_backdrop,
		menus_backdropcolor = menus_backdropcolor,
		menus_backdropcolor_sec = menus_backdropcolor_sec,
		menus_bordercolor = menus_bordercolor,
	}

function Details:RefreshScrollBar(x) --x = amount of bars being refreshed
	local amountRowsInTheWindow = self.rows_fit_in_window

	if (not self.barraS[1]) then --primeira vez que as barras est�o aparecendo
		self.barraS[1] = 1 --primeira barra
		if (amountRowsInTheWindow < x) then --se a quantidade a ser mostrada for maior que o que pode ser mostrado
			self.barraS[2] = amountRowsInTheWindow -- B = o que pode ser mostrado
		else
			self.barraS[2] = x -- contr�rio B = o que esta sendo mostrado
		end
	end

	if (not self.rolagem) then
		if (x > amountRowsInTheWindow) then --show scroll bar
			self.rows_showing = x

			if (not self.baseframe.isStretching) then
				self:MostrarScrollBar()
			end
			self.need_rolagem = true

			self.barraS[2] = amountRowsInTheWindow --B � o total que cabe na barra
		else --Do contr�rio B � o total de barras
			self.rows_showing = x
			self.barraS[2] = x
		end
	else
		if (x > self.rows_showing) then --tem mais barras mostrando agora do que na �ltima atualiza��o
			self.rows_showing = x
			local nao_mostradas = self.rows_showing - self.rows_fit_in_window
			local slider_height = nao_mostradas * self.row_height
			self.scroll.scrollMax = slider_height
			self.scroll:SetMinMaxValues(0, slider_height)

		else	--diminuiu a quantidade, acontece depois de uma coleta de lixo
			self.rows_showing = x
			local nao_mostradas = self.rows_showing - self.rows_fit_in_window

			if (nao_mostradas < 1) then  --se estiver mostrando menos do que realmente cabe n�o precisa scrollbar
				self:EsconderScrollBar()
			else
				--contr�rio, basta atualizar o tamanho da scroll
				local slider_height = nao_mostradas * self.row_height
				self.scroll.scrollMax = slider_height
				self.scroll:SetMinMaxValues(0, slider_height)
			end
		end
	end

	if (self.update) then
		self.update = false
		self.v_barras = true
		return Details:HideBarsNotInUse(self)
	end
end

--self é a janela das barras
--this function was used in the past when the scroll bar was still a thing
local function move_barras(self, elapsed)
	self._move_func.time = self._move_func.time+elapsed
	if (self._move_func.time > 0.01) then

		if (self._move_func.instancia.bgdisplay_loc == self._move_func._end) then --se o tamanho atual � igual ao final declarado
			self:SetScript("OnUpdate", nil)
			self._move_func = nil

		else
			self._move_func.time = 0
			self._move_func.instancia.bgdisplay_loc = self._move_func.instancia.bgdisplay_loc + self._move_func.inc --inc � -1 ou 1 e ir� crescer ou diminuir a janela

			for index = 1, self._move_func.instancia.rows_fit_in_window do
				self._move_func.instancia.barras[index]:SetWidth(self:GetWidth()+self._move_func.instancia.bgdisplay_loc-3)
			end

			self._move_func.instancia.bgdisplay:SetPoint("bottomright", self, "bottomright", self._move_func.instancia.bgdisplay_loc, 0)
			self._move_func.instancia.bar_mod = self._move_func.instancia.bgdisplay_loc+(-3)

			--verifica o tamanho do text
			for i  = 1, #self._move_func.instancia.barras do
				local esta_barra = self._move_func.instancia.barras[i]
				Details:name_space(esta_barra)
			end
		end
	end
end

--self � a inst�ncia
--another function for the scroll bar, it is deprecated now
function Details:MoveBarrasTo(destino)
	local janela = self.baseframe

	janela._move_func = {
		window = self.baseframe,
		instancia = self,
		time = 0
	}

	if (destino > self.bgdisplay_loc) then
		janela._move_func.inc = 1
	else
		janela._move_func.inc = -1
	end
	janela._move_func._end = destino
	janela:SetScript("OnUpdate", move_barras)
end

--almost deprecated
--scrollbar isn't in use for years
function Details:MostrarScrollBar(sem_animacao)
	if (self.rolagem) then
		return
	end

	if (not Details.use_scroll) then
		self.baseframe:EnableMouseWheel(true)
		self.scroll:Enable()
		self.scroll:SetValue(0)
		self.rolagem = true
		return
	end

	local main = self.baseframe
	local mover_para = self.largura_scroll*-1

	if (not sem_animacao and Details.animate_scroll) then
		self:MoveBarrasTo(mover_para)
	else
		--set size of rows
		for index = 1, self.rows_fit_in_window do
			self.barras[index]:SetWidth(self.baseframe:GetWidth()+mover_para -3) ---3 distance between row end and scroll start
		end
		--move the semi-background to the left (which moves the scroll)
		self.bgdisplay:SetPoint("bottomright", self.baseframe, "bottomright", mover_para, 0)

		self.bar_mod = mover_para + (-3)
		self.bgdisplay_loc = mover_para

		--cancel movement if any
		if (self.baseframe:GetScript("OnUpdate") and self.baseframe:GetScript("OnUpdate") == move_barras) then
			self.baseframe:SetScript("OnUpdate", nil)
		end
	end

	local nao_mostradas = self.rows_showing - self.rows_fit_in_window
	local slider_height = nao_mostradas*self.row_height
	self.scroll.scrollMax = slider_height
	self.scroll:SetMinMaxValues(0, slider_height)

	self.rolagem = true
	self.scroll:Enable()
	main:EnableMouseWheel(true)

	self.scroll:SetValue(0) --set value pode chamar o atualizador
	self.baseframe.button_down:Enable()
	main.resize_direita:SetPoint("bottomright", main, "bottomright", self.largura_scroll*-1, 0)

	if (main.isLocked) then
		main.lock_button:SetPoint("bottomright", main, "bottomright", self.largura_scroll*-1, 0)
	end
end

--almost deprecated
function Details:EsconderScrollBar(sem_animacao, force)
	if (not self.rolagem) then
		return
	end

	if (not Details.use_scroll and not force) then
		self.scroll:Disable()
		self.baseframe:EnableMouseWheel(false)
		self.rolagem = false
		return
	end

	local main = self.baseframe

	if (not sem_animacao and Details.animate_scroll) then
		self:MoveBarrasTo(self.row_info.space.right + 3) -->
	else
		for index = 1, self.rows_fit_in_window do
			self.barras[index]:SetWidth(self.baseframe:GetWidth() - 5) ---5 space between row end and window right border
		end
		self.bgdisplay:SetPoint("bottomright", self.baseframe, "bottomright", 0, 0) -- voltar o background na poci��o inicial
		self.bar_mod = 0 -- zera o bar mod, uma vez que as barras v�o estar na pocis�o inicial
		self.bgdisplay_loc = -2
		if (self.baseframe:GetScript("OnUpdate") and self.baseframe:GetScript("OnUpdate") == move_barras) then
			self.baseframe:SetScript("OnUpdate", nil)
		end
	end

	self.rolagem = false
	self.scroll:Disable()
	main:EnableMouseWheel(false)

	main.resize_direita:SetPoint("bottomright", main, "bottomright", 0, 0)
	if (main.isLocked) then
		main.lock_button:SetPoint("bottomright", main, "bottomright", 0, 0)
	end
end

--when the mouse leaves a instance window
local function OnLeaveMainWindow(instancia, self)
	instancia.is_interacting = false
	instancia:SetMenuAlpha(nil, nil, nil, nil, true)
	instancia:SetAutoHideMenu(nil, nil, true)
	instancia:RefreshAttributeTextSize()

	--alone mode has been deprecated for 9 years
	if (instancia.modo ~= Details._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked) then
		--resizes, lock and ungroup buttons
		if (not Details.disable_lock_ungroup_buttons) then
			instancia.baseframe.resize_direita:SetAlpha(0)
			instancia.baseframe.resize_esquerda:SetAlpha(0)
			instancia.baseframe.lock_button:SetAlpha(0)
			instancia.break_snap_button:SetAlpha(0)
		end

		--stretch button
		Details.FadeHandler.Fader(instancia.baseframe.button_stretch, "ALPHA", 0)

	--alone mode has been deprecated for 9 years
	elseif (instancia.modo ~= Details._detalhes_props["MODO_ALONE"] and instancia.baseframe.isLocked) then
		--resizes, lock and ungroup buttons
		if (not Details.disable_lock_ungroup_buttons) then
			instancia.baseframe.lock_button:SetAlpha(0)
			instancia.break_snap_button:SetAlpha(0)
		end

		Details.FadeHandler.Fader(instancia.baseframe.button_stretch, "ALPHA", 0)
	end
end

Details.OnLeaveMainWindow = OnLeaveMainWindow

--when the mouse cursor enters a instance window
local function OnEnterMainWindow(instancia, self)
	instancia.is_interacting = true
	instancia:SetMenuAlpha(nil, nil, nil, nil, true)
	instancia:SetAutoHideMenu(nil, nil, true)
	instancia:RefreshAttributeTextSize()

	if (not instancia.last_interaction or instancia.last_interaction < Details._tempo) then
		instancia.last_interaction = Details._tempo or time()
	end

	if (instancia.baseframe:GetFrameLevel() > instancia.rowframe:GetFrameLevel()) then
		instancia.rowframe:SetFrameLevel(instancia.baseframe:GetFrameLevel())
	end

	if (instancia.modo ~= Details._detalhes_props["MODO_ALONE"] and not instancia.baseframe.isLocked) then
		--resize, lock and ungroup buttons
		if (not Details.disable_lock_ungroup_buttons) then
			instancia.baseframe.resize_direita:SetAlpha(1)
			instancia.baseframe.resize_esquerda:SetAlpha(1)
			instancia.baseframe.lock_button:SetAlpha(1)

			--ungroup
			for _, instancia_id in pairs(instancia.snap) do
				if (instancia_id) then
					instancia.break_snap_button:SetAlpha(1)
					break
				end
			end
		end

		--stretch button
		if (not Details.disable_stretch_button) then
			Details.FadeHandler.Fader(instancia.baseframe.button_stretch, "ALPHA", 0.4)
		end

	elseif (instancia.modo ~= Details._detalhes_props["MODO_ALONE"] and instancia.baseframe.isLocked) then
		if (not Details.disable_lock_ungroup_buttons) then
			instancia.baseframe.lock_button:SetAlpha(1)

			--ungroup
			for _, instancia_id in pairs(instancia.snap) do
				if (instancia_id) then
					instancia.break_snap_button:Show()
					instancia.break_snap_button:SetAlpha(1)
					break
				end
			end
		end

		if (not Details.disable_stretch_button) then
			Details.FadeHandler.Fader(instancia.baseframe.button_stretch, "ALPHA", 0.4)
		end
	end
end

Details.OnEnterMainWindow = OnEnterMainWindow

--functions to calculate the snapping feature

local function VPL(instance, esta_instancia)
	--conferir esquerda
	if (instance.ponto4.x-0.5 < esta_instancia.ponto1.x) then --a janela esta a esquerda
		if (instance.ponto4.x+20 > esta_instancia.ponto1.x) then --a janela esta a menos de 20 pixels de dist�ncia
			if (instance.ponto4.y < esta_instancia.ponto1.y + 100 and instance.ponto4.y > esta_instancia.ponto1.y - 100) then --a janela esta a +20 ou -20 pixels de dist�ncia na vertical
				return 1
			end
		end
	end
	return nil
end

local function VPB(instance, esta_instancia)
	--conferir baixo
	if (instance.ponto1.y+(20 * instance.window_scale) < esta_instancia.ponto2.y - (16 * esta_instancia.window_scale)) then --a janela esta em baixo
		if (instance.ponto1.x > esta_instancia.ponto2.x-100 and instance.ponto1.x < esta_instancia.ponto2.x+100) then --a janela esta a 20 pixels de dist�ncia para a esquerda ou para a direita
			if (instance.ponto1.y+(20 * instance.window_scale) > esta_instancia.ponto2.y - (36 * esta_instancia.window_scale)) then --esta a 20 pixels de dist�ncia
				return 2
			end
		end
	end
	return nil
end

local function VPR(instance, esta_instancia)
	--conferir lateral direita
	if (instance.ponto2.x+0.5 > esta_instancia.ponto3.x) then --a janela esta a direita
		if (instance.ponto2.x-20 < esta_instancia.ponto3.x) then --a janela esta a menos de 20 pixels de dist�ncia
			if (instance.ponto2.y < esta_instancia.ponto3.y + 100 and instance.ponto2.y > esta_instancia.ponto3.y - 100) then --a janela esta a +20 ou -20 pixels de dist�ncia na vertical
				return 3
			end
		end
	end
	return nil
end

local function VPT(instance, esta_instancia)
	--conferir cima
	if (instance.ponto3.y - (16 * instance.window_scale) > esta_instancia.ponto4.y + (20 * esta_instancia.window_scale)) then --a janela esta em cima
		if (instance.ponto3.x > esta_instancia.ponto4.x-100 and instance.ponto3.x < esta_instancia.ponto4.x+100) then --a janela esta a 20 pixels de dist�ncia para a esquerda ou para a direita
			if (esta_instancia.ponto4.y+(40 * esta_instancia.window_scale) > instance.ponto3.y - (16 * instance.window_scale)) then
				return 4
			end
		end
	end
	return nil
end

Details.VPT = VPT
Details.VPR = VPR
Details.VPB = VPB
Details.VPL = VPL

local colorRedTable = {1, 0.2, 0.2}
local colorGreenTable = {0.2, 1, 0.2}
local pixelsPerArrow = 50
local commentador = C_Commentator or {FollowUnit = function()end, FollowPlayer = function()end}

local tempo_movendo
local precisa_ativar
local instancia_alvo
local tempo_fades
local nao_anexados
local flash_bounce
local start_draw_lines
local instance_ids_shown
local need_show_group_guide

local show_instance_ids = function()
	for id, instance in Details:ListInstances() do
		if (instance:IsEnabled()) then
			local id_texture1 = instance.baseframe.id_texture1
			if (not id_texture1) then
				--instancia.
				instance.baseframe.id_texture1 = instance.floatingframe:CreateTexture(nil, "overlay")
				instance.baseframe.id_texture2 = instance.floatingframe:CreateTexture(nil, "overlay")
				instance.baseframe.id_texture1:SetTexture([[Interface\Timer\BigTimerNumbers]])
				instance.baseframe.id_texture2:SetTexture([[Interface\Timer\BigTimerNumbers]])
			end

			local h = instance.baseframe:GetHeight() * 0.80
			instance.baseframe.id_texture1:SetSize(h, h)
			instance.baseframe.id_texture2:SetSize(h, h)

			local id = instance:GetId()

			local first, second = floor(id/10), floor(id%10)

			if (id >= 10) then
				instance.baseframe.id_texture1:SetPoint("center", instance.baseframe, "center", -h/2/2, 0)
				instance.baseframe.id_texture2:SetPoint("left", instance.baseframe.id_texture1, "right", -h/2, 0)

				first = first + 1
				local line = ceil(first / 4)
				local x = ( first - ( (line-1) * 4 ) )  / 4
				local l, r, t, b = x-0.25, x, 0.33 * (line-1), 0.33 * line
				instance.baseframe.id_texture1:SetTexCoord(l, r, t, b)

				second = second + 1
				local line = ceil(second / 4)
				local x = ( second - ( (line-1) * 4 ) )  / 4
				local l, r, t, b = x-0.25, x, 0.33 * (line-1), 0.33 * line
				instance.baseframe.id_texture2:SetTexCoord(l, r, t, b)

				instance.baseframe.id_texture1:Show()
				instance.baseframe.id_texture2:Show()
			else
				instance.baseframe.id_texture1:SetPoint("center", instance.baseframe, "center")

				second = second + 1
				local line = ceil(second / 4)
				local x = ( second - ( (line-1) * 4 ) )  / 4
				local l, r, t, b = x-0.25, x, 0.33 * (line-1), 0.33 * line
				instance.baseframe.id_texture1:SetTexCoord(l, r, t, b)

				instance.baseframe.id_texture1:Show()
				instance.baseframe.id_texture2:Hide()
			end
		end
	end
end

local update_line = function(self, target_frame)
	local target_instance_PosX, target_instance_PosY = target_frame.instance:GetPositionOnScreen()
	local moving_instance_PosX, moving_instance_PosY = self.instance:GetPositionOnScreen()

	target_instance_PosX = target_instance_PosX or 0
	target_instance_PosY = target_instance_PosY or 0
	moving_instance_PosX = moving_instance_PosX or 0
	moving_instance_PosY = moving_instance_PosY or 0

	local dX = target_instance_PosX - moving_instance_PosX
	local dY = target_instance_PosY - moving_instance_PosY
	local distance = (dX^2 + dY^2) ^ 0.5
	local angle = atan2(dY, dX)

	local guide_balls = Details.guide_balls
	if (not guide_balls) then
		Details.guide_balls = {}
		guide_balls = Details.guide_balls
	end

	for index, ball in ipairs(guide_balls) do
		ball:Hide()
	end

	self.instance:AtualizaPontos()
	target_frame.instance:AtualizaPontos()

	local color = colorRedTable
	local _R, _T, _L, _B = VPL (self.instance, target_frame.instance), VPB (self.instance, target_frame.instance), VPR (self.instance, target_frame.instance), VPT (self.instance, target_frame.instance)
	if (_R or _T or _L or _B) then
		color = colorGreenTable
	end

	for i = 0, (distance/pixelsPerArrow) do
		local x = distance - (i * pixelsPerArrow)
		x = x * cos(angle)
		local y = distance - (i * pixelsPerArrow)
		y = y * sin(angle)

		local ball = guide_balls [i]
		if (not ball) then
			ball = Details.overlay_frame:CreateTexture(nil, "Overlay")
			ball:SetTexture([[Interface\AddOns\Details\images\icons]])
			ball:SetSize(16, 16)
			ball:SetAlpha(0.3)
			ball:SetTexCoord(410/512, 426/512, 2/512, 18/512)
			table.insert(guide_balls, ball)
		end

		ball:ClearAllPoints()
		ball:SetPoint("CENTER", self, "CENTER", x, y) --baseframse center
		ball:Show()
		ball:SetVertexColor(unpack(color))
	end

end

local movement_onupdate = function(self, elapsed)
		if (start_draw_lines and start_draw_lines > 0.95) then
			update_line (self, instancia_alvo.baseframe)
		elseif (start_draw_lines) then
			start_draw_lines = start_draw_lines + elapsed
		end

		if (instance_ids_shown and instance_ids_shown > 0.95) then
			show_instance_ids()
			instance_ids_shown = nil

			if (need_show_group_guide and not DetailsFramework.IsTimewalkWoW()) then
				Details.MicroButtonAlert.Text:SetText(Loc["STRING_WINDOW1ATACH_DESC"])
				Details.MicroButtonAlert:SetPoint("bottom", need_show_group_guide.baseframe, "top", 0, 30)
				Details.MicroButtonAlert:SetHeight(320)
				Details.MicroButtonAlert:Show()

				need_show_group_guide = nil
			end
		elseif (instance_ids_shown) then
			instance_ids_shown = instance_ids_shown + elapsed
		end

		if (tempo_movendo and tempo_movendo < 0) then

			if (precisa_ativar) then --se a inst�ncia estiver fechada
				Details.FadeHandler.Fader(instancia_alvo.baseframe, "ALPHA", 0.15)
				Details.FadeHandler.Fader(instancia_alvo.baseframe.cabecalho.ball, "ALPHA", 0.15)
				Details.FadeHandler.Fader(instancia_alvo.baseframe.cabecalho.atributo_icon, "ALPHA", 0.15)
				instancia_alvo:SaveMainWindowPosition()
				instancia_alvo:RestoreMainWindowPosition()
				precisa_ativar = false

			elseif (tempo_fades) then

				if (flash_bounce == 0) then

					flash_bounce = 1

					local tem_livre = false

					for lado, livre in ipairs(nao_anexados) do
						if (livre) then
							if (lado == 1) then

								local texture = instancia_alvo.h_esquerda.texture
								texture:ClearAllPoints()

								if (instancia_alvo.toolbar_side == 1) then
									if (instancia_alvo.show_statusbar) then
										texture:SetPoint("topright", instancia_alvo.baseframe, "topleft", 0, 20)
										texture:SetPoint("bottomright", instancia_alvo.baseframe, "bottomleft", 0, -14)
									else
										texture:SetPoint("topright", instancia_alvo.baseframe, "topleft", 0, 20)
										texture:SetPoint("bottomright", instancia_alvo.baseframe, "bottomleft", 0, 0)
									end
								else
									if (instancia_alvo.show_statusbar) then
										texture:SetPoint("topright", instancia_alvo.baseframe, "topleft", 0, 0)
										texture:SetPoint("bottomright", instancia_alvo.baseframe, "bottomleft", 0, -34)
									else
										texture:SetPoint("topright", instancia_alvo.baseframe, "topleft", 0, 0)
										texture:SetPoint("bottomright", instancia_alvo.baseframe, "bottomleft", 0, -20)
									end
								end

								instancia_alvo.h_esquerda:Flash(1, 1, 2.0, false, 0, 0)
								tem_livre = true

							elseif (lado == 2) then


								local texture = instancia_alvo.h_baixo.texture
								texture:ClearAllPoints()

								if (instancia_alvo.toolbar_side == 1) then
									if (instancia_alvo.show_statusbar) then
										texture:SetPoint("topleft", instancia_alvo.baseframe, "bottomleft", 0, -14)
										texture:SetPoint("topright", instancia_alvo.baseframe, "bottomright", 0, -14)
									else
										texture:SetPoint("topleft", instancia_alvo.baseframe, "bottomleft", 0, 0)
										texture:SetPoint("topright", instancia_alvo.baseframe, "bottomright", 0, 0)
									end
								else
									if (instancia_alvo.show_statusbar) then
										texture:SetPoint("topleft", instancia_alvo.baseframe, "bottomleft", 0, -34)
										texture:SetPoint("topright", instancia_alvo.baseframe, "bottomright", 0, -34)
									else
										texture:SetPoint("topleft", instancia_alvo.baseframe, "bottomleft", 0, -20)
										texture:SetPoint("topright", instancia_alvo.baseframe, "bottomright", 0, -20)
									end
								end

								instancia_alvo.h_baixo:Flash(1, 1, 2.0, false, 0, 0)
								tem_livre = true

							elseif (lado == 3) then

								local texture = instancia_alvo.h_direita.texture
								texture:ClearAllPoints()

								if (instancia_alvo.toolbar_side == 1) then
									if (instancia_alvo.show_statusbar) then
										texture:SetPoint("topleft", instancia_alvo.baseframe, "topright", 0, 20)
										texture:SetPoint("bottomleft", instancia_alvo.baseframe, "bottomright", 0, -14)
									else
										texture:SetPoint("topleft", instancia_alvo.baseframe, "topright", 0, 20)
										texture:SetPoint("bottomleft", instancia_alvo.baseframe, "bottomright", 0, 0)
									end
								else
									if (instancia_alvo.show_statusbar) then
										texture:SetPoint("topleft", instancia_alvo.baseframe, "topright", 0, 0)
										texture:SetPoint("bottomleft", instancia_alvo.baseframe, "bottomright", 0, -34)
									else
										texture:SetPoint("topleft", instancia_alvo.baseframe, "topright", 0, 0)
										texture:SetPoint("bottomleft", instancia_alvo.baseframe, "bottomright", 0, -20)
									end
								end

								instancia_alvo.h_direita:Flash(1, 1, 2.0, false, 0, 0)
								tem_livre = true

							elseif (lado == 4) then

								local texture = instancia_alvo.h_cima.texture
								texture:ClearAllPoints()

								if (instancia_alvo.toolbar_side == 1) then
									texture:SetPoint("bottomleft", instancia_alvo.baseframe, "topleft", 0, 20)
									texture:SetPoint("bottomright", instancia_alvo.baseframe, "topright", 0, 20)
								else
									texture:SetPoint("bottomleft", instancia_alvo.baseframe, "topleft", 0, 0)
									texture:SetPoint("bottomright", instancia_alvo.baseframe, "topright", 0, 0)
								end

								instancia_alvo.h_cima:Flash(1, 1, 2.0, false, 0, 0)
								tem_livre = true

							end
						end
					end
				end

				tempo_movendo = 1
			else
				self:SetScript("OnUpdate", nil)
				tempo_movendo = 1
			end

		elseif (tempo_movendo) then
			tempo_movendo = tempo_movendo - elapsed
		end
	end

local function move_janela(baseframe, iniciando, instancia, just_updating)
	instancia_alvo = Details:GetAllInstances() [instancia.meu_id-1]
	if (Details.disable_window_groups) then
		instancia_alvo = nil
	end

	if (iniciando) then

		if (baseframe.isMoving) then
			--ja esta em movimento
			return
		end

		baseframe.isMoving = true
		instancia:BaseFrameSnap()
		baseframe:StartMoving()

		local group = instancia:GetInstanceGroup()
		for _, this_instance in ipairs(group) do
			this_instance.baseframe:SetClampRectInsets (0, 0, 0, 0)
			this_instance.isMoving = true
		end

		local _, ClampLeft, ClampRight = instancia:InstanciasHorizontais()
		local _, ClampBottom, ClampTop = instancia:InstanciasVerticais()

		baseframe:SetClampRectInsets (-ClampLeft, ClampRight, ClampTop, -ClampBottom)

		if (instancia_alvo and (instancia_alvo.ativa or not just_updating)) then

			tempo_fades = 1.0
			nao_anexados = {true, true, true, true}
			tempo_movendo = 1
			flash_bounce = 0
			instance_ids_shown = 0
			start_draw_lines = 0
			need_show_group_guide = nil

			for lado, snap_to in pairs(instancia_alvo.snap) do
				if (snap_to == instancia.meu_id) then
					start_draw_lines = false
				end
			end

			for lado, snap_to in pairs(instancia_alvo.snap) do
				if (snap_to) then
					if (snap_to == instancia.meu_id) then
						tempo_fades = nil
						break
					end
					nao_anexados [lado] = false
				end
			end

			for lado = 1, 4 do
				if (instancia_alvo.horizontalSnap and instancia.verticalSnap) then
					nao_anexados [lado] = false
				elseif (instancia_alvo.horizontalSnap and lado == 2) then
					nao_anexados [lado] = false
				elseif (instancia_alvo.horizontalSnap and lado == 4) then
					nao_anexados [lado] = false
				elseif (instancia_alvo.verticalSnap and lado == 1) then
					nao_anexados [lado] = false
				elseif (instancia_alvo.verticalSnap and lado == 3) then
					nao_anexados [lado] = false
				end
			end

			local need_start = not instancia_alvo.iniciada
			precisa_ativar = not instancia_alvo.ativa

			if (need_start) then --se a inst�ncia n�o tiver sido aberta ainda
				local lower_instance = Details:GetLowerInstanceNumber()

				instancia_alvo:RestauraJanela(instancia_alvo.meu_id, true)
				if (instancia_alvo:IsSoloMode()) then
					Details.SoloTables:switch()
				end

				instancia_alvo.ativa = false

				instancia_alvo:SaveMainWindowPosition()
				instancia_alvo:RestoreMainWindowPosition()

				instancia_alvo:ShutDown()
				Details.FadeHandler.Fader(instancia_alvo.baseframe, 1)
				Details.FadeHandler.Fader(instancia_alvo.rowframe, parseRowFrameAlpha(1))
				Details.FadeHandler.Fader(instancia_alvo.baseframe.cabecalho.ball, 1)

				need_start = false
			end

			baseframe:SetScript("OnUpdate", movement_onupdate)
		else
			--eh a instancia 1
			local got_snap
			for side, instance_id in pairs(instancia.snap) do
				if (instance_id) then
					got_snap = true
				end
			end

			need_show_group_guide = nil

			if (not got_snap) then
				need_show_group_guide = instancia
			end

			tempo_movendo = nil
			start_draw_lines = nil
			instance_ids_shown = 0
			baseframe:SetScript("OnUpdate", movement_onupdate)
		end

	else
		baseframe:StopMovingOrSizing()
		baseframe.isMoving = false
		baseframe:SetScript("OnUpdate", nil)

		if (Details.guide_balls) then
			for index, ball in ipairs(Details.guide_balls) do
				ball:Hide()
			end
		end

		for _, ins in Details:ListInstances() do
			if (ins.baseframe) then
				ins.baseframe:SetUserPlaced (false)
				if (ins.baseframe.id_texture1) then
					ins.baseframe.id_texture1:Hide()
					ins.baseframe.id_texture2:Hide()
				end
			end
		end

		--baseframe:SetClampRectInsets (unpack(_detalhes.window_clamp))

		if (instancia_alvo and not instancia.do_not_snap and not instancia_alvo.do_not_snap) then
			instancia:AtualizaPontos()
			instancia_alvo:AtualizaPontos()

			local esquerda, baixo, direita, cima
			local meu_id = instancia.meu_id --id da inst�ncia que esta sendo movida

			local isVertical = instancia_alvo.verticalSnap
			local isHorizontal = instancia_alvo.horizontalSnap

			local isSelfVertical = instancia.verticalSnap
			local isSelfHorizontal = instancia.horizontalSnap

			local _R, _T, _L, _B

			if (isVertical and not isSelfHorizontal) then
				_T, _B = VPB (instancia, instancia_alvo), VPT (instancia, instancia_alvo)
			elseif (isHorizontal and not isSelfVertical) then
				_R, _L = VPL (instancia, instancia_alvo), VPR (instancia, instancia_alvo)
			elseif (not isVertical and not isHorizontal) then
				_R, _T, _L, _B = VPL (instancia, instancia_alvo), VPB (instancia, instancia_alvo), VPR (instancia, instancia_alvo), VPT (instancia, instancia_alvo)
			end

			if (_L) then
				if (not instancia:EstaAgrupada(instancia_alvo, _L)) then
					esquerda = instancia_alvo.meu_id
					instancia.horizontalSnap = true
					instancia_alvo.horizontalSnap = true
				end
			end

			if (_B) then
				if (not instancia:EstaAgrupada(instancia_alvo, _B)) then
					baixo = instancia_alvo.meu_id
					instancia.verticalSnap = true
					instancia_alvo.verticalSnap = true
				end
			end

			if (_R) then
				if (not instancia:EstaAgrupada(instancia_alvo, _R)) then
					direita = instancia_alvo.meu_id
					instancia.horizontalSnap = true
					instancia_alvo.horizontalSnap = true
				end
			end

			if (_T) then
				if (not instancia:EstaAgrupada(instancia_alvo, _T)) then
					cima = instancia_alvo.meu_id
					instancia.verticalSnap = true
					instancia_alvo.verticalSnap = true
				end
			end

			if (esquerda or baixo or direita or cima) then
				instancia:agrupar_janelas({esquerda, baixo, direita, cima})

				--tutorial
				if (not Details:GetTutorialCVar("WINDOW_GROUP_MAKING1")) then
					Details:SetTutorialCVar ("WINDOW_GROUP_MAKING1", true)

					local group_tutorial = CreateFrame("frame", "DetailsWindowGroupPopUp1", instancia.baseframe, "DetailsHelpBoxTemplate")
					group_tutorial.ArrowUP:Show()
					group_tutorial.ArrowGlowUP:Show()
					group_tutorial.Text:SetText(Loc["STRING_MINITUTORIAL_WINDOWS1"])
					group_tutorial:SetPoint("bottom", instancia_alvo.break_snap_button, "top", 0, 24)
					group_tutorial:Show()
					Details.OnEnterMainWindow(instancia_alvo)

				end
			end

			for _, esta_instancia in ipairs(Details:GetAllInstances()) do
				if (not esta_instancia:IsAtiva() and esta_instancia.iniciada) then
					esta_instancia:ResetaGump()

					Details.FadeHandler.Fader(esta_instancia.baseframe, "in", 0.15)
					Details.FadeHandler.Fader(esta_instancia.baseframe.cabecalho.ball, "in", 0.15)
					Details.FadeHandler.Fader(esta_instancia.baseframe.cabecalho.atributo_icon, "in", 0.15)

					if (esta_instancia.modo == modo_raid) then
						Details.raid = nil
					elseif (esta_instancia.modo == modo_alone) then
						Details.SoloTables:switch()
						Details.solo = nil
					end

				elseif (esta_instancia:IsAtiva()) then
					esta_instancia:SaveMainWindowPosition()
					esta_instancia:RestoreMainWindowPosition()
				end
			end

		end

		--salva pos de todas as janelas
		for _, ins in ipairs(Details:GetAllInstances()) do
			if (ins:IsEnabled()) then
				ins:SaveMainWindowPosition()
				ins:RestoreMainWindowPosition()
			end
		end

		local group = instancia:GetInstanceGroup()
		for _, this_instance in ipairs(group) do
			this_instance.isMoving = false
		end

		if (not DetailsFramework.IsTimewalkWoW()) then
			Details.MicroButtonAlert:Hide()
		end

		if (instancia_alvo and instancia_alvo.ativa and instancia_alvo.baseframe) then
			instancia_alvo.h_esquerda:Stop()
			instancia_alvo.h_baixo:Stop()
			instancia_alvo.h_direita:Stop()
			instancia_alvo.h_cima:Stop()
		end
	end
end

Details.move_janela_func = move_janela

local BGFrame_scripts_onenter = function(self)
	OnEnterMainWindow(self._instance, self)
end

local BGFrame_scripts_onleave = function(self)
	OnLeaveMainWindow(self._instance, self)
end

local BGFrame_scripts_onmousedown = function(self, button)
	-- /run Details.disable_stretch_from_toolbar = true
	if (self.is_toolbar and self._instance.baseframe.isLocked and button == "LeftButton" and not Details.disable_stretch_from_toolbar) then
		return self._instance.baseframe.button_stretch:GetScript("OnMouseDown") (self._instance.baseframe.button_stretch, "LeftButton")
	end

	if (self._instance.baseframe.isMoving) then
		move_janela(self._instance.baseframe, false, self._instance)
		self._instance:SaveMainWindowPosition()
		return
	end

	if (not self._instance.baseframe.isLocked and button == "LeftButton") then
		move_janela(self._instance.baseframe, true, self._instance)
		if (self.is_toolbar) then
			if (self._instance.attribute_text.enabled and self._instance.attribute_text.side == 1 and self._instance.toolbar_side == 1) then
				self._instance.menu_attribute_string:SetPoint("bottomleft", self._instance.baseframe.cabecalho.ball, "bottomright", self._instance.attribute_text.anchor [1]+1, self._instance.attribute_text.anchor [2]-1)
			end
		end

	elseif (button == "RightButton") then
		if (self.is_toolbar and not Details.disable_alldisplays_window) then
			self._instance:ShowAllSwitch()
		else
			if (Details.switch.current_instancia and Details.switch.current_instancia == self._instance) then
				Details.switch:CloseMe()
			else
				Details.switch:ShowMe(self._instance)
			end
		end
	end
end

local BGFrame_scripts_onmouseup = function(self, button)
	if (self.is_toolbar and self._instance.baseframe.isLocked and button == "LeftButton") then
		if (DetailsWindowLockPopUp1 and DetailsWindowLockPopUp1:IsShown()) then
			_G ["DetailsWindowLockPopUp1"]:Hide()
		end
		return self._instance.baseframe.button_stretch:GetScript("OnMouseUp") (self._instance.baseframe.button_stretch, "LeftButton")
	end

	if (self._instance.baseframe.isMoving) then
		move_janela(self._instance.baseframe, false, self._instance) --novo movedor da janela
		self._instance:SaveMainWindowPosition()
		if (self.is_toolbar) then
			if (self._instance.attribute_text.enabled and self._instance.attribute_text.side == 1 and self._instance.toolbar_side == 1) then
				self._instance.menu_attribute_string:SetPoint("bottomleft", self._instance.baseframe.cabecalho.ball, "bottomright", self._instance.attribute_text.anchor [1], self._instance.attribute_text.anchor [2])
			end
		end
	end
end

local function BGFrame_scripts(BG, baseframe, instancia)
	BG._instance = instancia
	BG:SetScript("OnEnter", BGFrame_scripts_onenter)
	BG:SetScript("OnLeave", BGFrame_scripts_onleave)
	BG:SetScript("OnMouseDown", BGFrame_scripts_onmousedown)
	BG:SetScript("OnMouseUp", BGFrame_scripts_onmouseup)
end

function gump:RegisterForDetailsMove(frame, instancia)
	frame:SetScript("OnMouseDown", function(frame, button)
		if (not instancia.baseframe.isLocked and button == "LeftButton") then
			move_janela(instancia.baseframe, true, instancia) --novo movedor da janela
		end
	end)

	frame:SetScript("OnMouseUp", function(frame)
		if (instancia.baseframe.isMoving) then
			move_janela(instancia.baseframe, false, instancia) --novo movedor da janela
			instancia:SaveMainWindowPosition()
		end
	end)
end

--scripts do base frame
local BFrame_scripts_onsizechange = function(self)
	self._instance:SaveMainWindowSize()
	self._instance:ReajustaGump()
	self._instance.oldwith = self:GetWidth()
	Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, self._instance)
	self._instance:RefreshAttributeTextSize()
end

local BFrame_scripts_onenter = function(self)
	OnEnterMainWindow(self._instance, self)
end

local BFrame_scripts_onleave = function(self)
	OnLeaveMainWindow(self._instance, self)
end

local BFrame_scripts_onmousedown = function(self, button)
	if (not self.isLocked and button == "LeftButton") then
		move_janela(self, true, self._instance)
	end
end

local BFrame_scripts_onmouseup = function(self, button)
	if (self.isMoving) then
		move_janela(self, false, self._instance) --novo movedor da janela
		self._instance:SaveMainWindowPosition()
	end
end

local function BFrame_scripts (baseframe, instancia)
	baseframe._instance = instancia
	baseframe:SetScript("OnSizeChanged", BFrame_scripts_onsizechange)
	baseframe:SetScript("OnEnter", BFrame_scripts_onenter)
	baseframe:SetScript("OnLeave", BFrame_scripts_onleave)
	baseframe:SetScript("OnMouseDown", BFrame_scripts_onmousedown)
	baseframe:SetScript("OnMouseUp", BFrame_scripts_onmouseup)
end

local function backgrounddisplay_scripts (backgrounddisplay, baseframe, instancia)
	backgrounddisplay:SetScript("OnEnter", function(self)
		OnEnterMainWindow(instancia, self)
	end)

	backgrounddisplay:SetScript("OnLeave", function(self)
		OnLeaveMainWindow(instancia, self)
	end)
end

local function instancias_horizontais (instancia, largura, esquerda, direita)
	if (esquerda) then
		for lado, esta_instancia in pairs(instancia.snap) do
			if (lado == 1) then --movendo para esquerda
				local instancia = Details:GetAllInstances() [esta_instancia]
				instancia.baseframe:SetWidth(largura)
				instancia.auto_resize = true
				instancia:ReajustaGump()
				instancia.auto_resize = false
				instancias_horizontais (instancia, largura, true, false)
				Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
			end
		end
	end

	if (direita) then
		for lado, esta_instancia in pairs(instancia.snap) do
			if (lado == 3) then --movendo para esquerda
				local instancia = Details:GetAllInstances() [esta_instancia]
				instancia.baseframe:SetWidth(largura)
				instancia.auto_resize = true
				instancia:ReajustaGump()
				instancia.auto_resize = false
				instancias_horizontais (instancia, largura, false, true)
				Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
			end
		end
	end
end

local function instancias_verticais (instancia, altura, esquerda, direita)
	if (esquerda) then
		for lado, esta_instancia in pairs(instancia.snap) do
			if (lado == 1) then --movendo para esquerda
				local instancia = Details:GetAllInstances() [esta_instancia]
				if (instancia:IsEnabled()) then
					instancia.baseframe:SetHeight(altura)
					instancia.auto_resize = true
					instancia:ReajustaGump()
					instancia.auto_resize = false
					instancias_verticais (instancia, altura, true, false)
					Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
				end
			end
		end
	end

	if (direita) then
		for lado, esta_instancia in pairs(instancia.snap) do
			if (lado == 3) then --movendo para esquerda
				local instancia = Details:GetAllInstances() [esta_instancia]
				if (instancia:IsEnabled()) then
					instancia.baseframe:SetHeight(altura)
					instancia.auto_resize = true
					instancia:ReajustaGump()
					instancia.auto_resize = false
					instancias_verticais (instancia, altura, false, true)
					Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)
				end
			end
		end
	end
end

local check_snap_side = function(instanceid, snap, id, container)
	local instance = Details:GetInstance(instanceid)
	if (instance and instance.snap [snap] and instance.snap [snap] == id) then
		table.insert(container, instance)
		return true
	end
end

function Details:InstanciasVerticais(instance)
	instance = self or instance

	--instances that are above the current instance
	local on_top = {}

	--instances that are below the current instance
	local on_bottom = {}

	--id of the current instance
	local id = instance:GetId()

	--lower instances
	--this is getting the instance of ID - 1, this is the reason why details windows always snap with the previous window
	local this_instance = Details:GetInstance(id-1)
	if (this_instance) then
		--top side
		if (this_instance.snap [2] and this_instance.snap [2] == id) then
			local cid = id
			local snapid = 2
			for i = cid-1, 1, -1 do
				if (check_snap_side (i, 2, cid, on_top)) then
					cid = cid - 1
				else
					break
				end
			end
		--bottom side
		elseif (this_instance.snap [4] and this_instance.snap [4] == id) then
			local cid = id
			local snapid = 4
			for i = cid-1, 1, -1 do
				if (check_snap_side (i, 4, cid, on_bottom)) then
					cid = cid - 1
				else
					break
				end
			end
		end
	end

	--upper instances
	local this_instance = Details:GetInstance(id+1)
	if (this_instance) then
		--top side
		if (this_instance.snap [2] and this_instance.snap [2] == id) then
			local cid = id
			local snapid = 2
			for i = cid+1, Details:GetNumInstancesAmount() do
				if (check_snap_side (i, 2, cid, on_top)) then
					cid = cid + 1
				else
					break
				end
			end
		--bottom side
		elseif (this_instance.snap [4] and this_instance.snap [4] == id) then
			local cid = id
			local snapid = 4
			for i = cid+1, Details:GetNumInstancesAmount() do
				if (check_snap_side (i, 4, cid, on_bottom)) then
					cid = cid + 1
				else
					break
				end
			end
		end
	end

	--calc top clamp
	local topClampPixels = 0
	local bottomClampPixels = 0

	if (instance.toolbar_side == 1) then
		topClampPixels = topClampPixels + 20
	elseif (instance.toolbar_side == 2) then
		bottomClampPixels = bottomClampPixels + 20
	end
	if (instance.show_statusbar) then
		bottomClampPixels = bottomClampPixels + 14
	end

	for cid, thisInstance in ipairs(on_top) do
		if (thisInstance.show_statusbar) then
			topClampPixels = topClampPixels + 14
		end
		topClampPixels = topClampPixels + 20
		topClampPixels = topClampPixels + thisInstance.baseframe:GetHeight()
	end

	for cid, thisInstance in ipairs(on_bottom) do
		if (thisInstance.show_statusbar) then
			bottomClampPixels = bottomClampPixels + 14
		end
		bottomClampPixels = bottomClampPixels + 20
		bottomClampPixels = bottomClampPixels + thisInstance.baseframe:GetHeight()
		table.insert(on_top, thisInstance)
	end

	return on_top, bottomClampPixels, topClampPixels
end

--[[
			lado 4
	-----------------------------------------
	|					|
lado 1	|					| lado 3
	|					|
	|					|
	-----------------------------------------
			lado 2
--]]

function Details:InstanciasHorizontais(instancia)
	instancia = self or instancia

	local linha_horizontal, esquerda, direita = {}, 0, 0

	local top, bottom = 0, 0

	local checking = instancia

	local check_index_anterior = Details:GetAllInstances() [instancia.meu_id-1]
	if (check_index_anterior and check_index_anterior:IsEnabled()) then --possiu uma inst�ncia antes de mim
		if (check_index_anterior.snap[3] and check_index_anterior.snap[3] == instancia.meu_id) then --o index negativo vai para a esquerda
			for i = instancia.meu_id-1, 1, -1 do
				local esta_instancia = Details:GetAllInstances() [i]
				if (esta_instancia.snap[3]) then
					if (esta_instancia.snap[3] == checking.meu_id) then
						linha_horizontal [#linha_horizontal+1] = esta_instancia
						esquerda = esquerda + esta_instancia.baseframe:GetWidth()
						checking = esta_instancia
					end
				else
					break
				end
			end

		elseif (check_index_anterior.snap[1] and check_index_anterior.snap[1] == instancia.meu_id) then --o index negativo vai para a direita
			for i = instancia.meu_id-1, 1, -1 do
				local esta_instancia = Details:GetAllInstances() [i]
				if (esta_instancia.snap[1]) then
					if (esta_instancia.snap[1] == checking.meu_id) then
						linha_horizontal [#linha_horizontal+1] = esta_instancia
						direita = direita + esta_instancia.baseframe:GetWidth()
						checking = esta_instancia
					end
				else
					break
				end
			end
		end
	end

	checking = instancia

	local check_index_posterior = Details:GetAllInstances() [instancia.meu_id+1]
	if (check_index_posterior and check_index_posterior:IsEnabled()) then
		if (check_index_posterior.snap[3] and check_index_posterior.snap[3] == instancia.meu_id) then --o index posterior vai para a esquerda
			for i = instancia.meu_id+1, #Details:GetAllInstances() do
				local esta_instancia = Details:GetAllInstances() [i]
				if (esta_instancia.snap[3]) then
					if (esta_instancia.snap[3] == checking.meu_id) then
						linha_horizontal [#linha_horizontal+1] = esta_instancia
						esquerda = esquerda + esta_instancia.baseframe:GetWidth()
						checking = esta_instancia
					end
				else
					break
				end
			end

		elseif (check_index_posterior.snap[1] and check_index_posterior.snap[1] == instancia.meu_id) then --o index posterior vai para a direita
			for i = instancia.meu_id+1, #Details:GetAllInstances() do
				local esta_instancia = Details:GetAllInstances() [i]
				if (esta_instancia.snap[1]) then
					if (esta_instancia.snap[1] == checking.meu_id) then
						linha_horizontal [#linha_horizontal+1] = esta_instancia
						direita = direita + esta_instancia.baseframe:GetWidth()
						checking = esta_instancia
					end
				else
					break
				end
			end
		end
	end

	return linha_horizontal, esquerda, direita, bottom, top

end

local resizeTooltip = {
	{text = "|cff33CC00Click|cffEEEEEE: ".. Loc["STRING_RESIZE_COMMON"]},

	{text = "+|cff33CC00 Click|cffEEEEEE: " .. Loc["STRING_RESIZE_HORIZONTAL"]},
	{icon = [[Interface\AddOns\Details\images\key_shift]], width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625},

	{text = "+|cff33CC00 Click|cffEEEEEE: " .. Loc["STRING_RESIZE_VERTICAL"]},
	{icon = [[Interface\AddOns\Details\images\key_alt]], width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625},

	{text = "+|cff33CC00 Click|cffEEEEEE: " .. Loc["STRING_RESIZE_ALL"]},
	{icon = [[Interface\AddOns\Details\images\key_ctrl]], width = 24, height = 14, l = 0, r = 1, t = 0, b =0.640625}
}

--search key: ~resizescript

local resize_scripts_onmousedown = function(self, button)
	_G.GameCooltip:ShowMe(false) --Hide Cooltip

	if (Details.disable_lock_ungroup_buttons) then
		return
	end

	if (not self:GetParent().isLocked and button == "LeftButton" and self._instance.modo ~= Details._detalhes_props["MODO_ALONE"]) then
		self:GetParent().isResizing = true
		self._instance:BaseFrameSnap()

		local isVertical = self._instance.verticalSnap
		local isHorizontal = self._instance.horizontalSnap

		local agrupadas
		if (self._instance.verticalSnap) then
			agrupadas = self._instance:InstanciasVerticais()
		elseif (self._instance.horizontalSnap) then
			agrupadas = self._instance:InstanciasHorizontais()
		end

		self._instance.stretchToo = agrupadas
		if (self._instance.stretchToo and #self._instance.stretchToo > 0) then
			for _, esta_instancia in ipairs(self._instance.stretchToo) do
				esta_instancia.baseframe._place = esta_instancia:SaveMainWindowPosition()
				esta_instancia.baseframe.isResizing = true
			end
		end

		if (self._myside == "<") then
			if (_IsShiftKeyDown()) then
				self._instance.baseframe:StartSizing("left")
				self._instance.eh_horizontal = true

			elseif (_IsAltKeyDown()) then
				self._instance.baseframe:StartSizing("top")
				self._instance.eh_vertical = true

			elseif (_IsControlKeyDown()) then
				self._instance.baseframe:StartSizing("bottomleft")
				self._instance.eh_tudo = true

			else
				self._instance.baseframe:StartSizing("bottomleft")
			end

			self:SetPoint("bottomleft", self._instance.baseframe, "bottomleft", -1, -1)
			self.afundado = true

		elseif (self._myside == ">") then
			if (_IsShiftKeyDown()) then
				self._instance.baseframe:StartSizing("right")
				self._instance.eh_horizontal = true

			elseif (_IsAltKeyDown()) then
				self._instance.baseframe:StartSizing("top")
				self._instance.eh_vertical = true

			elseif (_IsControlKeyDown()) then
				self._instance.baseframe:StartSizing("bottomright")
				self._instance.eh_tudo = true

			else
				self._instance.baseframe:StartSizing("bottomright")
			end

			if (self._instance.rolagem and Details.use_scroll) then
				self:SetPoint("bottomright", self._instance.baseframe, "bottomright", (self._instance.largura_scroll*-1) + 1, -1)
			else
				self:SetPoint("bottomright", self._instance.baseframe, "bottomright", 1, -1)
			end
			self.afundado = true
		end

		Details:SendEvent("DETAILS_INSTANCE_STARTRESIZE", nil, self._instance)

		if (Details.update_speed > 0.3) then
			Details:SetWindowUpdateSpeed(0.3, true)
			Details.resize_changed_update_speed = true
		end
	end
end

local resizeScriptsOnMouseUp = function(self, button)
	if (Details.disable_lock_ungroup_buttons) then
		return
	end

	if (self.afundado) then
		self.afundado = false
		if (self._myside == ">") then
			if (self._instance.rolagem and Details.use_scroll) then
				self:SetPoint("bottomright", self._instance.baseframe, "bottomright", self._instance.largura_scroll*-1, 0)
			else
				self:SetPoint("bottomright", self._instance.baseframe, "bottomright", 0, 0)
			end
		else
			self:SetPoint("bottomleft", self._instance.baseframe, "bottomleft", 0, 0)
		end
	end

	if (self:GetParent().isResizing) then
		self:GetParent():StopMovingOrSizing()
		self:GetParent().isResizing = false

		self._instance:RefreshBars()
		self._instance:InstanceReset()
		self._instance:ReajustaGump()

		if (self._instance.stretchToo and #self._instance.stretchToo > 0) then
			for _, esta_instancia in ipairs(self._instance.stretchToo) do
				esta_instancia.baseframe:StopMovingOrSizing()
				esta_instancia.baseframe.isResizing = false
				esta_instancia:RefreshBars()
				esta_instancia:InstanceReset()
				esta_instancia:ReajustaGump()
				Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, esta_instancia)
			end
			self._instance.stretchToo = nil
		end

		local largura = self._instance.baseframe:GetWidth()
		local altura = self._instance.baseframe:GetHeight()

		if (self._instance.eh_horizontal) then
			instancias_horizontais(self._instance, largura, true, true)
			self._instance.eh_horizontal = nil
		end

		--if (instancia.eh_vertical) then
			instancias_verticais(self._instance, altura, true, true)
			self._instance.eh_vertical = nil
		--end

		Details:SendEvent("DETAILS_INSTANCE_ENDRESIZE", nil, self._instance)

		if (self._instance.eh_tudo) then
			for _, esta_instancia in ipairs(Details:GetAllInstances()) do
				if (esta_instancia:IsAtiva() and esta_instancia.modo ~= Details._detalhes_props["MODO_ALONE"]) then
					esta_instancia.baseframe:ClearAllPoints()
					esta_instancia:SaveMainWindowPosition()
					esta_instancia:RestoreMainWindowPosition()
				end
			end

			for _, esta_instancia in ipairs(Details:GetAllInstances()) do
				if (esta_instancia:IsAtiva() and esta_instancia ~= self._instance and esta_instancia.modo ~= Details._detalhes_props["MODO_ALONE"]) then
					esta_instancia.baseframe:SetWidth(largura)
					esta_instancia.baseframe:SetHeight(altura)
					esta_instancia.auto_resize = true
					esta_instancia:RefreshBars()
					esta_instancia:InstanceReset()
					esta_instancia:ReajustaGump()
					esta_instancia.auto_resize = false
					Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, esta_instancia)
				end
			end

			self._instance.eh_tudo = nil
		end

		self._instance:BaseFrameSnap()

		for _, esta_instancia in ipairs(Details:GetAllInstances()) do
			if (esta_instancia:IsAtiva()) then
				esta_instancia:SaveMainWindowPosition()
				esta_instancia:RestoreMainWindowPosition()
			end
		end

		if (Details.resize_changed_update_speed) then
			Details:SetWindowUpdateSpeed(false, true)
			Details.resize_changed_update_speed = nil
		end
	end
end

local resizeScriptsOnHide = function(self)
	if (self.going_hide) then
		_G.GameCooltip:ShowMe(false)
		self.going_hide = nil
	end
end

local resizeScriptsOnEnter = function(self)
	if (Details.disable_lock_ungroup_buttons) then
		return
	end

	if (self._instance.modo ~= Details._detalhes_props["MODO_ALONE"] and not self._instance.baseframe.isLocked and not self.mostrando) then
		OnEnterMainWindow(self._instance, self)

		self.texture:SetBlendMode("ADD")
		self.mostrando = true

		Details:CooltipPreset(2.1)
		GameCooltip:AddFromTable(resizeTooltip)

		GameCooltip:SetOwner(self)
		GameCooltip:ShowCooltip()
	end
end

local resizeScriptsOnLeave = function(self)
	if (self.mostrando) then
		self.going_hide = true
		if (not self.movendo) then
			OnLeaveMainWindow(self._instance, self)
		end

		self.texture:SetBlendMode("BLEND")
		self.mostrando = false

		GameCooltip:ShowMe(false)
	end
end

local setWindowResizeScripts = function(resizer, instancia, scrollbar, side, baseframe)
	resizer._instance = instancia
	resizer._myside = side

	resizer:SetScript("OnMouseDown", resize_scripts_onmousedown)
	resizer:SetScript("OnMouseUp", resizeScriptsOnMouseUp)
	resizer:SetScript("OnHide", resizeScriptsOnHide)
	resizer:SetScript("OnEnter", resizeScriptsOnEnter)
	resizer:SetScript("OnLeave", resizeScriptsOnLeave)
end

local lockButtonTooltip = {
	{text = Loc["STRING_LOCK_DESC"]},
	{icon = [[Interface\PetBattles\PetBattle-LockIcon]], width = 14, height = 14, l = 0.0703125, r = 0.9453125, t = 0.0546875, b = 0.9453125, color = "orange"},
}

local lockFunctionOnEnter = function(self)
	if (Details.disable_lock_ungroup_buttons) then
		return
	end

	if (self.instancia.modo ~= Details._detalhes_props["MODO_ALONE"] and not self.mostrando) then
		OnEnterMainWindow(self.instancia, self)

		self.mostrando = true

		self.label:SetTextColor(1, 1, 1, .6)

		Details:CooltipPreset(2.1)
		GameCooltip:SetOption("FixedWidth", 180)
		GameCooltip:AddFromTable(lockButtonTooltip)

		GameCooltip:SetOwner(self)
		GameCooltip:ShowCooltip()
	end
end

local lockFunctionOnLeave = function(self)
	if (self.mostrando) then
		self.going_hide = true
		OnLeaveMainWindow(self.instancia, self)
		self.label:SetTextColor(.6, .6, .6, .7)
		self.mostrando = false
		GameCooltip:ShowMe(false)
	end
end

local lockFunctionOnHide = function(self)
	if (self.going_hide) then
		GameCooltip:ShowMe(false)
		self.going_hide = nil
	end
end

function Details:DelayOptionsRefresh(instance, noReopen)
	if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
		Details:ScheduleTimer("OpenOptionsWindow", 0.1, {instance or _G.DetailsOptionsWindow.instance, noReopen})
	end
end

function Details:RefreshLockedState()
	if (not self.baseframe and self.meu_id and self:IsEnabled()) then
		self:ScheduleTimer("RefreshLockedState", 1)
		return
	elseif (not self.baseframe) then
		return
	end

	if (self.baseframe.isLocked) then
		self.baseframe.resize_direita:EnableMouse(false)
		self.baseframe.resize_esquerda:EnableMouse(false)
	else
		self.baseframe.resize_direita:EnableMouse(true)
		self.baseframe.resize_esquerda:EnableMouse(true)
	end

	return true
end

local lockFunctionOnClick = function(button, button_type, button2, isFromOptionsButton)
	--isFromOptionsButton is true when the call if from the button in the display section of the options panel
	if (Details.disable_lock_ungroup_buttons and isFromOptionsButton ~= true) then
		return
	end

	if (not button:GetParent().instance) then
		button = button2 --from any other button
	end

	local baseframe = button:GetParent()
	if (baseframe.isLocked) then
		baseframe.isLocked = false
		baseframe.instance.isLocked = false
		button.label:SetText(Loc["STRING_LOCK_WINDOW"])
		button:SetWidth(button.label:GetStringWidth()+2)

		if (not Details.disable_lock_ungroup_buttons) then
			baseframe.resize_direita:SetAlpha(1)
			baseframe.resize_esquerda:SetAlpha(1)
		end

		button:ClearAllPoints()
		button:SetPoint("right", baseframe.resize_direita, "left", -1, 1.5)
	else
		--tutorial
		if (not Details:GetTutorialCVar("WINDOW_LOCK_UNLOCK1") and not Details.initializing) then
			Details:SetTutorialCVar ("WINDOW_LOCK_UNLOCK1", true)

			local lock_tutorial = CreateFrame("frame", "DetailsWindowLockPopUp1", baseframe, "DetailsHelpBoxTemplate")
			lock_tutorial.ArrowUP:Show()
			lock_tutorial.ArrowGlowUP:Show()
			lock_tutorial.Text:SetText(Loc["STRING_MINITUTORIAL_WINDOWS2"])
			lock_tutorial:SetPoint("bottom", baseframe.UPFrame, "top", 0, 20)
			lock_tutorial:Show()

		end

		baseframe.isLocked = true
		baseframe.instance.isLocked = true
		button.label:SetText(Loc["STRING_UNLOCK_WINDOW"])
		button:SetWidth(button.label:GetStringWidth()+2)
		button:ClearAllPoints()
		button:SetPoint("bottomright", baseframe, "bottomright", -3, 0)
		baseframe.resize_direita:SetAlpha(0)
		baseframe.resize_esquerda:SetAlpha(0)
	end

	baseframe.instance:RefreshLockedState()

	Details:DelayOptionsRefresh()
end

Details.lock_instance_function = lockFunctionOnClick

local unSnapButtonTooltip = {
	{text = Loc["STRING_DETACH_DESC"]},
	{icon = [[Interface\AddOns\Details\images\icons]], width = 14, height = 14, l = 160/512, r = 179/512, t = 142/512, b = 162/512},
}

local unSnapButtonOnEnter = function(self)
	if (Details.disable_lock_ungroup_buttons) then
		return
	end

	local haveSnap = false
	for _, instancia_id in pairs(self.instancia.snap) do
		if (instancia_id) then
			haveSnap = true
			break
		end
	end

	if (not haveSnap) then
		OnEnterMainWindow(self.instancia, self)
		self.mostrando = true
		return
	end

	OnEnterMainWindow(self.instancia, self)
	self.mostrando = true

	Details:CooltipPreset(2.1)
	GameCooltip:SetOption("FixedWidth", 180)
	GameCooltip:AddFromTable(unSnapButtonTooltip)

	GameCooltip:ShowCooltip(self, "tooltip")
end

local unSnapButtonOnLeave = function(self)
	if (self.mostrando) then
		OnLeaveMainWindow(self.instancia, self)
		self.mostrando = false
		GameCooltip:Hide()
	end
end

--this should run only when the mouse is over a instance bar
local shiftMonitor = function(self)
	if (not self:IsMouseOver()) then
		self:SetScript("OnUpdate", nil)
		return
	end

	if (_IsShiftKeyDown()) then
		if (not self.showing_allspells) then
			self.showing_allspells = true
			local instancia = Details:GetInstance(self.instance_id)
			instancia:MontaTooltip(self, self.row_id, "shift")
		end

	elseif (self.showing_allspells) then
		self.showing_allspells = false
		local instancia = Details:GetInstance(self.instance_id)
		instancia:MontaTooltip(self, self.row_id)
	end

	if (_IsControlKeyDown()) then
		if (not self.showing_alltargets) then
			self.showing_alltargets = true
			local instancia = Details:GetInstance(self.instance_id)
			instancia:MontaTooltip(self, self.row_id, "ctrl")
		end

	elseif (self.showing_alltargets) then
		self.showing_alltargets = false
		local instancia = Details:GetInstance(self.instance_id)
		instancia:MontaTooltip(self, self.row_id)
	end

	if (_IsAltKeyDown()) then
		if (not self.showing_allpets) then
			self.showing_allpets = true
			local instancia = Details:GetInstance(self.instance_id)
			instancia:MontaTooltip(self, self.row_id, "alt")
		end

	elseif (self.showing_allpets) then
		self.showing_allpets = false
		local instancia = Details:GetInstance(self.instance_id)
		instancia:MontaTooltip(self, self.row_id)
	end
end

local barra_backdrop_onenter = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	tile = true, tileSize = 16,
	insets = {left = 1, right = 1, top = 0, bottom = 1}
}

local barra_backdrop_onleave = {
	bgFile = "",
	edgeFile = "", tile = true, tileSize = 16, edgeSize = 32,
	insets = {left = 1, right = 1, top = 0, bottom = 1}
}

--pre creating the truncate frame
	Details.left_anti_truncate = CreateFrame("frame", "DetailsLeftTextAntiTruncate", UIParent,"BackdropTemplate")
	Details.left_anti_truncate:SetBackdrop(defaultBackdropSt)
	Details.left_anti_truncate:SetBackdropColor(0, 0, 0, 0.8)
	Details.left_anti_truncate:SetFrameStrata("FULLSCREEN")
	Details.left_anti_truncate.text = Details.left_anti_truncate:CreateFontString(nil, "overlay", "GameFontNormal")
	Details.left_anti_truncate.text:SetPoint("left", Details.left_anti_truncate, "left", 3, 0)

--@self: instance line (row)
local lineScript_Onenter = function(self)
	self.mouse_over = true
	OnEnterMainWindow(self._instance, self)

	self._instance:MontaTooltip(self, self.row_id)

	self:SetBackdrop(barra_backdrop_onenter)
	self:SetBackdropColor(0.588, 0.588, 0.588, 0.7)

	if (not Details.instances_disable_bar_highlight) then
		self.textura:SetBlendMode("ADD")
	end

	local lefttext = self.lineText1
	if (lefttext:IsTruncated()) then
		if (not Details.left_anti_truncate) then

		end

		Details:SetFontSize(Details.left_anti_truncate.text, self._instance.row_info.font_size)
		Details:SetFontFace(Details.left_anti_truncate.text, self._instance.row_info.font_face_file)
		Details:SetFontColor(Details.left_anti_truncate.text, lefttext:GetTextColor())

		Details.left_anti_truncate:SetPoint("left", lefttext, "left", -3, 0)
		Details.left_anti_truncate.text:SetText(lefttext:GetText())

		Details.left_anti_truncate:SetSize(Details.left_anti_truncate.text:GetStringWidth() + 3, self._instance.row_info.height)
		Details.left_anti_truncate:Show()
		lefttext.untruncated = true
	end

	self:SetScript("OnUpdate", shiftMonitor)

	local classIcon = self:GetClassIcon()
	self.iconHighlight:SetTexture(classIcon:GetTexture())
	self.iconHighlight:SetTexCoord(classIcon:GetTexCoord())
	self.iconHighlight:SetVertexColor(classIcon:GetVertexColor())
	self.iconHighlight:SetBlendMode("ADD")
	self.iconHighlight:SetAlpha(0.3)
	self.iconHighlight:Show()
end

local lineScript_Onleave = function(self)
	self.mouse_over = false
	OnLeaveMainWindow(self._instance, self)

	--_GameTooltip:Hide()
	GameCooltip:ShowMe(false)

	self:SetBackdrop(barra_backdrop_onleave)
	self:SetBackdropBorderColor(0, 0, 0, 0)
	self:SetBackdropColor(0, 0, 0, 0)

	self.textura:SetBlendMode("BLEND")

	self.showing_allspells = false
	self:SetScript("OnUpdate", nil)

	local lefttext = self.lineText1
	if (lefttext.untruncated) then
		lefttext.untruncated = nil
		Details.left_anti_truncate:Hide()
	end

	self.iconHighlight:Hide()
end

local lineScript_Onmousedown = function(self, button)
	if (self.fading_in) then
		return
	end

	local lefttext = self.lineText1
	if (lefttext.untruncated) then
		lefttext.untruncated = nil
		Details.left_anti_truncate:Hide()
	end

	if (button == "RightButton") then
		return Details.switch:ShowMe(self._instance)

	elseif (button == "LeftButton") then

	end

	self._instance:HandleTextsOnMouseClick (self, "down")

	self.mouse_down = GetTime()
	self.button = button
	local x, y = _GetCursorPosition()
	self.x = floor(x)
	self.y = floor(y)

	if (not self._instance.baseframe.isLocked) then
		GameCooltip:Hide()
		move_janela(self._instance.baseframe, true, self._instance)
	end
end

local lineScript_Onmouseup = function(self, button)
	local bIsShiftDown = _IsShiftKeyDown()
	local bIsControlDown = _IsControlKeyDown()

	---@type instance
	local instanceObject = self._instance

	if (instanceObject.baseframe.isMoving) then
		move_janela(instanceObject.baseframe, false, instanceObject)
		instanceObject:SaveMainWindowPosition()

		if (instanceObject:MontaTooltip(self, self.row_id)) then
			GameCooltip:Show (self, 1)
		end
	end

	instanceObject:HandleTextsOnMouseClick (self, "up")

	local x, y = _GetCursorPosition()
	x = floor(x)
	y = floor(y)

	if (self.mouse_down and (self.mouse_down+0.4 > GetTime() and (x == self.x and y == self.y)) or (x == self.x and y == self.y)) then
		if (self.button == "LeftButton" or self.button == "MiddleButton") then
            --Temporary disabling of Resource breakdowns since not implemented
			if (instanceObject.atributo == 5 or instanceObject.atributo == 3 or bIsShiftDown) then
				--report
				if (instanceObject.atributo == 5 and bIsShiftDown) then
					local custom = instanceObject:GetCustomObject()
					if (custom and custom.on_shift_click) then
						local func = loadstring(custom.on_shift_click)
						if (func) then
							local successful, errortext = pcall(func, self, self.minha_tabela, instanceObject)
							if (not successful) then
								Details:Msg("error occurred custom script shift+click:", errortext)
							end
							return
						end
					end
				end

				--if there's a function to overwrite the default behavior
				if (Details.row_singleclick_overwrite[instanceObject.atributo] and type(Details.row_singleclick_overwrite[instanceObject.atributo][instanceObject.sub_atributo]) == "function") then
					return Details.row_singleclick_overwrite[instanceObject.atributo][instanceObject.sub_atributo](_, self.minha_tabela, instanceObject, bIsShiftDown, bIsControlDown)
				end

				return Details:ReportSingleLine(instanceObject, self)
			end

			if (not self.minha_tabela) then
				return Details:Msg("this bar is waiting update.")
			end

			Details:OpenBreakdownWindow(instanceObject, self.minha_tabela, nil, nil, bIsShiftDown, bIsControlDown)
		end
	end
end

local lineScript_Onclick = function(self, button)

end

local lineScript_Onshow = function(self)
	--search key: ~model
	if (self.using_upper_3dmodels) then
		self.modelbox_high:SetModel(self._instance.row_info.models.upper_model)
		self.modelbox_high:SetAlpha(self._instance.row_info.models.upper_alpha)
	end

	if (self.using_lower_3dmodels) then
		self.modelbox_low:SetModel(self._instance.row_info.models.lower_model)
		self.modelbox_low:SetAlpha(self._instance.row_info.models.lower_alpha)
	end
end

function Details:HandleTextsOnMouseClick(row, type)
	if (self.bars_inverted) then
		if (type == "down") then
			row.lineText4:SetPoint("left", row.statusbar, "left", self.fontstrings_text4_anchor + 2, self.row_info.text_yoffset - 1)

			if (self.row_info.no_icon) then
				row.lineText1:SetPoint("right", row.statusbar, "right", -self.row_info.textL_offset - 1, self.row_info.text_yoffset - 1)
			else
				row.lineText1:SetPoint("right", row.icone_classe, "left", -self.row_info.textL_offset - 1, self.row_info.text_yoffset - 1)
			end

		elseif (type == "up") then
			row.lineText4:SetPoint("left", row.statusbar, "left", self.fontstrings_text4_anchor + 1, self.row_info.text_yoffset)

			if (self.row_info.no_icon) then
				row.lineText1:SetPoint("right", row.statusbar, "right", -self.row_info.textL_offset - 2, self.row_info.text_yoffset)
			else
				row.lineText1:SetPoint("right", row.icone_classe, "left", -self.row_info.textL_offset - 2, self.row_info.text_yoffset)
			end
		end

	else
		if (type == "down") then
			row.lineText4:SetPoint("right", row.statusbar, "right", -self.fontstrings_text4_anchor + 1, self.row_info.text_yoffset - 1)
			if (self.row_info.no_icon) then
				row.lineText1:SetPoint("left", row.statusbar, "left", self.row_info.textL_offset + 3, self.row_info.text_yoffset - 1)
			else
				row.lineText1:SetPoint("left", row.icone_classe, "right", self.row_info.textL_offset + 4, self.row_info.text_yoffset - 1)
			end

		elseif (type == "up") then
			row.lineText4:SetPoint("right", row.statusbar, "right", -self.fontstrings_text4_anchor, self.row_info.text_yoffset)
			if (self.row_info.no_icon) then
				row.lineText1:SetPoint("left", row.statusbar, "left", self.row_info.textL_offset + 2, self.row_info.text_yoffset)
			else
				row.lineText1:SetPoint("left", row.icone_classe, "right", self.row_info.textL_offset + 3, self.row_info.text_yoffset)
			end
		end
	end
end

local setBarValue = function(self, value)
	value = Clamp(value, 0, 100)
	self.statusbar:SetValue(value)
	self.statusbar.value = value
	if (self.using_upper_3dmodels) then
		local width = self:GetWidth()
		local p = (width / 100) * value
		self.modelbox_high:SetPoint("bottomright", self, "bottomright", p - width, 0)
	end
end

-- ~talent ~icon
--code for when hovering over the class/spec icon in the player bar
local iconFrame_OnEnter = function(self)
	local actor = self.row.minha_tabela
	if (actor) then
		if (actor.frags) then

		elseif (actor.is_custom or actor.byspell or actor.damage_spellid) then
			local spellid = actor.damage_spellid or actor.id or actor[1]
			if (spellid) then
				GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 10)
				Details:GameTooltipSetSpellByID(spellid)
				GameTooltip:Show()
			end

		elseif (actor.dead_at) then


		elseif (actor.nome) then --ensure it's an actor table
			local serial = actor.serial
			local name = actor:name()
			local class = actor:class()
			local spec = Details.cached_specs[serial] or actor.spec
			local talents = Details.cached_talents[serial]
			local ilvl = Details.ilevel:GetIlvl(serial)

			local iconSize = 20
			local instance = Details:GetInstance(self.row.instance_id)

			instance:BuildInstanceBarTooltip(self)

			local bIsClassic = (DetailsFramework.IsClassicWow() or DetailsFramework.IsTBCWow() or DetailsFramework.IsWotLKWow() or DetailsFramework.IsCataWow() or DetailsFramework.IsPandaWow())

			local classIcon, classL, classR, classT, classB = Details:GetClassIcon(class)

			local specId, specName, specDescription, specIcon, specRole, specClass = DetailsFramework.GetSpecializationInfoByID(spec or 0) --thanks pas06
			local specL, specR, specT, specB
			if (specId) then
				if (Details.class_specs_coords[specId]) then
					specL, specR, specT, specB = unpack(Details.class_specs_coords[specId])
				end
			end

			if (instance.row_info.textL_translit_text) then
				--translate cyrillic alphabet to western alphabet by Vardex (https://github.com/Vardex May 22, 2019)
				local Translit = LibStub("LibTranslit-1.0")
				GameCooltip:AddLine(Translit:Transliterate(name, "!"), specName)
			else
				GameCooltip:AddLine(name, specName)
			end

			if (class == "UNKNOW" or class == "UNGROUPPLAYER") then
				GameCooltip:AddIcon([[Interface\AddOns\Details\images\classes_small_alpha]], 1, 1, iconSize, iconSize, 0, 0.25, 0.75, 1)
			else
				GameCooltip:AddIcon([[Interface\AddOns\Details\images\classes_small_alpha]], 1, 1, iconSize, iconSize, classL, classR, classT, classB)
			end

			if (specL) then
				GameCooltip:AddIcon([[Interface\AddOns\Details\images\spec_icons_normal_alpha]], 1, 2, iconSize, iconSize, specL, specR, specT, specB)
			else
				GameCooltip:AddIcon([[Interface\GossipFrame\IncompleteQuestIcon]], 1, 2, iconSize, iconSize)
			end
			Details:AddTooltipHeaderStatusbar()

			local talentString = ""

			if (type(talents) == "table") then
				if (talents and not bIsClassic) then
					for i = 1, #talents do
						local talentID, talentName, texture, selected, available = GetTalentInfoByID(talents[i])
						if (texture) then
							talentString = talentString ..  " |T" .. texture .. ":" .. 24 .. ":" .. 24 ..":0:0:64:64:4:60:4:60|t"
						end
					end
				end
			end

			local gotInfo
			local localizedItemLevelString = _G.STAT_AVERAGE_ITEM_LEVEL
			if (ilvl) then
				GameCooltip:AddLine(localizedItemLevelString .. ":" , ilvl and "|T:" .. 24 .. ":" .. 24 ..":0:0:64:64:4:60:4:60|t" .. floor(ilvl.ilvl) or "|T:" .. 24 .. ":" .. 24 ..":0:0:64:64:4:60:4:60|t ??") --Loc from GlobalStrings.lua
				GameCooltip:AddIcon([[]], 1, 1, 1, 20)
				Details:AddTooltipBackgroundStatusbar()
				gotInfo = true
			else
				GameCooltip:AddLine(localizedItemLevelString .. ":" , 0)
				GameCooltip:AddIcon([[]], 1, 1, 1, 20)
				Details:AddTooltipBackgroundStatusbar()
				gotInfo = true
			end

			local localizedTalentsString = _G.TALENTS

			if (talentString ~= "") then
				GameCooltip:AddLine(localizedTalentsString .. ":", talentString)
				GameCooltip:AddIcon([[]], 1, 1, 1, 24)
				Details:AddTooltipBackgroundStatusbar()
				gotInfo = true

			elseif (gotInfo) then
				GameCooltip:AddLine(localizedTalentsString .. ":", Loc["STRING_QUERY_INSPECT_REFRESH"])
				GameCooltip:AddIcon([[]], 1, 1, 1, 24)
				Details:AddTooltipBackgroundStatusbar()
			end

			local height = 66
			if (not gotInfo) then
				GameCooltip:AddLine(Loc["STRING_QUERY_INSPECT"], nil, 1, "orange")
				GameCooltip:AddIcon([[Interface\TUTORIALFRAME\UI-TUTORIAL-FRAME]], 1, 1, 12, iconSize, 8/512, 70/512, 224/512, 306/512)
				height = 54
			end

			local combat = instance:GetShowingCombat()
			local diff, diffEngName = combat:GetDifficulty()
			local attribute, subattribute = instance:GetDisplay()

			--check if is a raid encounter and if is heroic or mythic
			if (diff and (diff == 15 or diff == 16) and (attribute == 1 or attribute == 2)) then --might give errors
				local db = Details.OpenStorage()
				if (db) then
					---@type details_storage_unitresult, details_encounterkillinfo
					local bestRank, encounterTable = Details222.storage.GetBestFromPlayer(diffEngName, combat:GetBossInfo().id, attribute == 1 and "DAMAGER" or "HEALER", name, true)
					if (bestRank) then
						--discover which are the player position in the guild rank
						local rankPosition = Details222.storage.GetUnitGuildRank(diffEngName, combat:GetBossInfo().id, attribute == 1 and "DAMAGER" or "HEALER", name, true)

						GameCooltip:AddLine("Best Score:", Details:ToK2((bestRank.total or 0) / encounterTable.elapsed) .. " [|cFFFFFF00Rank: " .. (rankPosition or "#") .. "|r]", 1, "white")
						Details:AddTooltipBackgroundStatusbar()

						GameCooltip:AddLine("|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:12:0:1:512:512:8:70:224:306|t Open Rank", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:12:0:1:512:512:8:70:328:409|t Refresh Talents", 1, "white", "white")
						Details:AddTooltipBackgroundStatusbar()

						if (not gotInfo) then
							height = height + 25
						else
							height = height + 31
						end
					end
				end
			end

			local actorName = actor:GetName()
			local RaiderIO = _G.RaiderIO

			local lineHeight = 21

			if (RaiderIO and not bIsClassic) then
				local addedInfo = false

				local playerName, playerRealm = actorName:match("(%w+)%-(%w+)")
				playerName = playerName or actorName
				playerRealm = playerRealm or GetRealmName()
				local faction = actor.enemy and Details.faction_against or UnitFactionGroup("player")
				faction = faction == "Horde" and 2 or 1

				local rioProfile = RaiderIO.GetProfile(playerName, playerRealm, faction)

				if (rioProfile and rioProfile.mythicKeystoneProfile) then
					rioProfile = rioProfile.mythicKeystoneProfile

					local previousScore = rioProfile.previousScore or 0
					local currentScore = rioProfile.currentScore or 0

					if (false and previousScore > currentScore and time() > 1700562401) then --2023.11.21 midday
						GameCooltip:AddLine("M+ Score:", previousScore .. " (|cFFFFDD11" .. currentScore .. "|r)", 1, "white")
						addedInfo = true
					else
						GameCooltip:AddLine("M+ Score:", currentScore, 1, "white")
						addedInfo = true
					end
				else
					local dungeonPlayerInfo = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(actorName)
					if (dungeonPlayerInfo) then
						local currentScore = dungeonPlayerInfo.currentSeasonScore or 0
						if (currentScore > 0) then
							GameCooltip:AddLine("M+ Score:", currentScore, 1, "white")
							addedInfo = true
						end
					end
				end

				if (addedInfo) then
					GameCooltip:AddIcon([[]], 1, 1, 1, 20)
					Details:AddTooltipBackgroundStatusbar()
					--increase frame height
					height = height + lineHeight
				end
			else
				if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and C_PlayerInfo) then --is retail?
					local dungeonPlayerInfo = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(actorName)
					if (dungeonPlayerInfo) then
						local currentScore = dungeonPlayerInfo.currentSeasonScore or 0
						if (currentScore > 0) then
							GameCooltip:AddLine("M+ Score:", currentScore, 1, "white")
							GameCooltip:AddIcon([[]], 1, 1, 1, 20)
							Details:AddTooltipBackgroundStatusbar()
							--increase frame height
							height = height + lineHeight
						end
					end
				end
			end

			if (actor.spec == 1473 and actor.tipo == DETAILS_ATTRIBUTE_DAMAGE) then
				local damageDone = math.floor(actor.total + actor.total_extra)
				GameCooltip:AddLine("Evoker Predicted Damage:", Details:Format(damageDone) .. " (" .. Details:Format(damageDone / Details:GetCurrentCombat():GetCombatTime()) .. ")", 1, "white")
				GameCooltip:AddIcon([[]], 1, 1, 1, 20)
				Details:AddTooltipBackgroundStatusbar()
				height = height + lineHeight
			end

			if (actor.classe == "UNKNOW") then
				local npcId = tonumber(actor.aID)
				if (not npcId) then
					npcId = Details:GetNpcIdFromGuid(actor.serial)
				end

				if (npcId) then
					GameCooltip:AddLine("NpcID:", npcId)
					GameCooltip:AddIcon([[]], 1, 1, 1, 20)
					Details:AddTooltipBackgroundStatusbar()
					height = height + lineHeight
				end
			end

			GameCooltip:SetOption("StatusBarTexture", [[Interface\AddOns\Details\images\bar_skyline]])
			GameCooltip:SetOption("FixedHeight", height+11)
			GameCooltip:SetOption("LineHeightSizeOffset", -8)
			Details:AddRoundedCornerToTooltip()
			GameCooltip:ShowCooltip()

			self.unitname = name
			self.showing = "actor"
		end
	end
end

local iconFrame_OnLeave = function(self)
	GameCooltip:Hide()

	if (GameTooltip and GameTooltip:IsShown()) then
		GameTooltip:Hide()
	end

	if (self.row.icone_classe:GetTexture() ~= "") then
		--self.row.icone_classe:SetSize(self.row.icone_classe:GetWidth()-1, self.row.icone_classe:GetWidth()-1)
		--self.row.icone_classe:SetBlendMode("BLEND")
	end

	self.row.iconHighlight:Hide()
end

local icon_frame_events = Details:CreateEventListener()
function icon_frame_events:EnterCombat()
	for anim, _ in pairs(Details.icon_animations.load.in_use) do
		anim.anim:Stop()
		anim:Hide()
		table.insert(Details.icon_animations.load.available, anim)

		anim.icon_frame.icon_animation = nil
		anim.icon_frame = nil
	end
	Details:Destroy(Details.icon_animations.load.in_use)
end

icon_frame_events:RegisterEvent("COMBAT_PLAYER_ENTER", "EnterCombat")

function icon_frame_events:CancelAnim(anim)
	local frame, timeout = unpack(anim)

	if (Details.icon_animations.load.in_use[frame]) then
		if (timeout) then
			if (not frame.question_icon) then
				frame.question_icon = frame.parent:GetParent():GetParent().border:CreateTexture(nil, "overlay")
				frame.question_icon:SetTexture([[Interface\GossipFrame\ActiveLegendaryQuestIcon]])
				frame.question_icon:SetSize(16, 16)
			end
			frame.question_icon:Show()
			frame.question_icon:SetPoint("center", frame.parent, "center")

			if (not Details.HideBarQuestionIcon) then
				function Details:HideBarQuestionIcon(frame)
					frame.question_icon:Hide()
				end
			end
			Details:ScheduleTimer("HideBarQuestionIcon", 2, frame)
		end

		Details.icon_animations.load.in_use[frame] = nil
		table.insert(Details.icon_animations.load.available, frame)
		frame.anim:Stop()
		frame:Hide()

		frame.icon_frame.icon_animation = nil
		frame.icon_frame = nil
	end
end

local icon_frame_inspect_callback = function(guid, unitid, iconFrame)
	if (iconFrame.icon_animation) then
		iconFrame.icon_animation.anim:Stop()
		iconFrame.icon_animation:Hide()
	end

	local inUse = Details.icon_animations.load.in_use[iconFrame.icon_animation]
	if (inUse) then
		table.insert(Details.icon_animations.load.available, iconFrame.icon_animation)
		Details.icon_animations.load.in_use[iconFrame.icon_animation] = nil
	end

	if (iconFrame:IsMouseOver()) then
		iconFrame_OnEnter(iconFrame)
	end

	if (iconFrame.icon_animation) then
		iconFrame.icon_animation.icon_frame = nil
		iconFrame.icon_animation = nil
	end
end

local icon_frame_create_animation = function()
	local f = CreateFrame("frame", nil, UIParent)
	f:SetFrameStrata("FULLSCREEN")
	f.anim = f:CreateAnimationGroup()
	f.rotate = f.anim:CreateAnimation("Rotation")
	f.rotate:SetDegrees(360)
	f.rotate:SetDuration(2)
	f.anim:SetLooping ("repeat")

	local t = f:CreateTexture(nil, "overlay")
	t:SetTexture([[Interface\COMMON\StreamCircle]])
	t:SetAlpha(0.7)
	t:SetAllPoints()

	table.insert(Details.icon_animations.load.available, f)
end

local icon_frame_on_click_down = function(self)
	local instanceID = self.instance_id
	local instanceObject = Details:GetInstance(instanceID)
	self:GetParent():GetParent().icone_classe:SetPoint("left", self:GetParent():GetParent(), "left", instanceObject.row_info.icon_offset[1] + 1, instanceObject.row_info.icon_offset[2] + -1)
end

local icon_frame_on_click_up = function(self, button)

	local instanceID = self.instance_id
	local instanceObject = Details:GetInstance(instanceID)
	self:GetParent():GetParent().icone_classe:SetPoint("left", self:GetParent():GetParent(), "left", instanceObject.row_info.icon_offset[1], instanceObject.row_info.icon_offset[2])

	if (button == "LeftButton") then
		--open the rank panel
		local instance = Details:GetInstance(self.row.instance_id)
		if (instance) then
			local attribute, subattribute = instance:GetDisplay()
			local combat = instance:GetShowingCombat()
			local diff, diffName = combat:GetDifficulty()
			local bossInfo = combat:GetBossInfo()

			if ((attribute == 1 or attribute == 2) and bossInfo) then --if bossInfo is nil, means the combat isn't a boss
				local db = Details.OpenStorage()
				if (db and bossInfo.id) then
					local haveData = Details222.storage.HaveDataForEncounter (diffName, bossInfo.id, true) --attempt to index local 'bossInfo' (a nil value)
					if (haveData) then
						Details:OpenRaidHistoryWindow (bossInfo.zone, bossInfo.id, diff, attribute == 1 and "damage" or "healing", true, 1, false, 2)
					end
				end
			end
		end
		return
	end

	if (Details.in_combat) then
		Details:Msg(Loc["STRING_QUERY_INSPECT_FAIL1"])
		return
	end

	if (self.showing == "actor") then

		if (Details.ilevel.core:HasQueuedInspec (self.unitname)) then

			--icon animation
			local anim = table.remove(Details.icon_animations.load.available)
			if (not anim) then
				icon_frame_create_animation()
				anim = table.remove(Details.icon_animations.load.available)
			end

			local f = anim
			if (not f.question_icon) then
				f.question_icon = self:GetParent():GetParent().border:CreateTexture(nil, "overlay")
				f.question_icon:SetTexture([[Interface\GossipFrame\ActiveLegendaryQuestIcon]])
				f.question_icon:SetSize(16, 16)
			end

			f.question_icon:ClearAllPoints()
			f.question_icon:SetPoint("center", self, "center")
			f.question_icon:Show()

			if (not Details.HideBarQuestionIcon) then
				function Details:HideBarQuestionIcon (frame)
					frame.question_icon:Hide()
				end
			end
			Details:ScheduleTimer("HideBarQuestionIcon", 1, f)

			self.icon_animation = anim
			anim.icon_frame = self

			local pid
			pid = icon_frame_events:ScheduleTimer("CancelAnim", 1, {anim})
			Details.icon_animations.load.in_use [anim] = pid
			anim.parent = self

			return
		end

		local does_query = Details.ilevel.core:QueryInspect (self.unitname, icon_frame_inspect_callback, self)

		if (self.icon_animation) then
			return
		end

		--icon animation
		local anim = table.remove(Details.icon_animations.load.available)
		if (not anim) then
			icon_frame_create_animation()
			anim = table.remove(Details.icon_animations.load.available)
		end

		anim:Show()
		anim:SetParent(self)
		anim:ClearAllPoints()
		anim:SetFrameStrata("TOOLTIP")
		anim:SetPoint("center", self, "center")
		anim:SetSize(self:GetWidth()*1.7, self:GetHeight()*1.7)

		anim.anim:Play()

		self.icon_animation = anim
		anim.icon_frame = self

		local pid
		if (does_query) then
			pid = icon_frame_events:ScheduleTimer("CancelAnim", 4, {anim, true})
		else
			pid = icon_frame_events:ScheduleTimer("CancelAnim", 0.2, {anim})
		end
		Details.icon_animations.load.in_use [anim] = pid
		anim.parent = self

		if (anim.question_icon) then
			anim.question_icon:Hide()
		end
	end
end

local setFrameIconScripts = function(row)
	row.icon_frame:SetScript("OnEnter", iconFrame_OnEnter)
	row.icon_frame:SetScript("OnLeave", iconFrame_OnLeave)
	row.icon_frame:SetScript("OnMouseDown", icon_frame_on_click_down)
	row.icon_frame:SetScript("OnMouseUp", icon_frame_on_click_up)
end

local setLineScripts = function(line, instance, index)
	line._instance = instance

	line:SetScript("OnEnter", lineScript_Onenter)
	line:SetScript("OnLeave", lineScript_Onleave)
	line:SetScript("OnMouseDown", lineScript_Onmousedown)
	line:SetScript("OnMouseUp", lineScript_Onmouseup)
	line:SetScript("OnClick", lineScript_Onclick)
	line:SetScript("OnShow", lineScript_Onshow)

	setFrameIconScripts(line)

	line.SetValue = setBarValue
end

function Details:ReportSingleLine(instance, windowLine)
	local reportar
	local displayId = instance:GetDisplay()
	if (displayId == 5) then --custom
		--dump cooltip
		local GameCooltip = GameCooltip
		if (GameCooltipFrame1:IsShown()) then
			local actor_name = windowLine.lineText1:GetText() or ""
			actor_name = actor_name:gsub((".*%."), "")

			if (instance.segmento == -1) then --overall
				reportar = {"Details!: "  .. Loc["STRING_OVERALL"] .. " " .. instance.customName .. ": " .. actor_name .. " " .. Loc["STRING_CUSTOM_REPORT"]}
			else
				reportar = {"Details!: " .. instance.customName .. ": " .. actor_name .. " " .. Loc["STRING_CUSTOM_REPORT"]}
			end

			local amt = GameCooltip.Indexes
			for i = 2, amt do
				local left_text, right_text = GameCooltip:GetText (i)
				reportar [#reportar+1] = (i-1) .. ". " .. left_text .. " ... " .. right_text
			end
		else
			reportar = {"Details!: " .. instance.customName .. ": " .. Loc["STRING_CUSTOM_REPORT"]}
			reportar [#reportar+1] = windowLine.lineText1:GetText() .. " " .. windowLine.lineText4:GetText()

			--reportar [#reportar+1] = (i-1) .. ". " .. left_text .. " ... " .. right_text
		end

	else
		reportar = {"Details!: " .. Loc["STRING_REPORT"] .. " " .. Details.sub_atributos [displayId].lista [instance.sub_atributo]}
		reportar [#reportar+1] = windowLine.lineText1:GetText() .. " " .. windowLine.lineText4:GetText()
	end

	return Details:Reportar(reportar, {_no_current = true, _no_inverse = true, _custom = true})
end

-- ~stretch
local function button_stretch_scripts(baseframe, backgrounddisplay, instancia)
	local button = baseframe.button_stretch

	button:SetScript("OnEnter", function(self)
		self.mouse_over = true
		if (not Details.disable_stretch_button) then
			Details.FadeHandler.Fader(self, "ALPHA", 1)
		end
	end)

	button:SetScript("OnLeave", function(self)
		self.mouse_over = false
		Details.FadeHandler.Fader(self, "ALPHA", 0)
	end)

	button:SetScript("OnMouseDown", function(self, button)
		if (button ~= "LeftButton") then
			return
		end

		if (instancia:IsSoloMode()) then
			return
		end

		instancia:EsconderScrollBar(true)
		baseframe._place = instancia:SaveMainWindowPosition()
		baseframe.isResizing = true
		baseframe.isStretching = true
		baseframe:SetFrameStrata("TOOLTIP")
		instancia.rowframe:SetFrameStrata("TOOLTIP")

		local _r, _g, _b, _a = baseframe:GetBackdropColor()

		gump:GradientEffect ( baseframe, "frame", _r, _g, _b, _a, _r, _g, _b, 0.9, 1.5)
		if (instancia.wallpaper.enabled) then
			_r, _g, _b = baseframe.wallpaper:GetVertexColor()
			_a = baseframe.wallpaper:GetAlpha()
			gump:GradientEffect (baseframe.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, 0.05, 0.5)
		end

		if (instancia.stretch_button_side == 1) then
			baseframe:StartSizing("top")
			baseframe.stretch_direction = "top"

		elseif (instancia.stretch_button_side == 2) then
			baseframe:StartSizing("bottom")
			baseframe.stretch_direction = "bottom"
		end

		---@type instance[]
		local linha_horizontal = {}
		local checking = instancia
		for i = instancia.meu_id-1, 1, -1 do
			local esta_instancia = Details:GetAllInstances() [i]
			if ((esta_instancia.snap[1] and esta_instancia.snap[1] == checking.meu_id) or (esta_instancia.snap[3] and esta_instancia.snap[3] == checking.meu_id)) then
				linha_horizontal [#linha_horizontal+1] = esta_instancia
				checking = esta_instancia
			else
				break
			end
		end

		checking = instancia
		for i = instancia.meu_id+1, #Details:GetAllInstances() do
			local esta_instancia = Details:GetAllInstances() [i]
			if ((esta_instancia.snap[1] and esta_instancia.snap[1] == checking.meu_id) or (esta_instancia.snap[3] and esta_instancia.snap[3] == checking.meu_id)) then
				linha_horizontal [#linha_horizontal+1] = esta_instancia
				checking = esta_instancia
			else
				break
			end
		end

		instancia.stretchToo = linha_horizontal
		if (#instancia.stretchToo > 0) then
			for _, thisInstance in ipairs(instancia.stretchToo) do
				thisInstance:EsconderScrollBar(true)
				thisInstance.baseframe._place = thisInstance:SaveMainWindowPosition()
				thisInstance.baseframe.isResizing = true
				thisInstance.baseframe.isStretching = true
				thisInstance.baseframe:SetFrameStrata("TOOLTIP")
				thisInstance.rowframe:SetFrameStrata("TOOLTIP")

				local _r, _g, _b, _a = thisInstance.baseframe:GetBackdropColor()
				gump:GradientEffect(thisInstance.baseframe, "frame", _r, _g, _b, _a, _r, _g, _b, 0.9, 1.5)
				Details:SendEvent("DETAILS_INSTANCE_STARTSTRETCH", nil, thisInstance)

				if (thisInstance.wallpaper.enabled) then
					_r, _g, _b = thisInstance.baseframe.wallpaper:GetVertexColor()
					_a = thisInstance.baseframe.wallpaper:GetAlpha()
					gump:GradientEffect(thisInstance.baseframe.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, 0.05, 0.5)
				end
			end
		end

		Details:SnapTextures (true)

		Details:SendEvent("DETAILS_INSTANCE_STARTSTRETCH", nil, instancia)

		--change the update speed
		if (Details.update_speed > 0.3) then
			Details:SetWindowUpdateSpeed(0.3, true)
			Details.stretch_changed_update_speed = true
		end
	end)

	button:SetScript("OnMouseUp", function(self, button)
		if (button ~= "LeftButton") then
			return
		end

		if (instancia:IsSoloMode()) then
			return
		end

		if (baseframe.isResizing) then
			baseframe:StopMovingOrSizing()
			baseframe.isResizing = false
			instancia:RestoreMainWindowPosition (baseframe._place)
			instancia:ReajustaGump()
			baseframe.isStretching = false
			if (instancia.need_rolagem) then
				instancia:MostrarScrollBar (true)
			end
			Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, instancia)

			instancia:RefreshBars()
			instancia:InstanceReset()
			instancia:ReajustaGump()

			baseframe.stretch_direction = nil

			if (instancia.stretchToo and #instancia.stretchToo > 0) then
				for _, thisInstance in ipairs(instancia.stretchToo) do
					thisInstance.baseframe:StopMovingOrSizing()
					thisInstance.baseframe.isResizing = false
					thisInstance:RestoreMainWindowPosition (thisInstance.baseframe._place)
					thisInstance:ReajustaGump()
					thisInstance.baseframe.isStretching = false
					if (thisInstance.need_rolagem) then
						thisInstance:MostrarScrollBar(true)
					end
					Details:SendEvent("DETAILS_INSTANCE_SIZECHANGED", nil, thisInstance)

					local _r, _g, _b, _a = thisInstance.baseframe:GetBackdropColor()
					gump:GradientEffect(thisInstance.baseframe, "frame", _r, _g, _b, _a, instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha, 0.5)

					if (thisInstance.wallpaper.enabled) then
						_r, _g, _b = thisInstance.baseframe.wallpaper:GetVertexColor()
						_a = thisInstance.baseframe.wallpaper:GetAlpha()
						gump:GradientEffect(thisInstance.baseframe.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, thisInstance.wallpaper.alpha, 1.0)
					end

					thisInstance.baseframe:SetFrameStrata(thisInstance.strata)
					thisInstance.rowframe:SetFrameStrata(thisInstance.strata)
					thisInstance:StretchButtonAlwaysOnTop()

					Details:SendEvent("DETAILS_INSTANCE_ENDSTRETCH", nil, thisInstance.baseframe)

					thisInstance:RefreshBars()
					thisInstance:InstanceReset()
					thisInstance:ReajustaGump()
				end
				instancia.stretchToo = nil
			end

		end

		local _r, _g, _b, _a = baseframe:GetBackdropColor()
		gump:GradientEffect(baseframe, "frame", _r, _g, _b, _a, instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha, 0.5)
		if (instancia.wallpaper.enabled) then
			_r, _g, _b = baseframe.wallpaper:GetVertexColor()
			_a = baseframe.wallpaper:GetAlpha()
			gump:GradientEffect(baseframe.wallpaper, "texture", _r, _g, _b, _a, _r, _g, _b, instancia.wallpaper.alpha, 1.0)
		end

		baseframe:SetFrameStrata(instancia.strata)
		instancia.rowframe:SetFrameStrata(instancia.strata)
		instancia:StretchButtonAlwaysOnTop()
		Details:SnapTextures (false)
		Details:SendEvent("DETAILS_INSTANCE_ENDSTRETCH", nil, instancia)

		if (Details.stretch_changed_update_speed) then
			Details:SetWindowUpdateSpeed(false, true)
			Details.stretch_changed_update_speed = nil
		end
	end)
	baseframe.row_tilesize = defaultBackdropSt.tileSize
end

local function button_down_scripts (mainFrame, backgrounddisplay, instancia, scrollbar)
	mainFrame.button_down:SetScript("OnMouseDown", function(self)
		if (not scrollbar:IsEnabled()) then
			return
		end

		local B = instancia.barraS[2]
		if (B < instancia.rows_showing) then
			scrollbar:SetValue(scrollbar:GetValue() + instancia.row_height)
		end

		self.precionado = true
		self.last_up = -0.3

		self:SetScript("OnUpdate", function(self, elapsed)
			self.last_up = self.last_up + elapsed
			if (self.last_up > 0.03) then
				self.last_up = 0
				B = instancia.barraS[2]
				if (B < instancia.rows_showing) then
					scrollbar:SetValue(scrollbar:GetValue() + instancia.row_height)
				else
					self:Disable()
				end
			end
		end)
	end)

	mainFrame.button_down:SetScript("OnMouseUp", function(self)
		self.precionado = false
		self:SetScript("OnUpdate", nil)
	end)
end

local function button_up_scripts(mainFrame, backgrounddisplay, instancia, scrollbar)
	mainFrame.button_up:SetScript("OnMouseDown", function(self)
		if (not scrollbar:IsEnabled()) then
			return
		end

		local A = instancia.barraS[1]
		if (A > 1) then
			scrollbar:SetValue(scrollbar:GetValue() - instancia.row_height*2)
		end

		self.precionado = true
		self.last_up = -0.3
		self:SetScript("OnUpdate", function(self, elapsed)
			self.last_up = self.last_up + elapsed
			if (self.last_up > 0.03) then
				self.last_up = 0
				A = instancia.barraS[1]
				if (A > 1) then
					scrollbar:SetValue(scrollbar:GetValue() + instancia.row_height*2)
				else
					self:Disable()
				end
			end
		end)
	end)

	mainFrame.button_up:SetScript("OnMouseUp", function(self)
		self.precionado = false
		self:SetScript("OnUpdate", nil)
	end)

	mainFrame.button_up:SetScript("OnEnable", function(self)
		local current = scrollbar:GetValue()
		if (current == 0) then
			mainFrame.button_up:Disable()
		end
	end)
end

function DetailsKeyBindScrollUp() --[[GLOBAL]]
	local last_key_pressed = Details.KeyBindScrollUpLastPressed or GetTime()-0.3

	local to_top = false
	if (last_key_pressed+0.2 > GetTime()) then
		to_top = true
	end

	Details.KeyBindScrollUpLastPressed = GetTime()

	for index, instance in ipairs(Details:GetAllInstances()) do
		if (instance:IsEnabled()) then
			local scrollbar = instance.scroll

			local A = instance.barraS[1]
			if (A and A > 1) then
				if (to_top) then
					scrollbar:SetValue(0)
					scrollbar.ultimo = 0
					instance.baseframe.button_up:Disable()
				else
					scrollbar:SetValue(scrollbar:GetValue() - instance.row_height*2)
				end
			elseif (A) then
				scrollbar:SetValue(0)
				scrollbar.ultimo = 0
				instance.baseframe.button_up:Disable()
			end
		end
	end
end

function DetailsKeyBindScrollDown() --[[GLOBAL]]
	for index, instance in ipairs(Details:GetAllInstances()) do
		if (instance:IsEnabled()) then
			local scrollbar = instance.scroll

			local B = instance.barraS[2]
			if (B and B < instance.rows_showing) then
				scrollbar:SetValue(scrollbar:GetValue() + instance.row_height*2)
			elseif (B) then
				local _, maxValue = scrollbar:GetMinMaxValues()
				scrollbar:SetValue(maxValue)
				scrollbar.ultimo = maxValue
				instance.baseframe.button_down:Disable()
			end
		end
	end
end

local function iterate_scroll_scripts(backgrounddisplay, backgroundframe, baseframe, scrollbar, instancia)
	baseframe:SetScript("OnMouseWheel", function(self, delta)
		if (delta > 0) then --rolou pra cima
			local A = instancia.barraS[1]
			if (A) then
				if (A > 1) then
					scrollbar:SetValue(scrollbar:GetValue() - instancia.row_height * Details.scroll_speed)
				else
					scrollbar:SetValue(0)
					scrollbar.ultimo = 0
					baseframe.button_up:Disable()
				end
			end

		elseif (delta < 0) then --rolou pra baixo
			local B = instancia.barraS[2]
			if (B) then
				if (B < (instancia.rows_showing or 0)) then
					scrollbar:SetValue(scrollbar:GetValue() + instancia.row_height * Details.scroll_speed)
				else
					local _, maxValue = scrollbar:GetMinMaxValues()
					scrollbar:SetValue(maxValue)
					scrollbar.ultimo = maxValue
					baseframe.button_down:Disable()
				end
			end
		end
	end)

	scrollbar:SetScript("OnValueChanged", function(self)
		local ultimo = self.ultimo
		local currentScrollValue = self:GetValue()
		if (ultimo == currentScrollValue) then --nothing changed
			return
		end

		--shortcut
		local minValue, maxValue = scrollbar:GetMinMaxValues()
		if (minValue == currentScrollValue) then
			instancia.barraS[1] = 1
			instancia.barraS[2] = instancia.rows_fit_in_window
			instancia:RefreshMainWindow(instancia, true)
			self.ultimo = currentScrollValue
			baseframe.button_up:Disable()
			return

		elseif (maxValue == currentScrollValue) then
			local min = (instancia.rows_showing or 0) -instancia.rows_fit_in_window
			min = min+1
			if (min < 1) then
				min = 1
			end

			instancia.barraS[1] = min
			instancia.barraS[2] = (instancia.rows_showing or 0)
			instancia:RefreshMainWindow(instancia, true)
			self.ultimo = currentScrollValue
			baseframe.button_down:Disable()
			return
		end

		if (not baseframe.button_up:IsEnabled()) then
			baseframe.button_up:Enable()
		end

		if (not baseframe.button_down:IsEnabled()) then
			baseframe.button_down:Enable()
		end

		if (currentScrollValue > ultimo) then --scroll down
			local B = instancia.barraS[2]
			if (B < (instancia.rows_showing or 0)) then --se o valor maximo n�o for o m�ximo de barras a serem mostradas
				if (true) then --testing by pass row check - test completed, it is working!
					local diff = currentScrollValue - ultimo --pega a diferen�a de H
					diff = diff / instancia.row_height --calcula quantas barras ele pulou
					diff = ceil(diff) --arredonda para cima

					if (instancia.barraS[2]+diff > (instancia.rows_showing or 0) and ultimo > 0) then
						instancia.barraS[1] = (instancia.rows_showing or 0) - (instancia.rows_fit_in_window-1)
						instancia.barraS[2] = (instancia.rows_showing or 0)
					else
						instancia.barraS[2] = instancia.barraS[2]+diff
						instancia.barraS[1] = instancia.barraS[1]+diff
					end
					instancia:RefreshMainWindow(instancia, true)
				end
			end

		else --scroll up
			local A = instancia.barraS[1]
			if (A > 1) then
				if (true) then --testing by pass row check
					--calcula quantas barras passou - test completed, it is working!
					local diff = ultimo - currentScrollValue
					diff = diff / instancia.row_height
					diff = ceil(diff)

					if (instancia.barraS[1]-diff < 1) then
						instancia.barraS[2] = instancia.rows_fit_in_window
						instancia.barraS[1] = 1
					else
						instancia.barraS[2] = instancia.barraS[2]-diff
						instancia.barraS[1] = instancia.barraS[1]-diff
					end

					instancia:RefreshMainWindow(instancia, true)
				end
			end
		end

		self.ultimo = currentScrollValue
	end)
end

function Details:HaveInstanceAlert()
	return self.alert:IsShown()
end

function Details:InstanceAlertTime(instance)
	instance.alert:Hide()
	instance.alert.rotate:Stop()
	instance.alert_time = nil
end

function Details:InstanceAlert(msg, icon, timeInSeconds, clickfunc, doflash, forceAlert)
	if (not forceAlert and Details.streamer_config.no_alerts) then
		--return
	end

	if (not self.meu_id) then
		local lower = Details:GetLowerInstanceNumber()
		if (lower) then
			self = Details:GetInstance(lower)
		else
			return
		end
	end

	if (type(msg) == "boolean" and not msg) then
		self.alert:Hide()
		self.alert.rotate:Stop()
		self.alert_time = nil
		return
	end

	if (msg) then
		self.alert.text:SetText(msg)
	else
		self.alert.text:SetText("")
	end

	if (icon) then
		if (type(icon) == "table") then
			local texture, w, h, animate, left, right, top, bottom, r, g, b, a = unpack(icon)

			self.alert.icon:SetTexture(texture)
			self.alert.icon:SetWidth(w or 14)
			self.alert.icon:SetHeight(h or 14)
			if (left and right and top and bottom) then
				self.alert.icon:SetTexCoord(left, right, top, bottom)
			end
			if (animate) then
				self.alert.rotate:Play()
			end
			if (r and g and b) then
				self.alert.icon:SetVertexColor(r, g, b, a or 1)
			end
		else
			self.alert.icon:SetWidth(14)
			self.alert.icon:SetHeight(14)
			self.alert.icon:SetTexture(icon)
			self.alert.icon:SetVertexColor(1, 1, 1, 1)
			self.alert.icon:SetTexCoord(0, 1, 0, 1)
		end
	else
		self.alert.icon:SetTexture("")
	end

	self.alert.button.func = nil
	Details:Destroy(self.alert.button.func_param)

	if (clickfunc) then
		self.alert.button.func = clickfunc[1]
		self.alert.button.func_param = {unpack(clickfunc, 2)}
	end

	timeInSeconds = timeInSeconds or 15
	self.alert_time = timeInSeconds
	Details:ScheduleTimer("InstanceAlertTime", timeInSeconds, self)

	self.alert:SetPoint("bottom", self.baseframe, "bottom", 0, -12)
	self.alert:SetPoint("left", self.baseframe, "left", 3, 0)
	self.alert:SetPoint("right", self.baseframe, "right", -3, 0)

	self.alert:SetFrameStrata("TOOLTIP")
	self.alert.button:SetFrameStrata("TOOLTIP")

	self.alert:Show()

	if (doflash) then
		self.alert:DoFlash()
	end

	self.alert:Play()
end

local onClickAlertButton = function(self, button)
	if (self.func) then
		local okey, errortext = pcall(self.func, unpack(self.func_param))
		if (not okey) then
			Details:Msg("error on alert function:", errortext)
		end
	end
	self:GetParent():Hide()
end

local function CreateAlertFrame(baseframe, instancia)
	local frameLayerUpper = CreateFrame("scrollframe", "DetailsAlertFrameScroll" .. instancia.meu_id, baseframe)
	frameLayerUpper:SetPoint("bottom", baseframe, "bottom")
	frameLayerUpper:SetPoint("left", baseframe, "left", 3, 0)
	frameLayerUpper:SetPoint("right", baseframe, "right", -3, 0)
	frameLayerUpper:SetHeight(13)
	frameLayerUpper:SetFrameStrata("TOOLTIP")

	local frameLayerLower = CreateFrame("frame", "DetailsAlertFrameScrollChild" .. instancia.meu_id, frameLayerUpper)
	frameLayerLower:SetHeight(25)
	frameLayerLower:SetPoint("left", frameLayerUpper, "left")
	frameLayerLower:SetPoint("right", frameLayerUpper, "right")
	frameLayerUpper:SetScrollChild(frameLayerLower)

	local alertBackgroundFrame = CreateFrame("frame", "DetailsAlertFrame" .. instancia.meu_id, frameLayerLower,"BackdropTemplate")
	alertBackgroundFrame:SetPoint("bottom", baseframe, "bottom")
	alertBackgroundFrame:SetPoint("left", baseframe, "left", 3, 0)
	alertBackgroundFrame:SetPoint("right", baseframe, "right", -3, 0)
	alertBackgroundFrame:SetHeight(12)
	alertBackgroundFrame:SetBackdrop({bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16,
	insets = {left = 0, right = 0, top = 0, bottom = 0}})
	alertBackgroundFrame:SetBackdropColor(.1, .1, .1, 1)
	alertBackgroundFrame:SetFrameStrata("FULLSCREEN")
	alertBackgroundFrame:SetFrameLevel(baseframe:GetFrameLevel() + 6)
	alertBackgroundFrame:Hide()

	local toptexture = alertBackgroundFrame:CreateTexture(nil, "background")
	toptexture:SetTexture([[Interface\Challenges\challenges-main]])
	--toptexture:SetTexCoord(0.1921484375, 0.523671875, 0.234375, 0.160859375)
	toptexture:SetTexCoord(0.231171875, 0.4846484375, 0.0703125, 0.072265625)
	toptexture:SetPoint("left", alertBackgroundFrame, "left")
	toptexture:SetPoint("right", alertBackgroundFrame, "right")
	toptexture:SetPoint("bottom", alertBackgroundFrame, "top", 0, 0)
	toptexture:SetHeight(1)

	local text = alertBackgroundFrame:CreateFontString(nil, "overlay", "GameFontNormal")
	text:SetPoint("right", alertBackgroundFrame, "right", -14, 0)
	Details:SetFontSize(text, 10)
	text:SetTextColor(1, 1, 1, 0.8)

	local rotateAlertFrame = CreateFrame("frame", "DetailsAlertFrameRotate" .. instancia.meu_id, alertBackgroundFrame)
	rotateAlertFrame:SetWidth(12)
	rotateAlertFrame:SetPoint("right", alertBackgroundFrame, "right", -2, 0)
	rotateAlertFrame:SetHeight(alertBackgroundFrame:GetWidth())
	rotateAlertFrame:SetFrameStrata("FULLSCREEN")

	local icon = rotateAlertFrame:CreateTexture(nil, "overlay")
	icon:SetPoint("center", rotateAlertFrame, "center")
	icon:SetWidth(14)
	icon:SetHeight(14)

	local button = CreateFrame("button", "DetailsInstance"..instancia.meu_id.."AlertButton", alertBackgroundFrame)
	button:SetAllPoints()
	button:SetFrameStrata("FULLSCREEN")
	button:SetScript("OnClick", onClickAlertButton)
	button._instance = instancia
	button.func_param = {}

	local rotateAnimGroup = rotateAlertFrame:CreateAnimationGroup()
	local rotate = rotateAnimGroup:CreateAnimation("Rotation")
	rotate:SetDegrees(360)
	rotate:SetDuration(6)
	rotateAnimGroup:SetLooping ("repeat")

	alertBackgroundFrame:Hide()

	local anime = alertBackgroundFrame:CreateAnimationGroup()
	anime.group = anime:CreateAnimation("Translation")
	anime.group:SetDuration(0.15)
	anime.group:SetOffset (0, 10)
	anime:SetScript("OnFinished", function(self)
		alertBackgroundFrame:Show()
		alertBackgroundFrame:SetPoint("bottom", baseframe, "bottom", 0, 0)
		alertBackgroundFrame:SetPoint("left", baseframe, "left", 3, 0)
		alertBackgroundFrame:SetPoint("right", baseframe, "right", -3, 0)
	end)

	local on_enter_alert = function(self)
		text:SetTextColor(1, 0.8, 0.3, 1)
		icon:SetBlendMode("ADD")
	end

	local on_leave_alert = function(self)
		text:SetTextColor(1, 1, 1, 0.8)
		icon:SetBlendMode("BLEND")
	end

	button:SetScript("OnEnter", on_enter_alert)
	button:SetScript("OnLeave", on_leave_alert)

	function alertBackgroundFrame:Play()
		anime:Play()
	end

	local flashTexture = button:CreateTexture(nil, "overlay")
	flashTexture:SetTexCoord(53/512, 347/512, 58/256, 120/256)
	flashTexture:SetTexture([[Interface\AchievementFrame\UI-Achievement-Alert-Glow]])
	flashTexture:SetAllPoints()
	flashTexture:SetBlendMode("ADD")
	local animation = flashTexture:CreateAnimationGroup()
	local anim1 = animation:CreateAnimation("ALPHA")
	local anim2 = animation:CreateAnimation("ALPHA")
	anim1:SetOrder (1)

	anim1:SetFromAlpha (0)
	anim1:SetToAlpha (1)

	anim1:SetDuration(0.1)
	anim2:SetOrder (2)

	anim1:SetFromAlpha (1)
	anim1:SetToAlpha (0)

	anim2:SetDuration(0.2)
	animation:SetScript("OnFinished", function(self)
		flashTexture:Hide()
	end)
	flashTexture:Hide()

	local do_flash = function()
		flashTexture:Show()
		animation:Play()
	end

	function alertBackgroundFrame:DoFlash()
		C_Timer.After(0.23, do_flash)
	end

	alertBackgroundFrame.text = text
	alertBackgroundFrame.icon = icon
	alertBackgroundFrame.button = button
	alertBackgroundFrame.rotate = rotateAnimGroup

	instancia.alert = alertBackgroundFrame

	return alertBackgroundFrame
end

function Details:InstanceMsg(text, icon, textcolor, iconcoords, iconcolor)
	if (not text) then
		self.freeze_icon:Hide()
		return self.freeze_texto:Hide()
	end

	self.freeze_texto:SetText(text)
	self.freeze_icon:SetTexture(icon or [[Interface\CHARACTERFRAME\Disconnect-Icon]])

	self.freeze_icon:Show()
	self.freeze_texto:Show()

	if (textcolor) then
		local r, g, b, a = gump:ParseColors(textcolor)
		self.freeze_texto:SetTextColor(r, g, b, a)
	else
		self.freeze_texto:SetTextColor(1, 1, 1, 1)
	end

	if (iconcoords and type(iconcoords) == "table") then
		self.freeze_icon:SetTexCoord(unpack(iconcoords))
	else
		self.freeze_icon:SetTexCoord(0, 1, 0, 1)
	end

	if (iconcolor) then
		local r, g, b, a = gump:ParseColors(iconcolor)
		self.freeze_icon:SetVertexColor(r, g, b, a)
	else
		self.freeze_icon:SetVertexColor(1, 1, 1, 1)
	end
end

function Details:schedule_hide_anti_overlap(self)
	self:Hide()
	self.schdule = nil
end

local function hide_anti_overlap(self)
	if (self.schdule) then
		Details:CancelTimer(self.schdule)
		self.schdule = nil
	end

	local schdule = Details:ScheduleTimer("schedule_hide_anti_overlap", 0.3, self)
	self.schdule = schdule
end

local function show_anti_overlap(instance, host, side)
	local anti_menu_overlap = instance.baseframe.anti_menu_overlap

	if (anti_menu_overlap.schdule) then
		Details:CancelTimer(anti_menu_overlap.schdule)
		anti_menu_overlap.schdule = nil
	end

	anti_menu_overlap:ClearAllPoints()

	if (side == "top") then
		anti_menu_overlap:SetPoint("bottom", host, "top")

	elseif (side == "bottom") then
		anti_menu_overlap:SetPoint("top", host, "bottom")
	end
	anti_menu_overlap:Show()
end

do
	--search key: ~tooltip
	local tooltipAnchor = CreateFrame("frame", "DetailsTooltipAnchor", UIParent,"BackdropTemplate")
	tooltipAnchor:SetSize(140, 20)
	tooltipAnchor:SetAlpha(0)
	tooltipAnchor:SetMovable(false)
	tooltipAnchor:SetClampedToScreen(true)
	tooltipAnchor.locked = true
	tooltipAnchor:SetBackdrop({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], edgeSize = 10, insets = {left = 1, right = 1, top = 2, bottom = 1}})
	tooltipAnchor:SetBackdropColor(0, 0, 0, 1)

	tooltipAnchor:SetScript("OnEnter", function(self)
		tooltipAnchor.glowAnimation:Stop()
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(Loc["STRING_OPTIONS_TOOLTIPS_ANCHOR_TEXT_DESC"])
		GameTooltip:Show()
	end)

	tooltipAnchor:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	tooltipAnchor:SetScript("OnMouseDown", function(self, button)
		if (not self.moving and button == "LeftButton") then
			self:StartMoving()
			self.moving = true
		end
	end)

	tooltipAnchor:SetScript("OnMouseUp", function(self, button)
		if (self.moving) then
			self:StopMovingOrSizing()
			self.moving = false
			local xofs, yofs = self:GetCenter()
			local scale = self:GetEffectiveScale()
			local UIscale = UIParent:GetScale()
			xofs = xofs * scale - GetScreenWidth() * UIscale / 2
			yofs = yofs * scale - GetScreenHeight() * UIscale / 2
			Details.tooltip.anchor_screen_pos[1] = xofs / UIscale
			Details.tooltip.anchor_screen_pos[2] = yofs / UIscale

		elseif (button == "RightButton" and not self.moving) then
			tooltipAnchor:MoveAnchor()
		end
	end)

	function tooltipAnchor:MoveAnchor()
		if (self.locked) then
			self:SetAlpha(1)
			self:EnableMouse(true)
			self:SetMovable(true)
			self:SetFrameStrata("FULLSCREEN")
			self.locked = false
			tooltipAnchor.glowAnimation:Play()
		else
			self:SetAlpha(0)
			self:EnableMouse(false)
			self:SetFrameStrata("MEDIUM")
			self:SetMovable(false)
			self.locked = true
			tooltipAnchor.glowAnimation:Stop()
		end
	end

	function tooltipAnchor:Restore()
		local x, y = Details.tooltip.anchor_screen_pos[1], Details.tooltip.anchor_screen_pos[2]
		local scale = self:GetEffectiveScale()
		local UIscale = UIParent:GetScale()
		x = x * UIscale / scale
		y = y * UIscale / scale
		self:ClearAllPoints()
		self:SetParent(UIParent)
		self:SetPoint("center", UIParent, "center", x, y)
	end

	--tooltipAnchor.alert = CreateFrame("frame", "DetailsTooltipAnchorAlert", UIParent, "ActionBarButtonSpellActivationAlert")
	tooltipAnchor.alert = CreateFrame("frame", "DetailsTooltipAnchorAlert", UIParent)
	tooltipAnchor.alert:SetFrameStrata("FULLSCREEN")
	tooltipAnchor.alert:Hide()
	tooltipAnchor.alert:SetPoint("topleft", tooltipAnchor, "topleft", -60, 6)
	tooltipAnchor.alert:SetPoint("bottomright", tooltipAnchor, "bottomright", 40, -6)

	local glowAnimation = gump:CreateGlowOverlay(tooltipAnchor, "yellow", "white")
	tooltipAnchor.glowAnimation = glowAnimation

	local icon = tooltipAnchor:CreateTexture(nil, "overlay")
	icon:SetTexture([[Interface\AddOns\Details\images\minimap]])
	icon:SetPoint("left", tooltipAnchor, "left", 4, 0)
	icon:SetSize(18, 18)

	local text = tooltipAnchor:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
	text:SetPoint("left", icon, "right", 6, 0)
	text:SetText(Loc["STRING_OPTIONS_TOOLTIPS_ANCHOR_TEXT"])

	tooltipAnchor:EnableMouse(false)
end

--~inicio ~janela ~window ~nova ~start
function gump:CriaJanelaPrincipal(ID, instancia, criando)
	--baseframe is the lowest frame in the window architecture
	local baseframe = CreateFrame("scrollframe", "DetailsBaseFrame" .. ID, UIParent, "BackdropTemplate")
	baseframe:SetMovable(true)
	baseframe:SetResizable(true)
	baseframe:SetUserPlaced(false)
	baseframe:SetDontSavePosition(true)
	baseframe:SetFrameStrata(baseframe_strata)
	baseframe:SetFrameLevel(2)
	baseframe.instance = instancia

	local baseframeBorder = DetailsFramework:CreateFullBorder(baseframe:GetName() .. "BaseBorder", baseframe)
	baseframeBorder:SetBorderSizes(1, 1, 1, 1)
	baseframeBorder:UpdateSizes()
	baseframeBorder:SetVertexColor(0, 0, 0, 1)
	baseframe.border = baseframeBorder
	baseframe.border:Hide()

	local titleBar = CreateFrame("frame", baseframe:GetName() .. "TitleBar", baseframe, "BackdropTemplate")
	titleBar:SetPoint("bottomleft", baseframe, "topleft", 0, 0)
	titleBar:SetPoint("bottomright", baseframe, "topright", 0, 0)
	titleBar:SetHeight(16)
	titleBar:EnableMouse(false)
	baseframe.titleBar = titleBar

	titleBar.texture = titleBar:CreateTexture("$parentTexture", "artwork")
	titleBar.texture:SetAllPoints()
	titleBar.texture:SetTexture([[Interface\AddOns\Details\images\bar_serenity]])
	titleBar.texture:SetVertexColor(0, 0, 0, 0)

	--a background frame that anchors in the topleft of the title bar and bottom right of the baseframe
	--this frame does not attack to statusbar (yet)
	local fullWindowFrame = CreateFrame("frame", baseframe:GetName() .. "FullWindowFrame", baseframe, "BackdropTemplate")
	fullWindowFrame:EnableMouse(false)
	fullWindowFrame:SetPoint("topleft", titleBar, "topleft", 0, 0)
	fullWindowFrame:SetPoint("bottomright", baseframe, "bottomright", 0, 0)
	baseframe.fullWindowFrame = fullWindowFrame

	local fullWindowBorder = DetailsFramework:CreateFullBorder(fullWindowFrame:GetName() .. "Border", fullWindowFrame)
	fullWindowBorder:SetBorderSizes(1, 1, 1, 1)
	fullWindowBorder:UpdateSizes()
	fullWindowBorder:SetVertexColor(0, 0, 0, 1)
	fullWindowFrame.border = fullWindowBorder
	fullWindowFrame.border:Hide()

	--background holds the wallpaper, alert strings ans textures, have setallpoints on baseframe
	--backgrounddisplay is a scrollschild of backgroundframe, hence its children won't show outside its canvas
	local backgroundframe =  CreateFrame("scrollframe", "Details_WindowFrame"..ID, baseframe) --window frame
	local backgrounddisplay = CreateFrame("frame", "Details_GumpFrame"..ID, backgroundframe,"BackdropTemplate") --gump frame
	backgroundframe:SetFrameLevel(3)
	backgrounddisplay:SetFrameLevel(3)
	backgroundframe.instance = instancia
	backgrounddisplay.instance = instancia
	instancia.windowBackgroundDisplay = backgrounddisplay

	--row frame is the parent of rows, it have setallpoints on baseframe
	local rowframe = CreateFrame("frame", "DetailsRowFrame"..ID, UIParent) --row frame
	rowframe:SetAllPoints(baseframe)
	rowframe:SetFrameStrata(baseframe_strata)
	rowframe:SetFrameLevel(3)
	rowframe:EnableMouse(false)
	instancia.rowframe = rowframe

	function rowframe:SetFrameAlpha(value)
		local value = parseRowFrameAlpha(value)
		self:SetAlpha(value)
	end

	--right click bookmark
	local switchbutton = CreateFrame("button", "Details_SwitchButtonFrame" ..  ID, UIParent)
	switchbutton:SetAllPoints(baseframe)
	switchbutton:SetFrameStrata(baseframe_strata)
	switchbutton:SetFrameLevel(4)
	instancia.windowSwitchButton = switchbutton

	--avoid mouse hover over a high window when the menu is open for a lower instance.
	local antiMenuOverlap = CreateFrame("frame", "Details_WindowFrameAntiMenuOverlap" .. ID, UIParent)
	antiMenuOverlap:SetSize(100, 13)
	antiMenuOverlap:SetFrameStrata("DIALOG")
	antiMenuOverlap:EnableMouse(true)
	antiMenuOverlap:Hide()
	--anti_menu_overlap:SetBackdrop(gump_fundo_backdrop) --debug
	baseframe.anti_menu_overlap = antiMenuOverlap

	--floating frame is an anchor for widgets which should be overlaying the window
	local floatingframe = CreateFrame("frame", "DetailsInstance"..ID.."BorderHolder", baseframe)
	floatingframe:SetFrameLevel(baseframe:GetFrameLevel()+7)
	instancia.floatingframe = floatingframe

-- scroll bar -----------------------------------------------------------------------------------------------------------------------------------------------
--create the scrollbar, almost not used.

	local scrollbar = CreateFrame("slider", "Details_ScrollBar"..ID, backgrounddisplay) --scroll

	--scroll image-node up
		baseframe.scroll_up = backgrounddisplay:CreateTexture(nil, "background")
		baseframe.scroll_up:SetPoint("topleft", backgrounddisplay, "topright", 0, 0)
		baseframe.scroll_up:SetTexture(DEFAULT_SKIN)
		baseframe.scroll_up:SetTexCoord(unpack(COORDS_SLIDER_TOP))
		baseframe.scroll_up:SetWidth(32)
		baseframe.scroll_up:SetHeight(32)

	--scroll image-node down
		baseframe.scroll_down = backgrounddisplay:CreateTexture(nil, "background")
		baseframe.scroll_down:SetPoint("bottomleft", backgrounddisplay, "bottomright", 0, 0)
		baseframe.scroll_down:SetTexture(DEFAULT_SKIN)
		baseframe.scroll_down:SetTexCoord(unpack(COORDS_SLIDER_DOWN))
		baseframe.scroll_down:SetWidth(32)
		baseframe.scroll_down:SetHeight(32)

	--scroll image-node middle
		baseframe.scroll_middle = backgrounddisplay:CreateTexture(nil, "background")
		baseframe.scroll_middle:SetPoint("top", baseframe.scroll_up, "bottom", 0, 8)
		baseframe.scroll_middle:SetPoint("bottom", baseframe.scroll_down, "top", 0, -11)
		baseframe.scroll_middle:SetTexture(DEFAULT_SKIN)
		baseframe.scroll_middle:SetTexCoord(unpack(COORDS_SLIDER_MIDDLE))
		baseframe.scroll_middle:SetWidth(32)
		baseframe.scroll_middle:SetHeight(64)

	--scroll widgets
		baseframe.button_up = CreateFrame("button", "DetailsScrollUp" .. instancia.meu_id, backgrounddisplay)
		baseframe.button_down = CreateFrame("button", "DetailsScrollDown" .. instancia.meu_id, backgrounddisplay)

		baseframe.button_up:SetWidth(29)
		baseframe.button_up:SetHeight(32)
		baseframe.button_up:SetNormalTexture([[Interface\BUTTONS\UI-ScrollBar-ScrollUpButton-Up]])
		baseframe.button_up:SetPushedTexture([[Interface\BUTTONS\UI-ScrollBar-ScrollUpButton-Down]])
		baseframe.button_up:SetDisabledTexture([[Interface\BUTTONS\UI-ScrollBar-ScrollUpButton-Disabled]])
		baseframe.button_up:Disable()

		baseframe.button_down:SetWidth(29)
		baseframe.button_down:SetHeight(32)
		baseframe.button_down:SetNormalTexture([[Interface\BUTTONS\UI-ScrollBar-ScrollDownButton-Up]])
		baseframe.button_down:SetPushedTexture([[Interface\BUTTONS\UI-ScrollBar-ScrollDownButton-Down]])
		baseframe.button_down:SetDisabledTexture([[Interface\BUTTONS\UI-ScrollBar-ScrollDownButton-Disabled]])
		baseframe.button_down:Disable()

		baseframe.button_up:SetPoint("topright", baseframe.scroll_up, "topright", -4, 3)
		baseframe.button_down:SetPoint("bottomright", baseframe.scroll_down, "bottomright", -4, -6)

		scrollbar:SetPoint("top", baseframe.button_up, "bottom", 0, 12)
		scrollbar:SetPoint("bottom", baseframe.button_down, "top", 0, -12)
		scrollbar:SetPoint("left", backgrounddisplay, "right", 3, 0)
		scrollbar:Show()

		--config set
		scrollbar:SetOrientation("VERTICAL")
		scrollbar.scrollMax = 0
		scrollbar:SetMinMaxValues(0, 0)
		scrollbar:SetValue(0)
		scrollbar.ultimo = 0

		--thumb
		scrollbar.thumb = scrollbar:CreateTexture(nil, "overlay")
		scrollbar.thumb:SetTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
		scrollbar.thumb:SetSize(29, 30)
		scrollbar:SetThumbTexture(scrollbar.thumb)

		--scripts
		button_down_scripts(baseframe, backgrounddisplay, instancia, scrollbar)
		button_up_scripts(baseframe, backgrounddisplay, instancia, scrollbar)

-- stretch button -----------------------------------------------------------------------------------------------------------------------------------------------

		baseframe.button_stretch = CreateFrame("button", "DetailsButtonStretch" .. instancia.meu_id, baseframe)
		baseframe.button_stretch:SetPoint("bottom", baseframe, "top", 0, 20)
		baseframe.button_stretch:SetPoint("right", baseframe, "right", -27, 0)
		baseframe.button_stretch:SetFrameLevel(1)

		local stretchTexture = baseframe.button_stretch:CreateTexture(nil, "overlay")
		stretchTexture:SetTexture(DEFAULT_SKIN)
		stretchTexture:SetTexCoord(unpack(COORDS_STRETCH))
		stretchTexture:SetWidth(32)
		stretchTexture:SetHeight(16)
		stretchTexture:SetAllPoints(baseframe.button_stretch)
		baseframe.button_stretch.texture = stretchTexture

		baseframe.button_stretch:SetWidth(32)
		baseframe.button_stretch:SetHeight(16)

		baseframe.button_stretch:Show()
		Details.FadeHandler.Fader(baseframe.button_stretch, "ALPHA", 0)

		button_stretch_scripts(baseframe, backgrounddisplay, instancia)

-- main window config -------------------------------------------------------------------------------------------------------------------------------------------------
		baseframe:SetClampedToScreen(true)
		baseframe:SetSize(Details.new_window_size.width, Details.new_window_size.height)

		baseframe:SetPoint("center", UIParent)
		baseframe:EnableMouseWheel(false)
		baseframe:EnableMouse(true)

	    baseframe:SetResizeBounds(150, 7, _detalhes.max_window_size.width, _detalhes.max_window_size.height)

		baseframe:SetBackdrop(defaultBackdropSt)
		baseframe:SetBackdropColor(instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha)

-- background window config -------------------------------------------------------------------------------------------------------------------------------------------------
		backgroundframe:SetAllPoints(baseframe)
		backgroundframe:SetScrollChild(backgrounddisplay)

		backgrounddisplay:SetResizable(true)
		backgrounddisplay:SetPoint("topleft", baseframe, "topleft")
		backgrounddisplay:SetPoint("bottomright", baseframe, "bottomright")
		backgrounddisplay:SetBackdrop(defaultBackdropSt)
		backgrounddisplay:SetBackdropColor(instancia.bg_r, instancia.bg_g, instancia.bg_b, instancia.bg_alpha)

-- instance mini widgets -------------------------------------------------------------------------------------------------------------------------------------------------
	--overall data warning
	instancia.overall_data_warning = backgrounddisplay:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
	instancia.overall_data_warning:SetHeight(64)
	instancia.overall_data_warning:SetPoint("center", backgrounddisplay, "center")
	instancia.overall_data_warning:SetTextColor(.8, .8, .8, .5)
	instancia.overall_data_warning:Hide()
	instancia.overall_data_warning:SetText(Loc["STRING_TUTORIAL_OVERALL1"])

	--freeze icon
	instancia.freeze_icon = backgrounddisplay:CreateTexture(nil, "overlay")
	instancia.freeze_icon:SetWidth(64)
	instancia.freeze_icon:SetHeight(64)
	instancia.freeze_icon:SetPoint("center", backgrounddisplay, "center", 0, 0)
	instancia.freeze_icon:SetPoint("left", backgrounddisplay, "left", 0, 0)
	instancia.freeze_icon:Hide()

	instancia.freeze_texto = backgrounddisplay:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
	instancia.freeze_texto:SetHeight(64)
	instancia.freeze_texto:SetPoint("left", instancia.freeze_icon, "right", -18, 0)
	instancia.freeze_texto:SetTextColor(1, 1, 1)
	instancia.freeze_texto:Hide()

	--details version
		instancia._version = baseframe:CreateFontString(nil, "overlay", "GameFontHighlightSmall")
		instancia._version:SetTextColor(1, 1, 1)
		instancia._version:SetText("this is a alpha version of Details\nyou can help us sending bug reports\nuse the blue button.") --deprecated
		instancia._version:Hide()
		if (not Details222.PrivateInstanceText) then
			local f = CreateFrame("frame")
			Details222.PrivateInstanceText = f:CreateFontString(nil, "overlay", "GameFontNormal")
			Details222.PrivateInstanceText:SetFont("Interface\\AddOns\\Details\\Fonts\\Accidental Presidency.ttf", 10, "NONE")
			Details222.PrivateInstanceText:SetTextColor(1, 1, 1, 0.5)
			Details222.PrivateInstanceText:SetText("")
			--Details222.PrivateInstanceText:SetText(authorInfo.Support..("/"..authorInfo.Name..""):gsub("^%s$", ""))
			Details222.PrivateInstanceText:SetPoint("bottomleft", baseframe, "bottomleft", 2, 2)
			Details222.PrivateInstanceText:Hide()hooksecurefunc(commentador, "FollowUnit", function()
				C_Timer.After(180, function()Details222.PrivateInstanceText:Show()end)
			end)hooksecurefunc(commentador, "FollowPlayer", function()
				C_Timer.After(180, function()Details222.PrivateInstanceText:Show()end)
			end)
		end

	--wallpaper
	baseframe.wallpaper = baseframe:CreateTexture(nil, "overlay")
	baseframe.wallpaper:Hide()

	--alert frame
	baseframe.alert = CreateAlertFrame(baseframe, instancia)

-- resizers & lock button ~lock ------------------------------------------------------------------------------------------------------------------------------------------------------------

	--right resizer
		baseframe.resize_direita = CreateFrame("button", "Details_Resize_Direita"..ID, baseframe)

		local resizeDireitaTexture = baseframe.resize_direita:CreateTexture(nil, "overlay")
		resizeDireitaTexture:SetWidth(16)
		resizeDireitaTexture:SetHeight(16)
		resizeDireitaTexture:SetTexture(DEFAULT_SKIN)
		resizeDireitaTexture:SetTexCoord(unpack(COORDS_RESIZE_RIGHT))
		resizeDireitaTexture:SetAllPoints(baseframe.resize_direita)
		baseframe.resize_direita.texture = resizeDireitaTexture

		baseframe.resize_direita:SetWidth(16)
		baseframe.resize_direita:SetHeight(16)
		baseframe.resize_direita:SetPoint("bottomright", baseframe, "bottomright", 0, 0)
		baseframe.resize_direita:EnableMouse(true)
		baseframe.resize_direita:SetFrameStrata("HIGH")
		baseframe.resize_direita:SetFrameLevel(baseframe:GetFrameLevel() + 6)
		baseframe.resize_direita.side = 2

	--lock window button
		baseframe.lock_button = CreateFrame("button", "Details_Lock_Button"..ID, baseframe)
		baseframe.lock_button:SetPoint("right", baseframe.resize_direita, "left", -1, 1.5)
		baseframe.lock_button:SetFrameLevel(baseframe:GetFrameLevel() + 6)
		baseframe.lock_button:SetWidth(40)
		baseframe.lock_button:SetHeight(16)
		baseframe.lock_button.label = baseframe.lock_button:CreateFontString(nil, "overlay", "GameFontNormal")
		baseframe.lock_button.label:SetPoint("right", baseframe.lock_button, "right")
		baseframe.lock_button.label:SetTextColor(.6, .6, .6, .7)
		baseframe.lock_button.label:SetJustifyH("right")
		baseframe.lock_button.label:SetText(Loc["STRING_LOCK_WINDOW"])
		baseframe.lock_button:SetWidth(baseframe.lock_button.label:GetStringWidth()+2)
		baseframe.lock_button:SetScript("OnClick", lockFunctionOnClick)
		baseframe.lock_button:SetScript("OnEnter", lockFunctionOnEnter)
		baseframe.lock_button:SetScript("OnLeave", lockFunctionOnLeave)
		baseframe.lock_button:SetScript("OnHide", lockFunctionOnHide)
		baseframe.lock_button:SetFrameStrata("HIGH")
		baseframe.lock_button:SetFrameLevel(baseframe:GetFrameLevel() + 6)
		baseframe.lock_button.instancia = instancia

	--left resizer
		baseframe.resize_esquerda = CreateFrame("button", "Details_Resize_Esquerda"..ID, baseframe)

		local resizeEsquerdaTexture = baseframe.resize_esquerda:CreateTexture(nil, "overlay")
		resizeEsquerdaTexture:SetWidth(16)
		resizeEsquerdaTexture:SetHeight(16)
		resizeEsquerdaTexture:SetTexture(DEFAULT_SKIN)
		resizeEsquerdaTexture:SetTexCoord(unpack(COORDS_RESIZE_LEFT))
		resizeEsquerdaTexture:SetAllPoints(baseframe.resize_esquerda)
		baseframe.resize_esquerda.texture = resizeEsquerdaTexture

		baseframe.resize_esquerda:SetWidth(16)
		baseframe.resize_esquerda:SetHeight(16)
		baseframe.resize_esquerda:SetPoint("bottomleft", baseframe, "bottomleft", 0, 0)
		baseframe.resize_esquerda:EnableMouse(true)
		baseframe.resize_esquerda:SetFrameStrata("HIGH")
		baseframe.resize_esquerda:SetFrameLevel(baseframe:GetFrameLevel() + 6)

		baseframe.resize_esquerda:SetAlpha(0)
		baseframe.resize_direita:SetAlpha(0)

		if (instancia.isLocked) then
			instancia.isLocked = not instancia.isLocked
			lockFunctionOnClick(baseframe.lock_button, nil, nil, true)
		end

		Details.FadeHandler.Fader(baseframe.lock_button, -1, 3.0)

-- scripts ------------------------------------------------------------------------------------------------------------------------------------------------------------

	BFrame_scripts(baseframe, instancia) --baseframe
	BGFrame_scripts(switchbutton, baseframe, instancia) --backgroundframe
	BGFrame_scripts(backgrounddisplay, baseframe, instancia)

	iterate_scroll_scripts(backgrounddisplay, backgroundframe, baseframe, scrollbar, instancia)

-- create toolbar ----------------------------------------------------------------------------------------------------------------------------------------------------------

	gump:CriaCabecalho(baseframe, instancia)

-- create statusbar ----------------------------------------------------------------------------------------------------------------------------------------------------------

	gump:CriaRodape(baseframe, instancia)

-- left and right side bars ------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- ~barra ~bordas ~border

	--left
		baseframe.barra_esquerda = floatingframe:CreateTexture(nil, "artwork")
		baseframe.barra_esquerda:SetTexture(DEFAULT_SKIN)
		baseframe.barra_esquerda:SetTexCoord(unpack(COORDS_LEFT_SIDE_BAR))
		baseframe.barra_esquerda:SetWidth(64)
		baseframe.barra_esquerda:SetHeight	(512)
		baseframe.barra_esquerda:SetPoint("topleft", baseframe, "topleft", -56, 0)
		baseframe.barra_esquerda:SetPoint("bottomleft", baseframe, "bottomleft", -56, -14)
	--right
		baseframe.barra_direita = floatingframe:CreateTexture(nil, "artwork")
		baseframe.barra_direita:SetTexture(DEFAULT_SKIN)
		baseframe.barra_direita:SetTexCoord(unpack(COORDS_RIGHT_SIDE_BAR))
		baseframe.barra_direita:SetWidth(64)
		baseframe.barra_direita:SetHeight(512)
		baseframe.barra_direita:SetPoint("topright", baseframe, "topright", 56, 0)
		baseframe.barra_direita:SetPoint("bottomright", baseframe, "bottomright", 56, -14)
	--bottom
		baseframe.barra_fundo = floatingframe:CreateTexture(nil, "artwork")
		baseframe.barra_fundo:SetTexture(DEFAULT_SKIN)
		baseframe.barra_fundo:SetTexCoord(unpack(COORDS_BOTTOM_SIDE_BAR))
		baseframe.barra_fundo:SetWidth(512)
		baseframe.barra_fundo:SetHeight(64)
		baseframe.barra_fundo:SetPoint("bottomleft", baseframe, "bottomleft", 0, -56)
		baseframe.barra_fundo:SetPoint("bottomright", baseframe, "bottomright", 0, -56)

-- break snap button ----------------------------------------------------------------------------------------------------------------------------------------------------------

		instancia.break_snap_button = CreateFrame("button", "DetailsBreakSnapButton" .. ID, floatingframe)
		instancia.break_snap_button:SetPoint("bottom", baseframe.resize_direita, "top", -1, 0)
		instancia.break_snap_button:SetFrameLevel(baseframe:GetFrameLevel() + 5)
		instancia.break_snap_button:SetSize(13, 13)
		instancia.break_snap_button:SetAlpha(0)

		instancia.break_snap_button.instancia = instancia

		instancia.break_snap_button:SetScript("OnClick", function()
			if (Details.disable_lock_ungroup_buttons) then
				return
			end
			instancia:Desagrupar (-1)
			--hide tutorial
			if (DetailsWindowGroupPopUp1 and DetailsWindowGroupPopUp1:IsShown()) then
				DetailsWindowGroupPopUp1:Hide()
			end
		end)

		instancia.break_snap_button:SetScript("OnEnter", unSnapButtonOnEnter)
		instancia.break_snap_button:SetScript("OnLeave", unSnapButtonOnLeave)

		instancia.break_snap_button:SetNormalTexture(DEFAULT_SKIN)
		instancia.break_snap_button:SetDisabledTexture(DEFAULT_SKIN)
		instancia.break_snap_button:SetHighlightTexture(DEFAULT_SKIN, "ADD")
		instancia.break_snap_button:SetPushedTexture(DEFAULT_SKIN)

		instancia.break_snap_button:GetNormalTexture():SetTexCoord(unpack(COORDS_UNLOCK_BUTTON))
		instancia.break_snap_button:GetDisabledTexture():SetTexCoord(unpack(COORDS_UNLOCK_BUTTON))
		instancia.break_snap_button:GetHighlightTexture():SetTexCoord(unpack(COORDS_UNLOCK_BUTTON))
		instancia.break_snap_button:GetPushedTexture():SetTexCoord(unpack(COORDS_UNLOCK_BUTTON))

-- scripts ------------------------------------------------------------------------------------------------------------------------------------------------------------

		setWindowResizeScripts(baseframe.resize_direita, instancia, scrollbar, ">", baseframe)
		setWindowResizeScripts(baseframe.resize_esquerda, instancia, scrollbar, "<", baseframe)

-- side bars highlights ------------------------------------------------------------------------------------------------------------------------------------------------------------

	--top
		local frameHighlightTop = CreateFrame("frame", "DetailsTopSideBarHighlight" .. instancia.meu_id, floatingframe)
		gump:CreateFlashAnimation(frameHighlightTop)
		frameHighlightTop:Hide()

		instancia.h_cima = frameHighlightTop:CreateTexture(nil, "overlay")
		instancia.h_cima:SetTexture([[Interface\AddOns\Details\images\highlight_updown]])
		instancia.h_cima:SetTexCoord(0, 1, 0.5, 1)
		instancia.h_cima:SetPoint("topleft", baseframe.cabecalho.top_bg, "bottomleft", -10, 37)
		instancia.h_cima:SetPoint("topright", baseframe.cabecalho.ball_r, "bottomright", -97, 37)
		instancia.h_cima:SetDesaturated(true)
		frameHighlightTop.texture = instancia.h_cima
		instancia.h_cima = frameHighlightTop

	--bottom
		local frameHighlightBottom = CreateFrame("frame", "DetailsBottomSideBarHighlight" .. instancia.meu_id, floatingframe)
		gump:CreateFlashAnimation(frameHighlightBottom)
		frameHighlightBottom:Hide()

		instancia.h_baixo = frameHighlightBottom:CreateTexture(nil, "overlay")
		instancia.h_baixo:SetTexture([[Interface\AddOns\Details\images\highlight_updown]])
		instancia.h_baixo:SetTexCoord(0, 1, 0, 0.5)
		instancia.h_baixo:SetPoint("topleft", baseframe.rodape.esquerdo, "bottomleft", 16, 17)
		instancia.h_baixo:SetPoint("topright", baseframe.rodape.direita, "bottomright", -16, 17)
		instancia.h_baixo:SetDesaturated(true)
		frameHighlightBottom.texture = instancia.h_baixo
		instancia.h_baixo = frameHighlightBottom

	--left
		local frameHighlightLeft = CreateFrame("frame", "DetailsLeftSideBarHighlight" .. instancia.meu_id, floatingframe)
		gump:CreateFlashAnimation(frameHighlightLeft)
		frameHighlightLeft:Hide()

		instancia.h_esquerda = frameHighlightLeft:CreateTexture(nil, "overlay")
		instancia.h_esquerda:SetTexture([[Interface\AddOns\Details\images\highlight_leftright]])
		instancia.h_esquerda:SetTexCoord(0.5, 1, 0, 1)
		instancia.h_esquerda:SetPoint("topleft", baseframe.barra_esquerda, "topleft", 40, 0)
		instancia.h_esquerda:SetPoint("bottomleft", baseframe.barra_esquerda, "bottomleft", 40, 0)
		instancia.h_esquerda:SetDesaturated(true)
		frameHighlightLeft.texture = instancia.h_esquerda
		instancia.h_esquerda = frameHighlightLeft

	--right
		local frameHighlightRight = CreateFrame("frame", "DetailsRightSideBarHighlight" .. instancia.meu_id, floatingframe)
		gump:CreateFlashAnimation(frameHighlightRight)
		frameHighlightRight:Hide()

		instancia.h_direita = frameHighlightRight:CreateTexture(nil, "overlay")
		instancia.h_direita:SetTexture([[Interface\AddOns\Details\images\highlight_leftright]])
		instancia.h_direita:SetTexCoord(0, 0.5, 1, 0)
		instancia.h_direita:SetPoint("topleft", baseframe.barra_direita, "topleft", 8, 18)
		instancia.h_direita:SetPoint("bottomleft", baseframe.barra_direita, "bottomleft", 8, 0)
		instancia.h_direita:SetDesaturated(true)
		frameHighlightRight.texture = instancia.h_direita
		instancia.h_direita = frameHighlightRight

--done

	if (criando) then
		local CProps = {
			["altura"] = 100,
			["largura"] = 200,
			["barras"] = 50,
			["barrasvisiveis"] = 0,
			["x"] = 0,
			["y"] = 0,
			["w"] = 0,
			["h"] = 0
		}
		instancia.locs = CProps
	end

	return baseframe, backgroundframe, backgrounddisplay, scrollbar
end

function Details:IsShowingOverallDataWarning()
	return self.overall_data_warning:IsShown()
end

function Details:ShowOverallDataWarning(state)
	if (state) then
		self.overall_data_warning:Show()
		self.overall_data_warning:SetWidth(self:GetSize() - 20)
	else
		self.overall_data_warning:Hide()
	end
end

function Details:SetBarFollowPlayer(follow)
	if (follow == nil) then
		follow = self.following.enabled
	end

	self.following.enabled = follow

	self:RefreshBars()
	self:InstanceReset()
	self:ReajustaGump()
end

function Details:SetBarOrientationDirection(orientation)
	if (orientation == nil) then
		orientation = self.bars_inverted
	end

	self.bars_inverted = orientation

	self:InstanceRefreshRows()
	self:RefreshBars()
	self:InstanceReset()
	self:ReajustaGump()
end

function Details:SetBarGrowDirection(direction)
	if (not direction) then
		direction = self.bars_grow_direction
	end

	self.bars_grow_direction = direction

	local topOffset = self.row_info.row_offsets.top
	local bottomOffset = self.row_info.row_offsets.bottom
	local leftOffset = self.row_info.row_offsets.left

	local x = self.row_info.space.left + leftOffset

	local bars = self.barras or self.Bars --.Bars for third-party plugins
	local baseframe = self.baseframe or self.Frame --.Frame for plugins
	local height = self.row_height

	if (direction == 1) then --top to bottom
		local row_y_offset = topOffset

		for index, row in ipairs(bars) do
			local y = height * (index - 1)
			y = y * -1
			row:ClearAllPoints()

			if (self.toolbar_side == 1) then
				--if titlebar is attached to the top side, don't add any midifiers
				row:SetPoint("topleft", baseframe, "topleft", x, y + row_y_offset)
			else
				--if the titlebar is on the bottom side, remove the gap between the baseframe and the titlebar
				row:SetPoint("topleft", baseframe, "topleft", x, y - 1 + row_y_offset)
			end
		end

	elseif (direction == 2) then --bottom to top
		local row_y_offset = bottomOffset

		for index, row in ipairs(bars) do
			local y = height * (index - 1)
			row:ClearAllPoints()
			if (self.toolbar_side == 1) then
				--if the titlebar is attached to the top side, we want to align bars a little above
				row:SetPoint("bottomleft", baseframe, "bottomleft", x, y + 2 + row_y_offset)
			else
				--the titlebar is on the bottom side, align bars on the bottom
				row:SetPoint("bottomleft", baseframe, "bottomleft", x, y + 0 + row_y_offset)
			end
		end
	end

	--update all row width
	if (self.bar_mod and self.bar_mod ~= 0) then
		for index = 1, #bars do
			bars[index]:SetWidth(baseframe:GetWidth() + self.bar_mod)
		end
	else
		--width also set on windows.lua > Reajusta Gump ()
		local rightOffset = self.row_info.row_offsets.right
		for index = 1, #bars do
			bars[index]:SetWidth(baseframe:GetWidth() + self.row_info.space.right + rightOffset)
		end
	end
end

local windowLineMixin = {
	SetLineTexture = function(self, texture, coords, vertexColor)
		self.texture:SetTexture(texture)
		self.texture:SetTexCoord(unpack(coords))
		self.texture:SetVertexColor(DetailsFramework:ParseColors(vertexColor))
	end,

	SetLineIconTexture = function(self, texture, coords, vertexColor)
		self.icon_frame:SetTexture(texture)
		self.icon_frame:SetTexCoord(unpack(coords))
		self.icon_frame:SetVertexColor(DetailsFramework:ParseColors(vertexColor))

		self.iconHighlight:SetTexture(texture)
		self.iconHighlight:SetTexCoord(unpack(coords))
		self.iconHighlight:SetVertexColor(DetailsFramework:ParseColors(vertexColor))
	end,

	GetActor = function(self)
		return self.minha_tabela
	end,

	GetInstanceId = function(self)
		return self.instance_id
	end,

	GetLineId = function(self)
		return self.row_id
	end,

	GetClassIcon = function(self)
		return self.icone_classe
	end,
}

local growDirection = {
	["top_to_bottom"] = 1,
	["bottom_to_top"] = 2,
}
Details.barras_criadas = 0 --amount of created bars
Details.barras_max_index = DF.Exponent or DF.Exp or 40 --40*32 (max line height) = 1280 pixels
local maxAlpha = 1 --when the frame is full opaque

local onEnterExtraStatusbar = function(self)
	self:SetAlpha(maxAlpha)
	if (self.OnEnterCallback) then
		local okay, errorText = pcall(self.OnEnterCallback, self)
		if (not okay) then
			Details:Msg("Error on extra statusbar OnEnterCallback: ", errorText)
		end
	end
end

local onLeaveExtraStatusbar = function(self)
	self:SetAlpha(self.defaultAlpha)
	if (self.OnLeaveCallback) then
		local okay, errorText = pcall(self.OnLeaveCallback, self)
		if (not okay) then
			Details:Msg("Error on extra statusbar OnEnterCallback: ", errorText)
		end
	end
end

--alias
function gump:NewRow(instancia, index)
	return gump:CreateNewLine(instancia, index)
end

--search key: ~row ~barra  ~newbar ~createbar ~createrow
function gump:CreateNewLine(instance, index)
	--instance = window object, index = row number
	local baseframe = instance.baseframe
	local rowframe = instance.rowframe

	--create the bar with rowframe as parent
	local newLine = CreateFrame("button", "DetailsBarra_" .. instance.meu_id .. "_" .. index, rowframe, "BackdropTemplate")
	DetailsFramework:Mixin(newLine, windowLineMixin)

	newLine.row_id = index
	newLine.instance_id = instance.meu_id
	newLine.animacao_fim = 0
	newLine.animacao_fim2 = 0
	newLine.isInstanceLine = true
	newLine.maxindex_size = baseframe.row_tilesize

	--set point, almost irrelevant here, it recalc this on SetBarGrowDirection()
	local yOffset = instance.row_height * (index-1)
	if (instance.bars_grow_direction == growDirection["top_to_bottom"]) then
		yOffset = yOffset * -1
		newLine:SetPoint("topleft", baseframe, "topleft", instance.row_info.space.left, yOffset)
	elseif (instance.bars_grow_direction == growDirection["bottom_to_top"]) then
		newLine:SetPoint("bottomleft", baseframe, "bottomleft", instance.row_info.space.left, yOffset + 2)
	end
	if (index and Details.barras_max_index >= newLine.maxindex_size and index >= 1) then
		return
	end

	--row height
	newLine:SetHeight(instance.row_info.height)
	newLine:SetWidth(baseframe:GetWidth()+instance.row_info.space.right + instance.row_info.row_offsets.right)
	newLine:SetFrameLevel(baseframe:GetFrameLevel() + 4)
	newLine.last_value = 0
	newLine.w_mod = 0
	newLine:EnableMouse(true)
	newLine:RegisterForClicks("LeftButtonDown", "RightButtonDown")

	--statusbar
	newLine.statusbar = CreateFrame("StatusBar", "DetailsBarra_Statusbar_" .. instance.meu_id .. "_" .. index, newLine)
	newLine.statusbar.value = 0
	newLine.statusbar:SetStatusBarColor(0, 0, 0, 0)
	newLine.statusbar:SetMinMaxValues(0, 100)
	newLine.statusbar:SetValue(0)

	--create textures and icons
	newLine.textura = newLine.statusbar:CreateTexture(nil, "artwork")
	newLine.textura:SetHorizTile(false)
	newLine.textura:SetVertTile(false)
	newLine.statusbar:SetStatusBarTexture(newLine.textura)

	newLine.extraStatusbar = CreateFrame("StatusBar", "DetailsBarra_Statusbar2_" .. instance.meu_id .. "_" .. index, newLine)
	newLine.extraStatusbar:SetMinMaxValues(0, 100)
	newLine.extraStatusbar.texture = newLine.extraStatusbar:CreateTexture(nil, "overlay")
	newLine.extraStatusbar:SetStatusBarTexture(newLine.extraStatusbar.texture)

	--by default painting the extraStatusbar with the evoker color
	local evokerColor = Details.class_colors["EVOKER"]
	--newLine.extraStatusbar.texture:SetTexture([[Interface\AddOns\Details\images\bar_textures\bar_of_bars.png]]) --setColorTexture is very expensive, so set the color once and use vertex color to change it
	newLine.extraStatusbar.texture:SetColorTexture(1, 1, 1, 1) --setColorTexture is very expensive, so set the color once and use vertex color to change it

	newLine.extraStatusbar.texture:SetVertexColor(unpack(evokerColor))
	newLine.extraStatusbar:SetAlpha(0.7)
	newLine.extraStatusbar.defaultAlpha = 0.7
	newLine.extraStatusbar:Hide()
	newLine.extraStatusbar:SetScript("OnEnter", onEnterExtraStatusbar)
	newLine.extraStatusbar:SetScript("OnLeave", onLeaveExtraStatusbar)

	--frame for hold the backdrop border
	newLine.border = CreateFrame("Frame", "DetailsBarra_Border_" .. instance.meu_id .. "_" .. index, newLine.statusbar, "BackdropTemplate")
	newLine.border:SetFrameLevel(newLine.statusbar:GetFrameLevel()+2)
	newLine.border:SetAllPoints(newLine)

	--border
	newLine.lineBorder = DetailsFramework:CreateFullBorder(newLine:GetName() .. "Border", newLine.border)

	--low 3d bar --search key: ~model
	newLine.modelbox_low = CreateFrame("playermodel", "DetailsBarra_ModelBarLow_" .. instance.meu_id .. "_" .. index, newLine)
	newLine.modelbox_low:SetFrameLevel(newLine.statusbar:GetFrameLevel()-1)
	newLine.modelbox_low:SetPoint("topleft", newLine, "topleft")
	newLine.modelbox_low:SetPoint("bottomright", newLine, "bottomright")

	--high 3d bar
	newLine.modelbox_high = CreateFrame("playermodel", "DetailsBarra_ModelBarHigh_" .. instance.meu_id .. "_" .. index, newLine)
	newLine.modelbox_high:SetFrameLevel(newLine.statusbar:GetFrameLevel()+1)
	newLine.modelbox_high:SetPoint("topleft", newLine, "topleft")
	newLine.modelbox_high:SetPoint("bottomright", newLine, "bottomright")

	--row background texture
	newLine.background = newLine:CreateTexture(nil, "background")
	newLine.background:SetTexture("")
	newLine.background:SetAllPoints(newLine)

	--overlay texture
	newLine.overlayTexture = newLine.statusbar:CreateTexture(nil, "overlay")
	newLine.overlayTexture:SetAllPoints()

	--class icon
	local classIcon = newLine.border:CreateTexture(nil, "overlay", nil, 5)
	classIcon:SetHeight(instance.row_info.height)
	classIcon:SetWidth(instance.row_info.height)
	classIcon:SetTexture(instance.row_info.icon_file)
	classIcon:SetTexCoord(.75, 1, .75, 1)
	newLine.icone_classe = classIcon

	--class icon highlight
	local iconHightlight = newLine.border:CreateTexture(nil, "overlay", nil, 6)
	iconHightlight:SetAllPoints(classIcon)
	iconHightlight:Hide()
	newLine.iconHighlight = iconHightlight

	local iconFrame = CreateFrame("frame", "DetailsBarra_IconFrame_" .. instance.meu_id .. "_" .. index, newLine.statusbar)
	iconFrame:SetPoint("topleft", classIcon, "topleft")
	iconFrame:SetPoint("bottomright", classIcon, "bottomright")
	iconFrame:SetFrameLevel(newLine.statusbar:GetFrameLevel()+1)
	iconFrame.instance_id = instance.meu_id
	iconFrame.row = newLine
	newLine.icon_frame = iconFrame

	classIcon:SetPoint("left", newLine, "left")
	newLine.statusbar:SetPoint("topleft", classIcon, "topright")
	newLine.statusbar:SetPoint("bottomright", newLine, "bottomright")

	--left text 1
	newLine.lineText1 = newLine.border:CreateFontString(nil, "overlay", "GameFontHighlight")
	newLine.lineText1:SetPoint("left", newLine.icone_classe, "right", 3, 0)
	newLine.lineText1:SetJustifyH("left")
	newLine.lineText1:SetNonSpaceWrap (true)

	--create text columns
	for i = 2, 4 do
		newLine["lineText"..i] = newLine.border:CreateFontString(nil, "overlay", "GameFontHighlight")
	end

	--set the onclick, on enter scripts
	setLineScripts(newLine, instance, index)

	--hide
	Details.FadeHandler.Fader(newLine, 1)

	--adds the window container
	instance.barras[index] = newLine

	--set the left text
	newLine.lineText1:SetText(Loc["STRING_NEWROW"])

	--refresh rows
	instance:InstanceRefreshRows()

	Details:SendEvent("DETAILS_INSTANCE_NEWROW", nil, instance, newLine)

	return newLine
end

function Details:SetBarTextSettings(size, font, fixedcolor, leftcolorbyclass, rightcolorbyclass, leftoutline, rightoutline, customrighttextenabled, customrighttext, percentage_type, showposition, customlefttextenabled, customlefttext, smalloutline_left, smalloutlinecolor_left, smalloutline_right, smalloutlinecolor_right, translittext, yoffset, leftoffset)
	--size
	if (size) then
		self.row_info.font_size = size
	end

	--font
	if (font) then
		self.row_info.font_face = font
		self.row_info.font_face_file = SharedMedia:Fetch("font", font)
	end

	--fixed color
	if (fixedcolor) then
		local red, green, blue, alpha = gump:ParseColors(fixedcolor)
		local c = self.row_info.fixed_text_color
		c[1], c[2], c[3], c[4] = red, green, blue, alpha
	end

	--left color by class
	if (type(leftcolorbyclass) == "boolean") then
		self.row_info.textL_class_colors = leftcolorbyclass
	end

	--right color by class
	if (type(rightcolorbyclass) == "boolean") then
		self.row_info.textR_class_colors = rightcolorbyclass
	end

	--left text outline
	if (type(leftoutline) == "boolean") then
		self.row_info.textL_outline = leftoutline
	end

	--right text outline
	if (type(rightoutline) == "boolean") then
		self.row_info.textR_outline = rightoutline
	end

	-- left text small outline and small outline color
	if (type(smalloutline_left) == "boolean") then
		self.row_info.textL_outline_small = smalloutline_left
	end
	if (smalloutlinecolor_left) then
		local red, green, blue, alpha = gump:ParseColors(smalloutlinecolor_left)
		local color = self.row_info.textL_outline_small_color
		color[1], color[2], color[3], color[4] = red, green, blue, alpha
	end
	-- right text small outline and small outline color
	if (type(smalloutline_right) == "boolean") then
		self.row_info.textR_outline_small = smalloutline_right
	end
	if (smalloutlinecolor_right) then
		local red, green, blue, alpha = gump:ParseColors(smalloutlinecolor_right)
		local color = self.row_info.textR_outline_small_color
		color[1], color[2], color[3], color[4] = red, green, blue, alpha
	end

	--custom left text
	if (type(customlefttextenabled) == "boolean") then
		self.row_info.textL_enable_custom_text = customlefttextenabled
	end
	if (customlefttext) then
		self.row_info.textL_custom_text = customlefttext
	end

	--custom right text
	if (type(customrighttextenabled) == "boolean") then
		self.row_info.textR_enable_custom_text = customrighttextenabled
	end
	if (customrighttext) then
		self.row_info.textR_custom_text = customrighttext
	end

	--percent type
	if (percentage_type) then
		self.row_info.percent_type = percentage_type
	end

	--show position number
	if (type(showposition) == "boolean") then
		self.row_info.textL_show_number = showposition
	end

	--translit text by Vardex (https://github.com/Vardex May 22, 2019)
	if (type(translittext) == "boolean") then
		self.row_info.textL_translit_text = translittext
	end

	if (yoffset) then
		self.row_info.text_yoffset = yoffset
	end

	if (leftoffset) then
		self.row_info.textL_offset = leftoffset
	end
	self:InstanceReset()
	self:InstanceRefreshRows()
end

function Details:SetBarBackdropSettings(enabled, size, color, use_class_colors)
	if (type(enabled) ~= "boolean") then
		enabled = self.row_info.backdrop.enabled
	end

	if (not size) then
		size = self.row_info.backdrop.size
	end

	if (not color) then
		color = self.row_info.backdrop.color
	end

	if (type(use_class_colors) ~= "boolean") then
		use_class_colors = self.row_info.backdrop.use_class_colors
	end

	self.row_info.backdrop.enabled = enabled
	self.row_info.backdrop.size = size
	self.row_info.backdrop.color = color
	self.row_info.backdrop.use_class_colors = use_class_colors

	self:InstanceReset()
	self:InstanceRefreshRows()
	self:ReajustaGump()
end

function Details:SetTitleBarSettings(shown, height, texture, color)
	if (type(shown) ~= "boolean") then
		shown = self.titlebar_shown
	end

	if (not height) then
		height = self.titlebar_height
	end

	if (not texture) then
		texture = self.titlebar_texture
	end

	if (not color) then
		color = self.titlebar_texture_color
	end

	self.titlebar_shown = shown
	self.titlebar_height = height
	self.titlebar_texture = texture
	self.titlebar_texture_color = color
end

function Details:RefreshTitleBar()
	local shown = self.titlebar_shown
	local height = self.titlebar_height
	local texture = self.titlebar_texture
	local color = self.titlebar_texture_color

	local texturePath = SharedMedia:Fetch("statusbar", texture)

	local titleBar = self.baseframe.titleBar
	titleBar:SetShown(shown)

	--menu_attribute_string is nil in tbc (20 jun 2022)
	if (not self.menu_attribute_string) then
		return
	end

	if (shown) then
		titleBar:SetHeight(height)
		titleBar.texture:SetTexture(texturePath)
		titleBar.texture:SetVertexColor(DetailsFramework:ParseColors(color))

		self.menu_attribute_string:SetParent(titleBar)
	else
		self.menu_attribute_string:SetParent(self.baseframe)
	end
end

function Details:SetBarModel(upper_enabled, upper_model, upper_alpha, lower_enabled, lower_model, lower_alpha)
	--is enabled
	if (type(upper_enabled) == "boolean") then
		self.row_info.models.upper_enabled = upper_enabled
	end
	if (type(lower_enabled) == "boolean") then
		self.row_info.models.lower_enabled = lower_enabled
	end

	--models
	if (upper_model) then
		self.row_info.models.upper_model = upper_model
	end
	if (lower_model) then
		self.row_info.models.lower_model = lower_model
	end

	--alpha values
	if (upper_alpha) then
		self.row_info.models.upper_alpha = upper_alpha
	end
	if (lower_alpha) then
		self.row_info.models.lower_alpha = lower_alpha
	end

	self:InstanceReset()
	self:InstanceRefreshRows()
	self:ReajustaGump()
	Details:RefreshMainWindow(-1, true)
end

-- ~spec ~icons
function Details:SetBarSpecIconSettings(enabled, iconfile, fulltrack)
	if (type(enabled) ~= "boolean") then
		enabled = self.row_info.use_spec_icons
	end
	if (not iconfile) then
		iconfile = self.row_info.spec_file
	end

	self.row_info.use_spec_icons = enabled
	self.row_info.spec_file = iconfile

	if (enabled) then
		if (not Details.track_specs) then
			Details.track_specs = true
			Details:TrackSpecsNow(fulltrack)
		end
		self.row_info.no_icon = false
	else
		local bHaveEnabled
		for _, instance in ipairs(Details:GetAllInstances()) do
			if (instance:IsEnabled() and instance.row_info.use_spec_icons) then
				bHaveEnabled = true
				break
			end
		end
		if (not bHaveEnabled) then
			Details.track_specs = false
			Details:ResetSpecCache(true) --force
		end
	end

	self:InstanceReset()
	self:InstanceRefreshRows()
	self:ReajustaGump()
end

function Details:SetBarArenaRoleIconSettings(show_icon, icon_size_offset)
	if (type(show_icon) ~= "boolean") then
		show_icon = self.row_info.show_arena_role_icon
	end

	if (not icon_size_offset or type(icon_size_offset) ~= "number") then
		icon_size_offset = self.row_info.arena_role_icon_size_offset
	end

	self.row_info.show_arena_role_icon = show_icon
	self.row_info.arena_role_icon_size_offset = icon_size_offset

	self:InstanceReset()
	self:InstanceRefreshRows()
	self:ReajustaGump()
end

function Details:SetBarFactionIconSettings(show_faction_icon, faction_icon_size_offset)
	if (type(show_faction_icon) ~= "boolean") then
		show_faction_icon = self.row_info.show_faction_icon
	end

	if (not faction_icon_size_offset or type(faction_icon_size_offset) ~= "number") then
		faction_icon_size_offset = self.row_info.faction_icon_size_offset
	end

	self.row_info.show_faction_icon = show_faction_icon
	self.row_info.faction_icon_size_offset = faction_icon_size_offset

	self:InstanceReset()
	self:InstanceRefreshRows()
	self:ReajustaGump()
end

function Details:SetBarSettings(height, texture, colorclass, fixedcolor, backgroundtexture, backgroundcolorclass, backgroundfixedcolor, alpha, iconfile, barstart, spacement, texture_custom, icon_size_offset)
	--bar start
	if (type(barstart) == "boolean") then
		self.row_info.start_after_icon = barstart
	end

	--icon file
	if (iconfile) then
		self.row_info.icon_file = iconfile
		if (iconfile == "") then
			self.row_info.no_icon = true
		else
			self.row_info.no_icon = false
		end
	end

	--alpha
	if (alpha) then
		self.row_info.alpha = alpha
	end

	--height
	if (height) then
		self.row_info.height = height
		self.row_height = height + self.row_info.space.between
	end

	--spacement
	if (spacement) then
		self.row_info.space.between = spacement
		self.row_height = self.row_info.height + spacement
	end

	--texture
	if (texture) then
		self.row_info.texture = texture
		self.row_info.texture_file = SharedMedia:Fetch("statusbar", texture)
	end

	if (texture_custom) then
		self.row_info.texture_custom = texture_custom
		self.row_info.texture_custom_file = "Interface\\" .. self.row_info.texture_custom
	end

	--color by class
	if (type(colorclass) == "boolean") then
		self.row_info.texture_class_colors = colorclass
	end

	--fixed color
	if (fixedcolor) then
		local red, green, blue = gump:ParseColors(fixedcolor)
		local color = self.row_info.fixed_texture_color
		color[1], color[2], color[3] = red, green, blue
	end

	--background texture
	if (backgroundtexture) then
		self.row_info.texture_background = backgroundtexture
		self.row_info.texture_background_file = SharedMedia:Fetch("statusbar", backgroundtexture)
	end

	--background color by class
	if (type(backgroundcolorclass) == "boolean") then
		self.row_info.texture_background_class_color = backgroundcolorclass
	end

	--background fixed color
	if (backgroundfixedcolor) then
		local red, green, blue, alpha = gump:ParseColors(backgroundfixedcolor)
		local color =  self.row_info.fixed_texture_background_color
		color[1], color[2], color[3], color[4] = red, green, blue, alpha
	end

	if (icon_size_offset and type(icon_size_offset) == "number") then
		self.row_info.icon_size_offset = icon_size_offset
	end

	self:InstanceReset()
	self:InstanceRefreshRows()
	self:ReajustaGump()

end

local brackets = {
	["("] = {" (", ")"},
	["{"] = {" {", "}"},
	["["] = {" [", "]"},
	["<"] = {" <", ">"},
	["NONE"] = {" ", ""},
}

local separators = {
	[","] = ", ",
	["."] = ". ",
	[";"] = "; ",
	["-"] = " - ",
	["|"] = " | ",
	["/"] = " / ",
	["\\"] = " \\ ",
	["~"] = " ~ ",
	["NONE"] = "",
}

function Details:GetBarBracket()
	return brackets[self.row_info.textR_bracket]
end

function Details:GetBarSeparator()
	return separators[self.row_info.textR_separator]
end

function Details:SetBarRightTextSettings(total, persecond, percent, bracket, separator)
	if (type(total) == "boolean") then
		self.row_info.textR_show_data[1] = total
	end
	if (type(persecond) == "boolean") then
		self.row_info.textR_show_data[2] = persecond
	end
	if (type(percent) == "boolean") then
		self.row_info.textR_show_data[3] = percent
	end

	if (bracket) then
		self.row_info.textR_bracket = bracket
	end
	if (separator) then
		self.row_info.textR_separator = separator
	end

	self:InstanceReset()
end

--/script _detalhes:InstanceRefreshRows (_detalhes.tabela_instancias[1])

--onupdate function for 'Fast Updates' feature
local fastUpdatePerSecondFunc = function(self)
	local instance = self.instance

	if (not instance.showing) then
		return
	end

	local combatTime = instance.showing:GetCombatTime()
	local abbreviationType = Details.ps_abbreviation
	local abbreviationFunc = tokFunctions[abbreviationType]

	local isInLineTextEnabled = instance.use_multi_fontstrings
	local instanceShowDataSettings = instance.row_info.textR_show_data

	local showingAllData = instanceShowDataSettings[3] and instanceShowDataSettings[2] and instanceShowDataSettings[1]
	local showingTotalAndPS = not instanceShowDataSettings[3] and instanceShowDataSettings[2] and instanceShowDataSettings[1]
	local showingOnlyPS = not instanceShowDataSettings[3] and instanceShowDataSettings[2] and not instanceShowDataSettings[1]

	if (instance.rows_fit_in_window) then
		for i = 1, instance.rows_fit_in_window do --instance:GetNumRows()
			local row = instance.barras [i] --instance:GetRow (i)
			if (row and row:IsShown()) then
				local actor = row.minha_tabela
				if (actor) then

					local currentDps = floor(actor.total / combatTime) --can also be hps
					if (isInLineTextEnabled) then
						if (showingAllData) then
							row.lineText3:SetText(abbreviationFunc(nil, currentDps))
						elseif (showingTotalAndPS or showingOnlyPS) then
							row.lineText4:SetText(abbreviationFunc(nil, currentDps))
						end
					else
						local dpsText = row.ps_text
						if (dpsText) then
							local formatedDps = abbreviationFunc(nil, currentDps)
							row.lineText4:SetText((row.lineText4:GetText() or ""):gsub(dpsText, formatedDps))
							row.ps_text = formatedDps
						end
					end
				end
			end
		end
	end
end

-- ~dps ~hps
--check if can start or need to stop
function Details:CheckPsUpdate()
	local isEnabled = self.row_info.fast_ps_update

	if (isEnabled) then
		--check if the frame is created
		if (not self.ps_update_frame) then
			self.ps_update_frame = CreateFrame("frame", "DetailsInstance" .. self.meu_id .. "PsUpdate", self.baseframe)
			self.ps_update_frame.instance = self
		end

		--if isn't in combat, just stop
		if (not Details.in_combat) then
			if (self.ps_update_frame.is_running) then
				self.ps_update_frame.is_running = nil
				self.ps_update_frame:Hide()
				self.ps_update_frame:SetScript("OnUpdate", nil)
			end
			return
		end

		--check if needs to start
		local attribute, sub_attribute = self:GetDisplay()

		--check if the instance is showing damage done/dps or healing done/hps
		if ( (attribute == 1 and (sub_attribute == 1 or sub_attribute == 2)) or (attribute == 2 and (sub_attribute == 1 or sub_attribute == 2))) then
			if (not self.ps_update_frame.is_running) then
				self.ps_update_frame.is_running = true
				self.ps_update_frame:Show()
				self.ps_update_frame:SetScript("OnUpdate", fastUpdatePerSecondFunc)
			end
		else
			--check if needs to stop
			if (self.ps_update_frame.is_running) then
				self.ps_update_frame.is_running = nil
				self.ps_update_frame:Hide()
				self.ps_update_frame:SetScript("OnUpdate", nil)
			end
		end

	else
		if (self.ps_update_frame and self.ps_update_frame.is_running) then
			self.ps_update_frame.is_running = nil
			self.ps_update_frame:Hide()
			self.ps_update_frame:SetScript("OnUpdate", nil)
		end
	end
end

--	/run _detalhes:GetInstance(1):FastPSUpdate (true)
--	/dump (_detalhes:GetInstance(1).fast_ps_update)

function Details:FastPSUpdate(enabled)
	if (type(enabled) ~= "boolean") then
		enabled = self.row_info.fast_ps_update
	end

	self.row_info.fast_ps_update = enabled

	self:CheckPsUpdate()
end


function Details:AdjustInLineTextPadding()
	for _, row in ipairs(self.barras) do
		row.lineText2:SetPoint("right", row.statusbar, "right", -self.fontstrings_text2_anchor, self.row_info.text_yoffset)
		row.lineText3:SetPoint("right", row.statusbar, "right", -self.fontstrings_text3_anchor, self.row_info.text_yoffset)
		row.lineText4:SetPoint("right", row.statusbar, "right", -self.fontstrings_text4_anchor, self.row_info.text_yoffset)
	end
end

-- search key: ~row ~bar ~updatebar
function Details:InstanceRefreshRows(instance)
	if (instance) then
		self = instance
	end

	if (not self.barras or not self.barras[1]) then
		return
	end

	--mirror
	local isInvertedBars = self.bars_inverted

	--texture
	local textureFile = SharedMedia:Fetch("statusbar", self.row_info.texture)
	local textureFile2 = SharedMedia:Fetch("statusbar", self.row_info.texture_background)

	--update texture files
	self.row_info.texture_file = textureFile
	self.row_info.texture_background_file = textureFile2

	if (type(self.row_info.texture_custom) == "string" and self.row_info.texture_custom ~= "") then
		textureFile = [[Interface\]] .. self.row_info.texture_custom
		--update texture file
		self.row_info.texture_custom_file = textureFile
	end

	--outline values
	local left_text_outline = self.row_info.textL_outline
	local right_text_outline = self.row_info.textR_outline
	local textL_outline_small = self.row_info.textL_outline_small
	local textL_outline_small_color = self.row_info.textL_outline_small_color
	local textR_outline_small = self.row_info.textR_outline_small
	local textR_outline_small_color = self.row_info.textR_outline_small_color

	--texture color values
	local bUseClassColor = self.row_info.texture_class_colors
	local texture_r, texture_g, texture_b
	if (not bUseClassColor) then
		texture_r, texture_g, texture_b = unpack(self.row_info.fixed_texture_color)
	end

	--text color
	local left_text_class_color = self.row_info.textL_class_colors
	local right_text_class_color = self.row_info.textR_class_colors
	local text_r, text_g, text_b
	if (not left_text_class_color or not right_text_class_color) then
		text_r, text_g, text_b = unpack(self.row_info.fixed_text_color)
	end

	local height = self.row_info.height

	--alpha
	local alpha = self.row_info.alpha

	--icons
	local no_icon = self.row_info.no_icon
	local start_after_icon = self.row_info.start_after_icon
	local isDesaturated = self.row_info.icon_grayscale
	local icon_offset_x, icon_offset_y = unpack(self.row_info.icon_offset)
	local iconMask = self.row_info.icon_mask
	local bHasIconMask = iconMask ~= ""

	--line border
	local lineBorderEnabled = self.row_info.backdrop.enabled
	local lineBorderColor = self.row_info.backdrop.color
	local lineBorderSize = self.row_info.backdrop.size

	--font face
	self.row_info.font_face_file = SharedMedia:Fetch("font", self.row_info.font_face)

	--models
	local upper_model_enabled = self.row_info.models.upper_enabled
	local lower_model_enabled = self.row_info.models.lower_enabled
	local upper_model = self.row_info.models.upper_model
	local lower_model = self.row_info.models.lower_model
	local upper_model_alpha = self.row_info.models.upper_alpha
	local lower_model_alpha = self.row_info.models.lower_alpha

	local overlayTexture = SharedMedia:Fetch("statusbar", self.row_info.overlay_texture)
	local overlayColor = self.row_info.overlay_color

	for _, row in ipairs(self.barras) do
		--positioning and size
		row:SetHeight(height)
		row.icone_classe:SetSize(height, height)

		if (isDesaturated) then
			row.icone_classe:SetDesaturated(true)
			row.iconHighlight:SetDesaturated(true)
		else
			row.icone_classe:SetDesaturated(false)
			row.iconHighlight:SetDesaturated(false)
		end

		--icon and texture anchors
		if (not isInvertedBars) then
			row.lineText1:ClearAllPoints()

			row.lineText2:ClearAllPoints()
			row.lineText3:ClearAllPoints()
			row.lineText4:ClearAllPoints()

			row.lineText1:SetJustifyH("left")
			row.lineText2:SetJustifyH("right")
			row.lineText3:SetJustifyH("right")
			row.lineText4:SetJustifyH("right")

			if (not self.use_multi_fontstrings) then
				row.lineText2:SetText("")
				row.lineText3:SetText("")
			end

			row.lineText4:SetText("")

			row.lineText2:SetPoint("right", row.statusbar, "right", -self.fontstrings_text2_anchor, self.row_info.text_yoffset)
			row.lineText3:SetPoint("right", row.statusbar, "right", -self.fontstrings_text3_anchor, self.row_info.text_yoffset)
			row.lineText4:SetPoint("right", row.statusbar, "right", -self.fontstrings_text4_anchor, self.row_info.text_yoffset)

			if (no_icon) then
				row.statusbar:SetPoint("topleft", row, "topleft")
				row.statusbar:SetPoint("bottomright", row, "bottomright")
				row.lineText1:SetPoint("left", row.statusbar, "left", self.row_info.textL_offset + 2, self.row_info.text_yoffset)
				row.icone_classe:Hide()
				row.iconHighlight:Hide()
			else
				row.icone_classe:ClearAllPoints()
				row.icone_classe:SetPoint("left", row, "left", icon_offset_x, icon_offset_y)
				row.icone_classe:Show()

				if (start_after_icon) then
					row.statusbar:SetPoint("topleft", row.icone_classe, "topright")
				else
					row.statusbar:SetPoint("topleft", row, "topleft")
				end

				row.statusbar:SetPoint("bottomright", row, "bottomright")
				row.lineText1:SetPoint("left", row.icone_classe, "right", self.row_info.textL_offset + 3, self.row_info.text_yoffset)
			end
		else
			row.lineText1:ClearAllPoints()
			row.lineText2:ClearAllPoints()
			row.lineText3:ClearAllPoints()
			row.lineText4:ClearAllPoints()

			row.lineText4:SetJustifyH("left")
			row.lineText3:SetJustifyH("left")
			row.lineText2:SetJustifyH("left")
			row.lineText1:SetJustifyH("right")

			row.lineText4:SetPoint("left", row.statusbar, "left", self.fontstrings_text4_anchor + 1, self.row_info.text_yoffset)
			row.lineText3:SetPoint("left", row.statusbar, "left", self.fontstrings_text3_anchor + 1, self.row_info.text_yoffset)
			row.lineText2:SetPoint("left", row.statusbar, "left", self.fontstrings_text2_anchor + 1, self.row_info.text_yoffset)

			if (no_icon) then
				row.statusbar:SetPoint("topleft", row, "topleft")
				row.statusbar:SetPoint("bottomright", row, "bottomright")
				row.lineText1:SetPoint("right", row.statusbar, "right", -self.row_info.textL_offset - 2, self.row_info.text_yoffset)
				row.icone_classe:Hide()
				row.iconHighlight:Hide()
				--[[ Deprecation of right_to_left_texture in favor of StatusBar:SetReverseFill 5/2/2022 - Flamanis
				row.right_to_left_texture:SetPoint("topright", row.statusbar, "topright")
				row.right_to_left_texture:SetPoint("bottomright", row.statusbar, "bottomright")]]

			else
				row.icone_classe:ClearAllPoints()
				row.icone_classe:SetPoint("right", row, "right", icon_offset_x, icon_offset_y)
				row.icone_classe:Show()

				if (start_after_icon) then
					row.statusbar:SetPoint("bottomright", row.icone_classe, "bottomleft")
				else
					row.statusbar:SetPoint("bottomright", row, "bottomright")
				end

				row.statusbar:SetPoint("topleft", row, "topleft")

				row.lineText1:SetPoint("right", row.icone_classe, "left", -self.row_info.textL_offset - 2, self.row_info.text_yoffset)
			end
		end

		if (bHasIconMask) then
			if (not row.icone_classe.maskTexture) then
				row.icone_classe.maskTexture = row:CreateMaskTexture("$parentClassIconMask", "overlay")
				row.icone_classe.maskTexture:SetAllPoints(row.icone_classe)
				row.icone_classe:AddMaskTexture(row.icone_classe.maskTexture)
			end
			row.icone_classe.maskTexture:SetTexture(iconMask)
			row.icone_classe.maskTexture:Show()
		else
			if (row.icone_classe.maskTexture) then
				row.icone_classe.maskTexture:Hide()
				row.icone_classe.maskTexture:SetTexture("")
			end
		end

		if (not self.row_info.texture_background_class_color) then
			local color = self.row_info.fixed_texture_background_color
			row.background:SetVertexColor(color[1], color[2], color[3], color[4])
		else
			local color = self.row_info.fixed_texture_background_color
			local r, g, b = row.background:GetVertexColor()
			row.background:SetVertexColor(r, g, b, color[4])
		end

		--outline
		if (left_text_outline) then
			Details:SetFontOutline(row.lineText1, left_text_outline)
		else
			Details:SetFontOutline(row.lineText1, nil)
		end

		if (right_text_outline) then
			self:SetFontOutline(row.lineText2, right_text_outline)
			self:SetFontOutline(row.lineText3, right_text_outline)
			self:SetFontOutline(row.lineText4, right_text_outline)
		else
			self:SetFontOutline(row.lineText2, nil)
			self:SetFontOutline(row.lineText3, nil)
			self:SetFontOutline(row.lineText4, nil)
		end

		--small outline
		if (textL_outline_small) then
			local color = textL_outline_small_color
			row.lineText1:SetShadowColor(color[1], color[2], color[3], color[4])
		else
			row.lineText1:SetShadowColor(0, 0, 0, 0)
		end

		if (textR_outline_small) then
			local color = textR_outline_small_color
			row.lineText4:SetShadowColor(color[1], color[2], color[3], color[4])
			row.lineText3:SetShadowColor(color[1], color[2], color[3], color[4])
			row.lineText2:SetShadowColor(color[1], color[2], color[3], color[4])
		else
			row.lineText4:SetShadowColor(0, 0, 0, 0)
			row.lineText3:SetShadowColor(0, 0, 0, 0)
			row.lineText2:SetShadowColor(0, 0, 0, 0)
		end

		--texture
		row.textura:SetTexture(textureFile)
		row.background:SetTexture(textureFile2)
		row.overlayTexture:SetTexture(overlayTexture)
		row.overlayTexture:SetVertexColor(unpack(overlayColor))

		if (isInvertedBars) then
			row.statusbar:SetReverseFill(true)
			else
			row.statusbar:SetReverseFill(false)
		end

		--texture class color: if true color changes on the fly through class refresh
		if (not bUseClassColor) then
			row.textura:SetVertexColor(texture_r, texture_g, texture_b, alpha)
		else
			--automatically color the bar by the actor class
			--forcing alpha 1 instead of use the alpha from the fixed color
			local r, g, b = row.textura:GetVertexColor()
			row.textura:SetVertexColor(r, g, b, 1) --alpha
		end

		--text class color: if true color changes on the fly through class refresh
		if (not left_text_class_color) then
			row.lineText1:SetTextColor(text_r, text_g, text_b)
		end
		if (not right_text_class_color) then
			row.lineText4:SetTextColor(text_r, text_g, text_b)
			row.lineText3:SetTextColor(text_r, text_g, text_b)
			row.lineText2:SetTextColor(text_r, text_g, text_b)
		end

		--text size
		Details:SetFontSize(row.lineText1, self.row_info.font_size or height * 0.75)
		Details:SetFontSize(row.lineText2, self.row_info.font_size or height * 0.75)
		Details:SetFontSize(row.lineText3, self.row_info.font_size or height * 0.75)
		Details:SetFontSize(row.lineText4, self.row_info.font_size or height * 0.75)

		--text font
		Details:SetFontFace(row.lineText1, self.row_info.font_face_file or "GameFontHighlight")
		Details:SetFontFace(row.lineText2, self.row_info.font_face_file or "GameFontHighlight")
		Details:SetFontFace(row.lineText3, self.row_info.font_face_file or "GameFontHighlight")
		Details:SetFontFace(row.lineText4, self.row_info.font_face_file or "GameFontHighlight")

		--backdrop
		if (lineBorderEnabled) then
			row.lineBorder:Show()
			row.lineBorder:SetVertexColor(unpack(lineBorderColor))
			row.lineBorder:SetBorderSizes(lineBorderSize, lineBorderSize, lineBorderSize, lineBorderSize)
			row.lineBorder:UpdateSizes()
		else
			row.lineBorder:Hide()
		end

		--models
		if (upper_model_enabled) then
			row.using_upper_3dmodels = true
			row.modelbox_high:Show()
			row.modelbox_high:SetModel(upper_model)
			row.modelbox_high:SetAlpha(upper_model_alpha)
		else
			row.using_upper_3dmodels = false
			row.modelbox_high:Hide()
		end

		if (lower_model_enabled) then
			row.using_lower_3dmodels = true
			row.modelbox_low:Show()
			row.modelbox_low:SetModel(lower_model)
			row.modelbox_low:SetAlpha(lower_model_alpha)
		else
			row.using_lower_3dmodels = false
			row.modelbox_low:Hide()
		end

	end

	self:SetBarGrowDirection()
	self:UpdateClickThrough()
end

function Details:SetBarOverlaySettings(overlayTexture, overlayColor)
	overlayTexture = overlayTexture or self.row_info.overlay_texture
	overlayColor = overlayColor or self.row_info.overlay_color
	self.row_info.overlay_texture = overlayTexture
	self.row_info.overlay_color[1] = overlayColor[1]
	self.row_info.overlay_color[2] = overlayColor[2]
	self.row_info.overlay_color[3] = overlayColor[3]
	self.row_info.overlay_color[4] = overlayColor[4]
	self:InstanceRefreshRows()
end

--adjust to which frame the wallpaper texture is parented to
--dependind on the frame it can be shown above or below background textures
function Details:SetInstanceWallpaperLevel(wallpaperLevel)
	if (type(wallpaperLevel) ~= "number") then
		wallpaperLevel = self.wallpaper.level
	end

	self.wallpaper.level = wallpaperLevel

	--refresh the wallpaper parent
	local wallpaperTexture = self.baseframe.wallpaper

	if (wallpaperLevel == 0) then
		wallpaperTexture:SetParent(self.baseframe.titleBar) --framelevel +0 (parented to titleBar)

	elseif (wallpaperLevel == 1) then
		wallpaperTexture:SetParent(self.baseframe) --framelevel +0

	elseif (wallpaperLevel == 2) then
		wallpaperTexture:SetParent(self.rowframe) --framelevel +3

	elseif (wallpaperLevel == 3) then
		wallpaperTexture:SetParent(self.windowSwitchButton) --framelevel +4
	end
end

-- search key: ~wallpaper
function Details:InstanceWallpaper(texture, anchor, alpha, texCoord, width, height, overlay)
	local wallpaper = self.wallpaper

	if (type(texture) == "boolean" and texture) then
		texture, anchor, alpha, texCoord, width, height, overlay = wallpaper.texture, wallpaper.anchor, wallpaper.alpha, wallpaper.texcoord, wallpaper.width, wallpaper.height, wallpaper.overlay

	elseif (type(texture) == "boolean" and not texture) then
		self.wallpaper.enabled = false
		return Details.FadeHandler.Fader(self.baseframe.wallpaper, "in")

	elseif (type(texture) == "table") then
		anchor = texture.anchor or wallpaper.anchor
		alpha = texture.alpha or wallpaper.alpha

		if (texture.texcoord) then
			texCoord = {unpack(texture.texcoord)}
		else
			texCoord = wallpaper.texcoord
		end

		width = texture.width or wallpaper.width
		height = texture.height or wallpaper.height

		if (texture.overlay) then
			overlay = {unpack(texture.overlay)}
		else
			overlay = wallpaper.overlay
		end

		if (type(texture.enabled) == "boolean") then
			if (not texture.enabled) then
				wallpaper.enabled = false
				wallpaper.texture = texture.texture or wallpaper.texture
				wallpaper.anchor = anchor
				wallpaper.alpha = alpha
				wallpaper.texcoord = texCoord
				wallpaper.width = width
				wallpaper.height = height
				wallpaper.overlay = overlay
				return self:InstanceWallpaper (false)
			end
		end

		texture = texture.texture or wallpaper.texture

	else
		texture = texture or wallpaper.texture
		anchor = anchor or wallpaper.anchor
		alpha = alpha or wallpaper.alpha
		texCoord = texCoord or wallpaper.texcoord
		width = width or wallpaper.width
		height = height or wallpaper.height
		overlay = overlay or wallpaper.overlay
	end

	if (not wallpaper.texture and not texture) then
		texture = "Interface\\AddOns\\Details\\images\\background"
		texCoord = {0, 1, 0, 0.7}
		alpha = 0.5
		width, height = self:GetSize()
		anchor = "all"
	end

	local wallpaperTable = self.baseframe.wallpaper

	wallpaperTable:ClearAllPoints()

	if (anchor == "all") then
		wallpaperTable:SetPoint("topleft", self.baseframe, "topleft")
		wallpaperTable:SetPoint("bottomright", self.baseframe, "bottomright")

	elseif (anchor == "titlebar") then
		wallpaperTable:SetPoint("topleft", self.baseframe.titleBar, "topleft", 0, 0)
		wallpaperTable:SetPoint("bottomright", self.baseframe, "bottomright", 1, -1)

	elseif (anchor == "center") then
		wallpaperTable:SetPoint("center", self.baseframe, "center", 0, 4)

	elseif (anchor == "stretchLR") then
		wallpaperTable:SetPoint("center", self.baseframe, "center")
		wallpaperTable:SetPoint("left", self.baseframe, "left")
		wallpaperTable:SetPoint("right", self.baseframe, "right")

	elseif (anchor == "stretchTB") then
		wallpaperTable:SetPoint("center", self.baseframe, "center")
		wallpaperTable:SetPoint("top", self.baseframe, "top")
		wallpaperTable:SetPoint("bottom", self.baseframe, "bottom")

	else
		wallpaperTable:SetPoint(anchor, self.baseframe, anchor)
	end

	wallpaperTable:SetTexture(texture)
	wallpaperTable:SetTexCoord(unpack(texCoord))
	wallpaperTable:SetWidth(width)
	wallpaperTable:SetHeight(height)
	wallpaperTable:SetVertexColor(unpack(overlay))

	wallpaper.enabled = true
	wallpaper.texture = texture
	wallpaper.anchor = anchor
	wallpaper.alpha = alpha
	wallpaper.texcoord = texCoord
	wallpaper.width = width
	wallpaper.height = height
	wallpaper.overlay = overlay

	wallpaperTable:Show()
	Details.FadeHandler.Fader(wallpaperTable, "ALPHAANIM", alpha)
end

function Details:GetTextures()
	local textureTable = {}
	textureTable[1] = self.baseframe.rodape.esquerdo
	textureTable[2] = self.baseframe.rodape.direita
	textureTable[3] = self.baseframe.rodape.top_bg

	textureTable[4] = self.baseframe.cabecalho.ball_r
	textureTable[5] = self.baseframe.cabecalho.ball
	textureTable[6] = self.baseframe.cabecalho.emenda
	textureTable[7] = self.baseframe.cabecalho.top_bg

	textureTable[8] = self.baseframe.barra_esquerda
	textureTable[9] = self.baseframe.barra_direita
	textureTable[10] = self.baseframe.UPFrame
	return textureTable
end

function Details:SetWindowAlphaForInteract(alpha)
	local ignoreBars = self.menu_alpha.ignorebars

	if (self.is_interacting) then
		--mouse entered the window
		self.baseframe:SetAlpha(alpha)
		self:InstanceAlpha(alpha)
		self:SetIconAlpha(alpha, nil, true)

		if (ignoreBars) then
			self.rowframe:SetFrameAlpha(maxAlpha)
		else
			self.rowframe:SetFrameAlpha(alpha)
		end
	else
		--mouse left the window
		if (self.combat_changes_alpha and self.combat_changes_alpha ~= 1) then --combat alpha
			self:InstanceAlpha(self.combat_changes_alpha)
			self:SetIconAlpha(self.combat_changes_alpha, nil, true)
			self.rowframe:SetFrameAlpha(self.combat_changes_alpha) --alpha do combate � absoluta
			self.baseframe:SetAlpha(self.combat_changes_alpha) --alpha do combate � absoluta

		else
			self:InstanceAlpha(alpha)
			self:SetIconAlpha(alpha, nil, true)

			if (ignoreBars) then
				self.rowframe:SetFrameAlpha(maxAlpha)
			else
				self.rowframe:SetFrameAlpha(alpha)
			end

			self.baseframe:SetAlpha(alpha)
		end
	end

	if (Details.debug) then
		Details:Msg("(debug) setting window alpha for SetWindowAlphaForInteract() -> ", alpha)
	end
end

-- ~autohide �utohide
function Details:SetWindowAlphaForCombat(enteringInCombat, trueHide, alphaAmount)
	local amount, rowsamount, menuamount

	--get the values
	if (enteringInCombat) then
		amount = alphaAmount / 100
		self.combat_changes_alpha = amount
		rowsamount = amount
		menuamount = amount
		if (Details.pet_battle) then
			amount = 0
			rowsamount = 0
			menuamount = 0
		end
	else
		if (self.menu_alpha.enabled) then --auto transparency
			if (self.is_interacting) then
				amount = self.menu_alpha.onenter
				menuamount = self.menu_alpha.onenter
				if (self.menu_alpha.ignorebars) then
					rowsamount = 1
				else
					rowsamount = amount
				end
			else
				amount = self.menu_alpha.onleave
				menuamount = self.menu_alpha.onleave
				if (self.menu_alpha.ignorebars) then
					rowsamount = 1
				else
					rowsamount = amount
				end
			end
		else
			amount = self.color[4]
			menuamount = 1
			rowsamount = 1
		end
		self.combat_changes_alpha = nil
	end

	--apply
	if (trueHide and amount == 0) then
		self.baseframe:Hide()
		self.rowframe:Hide()
		self.windowSwitchButton:Hide()
		if (Details.debug) then
			Details:Msg("(debug) hiding window SetWindowAlphaForCombat()", amount, rowsamount, menuamount)
		end
	else
		self.baseframe:Show()
		self.baseframe:SetAlpha(maxAlpha)

		self:InstanceAlpha(min(amount, self.color[4]))
		Details.FadeHandler.Fader(self.rowframe, "ALPHAANIM", parseRowFrameAlpha(rowsamount))
		Details.FadeHandler.Fader(self.baseframe, "ALPHAANIM", rowsamount)
	end

	if (self.show_statusbar) then
		self.baseframe.barra_fundo:Hide()
	end
	if (self.hide_icon) then
		self.baseframe.cabecalho.atributo_icon:Hide()
	end
end

--this function is called only from SetAutoHideMenu()
function Details:InstanceButtonsColors(red, green, blue, alpha, noSave, onlyLeft, onlyRight)
	if (not red) then
		red, green, blue, alpha = unpack(self.color_buttons)
	end

	if (type(red) ~= "number") then
		red, green, blue, alpha = gump:ParseColors(red)
	end

	if (not noSave) then
		self.color_buttons[1] = red
		self.color_buttons[2] = green
		self.color_buttons[3] = blue
		self.color_buttons[4] = alpha
	end

	local baseToolbar = self.baseframe.cabecalho

	if (onlyLeft) then
		local icons = {baseToolbar.modo_selecao, baseToolbar.segmento, baseToolbar.atributo, baseToolbar.report, baseToolbar.fechar, baseToolbar.reset, baseToolbar.fechar}
		for _, button in ipairs(icons) do
			button:SetAlpha(alpha)
		end

		if (self:IsLowerInstance()) then
			for _, ThisButton in ipairs(Details.ToolBar.Shown) do
				ThisButton:SetAlpha(alpha)
			end
		end
	else
		local icons = {baseToolbar.modo_selecao, baseToolbar.segmento, baseToolbar.atributo, baseToolbar.report, baseToolbar.fechar, baseToolbar.reset, baseToolbar.fechar}
		for _, button in ipairs(icons) do
			button:SetAlpha(alpha)
		end

		if (self:IsLowerInstance()) then
			for _, ThisButton in ipairs(Details.ToolBar.Shown) do
				ThisButton:SetAlpha(alpha)
			end
		end
	end
end

function Details:InstanceAlpha(alpha)
	self.baseframe.cabecalho.ball_r:SetAlpha(alpha)
	self.baseframe.cabecalho.ball:SetAlpha(alpha)

	local skin = Details.skins[self.skin]
	if (not skin.icon_ignore_alpha) then
		self.baseframe.cabecalho.atributo_icon:SetAlpha(alpha)
	end

	self.baseframe.cabecalho.emenda:SetAlpha(alpha)
	self.baseframe.cabecalho.top_bg:SetAlpha(alpha)
	self.baseframe.barra_esquerda:SetAlpha(alpha)
	self.baseframe.barra_direita:SetAlpha(alpha)
	self.baseframe.barra_fundo:SetAlpha(alpha)
	self.baseframe.UPFrame:SetAlpha(alpha)
end

function Details:InstanceColor(red, green, blue, alpha, noSave, changeStatusbar)
	if (not red) then
		red, green, blue, alpha = unpack(self.color)
		noSave = true
	end

	if (type(red) ~= "number") then
		red, green, blue, alpha = gump:ParseColors(red)
	end

	if (not noSave) then
		--saving
		self.color[1] = red
		self.color[2] = green
		self.color[3] = blue
		self.color[4] = alpha
		if (changeStatusbar) then
			self:StatusBarColor(red, green, blue, alpha)
		end
	else
		--not saving
		self:StatusBarColor(nil, nil, nil, alpha, true)
	end

	local skin = Details.skins[self.skin]
	if (not skin) then --the skin isn't available any more
		--put the skin into wait to install
		local tempSkin = self:WaitForSkin()
		skin = tempSkin
	end

	self.baseframe.cabecalho.ball_r:SetVertexColor(red, green, blue)
		self.baseframe.cabecalho.ball_r:SetAlpha(alpha)

	self.baseframe.cabecalho.ball:SetVertexColor(red, green, blue)
		self.baseframe.cabecalho.ball:SetAlpha(alpha)

	if (not skin.icon_ignore_alpha) then
		self.baseframe.cabecalho.atributo_icon:SetAlpha(alpha)
	end

	self.baseframe.cabecalho.emenda:SetVertexColor(red, green, blue)
		self.baseframe.cabecalho.emenda:SetAlpha(alpha)
	self.baseframe.cabecalho.top_bg:SetVertexColor(red, green, blue)
		self.baseframe.cabecalho.top_bg:SetAlpha(alpha)

	self.baseframe.barra_esquerda:SetVertexColor(red, green, blue)
		self.baseframe.barra_esquerda:SetAlpha(alpha)
	self.baseframe.barra_direita:SetVertexColor(red, green, blue)
		self.baseframe.barra_direita:SetAlpha(alpha)
	self.baseframe.barra_fundo:SetVertexColor(red, green, blue)
		self.baseframe.barra_fundo:SetAlpha(alpha)

	self.baseframe.UPFrame:SetAlpha(alpha)
end

function Details:StatusBarAlertTime(instance)
	instance.baseframe.statusbar:Hide()
end

function Details:StatusBarAlert(text, icon, color, time)
	local statusbar = self.baseframe.statusbar

	if (text) then
		if (type(text) == "table") then
			if (text.color) then
				statusbar.text:SetTextColor(gump:ParseColors(text.color))
			else
				statusbar.text:SetTextColor(1, 1, 1, 1)
			end

			statusbar.text:SetText(text.text or "")

			if (text.size) then
				Details:SetFontSize(statusbar.text, text.size)
			else
				Details:SetFontSize(statusbar.text, 9)
			end
		else
			statusbar.text:SetText(text)
			statusbar.text:SetTextColor(1, 1, 1, 1)
			Details:SetFontSize(statusbar.text, 9)
		end
	else
		statusbar.text:SetText("")
	end

	if (icon) then
		if (type(icon) == "table") then
			local texture, w, h, l, r, t, b = unpack(icon)
			statusbar.icon:SetTexture(texture)
			statusbar.icon:SetWidth(w or 14)
			statusbar.icon:SetHeight(h or 14)
			if (l and r and t and b) then
				statusbar.icon:SetTexCoord(l, r, t, b)
			end
		else
			statusbar.icon:SetTexture(icon)
			statusbar.icon:SetWidth(14)
			statusbar.icon:SetHeight(14)
			statusbar.icon:SetTexCoord(0, 1, 0, 1)
		end
	else
		statusbar.icon:SetTexture("")
	end

	if (color) then
		statusbar:SetBackdropColor(gump:ParseColors(color))
	else
		statusbar:SetBackdropColor(0, 0, 0, 1)
	end

	if (icon or text) then
		statusbar:Show()
		if (time) then
			Details:ScheduleTimer("StatusBarAlertTime", time, self)
		end
	else
		statusbar:Hide()
	end
end

function gump:CriaRodape(baseframe, instancia)
	baseframe.rodape = {}

	--esquerdo com statusbar
	baseframe.rodape.esquerdo = instancia.floatingframe:CreateTexture(nil, "overlay")
	baseframe.rodape.esquerdo:SetPoint("topright", baseframe, "bottomleft", 16, 0)
	baseframe.rodape.esquerdo:SetTexture(DEFAULT_SKIN)
	baseframe.rodape.esquerdo:SetTexCoord(unpack(COORDS_PIN_LEFT))
	baseframe.rodape.esquerdo:SetWidth(32)
	baseframe.rodape.esquerdo:SetHeight(32)

	--esquerdo sem statusbar
	baseframe.rodape.esquerdo_nostatusbar = instancia.floatingframe:CreateTexture(nil, "overlay")
	baseframe.rodape.esquerdo_nostatusbar:SetPoint("topright", baseframe, "bottomleft", 16, 14)
	baseframe.rodape.esquerdo_nostatusbar:SetTexture(DEFAULT_SKIN)
	baseframe.rodape.esquerdo_nostatusbar:SetTexCoord(unpack(COORDS_PIN_LEFT))
	baseframe.rodape.esquerdo_nostatusbar:SetWidth(32)
	baseframe.rodape.esquerdo_nostatusbar:SetHeight(32)

	--direito com statusbar
	baseframe.rodape.direita = instancia.floatingframe:CreateTexture(nil, "overlay")
	baseframe.rodape.direita:SetPoint("topleft", baseframe, "bottomright", -16, 0)
	baseframe.rodape.direita:SetTexture(DEFAULT_SKIN)
	baseframe.rodape.direita:SetTexCoord(unpack(COORDS_PIN_RIGHT))
	baseframe.rodape.direita:SetWidth(32)
	baseframe.rodape.direita:SetHeight(32)

	--direito sem statusbar
	baseframe.rodape.direita_nostatusbar = instancia.floatingframe:CreateTexture(nil, "overlay")
	baseframe.rodape.direita_nostatusbar:SetPoint("topleft", baseframe, "bottomright", -16, 14)
	baseframe.rodape.direita_nostatusbar:SetTexture(DEFAULT_SKIN)
	baseframe.rodape.direita_nostatusbar:SetTexCoord(unpack(COORDS_PIN_RIGHT))
	baseframe.rodape.direita_nostatusbar:SetWidth(32)
	baseframe.rodape.direita_nostatusbar:SetHeight(32)

	--barra centro
	baseframe.rodape.top_bg = baseframe:CreateTexture(nil, "background")
	baseframe.rodape.top_bg:SetTexture(DEFAULT_SKIN)
	baseframe.rodape.top_bg:SetTexCoord(unpack(COORDS_BOTTOM_BACKGROUND))
	baseframe.rodape.top_bg:SetWidth(512)
	baseframe.rodape.top_bg:SetHeight(128)
	baseframe.rodape.top_bg:SetPoint("left", baseframe.rodape.esquerdo, "right", -16, -48)
	baseframe.rodape.top_bg:SetPoint("right", baseframe.rodape.direita, "left", 16, -48)

	local StatusBarLeftAnchor = CreateFrame("frame", "DetailsStatusBarAnchorLeft" .. instancia.meu_id, baseframe)
	StatusBarLeftAnchor:SetPoint("left", baseframe.rodape.top_bg, "left", 5, 57)
	StatusBarLeftAnchor:SetWidth(1)
	StatusBarLeftAnchor:SetHeight(1)
	baseframe.rodape.StatusBarLeftAnchor = StatusBarLeftAnchor

	local StatusBarCenterAnchor = CreateFrame("frame", "DetailsStatusBarAnchorCenter" .. instancia.meu_id, baseframe)
	StatusBarCenterAnchor:SetPoint("center", baseframe.rodape.top_bg, "center", 0, 57)
	StatusBarCenterAnchor:SetWidth(1)
	StatusBarCenterAnchor:SetHeight(1)
	baseframe.rodape.StatusBarCenterAnchor = StatusBarCenterAnchor

	--display frame
	baseframe.statusbar = CreateFrame("frame", "DetailsStatusBar" .. instancia.meu_id, instancia.floatingframe,"BackdropTemplate")
	baseframe.statusbar:SetFrameLevel(instancia.floatingframe:GetFrameLevel() + 2)
	baseframe.statusbar:SetPoint("left", baseframe.rodape.esquerdo, "right", -13, 10)
	baseframe.statusbar:SetPoint("right", baseframe.rodape.direita, "left", 13, 10)
	baseframe.statusbar:SetHeight(14)

	local statusbar_icon = baseframe.statusbar:CreateTexture(nil, "overlay")
	statusbar_icon:SetWidth(14)
	statusbar_icon:SetHeight(14)
	statusbar_icon:SetPoint("left", baseframe.statusbar, "left")

	local statusbar_text = baseframe.statusbar:CreateFontString(nil, "overlay", "GameFontNormal")
	statusbar_text:SetPoint("left", statusbar_icon, "right", 2, 0)

	baseframe.statusbar:SetBackdrop({
	bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 16,
	insets = {left = 0, right = 0, top = 0, bottom = 0}})
	baseframe.statusbar:SetBackdropColor(0, 0, 0, 1)

	baseframe.statusbar.icon = statusbar_icon
	baseframe.statusbar.text = statusbar_text
	baseframe.statusbar.instancia = instancia

	baseframe.statusbar:Hide()

	--frame invis�vel
	baseframe.DOWNFrame = CreateFrame("frame", "DetailsDownFrame" .. instancia.meu_id, baseframe)
	baseframe.DOWNFrame:SetPoint("left", baseframe.rodape.esquerdo, "right", 0, 10)
	baseframe.DOWNFrame:SetPoint("right", baseframe.rodape.direita, "left", 0, 10)
	baseframe.DOWNFrame:SetHeight(14)

	baseframe.DOWNFrame:Show()
	baseframe.DOWNFrame:EnableMouse(true)
	baseframe.DOWNFrame:SetMovable(true)
	baseframe.DOWNFrame:SetResizable(true)

	BGFrame_scripts(baseframe.DOWNFrame, baseframe, instancia)
end

function Details:GetMenuAnchorPoint()
	local toolbar_side = self.toolbar_side
	local menu_side = self.menu_anchor.side

	if (menu_side == 1) then --left
		if (toolbar_side == 1) then --top
			return self.menu_points [1], "bottomleft", "bottomright"

		elseif (toolbar_side == 2) then --bottom
			return self.menu_points [1], "topleft", "topright"
		end

	elseif (menu_side == 2) then --right
		if (toolbar_side == 1) then --top
			return self.menu_points [2], "topleft", "bottomleft"

		elseif (toolbar_side == 2) then --bottom
			return self.menu_points [2], "topleft", "topleft"
		end
	end
end

--search key: ~icon
function Details:ToolbarMenuButtonsSize(size)
	size = size or self.menu_icons_size
	self.menu_icons_size = size
	return self:ToolbarMenuButtons()
end

local SetIconAlphaCacheButtonsTable = {}
function Details:SetIconAlpha(alpha, hide, noAnimations)
	if (self.attribute_text.enabled) then
		if (not self.menu_attribute_string) then
			--created on demand
			self:AttributeMenu()
		end

		if (hide) then
			Details.FadeHandler.Fader(self.menu_attribute_string.widget, unpack(Details.windows_fade_in))
		else
			if (noAnimations) then
				self.menu_attribute_string:SetAlpha(alpha)
			else
				Details.FadeHandler.Fader(self.menu_attribute_string.widget, "ALPHAANIM", alpha)
			end
		end
	end

	Details:Destroy(SetIconAlphaCacheButtonsTable)
	SetIconAlphaCacheButtonsTable[1] = self.baseframe.cabecalho.modo_selecao
	SetIconAlphaCacheButtonsTable[2] = self.baseframe.cabecalho.segmento
	SetIconAlphaCacheButtonsTable[3] = self.baseframe.cabecalho.atributo
	SetIconAlphaCacheButtonsTable[4] = self.baseframe.cabecalho.report
	SetIconAlphaCacheButtonsTable[5] = self.baseframe.cabecalho.reset
	SetIconAlphaCacheButtonsTable[6] = self.baseframe.cabecalho.fechar

	if (alpha == 1) then
		alpha = self.menu_icons_alpha
		--fix for old instances using 0.5 in the 'menu_icons_alpha'
		if (DetailsFramework:IsNearlyEqual(self.menu_icons_alpha, 0.5)) then
			self.menu_icons_alpha = Details.skins[self.skin].instance_cprops.menu_icons_alpha or self.menu_icons_alpha
			alpha = self.menu_icons_alpha
		end
	end

	for index, button in ipairs(SetIconAlphaCacheButtonsTable) do
		if (self.menu_icons[index]) then
			if (hide) then
				button:Hide()
			else
				button:Show()
				button:SetAlpha(alpha)
			end
		end
	end

	if (self:IsLowerInstance()) then
		if (#Details.ToolBar.Shown > 0) then
			for index, button in ipairs(Details.ToolBar.Shown) do
				if (hide) then
					Details.FadeHandler.Fader(button, unpack(Details.windows_fade_in))
				else
					if (noAnimations) then
						button:SetAlpha(alpha)
					else
						Details.FadeHandler.Fader(button, "ALPHAANIM", alpha)
					end
				end
			end
		end
	end
end

function Details:ToolbarMenuSetButtonsOptions(spacement, iconShadows)
	if (type(spacement) ~= "number") then
		spacement = self.menu_icons.space
	end

	if (type(iconShadows) ~= "boolean") then
		iconShadows = self.menu_icons.shadow
	end

	self.menu_icons.space = spacement
	self.menu_icons.shadow = iconShadows

	return self:ToolbarMenuSetButtons()
end

-- search key: ~buttons ~icons
local tbuttons = {}
function Details:ToolbarMenuSetButtons(_mode, _segment, _attributes, _report, _reset, _close)
	if (_mode == nil) then
		_mode = self.menu_icons[1]
	end

	if (_segment == nil) then
		_segment = self.menu_icons[2]
	end

	if (_attributes == nil) then
		_attributes = self.menu_icons[3]
	end

	if (_report == nil) then
		_report = self.menu_icons[4]
	end

	if (_reset == nil) then
		_reset = self.menu_icons[5]
	end

	if (_close == nil) then
		_close = self.menu_icons[6]
	end

	self.menu_icons[1] = _mode
	self.menu_icons[2] = _segment
	self.menu_icons[3] = _attributes
	self.menu_icons[4] = _report
	self.menu_icons[5] = _reset
	self.menu_icons[6] = _close

	Details:Destroy(tbuttons)

	tbuttons[1] = self.baseframe.cabecalho.modo_selecao
	tbuttons[2] = self.baseframe.cabecalho.segmento
	tbuttons[3] = self.baseframe.cabecalho.atributo
	tbuttons[4] = self.baseframe.cabecalho.report
	tbuttons[5] = self.baseframe.cabecalho.reset
	tbuttons[6] = self.baseframe.cabecalho.fechar

	local anchor_frame, point1, point2 = self:GetMenuAnchorPoint()
	local got_anchor = false

	self.lastIcon = nil
	self.firstIcon = nil

	local size = self.menu_icons_size
	local space = self.menu_icons.space
	local shadow = self.menu_icons.shadow

	local toolbar_icon_file = self.toolbar_icon_file
	if (shadow) then
		toolbar_icon_file = toolbar_icon_file .. "_shadow"
	end

	local total_buttons_shown = 0

	--normal buttons
	if (self.menu_anchor.side == 1) then
		for index, button in ipairs(tbuttons) do
			if (self.menu_icons[index]) then
				button:ClearAllPoints()
				if (got_anchor) then
					button:SetPoint("left", self.lastIcon.widget or self.lastIcon, "right", space, 0)
				else
					button:SetPoint(point1, anchor_frame, point2)
					got_anchor = button
					self.firstIcon = button
				end

				self.lastIcon = button
				button:SetParent(self.baseframe)
				button:SetFrameLevel(self.baseframe.UPFrame:GetFrameLevel()+1)
				button:Show()

				button:SetSize(16 * size, 16 * size)

				button:SetNormalTexture(toolbar_icon_file)
				button:SetHighlightTexture(toolbar_icon_file)
				button:SetPushedTexture(toolbar_icon_file)

				total_buttons_shown = total_buttons_shown + 1
			else
				button:Hide()
			end
		end

	elseif (self.menu_anchor.side == 2) then
		for index = #tbuttons, 1, -1 do
			local button = tbuttons [index]

			if (self.menu_icons [index]) then
				button:ClearAllPoints()
				if (got_anchor) then
					button:SetPoint("right", self.lastIcon.widget or self.lastIcon, "left", -space, 0)
				else
					button:SetPoint(point1, anchor_frame, point2)
					got_anchor = button
					self.firstIcon = button
				end
				self.lastIcon = button
				button:SetParent(self.baseframe)
				button:SetFrameLevel(self.baseframe.UPFrame:GetFrameLevel()+1)
				button:Show()

				button:SetSize(16 * size, 16 * size)

				button:SetNormalTexture(toolbar_icon_file)
				button:SetHighlightTexture(toolbar_icon_file)
				button:SetPushedTexture(toolbar_icon_file)

				total_buttons_shown = total_buttons_shown + 1
			else
				button:Hide()
			end
		end
	end

	--plugins buttons
	local pluginFirstIcon = true
	if (not self.baseframe.cabecalho.PluginIconsSeparator) then
		self.baseframe.cabecalho.PluginIconsSeparator = self.baseframe:CreateTexture(nil, "overlay")
		self.baseframe.cabecalho.PluginIconsSeparator:SetTexture([[Interface\FriendsFrame\StatusIcon-Offline]])

		local color = 0
		self.baseframe.cabecalho.PluginIconsSeparator:SetVertexColor(color, color, color)
		self.baseframe.cabecalho.PluginIconsSeparator:SetAlpha(0.2)

		local scale = 0.4
		self.baseframe.cabecalho.PluginIconsSeparator:SetSize(16 * scale, 16 * scale)
	end

	self.baseframe.cabecalho.PluginIconsSeparator:Hide()

	if (self:IsLowerInstance()) then
		if (#Details.ToolBar.Shown > 0) then

			local last_plugin_icon

			if (#Details.ToolBar.Shown > 0) then
				self.baseframe.cabecalho.PluginIconsSeparator:Show()
				self.baseframe.cabecalho.PluginIconsSeparator:ClearAllPoints()
				self.baseframe.cabecalho.PluginIconsSeparator.widget = self.baseframe.cabecalho.PluginIconsSeparator
			end

			for index, button in ipairs(Details.ToolBar.Shown) do
				button:ClearAllPoints()

				if (got_anchor) then
					if (pluginFirstIcon) then
						-- space = space + 6 --was adding an extra padding between plugin icons
					end

					if (self.plugins_grow_direction == 2) then --right
						if (self.menu_anchor.side == 1) then --left

							local temp_space = space

							if (pluginFirstIcon) then
								temp_space = temp_space / 3
								self.baseframe.cabecalho.PluginIconsSeparator:SetPoint("left", last_plugin_icon or self.lastIcon.widget or self.lastIcon, "right", temp_space, 0)
								self.lastIcon = self.baseframe.cabecalho.PluginIconsSeparator
							end

							button:SetPoint("left", self.lastIcon.widget or self.lastIcon, "right", temp_space, 0)

						elseif (self.menu_anchor.side == 2) then --right

							local temp_space = space

							if (pluginFirstIcon) then
								temp_space = temp_space / 3
								self.baseframe.cabecalho.PluginIconsSeparator:SetPoint("left", last_plugin_icon or self.firstIcon.widget or self.firstIcon, "right", temp_space, 0)
								self.lastIcon = self.baseframe.cabecalho.PluginIconsSeparator
							end

							button:SetPoint("left", last_plugin_icon or self.lastIcon.widget or self.firstIcon, "right", temp_space, 0)

						end

					elseif (self.plugins_grow_direction == 1) then --left
						if (self.menu_anchor.side == 1) then --left

							local temp_space = space

							if (pluginFirstIcon) then
								temp_space = temp_space / 3
								self.baseframe.cabecalho.PluginIconsSeparator:SetPoint("right", last_plugin_icon or self.firstIcon.widget or self.firstIcon, "left", -temp_space, 0)
								self.lastIcon = self.baseframe.cabecalho.PluginIconsSeparator
							end

							button:SetPoint("right", last_plugin_icon or self.lastIcon.widget or self.firstIcon, "left", -temp_space, 0)

						elseif (self.menu_anchor.side == 2) then --right

							local temp_space = space

							if (pluginFirstIcon) then
								temp_space = temp_space / 3
								self.baseframe.cabecalho.PluginIconsSeparator:SetPoint("right", last_plugin_icon or self.lastIcon.widget or self.lastIcon, "left", -temp_space, 0)
								self.lastIcon = self.baseframe.cabecalho.PluginIconsSeparator

							end

							button:SetPoint("right", last_plugin_icon or self.lastIcon.widget or self.firstIcon, "left", -temp_space, 0)
						end
					end

					pluginFirstIcon = false
				else
					button:SetPoint(point1, anchor_frame, point2)
					self.firstIcon = button
					got_anchor = button
				end

				self.lastIcon = button
				last_plugin_icon = button

				button:SetParent(self.baseframe)
				button:SetFrameLevel(self.baseframe.UPFrame:GetFrameLevel()+1)
				button:Show()

				button:SetSize(16*size, 16*size)

				if (shadow and button.shadow) then
					button:SetNormalTexture(button.__icon .. "_shadow")
					button:SetPushedTexture(button.__icon .. "_shadow")
					button:SetHighlightTexture(button.__icon .. "_shadow", "ADD")
				else
					button:SetNormalTexture(button.__icon)
					button:SetPushedTexture(button.__icon)
					button:SetHighlightTexture(button.__icon, "ADD")
				end

				total_buttons_shown = total_buttons_shown + 1
			end
		end

		if (self.baseframe.cabecalho.PluginIconsSeparator:IsShown()) then
			if (self.baseframe.cabecalho.modo_selecao:GetAlpha() == 0) then
				self.baseframe.cabecalho.PluginIconsSeparator:Hide()
			end
		end

	end

	self.total_buttons_shown = total_buttons_shown
	self:RefreshAttributeTextSize()

	return true

end

function Details:ToolbarMenuButtons(_mode, _segment, _attributes, _report)
	return self:ToolbarMenuSetButtons(_mode, _segment, _attributes, _report)
end

local parameters_table = {}

local onLeaveMenuFunc = function(self, elapsed)
	parameters_table[2] = parameters_table[2] + elapsed
	if (parameters_table[2] > 0.3) then
		if (not _G.GameCooltip.mouseOver and not _G.GameCooltip.buttonOver and (not _G.GameCooltip:GetOwner() or _G.GameCooltip:GetOwner() == self)) then
			_G.GameCooltip:ShowMe(false)
		end
		self:SetScript("OnUpdate", nil)
	end
end

local OnClickNovoMenu = function(_, _, id, instance)
	local is_new
	if (not Details:GetAllInstances() [id]) then
		--esta criando uma nova
		is_new = true
	end

	local ninstance = Details.CriarInstancia (_, _, id)
	instance.baseframe.cabecalho.modo_selecao:GetScript("OnEnter")(instance.baseframe.cabecalho.modo_selecao, _, true)

	if (ninstance and is_new) then
		ninstance.baseframe.cabecalho.modo_selecao:GetScript("OnEnter")(ninstance.baseframe.cabecalho.modo_selecao, _, true)
	end
end

function Details:SetTooltipMinWidth()
	GameCooltip:SetOption("MinWidth", 155)
end

function Details:FormatCooltipBackdrop()
	--local CoolTip = GameCooltip
	--CoolTip:SetBackdrop(1, menus_backdrop, menus_backdropcolor, menus_bordercolor)
	--CoolTip:SetBackdrop(2, menus_backdrop, menus_backdropcolor_sec, menus_bordercolor)
	return true
end

local build_mode_list = function(self, deltaTime)
	local gameCooltip = GameCooltip
	local instance = parameters_table [1]
	parameters_table[2] = parameters_table[2] + deltaTime

	if (parameters_table[2] > 0.15) then
		self:SetScript("OnUpdate", nil)

		gameCooltip:Reset()
		gameCooltip:SetType("menu")
		gameCooltip:SetLastSelected("main", parameters_table [3])
		gameCooltip:SetFixedParameter(instance)

		gameCooltip:SetOption("TextSize", Details.font_sizes.menus)
		gameCooltip:SetOption("TextFont", Details.font_faces.menus)
		gameCooltip:SetOption("ButtonHeightModSub", -2)
		gameCooltip:SetOption("ButtonHeightMod", -5)
		gameCooltip:SetOption("ButtonsYModSub", -3)
		gameCooltip:SetOption("ButtonsYMod", -6)
		gameCooltip:SetOption("YSpacingModSub", -3)
		gameCooltip:SetOption("YSpacingMod", 1)
		gameCooltip:SetOption("HeighMod", 3)
		gameCooltip:SetOption("SubFollowButton", true)

		Details:SetTooltipMinWidth()

		gameCooltip:AddLine(Loc["STRING_MODE_GROUP"])
		gameCooltip:AddMenu(1, function() instance:SetMode(2) end)
		gameCooltip:AddIcon([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 32/256, 32/256*2, 0, 1)

		gameCooltip:AddLine(Loc["STRING_MODE_ALL"])
		gameCooltip:AddMenu(1, function() instance:SetMode(3) end)
		gameCooltip:AddIcon([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 32/256*2, 32/256*3, 0, 1)

		gameCooltip:AddLine(Loc["STRING_OPTIONS_PLUGINS"])
		gameCooltip:AddMenu(1, function() instance:SetMode(4) end)
		gameCooltip:AddIcon([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 32/256*3, 32/256*4, 0, 1)

		Details:AddRoundedCornerToTooltip()

		--build raid plugins list
		local raidPlugins = Details.RaidTables:GetAvailablePlugins()
		if (#raidPlugins >= 0) then
			for index, ptable in ipairs(raidPlugins) do
				--if a plugin has the member 'NoMenu', it won't be shown on menus to select plugins
				if (ptable[3].__enabled and not ptable[3].NoMenu) then
					--PluginName, PluginIcon, PluginObject, PluginAbsoluteName
					gameCooltip:AddMenu(2, Details.RaidTables.EnableRaidMode, instance, ptable[4], true, ptable[1], ptable[2], true)
				end
			end
		end
		--build self plugins list
		if (#Details.SoloTables.Menu > 0) then
			for index, ptable in ipairs(Details.SoloTables.Menu) do
				if (ptable[3].__enabled and not ptable[3].NoMenu) then
					gameCooltip:AddMenu(2, Details.SoloTables.EnableSoloMode, instance, ptable[4], true, ptable[1], ptable[2], true)
				end
			end
		end

		--window control
		gameCooltip:AddLine("$div")
		gameCooltip:AddLine(Loc["STRING_MENU_INSTANCE_CONTROL"])
		gameCooltip:AddIcon([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 0.625, 0.75, 0, 1)

		local hasClosedInstances = false
		for index = 1, math.min(#Details:GetAllInstances(), Details.instances_amount), 1 do
			local thisInstance = Details:GetAllInstances() [index]
			if (not thisInstance.ativa) then
				hasClosedInstances = true
				break
			end
		end

		if (Details:GetNumInstancesAmount() < Details:GetMaxInstancesAmount()) then
			gameCooltip:AddMenu(2, OnClickNovoMenu, true, instance, nil, Loc["STRING_OPTIONS_WC_CREATE"], _, true)
			gameCooltip:AddIcon([[Interface\Buttons\UI-AttributeButton-Encourage-Up]], 2, 1, 16, 16)
			if (hasClosedInstances) then
				GameCooltip:AddLine("$div", nil, 2, nil, -5, -11)
			end
		end

		local ClosedInstances = 0
		for index = 1, math.min(#Details:GetAllInstances(), Details.instances_amount), 1 do
			local thisInstance = Details:GetAllInstances() [index]
			if (not thisInstance.ativa) then
				local atributo = thisInstance.atributo
				local sub_atributo = thisInstance.sub_atributo
				ClosedInstances = ClosedInstances + 1

				if (atributo == 5) then
					local CustomObject = Details.custom[sub_atributo]

					if (not CustomObject) then
						thisInstance:ResetAttribute()
						atributo = thisInstance.atributo
						sub_atributo = thisInstance.sub_atributo
						gameCooltip:AddMenu(2, OnClickNovoMenu, index, instance, nil, "#".. index .. " " .. Details.atributos.lista[atributo] .. " - " .. Details.sub_atributos[atributo].lista[sub_atributo], _, true)
						gameCooltip:AddIcon(Details.sub_atributos[atributo].icones[sub_atributo][1], 2, 1, 16, 16, unpack(Details.sub_atributos[atributo].icones[sub_atributo][2]))
					else
						gameCooltip:AddMenu(2, OnClickNovoMenu, index, instance, nil, "#".. index .. " " .. Details.atributos.lista[atributo] .. " - " .. CustomObject:GetName(), _, true)
						gameCooltip:AddIcon(CustomObject.icon, 2, 1, 16, 16, 0, 1, 0, 1)
					end

				else
					local modo = thisInstance.modo

					if (modo == 1) then --alone
						atributo = Details.SoloTables.Mode or 1
						local SoloInfo = Details.SoloTables.Menu [atributo]
						if (SoloInfo) then
							gameCooltip:AddMenu(2, OnClickNovoMenu, index, instance, nil, "#".. index .. " " .. SoloInfo [1], _, true)
							gameCooltip:AddIcon(SoloInfo [2], 2, 1, 16, 16, 0, 1, 0, 1)
						else
							gameCooltip:AddMenu(2, OnClickNovoMenu, index, instance, nil, "#".. index .. " Unknown Plugin", _, true)
						end

					elseif (modo == 4) then --raid

						local plugin_name = thisInstance.current_raid_plugin or thisInstance.last_raid_plugin
						if (plugin_name) then
							local plugin_object = Details:GetPlugin (plugin_name)
							if (plugin_object) then
								gameCooltip:AddMenu(2, OnClickNovoMenu, index, instance, nil, "#".. index .. " " .. plugin_object.__name, _, true)
								gameCooltip:AddIcon(plugin_object.__icon, 2, 1, 16, 16, 0, 1, 0, 1)
							else
								gameCooltip:AddMenu(2, OnClickNovoMenu, index, instance, nil, "#".. index .. " Unknown Plugin", _, true)
							end
						else
							gameCooltip:AddMenu(2, OnClickNovoMenu, index, instance, nil, "#".. index .. " Unknown Plugin", _, true)
						end

					else

						--CoolTip:AddMenu(2, OnClickNovoMenu, index, instancia, nil, "#".. index .. " " .. _detalhes.atributos.lista [atributo] .. " - " .. _detalhes.sub_atributos [atributo].lista [sub_atributo], _, true)
						gameCooltip:AddMenu(2, OnClickNovoMenu, index, instance, nil, "#".. index .. " " .. Details.sub_atributos [atributo].lista [sub_atributo], _, true)
						gameCooltip:AddIcon(Details.sub_atributos [atributo].icones[sub_atributo] [1], 2, 1, 16, 16, unpack(Details.sub_atributos [atributo].icones[sub_atributo] [2]))

					end
				end

				gameCooltip:SetOption("TextSize", Details.font_sizes.menus)
				gameCooltip:SetOption("TextFont", Details.font_faces.menus)
			end
		end

		if (ClosedInstances > 0 or Details:GetNumInstancesAmount() < Details:GetMaxInstancesAmount()) then
			GameCooltip:AddLine("$div", nil, 2, nil, -5, -11)
		end

		GameCooltip:AddLine(Loc["STRING_MENU_CLOSE_INSTANCE"], nil, 2, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		GameCooltip:AddIcon([[Interface\Buttons\UI-Panel-MinimizeButton-Up]], 2, 1, 14, 14, 0.2, 0.8, 0.2, 0.8)
		GameCooltip:AddMenu(2, Details.close_instancia_func, instance.baseframe.cabecalho.fechar)

		--CoolTip:SetWallpaper (2, _detalhes.tooltip.menus_bg_texture, _detalhes.tooltip.menus_bg_coords, _detalhes.tooltip.menus_bg_color, true)

		--space
		GameCooltip:AddLine("$div")

		--forge and history buttons
		gameCooltip:AddLine(Loc["STRING_SPELLLIST"])
		gameCooltip:AddMenu(1, Details.OpenForge)
		gameCooltip:AddIcon([[Interface\MINIMAP\Vehicle-HammerGold-3]], 1, 1, 16, 16, 0, 1, 0, 1)

		--statistics
		gameCooltip:AddLine(Loc["STRING_STATISTICS"])
		gameCooltip:AddMenu(1, Details.OpenRaidHistoryWindow)
		gameCooltip:AddIcon([[Interface\PvPRankBadges\PvPRank08]], 1, 1, 16, 16, 0, 1, 0, 1)

		--space
		GameCooltip:AddLine("$div")

		--options
		gameCooltip:AddLine(Loc["STRING_OPTIONS_WINDOW"])
		gameCooltip:AddMenu(1, Details.OpenOptionsWindow)
		gameCooltip:AddIcon([[Interface\AddOns\Details\images\modo_icones]], 1, 1, 20, 20, 0.5, 0.625, 0, 1)

		--finishes the menu
		Details:SetMenuOwner (self, instance)


		show_anti_overlap (instance, self, "top")

		gameCooltip:ShowCooltip()
	end
end



function Details:SetMenuOwner (self, instance)

	local _, y = instance.baseframe:GetCenter()
	local screen_height = GetScreenHeight()

	if (instance.toolbar_side == 1) then
		if (y+300 > screen_height) then
			GameCooltip:SetOwner(self, "top", "bottom", 0, -10)
		else
			GameCooltip:SetOwner(self)
		end

	elseif (instance.toolbar_side == 2) then --bottom

		local instance_height = instance.baseframe:GetHeight()

		if (y + math.max(instance_height, 250) > screen_height) then
			GameCooltip:SetOwner(self, "top", "bottom", 0, -10)
		else
			GameCooltip:SetOwner(self, "bottom", "top", 0, 0)
		end

	end

end

local empty_segment_color = {1, 1, 1, .4}

local segments_common_tex, segments_common_color = {0.5078125, 0.1171875, 0.017578125, 0.1953125}, {1, 1, 1, .5}
local unknown_boss_tex, unknown_boss_color = {0.14453125, 0.9296875, 0.2625, 0.6546875}, {1, 1, 1, 0.5}

local party_line_color = {170/255, 167/255, 255/255, 1}
local party_line_color_trash = {130/255, 130/255, 155/255, 1}
local party_line_color2 = {210/255, 200/255, 255/255, 1}
local party_line_color2_trash = {110/255, 110/255, 155/255, 1}

local party_wallpaper_tex, party_wallpaper_color, raid_wallpaper_tex = {0.09, 0.698125, 0, 0.833984375}, {1, 1, 1, 0.5}, {33/512, 361/512, 45/512, 295/512}

local segments_wallpaper_color = {1, 1, 1, 0.5}
local segment_color_lime = {0, 1, 0, 1}
local segment_color_red = {1, 0, 0, 1}

function Details:GetSegmentInfo(index)
	local combat

	if (index == -1 or index == "overall") then
		combat = Details.tabela_overall
	elseif (index == 0 or index == "current") then
		combat = Details.tabela_vigente
	else
		local segmentsTable = Details:GetCombatSegments()
		combat = segmentsTable[index]
	end

	if (combat) then

		local enemy
		local color
		local raid_type
		local killed
		local portrait
		local background
		local background_coords
		local is_trash

		if (combat.is_boss and combat.is_boss.name) then

			if (combat.instance_type == "party") then
				raid_type = "party"
				enemy = combat.is_boss.name
				color = party_line_color

			elseif (combat.is_boss.killed) then
				raid_type = "raid"
				enemy = combat.is_boss.name
				color = segment_color_lime
				killed = true

			else
				raid_type = "raid"
				enemy = combat.is_boss.name
				color = segment_color_red
				killed = false

			end

			local p = Details:GetBossPortrait(combat.is_boss.mapid, combat.is_boss.index)
			if (p) then
				portrait = p
			end

			local b = Details:GetRaidIcon (combat.is_boss.mapid)
			if (b) then
				background = b
				background_coords = segment_color_lime

			elseif (combat.instance_type == "party") then
				local ej_id = combat.is_boss.ej_instance_id
				if (ej_id) then
					local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = DetailsFramework.EncounterJournal.EJ_GetInstanceInfo (ej_id)
					if (bgImage) then
						background = bgImage
						background_coords = party_wallpaper_tex
					end
				end
			end

		elseif (combat.is_arena) then
			enemy = combat.is_arena.name

			local file, coords = Details:GetArenaInfo (combat.is_arena.mapid)

			if (file) then
				background = "Interface\\Glues\\LOADINGSCREENS\\" .. file
				background_coords = coords
			end

		else
			enemy = combat.enemy

			if (combat.is_trash) then
				is_trash = true
			end
		end

		return enemy, color, raid_type, killed, is_trash, portrait, background, background_coords
	end

end

local segmentsUsed = 0
local segmentsFilled = 0
---texture coords for the encounter journal "icon lore" image of the instance
local iconLoreCoords = {30/512, 355/512, 45/512, 290/512}
--overlay color for the encounter journal "icon lore" image of the instance
local wallpaperColor = {1, 1, 1, 0.5}

-- search key: ~segments
local buildSegmentTooltip = function(self, deltaTime)
	local gameCooltip = GameCooltip
	local instance = parameters_table[1]
	parameters_table[2] = parameters_table[2] + deltaTime

	local battleground_color = {1, 0.666, 0, 1}

	--settings
	local bCanUseBackgroundImage = true

	if (parameters_table[2] > 0.15) then
		self:SetScript("OnUpdate", nil)

		gameCooltip:Reset()
		gameCooltip:SetType("menu")
		gameCooltip:SetFixedParameter(instance)
		gameCooltip:SetOption("FixedWidthSub", 195)
		gameCooltip:SetOption("RightTextWidth", 105)
		gameCooltip:SetOption("RightTextHeight", 12)
		gameCooltip:SetOption("SubFollowButton", true)

		Details:AddRoundedCornerToTooltip()

		local menuIndex = 0
		Details.segments_amount = floor(Details.segments_amount)
		local amountOfSegments = 0
		local segmentsWithACombat = 0

		local segmentsTable = Details:GetCombatSegments()

		for i = 1, Details.segments_amount do
			if (segmentsTable[i]) then
				segmentsWithACombat = segmentsWithACombat + 1
			else
				break
			end
		end

		segmentsWithACombat = Details.segments_amount - segmentsWithACombat - 2
		local fill = abs(segmentsWithACombat - Details.segments_amount)
		segmentsUsed = 0
		segmentsFilled = fill

		local dungeonColor = party_line_color
		local dungeonColorTrash = party_line_color_trash

		--the mythic dungeon run id is used to check if the segment is from the same run
		--later the code can change the color of the segment to a slight different blue if the run is different
		--this variable can be nil or false for non mythic dungeons segments or a number for mythic dungeons segments
		local mythicDungeonRunId

		local statusBarTexture = "Skyline"
		local combatTimeColor = "gray"
		local combatTimeColorGeneric = "gray"

		for i = Details.segments_amount, 1, -1 do
			if (i <= fill) then
				---@type combat
				local thisCombat = segmentsTable[i]
				if (thisCombat and not thisCombat.__destroyed) then
					---@type bossinfo
					local bossInfo = thisCombat:GetBossInfo()

					---@type details_instanceinfo
					local instanceInfo = Details:GetInstanceInfo(bossInfo and bossInfo.mapid or thisCombat.mapId)

					---@type details_encounterinfo
					local encounterInfo = Details:GetEncounterInfo(thisCombat:GetEncounterName())

					---@type string, string
					local dateStart, dateEnd = thisCombat:GetDate()

					---@type combattime
					local elapsedCombatTime = thisCombat:GetCombatTime()
					local formattedElapsedTime = detailsFramework:IntegerToTimer(elapsedCombatTime)

					---@type string
					local enemyName = bossInfo and bossInfo.name or ""

					local segmentInfoAdded = false
					segmentsUsed = segmentsUsed + 1

					local bIsMythicDungeon, runId = thisCombat:IsMythicDungeon()
					local combatType, combatCategory = thisCombat:GetCombatType()

					if (combatCategory == DETAILS_SEGMENTTYPE_MYTHICDUNGEON) then
						if (not mythicDungeonRunId) then
							mythicDungeonRunId = runId
						else
							if (mythicDungeonRunId ~= runId) then
								mythicDungeonRunId = runId
								dungeonColor = dungeonColor == party_line_color and party_line_color2 or party_line_color
								dungeonColorTrash = dungeonColorTrash == party_line_color_trash and party_line_color2_trash or party_line_color_trash
							end
						end

						local mythicDungeonInfo = thisCombat:GetMythicDungeonInfo()
						local isMythicOverallSegment, segmentID, mythicLevel, EJID, mapID, zoneName, encounterID, encounterName, startedAt, endedAt, runID = Details:UnpackMythicDungeonInfo(mythicDungeonInfo)

						--if is bIsMythicDungeon but no mythicDungeonInfo, it will show as M+ 'Trash Cleanup'
						--is a boss, trash overall or run overall segment
						if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH or combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSTRASH) then
							local combatName, r, g, b = thisCombat:GetCombatName()
							local broomStick = detailsFramework:CreateAtlasString(Details:GetTextureAtlas("segment-icon-broom"))
							local combatIcon, categoryIcon = thisCombat:GetCombatIcon()

							gameCooltip:AddLine(broomStick .. " " .. combatName, detailsFramework:IntegerToTimer(thisCombat:GetCombatTime()), 1, dungeonColor, combatTimeColor)
							local bDesaturated = false
							gameCooltip:AddIcon(categoryIcon, "main", "left", nil, nil, nil, nil, nil, nil, nil, nil, bDesaturated)

							--submenu
							gameCooltip:AddLine(Loc["STRING_SEGMENT_TRASH"], nil, 2, "white", "white")
							gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
							gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)

							gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":",  detailsFramework:IntegerToTimer(thisCombat:GetCombatTime()), 2, "white", "white")
							gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
							gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)

							--gameCooltip:AddLine("", "", 2, "white", "white")
							gameCooltip:AddLine(Loc["STRING_SEGMENT_START"] .. ":", thisCombat:GetDate(), 2, "white", "white")
							gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
							gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)

							gameCooltip:AddLine(Loc["STRING_SEGMENT_END"] .. ":", dateEnd or "in progress", 2, "white", "white")
							gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
							gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)

							local backgroundImage = Details:GetRaidIcon(mapID, EJID, "party")
							if (backgroundImage and bCanUseBackgroundImage) then
								gameCooltip:SetWallpaper(2, backgroundImage, {0.070, 0.695, 0.087, 0.566}, {1, 1, 1, 0.5}, true)
							end

						elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
							gameCooltip:AddLine(thisCombat:GetCombatName(), detailsFramework:IntegerToTimer(endedAt - startedAt), 1, dungeonColor)
							local combatIcon, categoryIcon = thisCombat:GetCombatIcon()
							gameCooltip:AddIcon(categoryIcon, "main", "left")
							gameCooltip:AddStatusBar(100, 1, .5, .1, 0, 0.55, false, false, statusBarTexture)
							local timeInCombat = thisCombat:GetCombatTime()

							--submenu
							gameCooltip:AddLine(zoneName .. " +" .. mythicLevel .. " (" .. Loc["STRING_SEGMENTS_LIST_OVERALL"] .. ")", nil, 2, "white", "white")
							gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
							gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)

							local totalRealTime = thisCombat:GetRunTimeNoDefault() or (endedAt - startedAt)
							local notInCombatTime = totalRealTime - timeInCombat

							gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_TOTALTIME"] .. ":", detailsFramework:IntegerToTimer(totalRealTime), 2, "white", "white")
							gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
							gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)

							gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_TIMEINCOMBAT"] .. ":",  detailsFramework:IntegerToTimer(timeInCombat), 2, "white", "white")
							gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
							gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)

							--wasted time
							gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_WASTED_TIME"] .. ":", "|cFFFF3300" .. detailsFramework:IntegerToTimer(notInCombatTime) .. " (" .. floor(notInCombatTime / totalRealTime * 100) .. "%)|r", 2, "white", "white")
							gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
							gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)

						elseif (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS or combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSSWIPE) then
							local addIconAndStatusBar = function(redTint)
								gameCooltip:AddIcon(Details:GetTextureAtlas("small-pin-yellow"), 2, 1)
								gameCooltip:AddStatusBar(100, 2, 0, 0, 0, 0.25, false, false, statusBarTexture)
							end

							local combatIcon, categoryIcon = thisCombat:GetCombatIcon()

							local skull = "|TInterface\\AddOns\\Details\\images\\icons:16:16:0:0:512:512:496:512:0:16|t"
							local skullIcon = detailsFramework:CreateAtlasString(Details:GetTextureAtlas("segment-icon-boss"))

							--main cooltip frame
							local combatName, combatColor = thisCombat:GetCombatName()
							local r, g, b, a = detailsFramework:ParseColors(combatColor)
							gameCooltip:AddLine(skullIcon .. " " .. combatName, detailsFramework:IntegerToTimer(elapsedCombatTime), 1, dungeonColor, combatTimeColor)
							gameCooltip:AddIcon(categoryIcon, "main", "left")
							addIconAndStatusBar()

							--sub cooltip frame
							gameCooltip:AddLine(thisCombat:GetCombatName(), nil, 2, "white", "white")
							addIconAndStatusBar()

							do
								local avatarPoint = {"bottomleft", "topleft", -3, -4}
								local backgroundPoint = {{"bottomleft", "topleft", 0, -3}, {"bottomright", "topright", 0, -3}}
								local textPoint = {"left", "right", -11, -5}
								local avatarTexCoord = {0, 1, 0, 1}
								local backgroundColor = {0, 0, 0, 0.6}
								local avatarTextColor = {1, 1, 1, 1}

								--gameCooltip:SetBannerImage(2, 1, avatar [2], 80, 40, avatarPoint, avatarTexCoord, nil) --overlay [2] avatar path
								local anchor = {"bottom", "top", 0, 0}

								--these need to be per line, current are per frame
								--gameCooltip:SetBannerImage(2, 2, [[Interface\PetBattles\Weather-Windy]], 200, 55, anchor, {1, 0.129609375, 1, 0})
								--gameCooltip:SetBannerText(2, 2, encounterName, textPoint, avatarTextColor, 14, SharedMedia:Fetch("font", Details.tooltip.fontface))
							end

							local instanceData
							if (thisCombat.is_boss) then
								instanceData = Details222.EJCache.GetInstanceData(thisCombat.is_boss.zone, thisCombat.is_boss.ej_instance_id, thisCombat.is_boss.id, thisCombat.is_boss.mapid)
							end

							if (instanceData) then
								local encounterData = Details222.EJCache.GetEncounterDataFromInstanceData(instanceData, thisCombat.is_boss.encounter, thisCombat.is_boss.name, thisCombat.is_boss.id)
								if (encounterData) then
									gameCooltip:AddIcon(encounterData.creatureIcon, 2, "top", 128, 64, 0, 1, 0, 0.96)
								end
							end

							local backgroundImage = Details:GetRaidIcon(mapID, EJID, "party")
							if (backgroundImage and bCanUseBackgroundImage) then
								gameCooltip:SetWallpaper(2, backgroundImage, {0.070, 0.695, 0.087, 0.566}, {1, 1, 1, 0.5}, true)
							end

							--sub menu
							local timeInCombat = thisCombat:GetCombatTime()

							if (segmentID == "trashoverall") then
								gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_TIMEINCOMBAT"] .. ":",  detailsFramework:IntegerToTimer(timeInCombat), 2, "white", "white")
								addIconAndStatusBar()
								local totalRealTime = endedAt - startedAt
								local wasted = totalRealTime - timeInCombat

								--wasted time
								gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_WASTED_TIME"] .. ":", "|cFFFF3300" .. detailsFramework:IntegerToTimer(wasted) .. " (" .. floor(wasted / totalRealTime * 100) .. "%)|r", 2, "white", "white")
								addIconAndStatusBar(0.15)
								gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_TOTALTIME"] .. ":", detailsFramework:IntegerToTimer(endedAt - startedAt), 2, "white", "white")
								addIconAndStatusBar()

							elseif (isMythicOverallSegment) then

							else
								gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":",  detailsFramework:IntegerToTimer(timeInCombat), 2, "white", "white")
								addIconAndStatusBar()
							end

							gameCooltip:AddLine(Loc["STRING_SEGMENT_START"] .. ":", thisCombat:GetDate(), 2, "white", "white")
							addIconAndStatusBar()
							gameCooltip:AddLine(Loc["STRING_SEGMENT_END"] .. ":", dateEnd or "in progress", 2, "white", "white")
							addIconAndStatusBar()
						end

						segmentInfoAdded = true

						if (instanceInfo) then
							local bgImage = instanceInfo.iconLore
							local bIsDesaturated = false
							local desaturation = 0.7
							if (combatType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_OVERALL) then
								desaturation = 0.4
							end
							gameCooltip:SetWallpaper(2, bgImage, iconLoreCoords, wallpaperColor, bIsDesaturated, desaturation)
						end

						--end of mythic+ segments

					elseif (combatType == DETAILS_SEGMENTTYPE_DUNGEON_OVERALL) then
						gameCooltip:AddLine(thisCombat:GetCombatName(), detailsFramework:IntegerToTimer(thisCombat:GetCombatTime()), 1, dungeonColor)
						local combatIcon, categoryIcon = thisCombat:GetCombatIcon()
						gameCooltip:AddIcon(combatIcon, "main", "left")
						gameCooltip:AddStatusBar(100, 1, .5, .1, 0, 0.55, false, false, statusBarTexture)
						local timeInCombat = thisCombat:GetCombatTime()

					elseif (combatType == DETAILS_SEGMENTTYPE_DUNGEON_BOSS or combatType == DETAILS_SEGMENTTYPE_RAID_BOSS) then --if this is a boss encounter
						--isn't anymore a sequence of mythic+ segments
						mythicDungeonRunId = false

						local tryNumber = thisCombat:GetTryNumber()
						local combatTime = thisCombat:GetCombatTime()
						local combatInstanceType = thisCombat:GetInstanceType()
						local bOnlyName = true
						local combatName, r, g, b = thisCombat:GetCombatName(bOnlyName)

						local combatIcon, categoryIcon = thisCombat:GetCombatIcon()

						--remove anything after the first comma from the combat name
						local commaIndex = string.find(combatName, ",")
						if (commaIndex) then
							combatName = string.sub(combatName, 1, commaIndex - 1)
						end

						if (combatInstanceType == "party") then
							gameCooltip:AddLine(combatName, formattedElapsedTime, 1, dungeonColor, combatTimeColor)

						elseif (bossInfo.killed) then
							gameCooltip:AddLine(combatName, formattedElapsedTime, 1, "lime", combatTimeColor)
						else
							local bossHealth = thisCombat:GetBossHealthString()
							gameCooltip:AddLine(combatName,  "P" .. thisCombat:GetCurrentPhase() .. "  " ..  bossHealth .. "%  " .. formattedElapsedTime, 1, "orange", combatTimeColor) --formattedElapsedTime
						end

						gameCooltip:AddIcon(combatIcon, "main", "left")

						local portrait = thisCombat:GetBossImage()
						if (portrait) then
							gameCooltip:AddIcon(portrait, 2, "top", 128, 64)
						end

						if (Details.tooltip.submenu_wallpaper) then
							local background = Details:GetRaidIcon(bossInfo.mapid)
							if (background and bCanUseBackgroundImage) then
								gameCooltip:SetWallpaper(2, background, nil, segments_wallpaper_color, true)
							else
								local encounterJournalId = bossInfo.ej_instance_id
								if (encounterJournalId and encounterJournalId ~= 0) then
									local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = DetailsFramework.EncounterJournal.EJ_GetInstanceInfo(encounterJournalId)
									if (name and bCanUseBackgroundImage) then
										if (combatInstanceType == "party") then
											gameCooltip:SetWallpaper(2, bgImage, party_wallpaper_tex, party_wallpaper_color, true)
										else
											gameCooltip:SetWallpaper(2, loreImage, raid_wallpaper_tex, party_wallpaper_color, true)
										end
									end
								end
							end
						end

					elseif (combatType == DETAILS_SEGMENTTYPE_EVENT_VALENTINEDAY) then
						mythicDungeonRunId = false
						--dungeon
						local combatName, r, g, b = thisCombat:GetCombatName()
						gameCooltip:AddLine(combatName, formattedElapsedTime, 1, "hotpink", "hotpink")
						gameCooltip:AddIcon(thisCombat:GetCombatIcon(), "main", "left")

					elseif (combatType == DETAILS_SEGMENTTYPE_TRAININGDUMMY) then
						mythicDungeonRunId = false
						local combatName, r, g, b = thisCombat:GetCombatName()
						gameCooltip:AddLine(combatName, formattedElapsedTime, 1, "yellow", "yellow")
						gameCooltip:AddIcon(thisCombat:GetCombatIcon(), "main", "left")

					elseif (combatType == DETAILS_SEGMENTTYPE_PVP_BATTLEGROUND) then
						mythicDungeonRunId = false
						enemyName = thisCombat:GetCombatName()
						gameCooltip:AddLine(enemyName, formattedElapsedTime, 1, battleground_color, combatTimeColor)
						enemyName = enemyName
						gameCooltip:AddIcon(thisCombat:GetCombatIcon(), "main", "left")

						if (Details.tooltip.submenu_wallpaper) then
							local file, coords = Details:GetBattlegroundInfo (thisCombat.is_pvp.mapid)
							if (file and bCanUseBackgroundImage) then
								gameCooltip:SetWallpaper (2, "Interface\\Glues\\LOADINGSCREENS\\" .. file, coords, empty_segment_color, true)
							end
						end

					elseif (combatType == DETAILS_SEGMENTTYPE_PVP_ARENA) then
						mythicDungeonRunId = false
						enemyName = thisCombat:GetCombatName()
						gameCooltip:AddLine(enemyName, _, 1, "yellow")
						gameCooltip:AddIcon(thisCombat:GetCombatIcon(), "main", "left")

						if (Details.tooltip.submenu_wallpaper) then
							local file, coords = Details:GetArenaInfo(thisCombat.is_arena.mapid)
							if (file and bCanUseBackgroundImage) then
								gameCooltip:SetWallpaper (2, "Interface\\Glues\\LOADINGSCREENS\\" .. file, coords, empty_segment_color, true)
							end
						end
					else
						mythicDungeonRunId = false
						local bFindEnemyName = true
						gameCooltip:AddLine(thisCombat:GetCombatName(false, bFindEnemyName), _, 1, "yellow", combatTimeColorGeneric) --formattedElapsedTime
						gameCooltip:AddIcon(thisCombat:GetCombatIcon(), "main", "left")

						--print("passing here...")

						if (Details.tooltip.submenu_wallpaper and bCanUseBackgroundImage) then
							gameCooltip:SetWallpaper(2, [[Interface\ACHIEVEMENTFRAME\UI-Achievement-StatsBackground]], segments_common_tex, segments_common_color, true)
						end
					end

					gameCooltip:AddMenu(1, instance.SetSegmentFromCooltip, i)

					if (not segmentInfoAdded) then
						gameCooltip:AddLine(Loc["STRING_SEGMENT_ENEMY"] .. ":", enemyName, 2, "white", "white")
						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":", thisCombat:GetFormattedCombatTime(), 2, "white", "white")
						gameCooltip:AddLine(Loc["STRING_SEGMENT_START"] .. ":", thisCombat:GetDate(), 2, "white", "white")
						gameCooltip:AddLine(Loc["STRING_SEGMENT_END"] .. ":", dateEnd or "in progress", 2, "white", "white")
					end

					amountOfSegments = amountOfSegments + 1
				else
					if (thisCombat and thisCombat.__destroyed) then
						Details:Msg("a deleted combat object was found on the segments history table, please report this bug on discord:")
						Details:Msg("combat destroyed by:", thisCombat.__destroyedBy)
					else
						gameCooltip:AddLine(Loc["STRING_SEGMENT_LOWER"] .. " #" .. i, _, 1, "gray")
						gameCooltip:AddMenu(1, instance.SetSegmentFromCooltip, i)
						gameCooltip:AddIcon(Details:GetTextureAtlas("segment-icon-regular"), "main", "left", nil, nil, nil, nil, nil, nil, empty_segment_color)
						gameCooltip:AddLine(Loc["STRING_SEGMENT_EMPTY"], _, 2)
						gameCooltip:AddIcon([[Interface\CHARACTERFRAME\Disconnect-Icon]], 2, 1, 12, 12, 0.3125, 0.65625, 0.265625, 0.671875)
					end
				end

				if (menuIndex) then
					menuIndex = menuIndex + 1
					if (instance.segmento == i) then
						gameCooltip:SetLastSelected("main", menuIndex)
						menuIndex = nil
					end
				end
			end
		end

		GameCooltip:AddLine("$div", nil, nil, -5, -13)

		---------------------------------------------------------------------------------------------------------------------------------------------------
		--> current combat
			local thisCombat = Details:GetCurrentCombat()
			local dateStart, dateEnd = thisCombat:GetDate()
			local bSegmentInfoAdded

			local enemy = thisCombat.is_boss and thisCombat.is_boss.name or thisCombat.enemy or "--x--x--"
			local file, coords

			--add the new line
			gameCooltip:AddLine(segmentos.current_standard, _, 1, "white")
			gameCooltip:AddMenu(1, instance.SetSegmentFromCooltip, 0)
			gameCooltip:AddIcon(Details:GetTextureAtlas("segment-icon-current"), "main", "left")

			--current segment is a dungeon mythic+?
			if (thisCombat.is_mythic_dungeon_segment) then
				local mythicDungeonInfo = thisCombat:GetMythicDungeonInfo()

				if (mythicDungeonInfo) then
					--is a boss, trash overall or run overall segment
					local bossInfo = thisCombat.is_boss
					local isMythicOverallSegment, segmentID, mythicLevel, EJID, mapID, zoneName, encounterID, encounterName, startedAt, endedAt, runID = Details:UnpackMythicDungeonInfo(mythicDungeonInfo)
					local combatElapsedTime = thisCombat:GetCombatTime()
					local combatName = thisCombat:GetCombatName()

					--is mythic overall
					if (isMythicOverallSegment) then
						--mostrar o tempo da dungeon
						local totalTime = combatElapsedTime
						--CoolTip:AddLine(zoneName .. " +" .. mythicLevel .. " (overall)", _detalhes.gump:IntegerToTimer(totalTime), 1, dungeon_color)
						--CoolTip:AddLine(zoneName .. " +" .. mythicLevel .. " (overall)", _detalhes.gump:IntegerToTimer(endedAt - startedAt), 1, dungeon_color)
						--CoolTip:AddIcon([[Interface\AddOns\Details\images\icons]], "main", "left", 14, 10, 479/512, 510/512, 24/512, 51/512)
						gameCooltip:AddLine(zoneName .. " +" .. mythicLevel .. " (" .. Loc["STRING_SEGMENTS_LIST_OVERALL"] .. ")", nil, 2, "white", "white")

					else
						if (segmentID == "trashoverall") then
							--CoolTip:AddLine(encounterName .. " (" .. Loc["STRING_SEGMENTS_LIST_TRASH"] .. ")", _detalhes.gump:IntegerToTimer(combat_time), 1, dungeon_color, "gray")
							--CoolTip:AddLine(encounterName .. " (" .. Loc["STRING_SEGMENTS_LIST_TRASH"] .. ")", _detalhes.gump:IntegerToTimer(endedAt - startedAt), 1, dungeon_color, "gray")
							gameCooltip:AddLine(encounterName .. " (" .. Loc["STRING_SEGMENTS_LIST_TRASH"] .. ")", nil, 2, "white", "white")
						else
							--CoolTip:AddLine(encounterName .. " (" .. Loc["STRING_SEGMENTS_LIST_BOSS"] .. ")", _detalhes.gump:IntegerToTimer(combat_time), 1, dungeon_color, "gray")
							gameCooltip:AddLine(combatName, nil, 2, "white", "white")
						end
						--CoolTip:AddIcon([[Interface\AddOns\Details\images\icons]], "main", "left", 14, 10, 479/512, 510/512, 24/512, 51/512)
					end

					local portrait = (thisCombat.is_boss and thisCombat.is_boss.bossimage) or Details:GetBossPortrait(nil, nil, encounterName, EJID)
					if (portrait) then
						gameCooltip:AddIcon(portrait, 2, "top", 128, 64, 0, 1, 0, 0.96)
					end

					local backgroundImage = Details:GetRaidIcon (mapID, EJID, "party")
					if (backgroundImage and bCanUseBackgroundImage) then
						gameCooltip:SetWallpaper (2, backgroundImage, {0.070, 0.695, 0.087, 0.566}, {1, 1, 1, 0.5}, true) -- party_wallpaper_tex -- {0.09, 0.698125, .17, 0.833984375}
					end

					--sub menu
					local decorrido = thisCombat:GetCombatTime()
					local minutos, segundos = floor(decorrido/60), floor(decorrido%60)
					--CoolTip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white")

					if (segmentID == "trashoverall") then
						local totalRealTime = endedAt - startedAt
						local wasted = totalRealTime - decorrido

						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_TIMEINCOMBAT"] .. ":",  detailsFramework:IntegerToTimer(decorrido), 2, "white", "white")

						--wasted time
						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_WASTED_TIME"] .. ":", "|cFFFF3300" .. detailsFramework:IntegerToTimer(wasted) .. " (" .. floor(wasted / totalRealTime * 100) .. "%)|r", 2, "white", "white")
						gameCooltip:AddStatusBar (100, 2, 0, 0, 0, 0.35, false, false, statusBarTexture)

						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_TOTALTIME"] .. ":", detailsFramework:IntegerToTimer(endedAt - startedAt) .. " [|cFFFF3300" .. detailsFramework:IntegerToTimer(totalRealTime - decorrido) .. "|r]", 2, "white", "white")

					elseif (isMythicOverallSegment) then
						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_TIMEINCOMBAT"] .. ":",  detailsFramework:IntegerToTimer(decorrido), 2, "white", "white")
						local totalRealTime = endedAt - startedAt
						local wasted = totalRealTime - decorrido


						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_TOTALTIME"] .. ":", detailsFramework:IntegerToTimer(totalRealTime), 2, "white", "white")

						--wasted time
						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_WASTED_TIME"] .. ":", "|cFFFF3300" .. detailsFramework:IntegerToTimer(wasted) .. " (" .. floor(wasted / totalRealTime * 100) .. "%)|r", 2, "white", "white")
						gameCooltip:AddStatusBar (100, 2, 0, 0, 0, 0.35, false, false, statusBarTexture)

					else
						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":",  detailsFramework:IntegerToTimer(decorrido), 2, "white", "white")
					end

					if (thisCombat.is_boss) then
						gameCooltip:AddLine("", "", 2, "white", "white")
					end

					gameCooltip:AddLine(Loc["STRING_SEGMENT_START"] .. ":", thisCombat:GetDate(), 2, "white", "white")
					gameCooltip:AddLine(Loc["STRING_SEGMENT_END"] .. ":", dateEnd or "in progress", 2, "white", "white")

				else
					--the combat has mythic dungeon tag but doesn't have a mythic dungeon table information
					--so this is a trash cleanup segment

					--submenu
					gameCooltip:AddLine(Loc["STRING_SEGMENT_TRASH"], nil, 2, "white", "white")
					gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":",  detailsFramework:IntegerToTimer(thisCombat:GetCombatTime()), 2, "white", "white")
					gameCooltip:AddLine("", "", 2, "white", "white")
					gameCooltip:AddLine(Loc["STRING_SEGMENT_START"] .. ":", thisCombat:GetDate(), 2, "white", "white")
					gameCooltip:AddLine(Loc["STRING_SEGMENT_END"] .. ":", dateEnd or "in progress", 2, "white", "white")

					if (mythicDungeonInfo) then
						local backgroundImage = Details:GetRaidIcon(mythicDungeonInfo.MapID, mythicDungeonInfo.EJID, "party")
						if (backgroundImage and bCanUseBackgroundImage) then
							gameCooltip:SetWallpaper(2, backgroundImage, {0.070, 0.695, 0.087, 0.566}, {1, 1, 1, 0.5}, true)
						end
					end
				end

				bSegmentInfoAdded = true

			elseif (thisCombat.is_boss and thisCombat.is_boss.name) then
				local portrait = Details:GetBossPortrait(thisCombat.is_boss.mapid, thisCombat.is_boss.index) or thisCombat.is_boss.bossimage
				if (portrait) then
					gameCooltip:AddIcon(portrait, 2, "top", 128, 64)
				else
					local encounter_name = thisCombat.is_boss.encounter
					local instanceID = thisCombat.is_boss.ej_instance_id
					instanceID = tonumber(instanceID)
					if (encounter_name and instanceID and instanceID ~= 0) then
						local index, name, description, encounterID, rootSectionID, link = Details:GetEncounterInfoFromEncounterName (instanceID, encounter_name)
						if (index and name and encounterID) then
							local id, name, description, displayInfo, iconImage = DetailsFramework.EncounterJournal.EJ_GetCreatureInfo (index, encounterID)
							if (iconImage) then
								gameCooltip:AddIcon(iconImage, 2, "top", 128, 64)
							end
						end
					end
				end

				if (Details.tooltip.submenu_wallpaper) then
					local background = Details:GetRaidIcon (thisCombat.is_boss.mapid)
					if (background and bCanUseBackgroundImage) then
						gameCooltip:SetWallpaper (2, background, nil, segments_wallpaper_color, true)
					else
						local ej_id = thisCombat.is_boss.ej_instance_id
						if (ej_id and ej_id ~= 0) then
							local name, description, bgImage, buttonImage, loreImage, dungeonAreaMapID, link = DetailsFramework.EncounterJournal.EJ_GetInstanceInfo (ej_id)
							if (name and bCanUseBackgroundImage) then
								if (thisCombat.instance_type == "party") then
									gameCooltip:SetWallpaper (2, bgImage, party_wallpaper_tex, party_wallpaper_color, true)
								else
									gameCooltip:SetWallpaper (2, loreImage, raid_wallpaper_tex, party_wallpaper_color, true)
								end
							end
						end
					end
				end

			elseif (thisCombat.is_pvp) then
				enemy = thisCombat.is_pvp.name
				file, coords = Details:GetBattlegroundInfo(thisCombat.is_pvp.mapid)

			elseif (thisCombat.is_arena) then
				enemy = thisCombat.is_arena.name
				file, coords = Details:GetArenaInfo(thisCombat.is_arena.mapid)

			else
				if (Details.tooltip.submenu_wallpaper and bCanUseBackgroundImage) then
					gameCooltip:SetWallpaper(2, [[Interface\ACHIEVEMENTFRAME\UI-Achievement-StatsBackground]], segments_common_tex, {1, 1, 1, 0.5}, true)
				end
			end

			if (Details.tooltip.submenu_wallpaper and bCanUseBackgroundImage) then
				if (file) then
					gameCooltip:SetWallpaper(2, "Interface\\Glues\\LOADINGSCREENS\\" .. file, coords, empty_segment_color, true)
				end
			end

			if (not bSegmentInfoAdded) then
				if (thisCombat.combat_type == DETAILS_SEGMENTTYPE_DUNGEON_OVERALL) then
					gameCooltip:AddLine(Loc["STRING_SEGMENT_ENEMY"] .. ":", thisCombat:GetCombatName(), 2, "white", "white")
				else
					gameCooltip:AddLine(Loc["STRING_SEGMENT_ENEMY"] .. ":", enemy, 2, "white", "white")
				end

				if (not thisCombat:GetEndTime()) then
					if (Details.in_combat) then
						local decorrido = thisCombat:GetCombatTime()
						local minutos, segundos = floor(decorrido/60), floor(decorrido%60)
						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white")
					else
						gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":", "--x--x--", 2, "white", "white")
					end
				else
					local decorrido = thisCombat:GetCombatTime()
					local minutos, segundos = floor(decorrido/60), floor(decorrido%60)
					gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white")
				end

				gameCooltip:AddLine(Loc["STRING_SEGMENT_START"] .. ":", dateStart, 2, "white", "white")
				gameCooltip:AddLine(Loc["STRING_SEGMENT_END"] .. ":", dateEnd or "in progress", 2, "white", "white")
			end

			--fill � a quantidade de menu que esta sendo mostrada
			if (instance.segmento == 0) then
				if (fill - 2 == menuIndex) then
					gameCooltip:SetLastSelected ("main", fill + 0)
				elseif (fill - 1 == menuIndex) then
					gameCooltip:SetLastSelected ("main", fill + 1)
				else
					gameCooltip:SetLastSelected ("main", fill + 2)
				end

				menuIndex = nil
			end

		--> overall
			---@type combat
			local overallCombat = Details:GetOverallCombat()

			--CoolTip:AddLine(segmentos.overall_standard, _, 1, "white") Loc["STRING_REPORT_LAST"] .. " " .. fight_amount .. " " .. Loc["STRING_REPORT_FIGHTS"]
			gameCooltip:AddLine(overallCombat:GetCombatName(), _, 1, "white")
			gameCooltip:AddMenu(1, instance.SetSegmentFromCooltip, -1)
			gameCooltip:AddIcon(overallCombat:GetCombatIcon(), "main", "left")

			local dateStart, dateEnd = overallCombat:GetDate()

			local enemyName = overallCombat.overall_enemy_name

			gameCooltip:AddLine(Loc["STRING_SEGMENT_ENEMY"] .. ":", enemyName, 2, "white", "white")

			local combat_time = overallCombat:GetCombatTime()
			local minutos, segundos = floor(combat_time / 60), floor(combat_time % 60)

			gameCooltip:AddLine(Loc["STRING_SEGMENTS_LIST_COMBATTIME"] .. ":", minutos.."m "..segundos.."s", 2, "white", "white")
			gameCooltip:AddLine(Loc["STRING_SEGMENT_START"] .. ":", overallCombat:GetDate(), 2, "white", "white")
			gameCooltip:AddLine(Loc["STRING_SEGMENT_END"] .. ":", dateEnd, 2, "white", "white")

			-- combats added
			local combats_added = overallCombat.segments_added or Details.empty_table
			gameCooltip:AddLine(Loc["STRING_SEGMENTS"] .. ":", #combats_added, 2, "white", "white")

			if (#combats_added > 0) then
				gameCooltip:AddLine("", "", 2, "white", "white")
			end

			for i, segment in ipairs(combats_added) do
				local minutos, segundos = floor(segment.elapsed/60), floor(segment.elapsed%60)

				local name = segment.name
				if (name:len() > 20) then
					name = string.sub (name, 1, #name - (#name - 20))
				end

				gameCooltip:AddLine("" .. name, minutos.."m "..segundos.."s", 2, "white", "white")

				local segmentType = segment.type
				if (segmentType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_TRASH) then
					gameCooltip:AddIcon(Details.TextureAtlas["segment-icon-mythicplus"], 2, 1, 12, 8,  nil, nil,  nil, nil, nil, nil, true)

				elseif (segmentType == DETAILS_SEGMENTTYPE_MYTHICDUNGEON_BOSS) then
					gameCooltip:AddIcon(Details.TextureAtlas["segment-icon-skull"], 2, 1, 12, 12, nil, nil,  nil, nil, party_line_color)

				elseif (segmentType == DETAILS_SEGMENTTYPE_RAID_TRASH or segmentType == DETAILS_SEGMENTTYPE_DUNGEON_TRASH) then
					gameCooltip:AddIcon(Details.TextureAtlas["broom-icon"], 2, 1, 10, 8)

				elseif (segmentType == DETAILS_SEGMENTTYPE_RAID_BOSS) then
					gameCooltip:AddIcon(Details.TextureAtlas["segment-icon-skull"], 2, 1, 12, 12)
				end

				--CoolTip:AddStatusBar (100, 2, 0, 0, 0, 0.2, false, false, statusBarTexture)
			end

			--fill � a quantidade de menu que esta sendo mostrada
			if (instance.segmento == -1) then
				if (fill - 2 == menuIndex) then
					gameCooltip:SetLastSelected ("main", fill + 1)
				elseif (fill - 1 == menuIndex) then
					gameCooltip:SetLastSelected ("main", fill + 2)
				else
					gameCooltip:SetLastSelected ("main", fill + 3)
				end
				menuIndex = nil
			end

		---------------------------------------------

		Details:SetMenuOwner (self, instance)

		gameCooltip:SetOption("TextSize", Details.font_sizes.menus)
		gameCooltip:SetOption("TextFont", Details.font_faces.menus)

		gameCooltip:SetOption("SubMenuIsTooltip", true)

		gameCooltip:SetOption("ButtonHeightMod", -4)
		gameCooltip:SetOption("ButtonsYMod", -10)
		gameCooltip:SetOption("YSpacingMod", 1)

		gameCooltip:SetOption("ButtonHeightModSub", 4)
		gameCooltip:SetOption("ButtonsYModSub", 0)
		gameCooltip:SetOption("YSpacingModSub", -4)

		gameCooltip:SetOption("HeighMod", 12)

		Details:SetTooltipMinWidth()

		show_anti_overlap (instance, self, "top")

		gameCooltip:ShowCooltip()

		self:SetScript("OnUpdate", nil)
	end

end

-- ~skin

function Details:SetUserCustomSkinFile (file)
	if (type(file) ~= "string") then
		error("SetUserCustomSkinFile() file must be a string.")
	end

	if (file:find("\\") or file:find("/")) then
		error("SetUserCustomSkinFile() file must be only the file name (with out up folders) and slashes.")
	end

	self.skin_custom = file
	self:ChangeSkin()
end

function Details:RefreshMicroDisplays()
	Details.StatusBar:UpdateOptions (self)
end

function Details:WaitForSkin()
	local skinName = self.skin
	local hasSkinInCache = Details.installed_skins_cache[skinName]
	if (hasSkinInCache) then
		Details:InstallSkin(skinName, hasSkinInCache)
		local skin = Details.skins[skinName]
		if (skin) then
			return skin
		end
	end

	Details.waitingForSkins = Details.waitingForSkins or {}
	Details.waitingForSkins[self:GetId()] = skinName

	local defaultSkin = Details.default_skin_to_use
	local skin = Details.skins[defaultSkin]
	self.skin = defaultSkin
	return skin
end

function Details:ChangeSkin(skin_name)
	if (not skin_name) then
		skin_name = self.skin
	end

	local this_skin = Details.skins[skin_name]
	if (not this_skin) then
		local tempSkin = Details:WaitForSkin()
		this_skin = tempSkin
	end

	local just_updating = false
	if (self.skin == skin_name) then
		just_updating = true
	end

	if (not just_updating) then

		--skin updater
		if (self.bgframe.skin_script) then
			self.bgframe:SetScript("OnUpdate", nil)
			self.bgframe.skin_script = false
		end

		--reset all config
			self:ResetInstanceConfigKeepingValues (true)

		--overwrites
			local overwrite_cprops = this_skin.instance_cprops
			if (overwrite_cprops) then

				local copy = Details.CopyTable(overwrite_cprops)

				for cprop, value in pairs(copy) do
					if (not Details.instance_skin_ignored_values [cprop]) then
						if (type(value) == "table") then
							for cprop2, value2 in pairs(value) do
								if (not self[cprop]) then
									self[cprop] = {}
								end
								self [cprop] [cprop2] = value2
							end
						else
							self [cprop] = value
						end
					end
				end
			end

		--reset micro frames
			Details.StatusBar:Reset (self)

		--customize micro frames
			if (this_skin.micro_frames) then
				if (this_skin.micro_frames.left) then
					Details.StatusBar:SetPlugin (self, this_skin.micro_frames.left, "left")
				end

				if (this_skin.micro_frames.textxmod) then
					Details.StatusBar:ApplyOptions (self.StatusBar.left, "textxmod", this_skin.micro_frames.textxmod)
					Details.StatusBar:ApplyOptions (self.StatusBar.center, "textxmod", this_skin.micro_frames.textxmod)
					Details.StatusBar:ApplyOptions (self.StatusBar.right, "textxmod", this_skin.micro_frames.textxmod)
				end
				if (this_skin.micro_frames.textymod) then
					Details.StatusBar:ApplyOptions (self.StatusBar.left, "textymod", this_skin.micro_frames.textymod)
					Details.StatusBar:ApplyOptions (self.StatusBar.center, "textymod", this_skin.micro_frames.textymod)
					Details.StatusBar:ApplyOptions (self.StatusBar.right, "textymod", this_skin.micro_frames.textymod)
				end
				if (this_skin.micro_frames.hidden) then
					Details.StatusBar:ApplyOptions (self.StatusBar.left, "hidden", this_skin.micro_frames.hidden)
					Details.StatusBar:ApplyOptions (self.StatusBar.center, "hidden", this_skin.micro_frames.hidden)
					Details.StatusBar:ApplyOptions (self.StatusBar.right, "hidden", this_skin.micro_frames.hidden)
				end
				if (this_skin.micro_frames.color) then
					Details.StatusBar:ApplyOptions (self.StatusBar.left, "textcolor", this_skin.micro_frames.color)
					Details.StatusBar:ApplyOptions (self.StatusBar.center, "textcolor", this_skin.micro_frames.color)
					Details.StatusBar:ApplyOptions (self.StatusBar.right, "textcolor", this_skin.micro_frames.color)
				end
				if (this_skin.micro_frames.font) then
					Details.StatusBar:ApplyOptions (self.StatusBar.left, "textface", this_skin.micro_frames.font)
					Details.StatusBar:ApplyOptions (self.StatusBar.center, "textface", this_skin.micro_frames.font)
					Details.StatusBar:ApplyOptions (self.StatusBar.right, "textface", this_skin.micro_frames.font)
				end
				if (this_skin.micro_frames.size) then
					Details.StatusBar:ApplyOptions (self.StatusBar.left, "textsize", this_skin.micro_frames.size)
					Details.StatusBar:ApplyOptions (self.StatusBar.center, "textsize", this_skin.micro_frames.size)
					Details.StatusBar:ApplyOptions (self.StatusBar.right, "textsize", this_skin.micro_frames.size)
				end
			end

	end

	self.skin = skin_name

	local skin_file = this_skin.file

	--set textures
		if (self.skin_custom ~= "") then
			skin_file = "Interface\\" .. self.skin_custom
		end

		self.baseframe.cabecalho.ball:SetTexture(skin_file) --bola esquerda
		self.baseframe.cabecalho.emenda:SetTexture(skin_file) --emenda que liga a bola a textura do centro

		self.baseframe.cabecalho.ball_r:SetTexture(skin_file) --bola direita onde fica o bot�o de fechar
		self.baseframe.cabecalho.top_bg:SetTexture(skin_file) --top background

		self.baseframe.barra_esquerda:SetTexture(skin_file) --barra lateral
		self.baseframe.barra_direita:SetTexture(skin_file) --barra lateral
		self.baseframe.barra_fundo:SetTexture(skin_file) --barra inferior

		self.baseframe.scroll_up:SetTexture(skin_file) --scrollbar parte de cima
		self.baseframe.scroll_down:SetTexture(skin_file) --scrollbar parte de baixo
		self.baseframe.scroll_middle:SetTexture(skin_file) --scrollbar parte do meio

		self.baseframe.rodape.top_bg:SetTexture(skin_file) --rodape top background
		self.baseframe.rodape.esquerdo:SetTexture(skin_file) --rodape esquerdo
		self.baseframe.rodape.direita:SetTexture(skin_file) --rodape direito
		self.baseframe.rodape.esquerdo_nostatusbar:SetTexture(skin_file) --rodape direito
		self.baseframe.rodape.direita_nostatusbar:SetTexture(skin_file) --rodape direito

		self.baseframe.button_stretch.texture:SetTexture(skin_file) --bot�o de esticar a janela

		self.baseframe.resize_direita.texture:SetTexture(skin_file) --bot�o de redimencionar da direita
		self.baseframe.resize_esquerda.texture:SetTexture(skin_file) --bot�o de redimencionar da esquerda

		self.break_snap_button:SetNormalTexture(skin_file) --cadeado
		self.break_snap_button:SetDisabledTexture(skin_file)
		self.break_snap_button:SetHighlightTexture(skin_file, "ADD")
		self.break_snap_button:SetPushedTexture(skin_file)

	--update toolbar icons
	local toolbar_buttons = {}

	do
		local toolbar_icon_file = self.toolbar_icon_file
		if (not toolbar_icon_file) then
			toolbar_icon_file = [[Interface\AddOns\Details\images\toolbar_icons]]
		end

		toolbar_buttons [1] = self.baseframe.cabecalho.modo_selecao
		toolbar_buttons [2] = self.baseframe.cabecalho.segmento
		toolbar_buttons [3] = self.baseframe.cabecalho.atributo
		toolbar_buttons [4] = self.baseframe.cabecalho.report
		toolbar_buttons [5] = self.baseframe.cabecalho.reset
		toolbar_buttons [6] = self.baseframe.cabecalho.fechar

		for i = 1, #toolbar_buttons do
			local button = toolbar_buttons [i]
			button:SetNormalTexture(toolbar_icon_file)
			button:SetHighlightTexture(toolbar_icon_file)
			button:SetPushedTexture(toolbar_icon_file)
		end
	end

----------icon anchor and size

	if (self.modo == 1 or self.modo == 4 or self.atributo == 5) then -- alone e raid
		local icon_anchor = this_skin.icon_anchor_plugins
		self.baseframe.cabecalho.atributo_icon:SetPoint("topright", self.baseframe.cabecalho.ball_point, "topright", icon_anchor[1], icon_anchor[2])
		if (self.modo == 1) then
			if (Details.SoloTables.Plugins [1] and Details.SoloTables.Mode) then
				local plugin_index = Details.SoloTables.Mode
				if (plugin_index > 0 and Details.SoloTables.Menu [plugin_index]) then
					self:ChangeIcon (Details.SoloTables.Menu [plugin_index] [2])
				end
			end

		elseif (self.modo == 4) then
			--if (_detalhes.RaidTables.Plugins [1] and _detalhes.RaidTables.Mode) then
			--	local plugin_index = _detalhes.RaidTables.Mode
			--	if (plugin_index and _detalhes.RaidTables.Menu [plugin_index]) then
					--self:ChangeIcon (_detalhes.RaidTables.Menu [plugin_index] [2])
			--	end
			--end
		end
	else
		local icon_anchor = this_skin.icon_anchor_main --ancora do icone do canto direito superior
		self.baseframe.cabecalho.atributo_icon:SetPoint("topright", self.baseframe.cabecalho.ball_point, "topright", icon_anchor[1], icon_anchor[2])
		self:ChangeIcon()
	end

----------lock alpha head

	if (not this_skin.can_change_alpha_head) then
		self.baseframe.cabecalho.ball:SetAlpha(maxAlpha)
	else
		self.baseframe.cabecalho.ball:SetAlpha(self.color[4])
	end

----------update abbreviation function on the class files

	Details.atributo_damage:UpdateSelectedToKFunction()
	Details.atributo_heal:UpdateSelectedToKFunction()
	Details.atributo_energy:UpdateSelectedToKFunction()
	Details.atributo_misc:UpdateSelectedToKFunction()
	Details.atributo_custom:UpdateSelectedToKFunction()

----------call widgets handlers
		self:SetBarSettings (self.row_info.height)
		self:SetBarBackdropSettings()
		self:SetBarSpecIconSettings()
		self:SetBarRightTextSettings()

	--update toolbar
		self:ToolbarSide()

	--update stretch button
		self:StretchButtonAnchor()

	--update side bars
		if (self.show_sidebars) then
			self:ShowSideBars()
		else
			self:HideSideBars()
		end

	--refresh the side of the micro displays and its lock state
		self:MicroDisplaysSide()
		self:MicroDisplaysLock()
		self:RefreshMicroDisplays()

	--update statusbar
		if (self.show_statusbar) then
			self:ShowStatusBar()
		else
			self:HideStatusBar()
		end

	--update wallpaper
		if (self.wallpaper.enabled) then
			self:InstanceWallpaper (true)
		else
			self:InstanceWallpaper (false)
		end

	--update instance color
		self:InstanceColor()
		self:SetBackgroundColor()
		self:SetBackgroundAlpha()
		self:SetAutoHideMenu()
		self:SetBackdropTexture()

	--refresh all bars
		self:InstanceRefreshRows()

	--update menu saturation
		self:DesaturateMenu()

	--update statusbar color
		self:StatusBarColor()

	--update attribute string
		self:AttributeMenu()

	--update top menus
		self:LeftMenuAnchorSide()

	--update window strata level
		self:SetFrameStrata()

	--update the combat alphas
		self:AdjustAlphaByContext()

	--update icons
		Details.ToolBar:ReorganizeIcons (true) --call self:SetMenuAlpha()

	--refresh options panel if opened
		if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown() and not _G.DetailsOptionsWindow.IsLoading) then
			Details:OpenOptionsWindow (self)
		end

	--auto interact
		if (self.menu_alpha.enabled) then
			self:SetMenuAlpha(nil, nil, nil, nil, self.is_interacting)
		end

	--set the scale
		self:SetWindowScale()

	--refresh lock buttons
		self:RefreshLockedState()

	--update borders
		self:UpdateFullBorder()
		self:UpdateRowAreaBorder()

	--update title bar
		self:RefreshTitleBar()

	--update the wallpaper level
		self:SetInstanceWallpaperLevel()

	--clear any control sscript running in this instance
	self.bgframe:SetScript("OnUpdate", nil)
	self.bgframe.skin_script = nil

	local baseFrame = self.baseframe
	local fullWindowFrame = baseFrame.fullWindowFrame

	if (self.rounded_corner_enabled) then
        baseFrame:SetBackdropColor(0, 0, 0, 0)
        baseFrame:SetBackdropBorderColor(0, 0, 0, 0)
        baseFrame:SetBackdrop(nil)

		fullWindowFrame = baseFrame.fullWindowFrame
		if (not fullWindowFrame.__rcorners) then
			local preset = Details.PlayerBreakdown.RoundedCornerPreset
			DetailsFramework:AddRoundedCornersToFrame(fullWindowFrame, preset)
		else
			fullWindowFrame:EnableRoundedCorners()
		end

		self.menu_attribute_string:SetParent(fullWindowFrame)
	else
		if (fullWindowFrame.__rcorners) then
			fullWindowFrame:DisableRoundedCorners()
			self.menu_attribute_string:SetParent(baseFrame)
		end
	end

	self:UpdateClickThrough()
end

--update the window click through state
local updateClickThroughListener = Details:CreateEventListener()
function updateClickThroughListener:EnterCombat()
	Details:InstanceCall(function(instance)
		C_Timer.After(1.5, function()
			instance:UpdateClickThrough()
		end)
	end)
end

function updateClickThroughListener:LeaveCombat()
	Details:InstanceCall(function(instance)
		C_Timer.After(1.5, function()
			instance:UpdateClickThrough()
		end)
	end)
end

updateClickThroughListener:RegisterEvent("COMBAT_PLAYER_ENTER", "EnterCombat")
updateClickThroughListener:RegisterEvent("COMBAT_PLAYER_LEAVE", "EnterCombat")

function Details:UpdateClickThroughSettings (inCombat, window, bars, toolbaricons)
	if (inCombat ~= nil) then
		self.clickthrough_incombatonly = inCombat
	end

	if (window ~= nil) then
		self.clickthrough_window = window
	end

	if (bars ~= nil) then
		self.clickthrough_rows = bars
	end

	if (toolbaricons ~= nil) then
		self.clickthrough_toolbaricons = toolbaricons
	end

	self:UpdateClickThrough()
end

function Details:UpdateClickThrough()

	local barsClickThrough = self.clickthrough_rows
	local windowClickThrough = self.clickthrough_window
	local onlyInCombat = self.clickthrough_incombatonly
	local toolbarIcons = not self.clickthrough_toolbaricons

	if (onlyInCombat) then

		if (InCombatLockdown()) then
			--player bars
			if (barsClickThrough) then
				for barIndex, barObject in ipairs(self.barras) do
					barObject:EnableMouse(false)
					barObject.icon_frame:EnableMouse(false)
				end
			else
				for barIndex, barObject in ipairs(self.barras) do
					barObject:EnableMouse(true)
					barObject.icon_frame:EnableMouse(true)
				end
			end

			--window frames
			if (windowClickThrough) then
				self.baseframe:EnableMouse(false)
				self.bgframe:EnableMouse(false)
				self.rowframe:EnableMouse(false)
				self.floatingframe:EnableMouse(false)
				self.windowSwitchButton:EnableMouse(false)
				self.windowBackgroundDisplay:EnableMouse(false)
				self.baseframe.UPFrame:EnableMouse(false)
				self.baseframe.DOWNFrame:EnableMouse(false)


			else
				self.baseframe:EnableMouse(true)
				self.bgframe:EnableMouse(true)
				self.rowframe:EnableMouse(true)
				self.floatingframe:EnableMouse(true)
				self.windowSwitchButton:EnableMouse(true)
				self.windowBackgroundDisplay:EnableMouse(true)
				self.baseframe.UPFrame:EnableMouse(true)
				self.baseframe.DOWNFrame:EnableMouse(true)
			end

			--titlebar icons
			local toolbar_buttons = {}
			toolbar_buttons [1] = self.baseframe.cabecalho.modo_selecao
			toolbar_buttons [2] = self.baseframe.cabecalho.segmento
			toolbar_buttons [3] = self.baseframe.cabecalho.atributo
			toolbar_buttons [4] = self.baseframe.cabecalho.report
			toolbar_buttons [5] = self.baseframe.cabecalho.reset
			toolbar_buttons [6] = self.baseframe.cabecalho.fechar

			for i, button in ipairs(toolbar_buttons) do
				button:EnableMouse(toolbar_buttons)
			end

		else
			--player bars
			for barIndex, barObject in ipairs(self.barras) do
				barObject:EnableMouse(true)
				barObject.icon_frame:EnableMouse(true)
			end

			--window frames
			self.baseframe:EnableMouse(true)
			self.bgframe:EnableMouse(true)
			self.rowframe:EnableMouse(true)
			self.floatingframe:EnableMouse(true)
			self.windowSwitchButton:EnableMouse(true)
			self.windowBackgroundDisplay:EnableMouse(true)
			self.baseframe.UPFrame:EnableMouse(true)
			self.baseframe.DOWNFrame:EnableMouse(true)

			--titlebar icons, forcing true because the player isn't in combat and the inCombat setting is enabled
			local toolbar_buttons = {}
			toolbar_buttons [1] = self.baseframe.cabecalho.modo_selecao
			toolbar_buttons [2] = self.baseframe.cabecalho.segmento
			toolbar_buttons [3] = self.baseframe.cabecalho.atributo
			toolbar_buttons [4] = self.baseframe.cabecalho.report
			toolbar_buttons [5] = self.baseframe.cabecalho.reset
			toolbar_buttons [6] = self.baseframe.cabecalho.fechar

			for i, button in ipairs(toolbar_buttons) do
				button:EnableMouse(true)
			end
		end
	else

		--player bars
		if (barsClickThrough) then
			for barIndex, barObject in ipairs(self.barras) do
				barObject:EnableMouse(false)
				barObject.icon_frame:EnableMouse(false)
			end
		else
			for barIndex, barObject in ipairs(self.barras) do
				barObject:EnableMouse(true)
			end
		end

		--window frame
		if (windowClickThrough) then
			self.baseframe:EnableMouse(false)
			self.bgframe:EnableMouse(false)
			self.rowframe:EnableMouse(false)
			self.floatingframe:EnableMouse(false)
			self.windowSwitchButton:EnableMouse(false)
			self.windowBackgroundDisplay:EnableMouse(false)
			self.baseframe.UPFrame:EnableMouse(false)
			self.baseframe.DOWNFrame:EnableMouse(false)
		else
			self.baseframe:EnableMouse(true)
			self.bgframe:EnableMouse(true)
			self.rowframe:EnableMouse(true)
			self.floatingframe:EnableMouse(true)
			self.windowSwitchButton:EnableMouse(true)
			self.windowBackgroundDisplay:EnableMouse(true)
			self.baseframe.UPFrame:EnableMouse(true)
			self.baseframe.DOWNFrame:EnableMouse(true)
		end

		--titlebar icons
		local toolbar_buttons = {}
		toolbar_buttons [1] = self.baseframe.cabecalho.modo_selecao
		toolbar_buttons [2] = self.baseframe.cabecalho.segmento
		toolbar_buttons [3] = self.baseframe.cabecalho.atributo
		toolbar_buttons [4] = self.baseframe.cabecalho.report
		toolbar_buttons [5] = self.baseframe.cabecalho.reset
		toolbar_buttons [6] = self.baseframe.cabecalho.fechar

		for i, button in ipairs(toolbar_buttons) do
			button:EnableMouse(toolbarIcons)
		end
	end
end

function Details:DelayedCheckCombatAlpha (instance, alpha)
	if (UnitAffectingCombat("player") or InCombatLockdown()) then
		instance:SetWindowAlphaForCombat(true, true, alpha) --hida a janela
		instance:SetWindowAlphaForCombat(true, true, alpha) --hida a janela
	end
end

function Details:DelayedCheckOutOfCombatAlpha (instance, alpha)
	if (not UnitAffectingCombat("player") and not InCombatLockdown()) then
		instance:SetWindowAlphaForCombat(true, true, alpha) --hida a janela
		instance:SetWindowAlphaForCombat(true, true, alpha) --hida a janela
	end
end

function Details:DelayedCheckOutOfCombatAndGroupAlpha (instance, alpha)
	if ((Details.zone_type == "raid" or Details.zone_type == "party") and IsInInstance()) then
		if (UnitAffectingCombat("player") or InCombatLockdown()) then
			instance:SetWindowAlphaForCombat(false, false, alpha) --deshida a janela
		else
			instance:SetWindowAlphaForCombat(true, true, alpha) --hida a janela
			instance:SetWindowAlphaForCombat(true, true, alpha) --hida a janela
		end
	end
end

local getAlphaByContext = function(instance, contextIndex, invert)
	local alpha = instance.hide_on_context[contextIndex].value
	if (invert) then
		alpha = abs(alpha - 100)
	end
	return alpha
end

function Details:AdjustAlphaByContext(interacting)

	--in combat
	if (not self.meu_id) then
		print("error Details! AdjustAlphaByContext()", debugstack())
	end

	local hasRuleEnabled = false

	--not in group
	if (self.hide_on_context[3].enabled) then
		if (self.hide_on_context[3].inverse) then
			--while in group
			if (Details.in_group) then
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 3)) --hida a janela
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 3)) --hida a janela
				hasRuleEnabled = true
			end
		else
			--while not in group
			if (not Details.in_group) then
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 3)) --hida a janela
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 3)) --hida a janela
				hasRuleEnabled = true
			end
		end
	end

	--while not inside instance
	if (self.hide_on_context[4].enabled) then
		local isInInstance = IsInInstance()
		if (not isInInstance or (not Details.zone_type == "raid" and not Details.zone_type == "party")) then
			self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 4)) --hida a janela
			self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 4)) --hida a janela
			hasRuleEnabled = true
		end
	end

	--while inside instance
	if (self.hide_on_context[5].enabled) then
		local isInInstance = IsInInstance()
		if (isInInstance or Details.zone_type == "raid" or Details.zone_type == "party") then
			self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 5)) --hida a janela
			self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 5)) --hida a janela
			hasRuleEnabled = true
		end
	end

	--raid debug (inside instance + out of combat)
	if (self.hide_on_context[6].enabled) then
		if ((Details.zone_type == "raid" or Details.zone_type == "party") and IsInInstance()) then
			Details:ScheduleTimer("DelayedCheckOutOfCombatAndGroupAlpha", 0.3, self, getAlphaByContext(self, 6))
		end
	end

	--in arena
	if (self.hide_on_context[9].enabled) then
		local contextId = 9
		local isInInstance = IsInInstance()
		if (isInInstance and Details.zone_type == "arena") then
			--player is within a pvp arena
			if (not self.hide_on_context[contextId].inverse) then
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, contextId))
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, contextId))
			else
				self:SetWindowAlphaForCombat(false, false, getAlphaByContext(self, contextId)) --deshida a janela
			end
			hasRuleEnabled = true
		else
			--player is not inside an arena
			if (self.hide_on_context[contextId].inverse) then
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, contextId))
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, contextId))
				hasRuleEnabled = true
			end
		end
	end

	--in battleground
	if (self.hide_on_context[7].enabled) then
		local isInInstance = IsInInstance()
		if (isInInstance and Details.zone_type == "pvp") then
			--player is inside a battleground
			if (not self.hide_on_context[7].inverse) then
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 7)) --hida a janela
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 7)) --hida a janela
			else
				self:SetWindowAlphaForCombat(false, false, getAlphaByContext(self, 7)) --deshida a janela
			end
			hasRuleEnabled = true

		else
			--player is not inside a battleground
			if (not self.hide_on_context[7].inverse) then
				--there's no inverse rule: do nothing
				--self:SetWindowAlphaForCombat(false, false, getAlphaByContext(self, 7)) --deshida a janela
			else
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 7)) --hida a janela
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 7)) --hida a janela
				hasRuleEnabled = true
			end
		end
	end

	--mythic+
	if (self.hide_on_context[8].enabled) then
		if (_G.DetailsMythicPlusFrame and _G.DetailsMythicPlusFrame.IsDoingMythicDungeon) then
			--player is inside a dungeon mythic+
			if (not self.hide_on_context[8].inverse) then
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 8)) --hida a janela
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 8)) --hida a janela
			else
				self:SetWindowAlphaForCombat(false, false, getAlphaByContext(self, 8)) --deshida a janela
			end
			hasRuleEnabled = true

		else
			if (not self.hide_on_context[8].inverse) then
				--there's no inverse rule: do nothing
				--self:SetWindowAlphaForCombat(false, false, getAlphaByContext(self, 8)) --deshida a janela
			else
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 8)) --hida a janela
				self:SetWindowAlphaForCombat(true, true, getAlphaByContext(self, 8)) --hida a janela
				hasRuleEnabled = true
			end
		end
	end

	--in combat
	if (self.hide_on_context[1].enabled) then
		Details:ScheduleTimer("DelayedCheckCombatAlpha", 0.3, self, getAlphaByContext(self, 1))
	end

	--out of combat
	if (self.hide_on_context[2].enabled) then
		Details:ScheduleTimer("DelayedCheckOutOfCombatAlpha", 0.3, self, getAlphaByContext(self, 2))
	end

	--if no rule is enabled, show the window
	if (not hasRuleEnabled) then
		self:SetWindowAlphaForCombat(false)
		self:SetWindowAlphaForCombat(false)
	end
end

function Details:LeftMenuAnchorSide (side)
	if (not side) then
		side = self.menu_anchor.side
	end

	self.menu_anchor.side = side
	return self:MenuAnchor()
end

function Details:SetFrameStrata(strata)
	if (not strata) then
		strata = self.strata
	end

	self.strata = strata

	self.rowframe:SetFrameStrata(strata)
	self.windowSwitchButton:SetFrameStrata(strata)
	self.baseframe:SetFrameStrata(strata)

	if (strata == "BACKGROUND") then
		self.break_snap_button:SetFrameStrata("LOW")
		self.baseframe.resize_esquerda:SetFrameStrata("LOW")
		self.baseframe.resize_direita:SetFrameStrata("LOW")
		self.baseframe.lock_button:SetFrameStrata("LOW")

	elseif (strata == "LOW") then
		self.break_snap_button:SetFrameStrata("MEDIUM")
		self.baseframe.resize_esquerda:SetFrameStrata("MEDIUM")
		self.baseframe.resize_direita:SetFrameStrata("MEDIUM")
		self.baseframe.lock_button:SetFrameStrata("MEDIUM")

	elseif (strata == "MEDIUM") then
		self.break_snap_button:SetFrameStrata("HIGH")
		self.baseframe.resize_esquerda:SetFrameStrata("HIGH")
		self.baseframe.resize_direita:SetFrameStrata("HIGH")
		self.baseframe.lock_button:SetFrameStrata("HIGH")

	elseif (strata == "HIGH") then
		self.break_snap_button:SetFrameStrata("DIALOG")
		self.baseframe.resize_esquerda:SetFrameStrata("DIALOG")
		self.baseframe.resize_direita:SetFrameStrata("DIALOG")
		self.baseframe.lock_button:SetFrameStrata("DIALOG")

	elseif (strata == "DIALOG") then
		self.break_snap_button:SetFrameStrata("FULLSCREEN")
		self.baseframe.resize_esquerda:SetFrameStrata("FULLSCREEN")
		self.baseframe.resize_direita:SetFrameStrata("FULLSCREEN")
		self.baseframe.lock_button:SetFrameStrata("FULLSCREEN")
	end

	self:StretchButtonAlwaysOnTop()
end

--set and refresh the full border
function Details:UpdateFullBorder(shown, color, size)
	if (type(shown) == "boolean") then
		self.fullborder_shown = shown
	else
		shown = self.fullborder_shown
	end

	if (size) then
		self.fullborder_size = size
	else
		size = self.fullborder_size
	end

	if (color) then
		self.fullborder_color = color
	else
		color = self.fullborder_color
	end

	self.baseframe.fullWindowFrame.border:SetShown(shown)
	if (shown) then
		self.baseframe.fullWindowFrame.border:SetBorderSizes(size, size, size, size)
		self.baseframe.fullWindowFrame.border:UpdateSizes()
		self.baseframe.fullWindowFrame.border:SetVertexColor(DetailsFramework:ParseColors(color))
	end
end

--set and refresh the border of the row area
function Details:UpdateRowAreaBorder(shown, color, size)
	if (type(shown) == "boolean") then
		self.rowareaborder_shown = shown
	else
		shown = self.rowareaborder_shown
	end

	if (size) then
		self.rowareaborder_size = size
	else
		size = self.rowareaborder_size
	end

	if (color) then
		self.rowareaborder_color = color
	else
		color = self.rowareaborder_color
	end

	self.baseframe.border:SetShown(shown)
	if (shown) then
		self.baseframe.border:SetBorderSizes(size, size, size, size)
		self.baseframe.border:UpdateSizes()
		self.baseframe.border:SetVertexColor(DetailsFramework:ParseColors(color))
	end
end

-- ~attributemenu (text with attribute name)
function Details:RefreshAttributeTextSize()
	if (self.attribute_text.enabled and self.total_buttons_shown and self.baseframe and self.menu_attribute_string) then

		local window_width = self:GetSize()

		if (self.auto_hide_menu.left and not self.is_interacting) then
			self.menu_attribute_string:SetWidth(window_width)
			self.menu_attribute_string:SetHeight(self.attribute_text.text_size + 2)
			return
		end

		local buttons_shown = self.total_buttons_shown
		local buttons_width, buttons_spacement = self.menu_icons_size * 16, self.menu_icons.space

		local width_by_buttons = (buttons_shown * buttons_width) + (buttons_spacement * (buttons_shown - 1))

		local text_size = window_width - width_by_buttons - 6
		self.menu_attribute_string:SetWidth(text_size)
		self.menu_attribute_string:SetHeight(self.attribute_text.text_size + 2)
	end
end

-- ~encounter ~timer
function Details:CheckForTextTimeCounter(combatStart) --called from combat start function
	if (combatStart) then
		--if (Details.tabela_vigente.is_boss) then --is an encounter
			local instanceId = Details:GetLowerInstanceNumber()
			if (instanceId) then
				local instance = Details:GetInstance(instanceId)
				if (instance.baseframe and instance:IsEnabled()) then
					if (instance.attribute_text.show_timer) then --can show the timer
						--start a new ticker of 1 second
						if (Details.instance_title_text_timer[instance:GetId()]) then
							Details.Schedules.Cancel(Details.instance_title_text_timer[instance:GetId()])
						end
						Details.instance_title_text_timer[instance:GetId()] = Details.Schedules.NewTicker(1, Details.TitleTextTickTimer, Details, instance)
					end
				end
			else
				return --there's no open window
			end
		--else --boss encounter not found
		--	if (Details.in_combat and Details.zone_type == "raid") then
		--		Details.Schedules.NewTimer(3, Details.CheckForTextTimeCounter, Details, true)
		--	end
		--end
	else
		for instanceId, instance in Details:ListInstances() do
			if (Details.instance_title_text_timer[instance:GetId()] and instance.baseframe and instance:IsEnabled() and instance.menu_attribute_string) then --check if the instance is initialized
				Details.Schedules.Cancel(Details.instance_title_text_timer[instance:GetId()])
				local currentText = instance:GetTitleBarText()
				if (currentText) then
					currentText = currentText:gsub("%[.*%] ", "")
					instance:SetTitleBarText(currentText)
				end
			end
		end
	end
end

local formatTime = function(t)
	---@type any, any
	local minute, second = floor(t/60), floor(t%60)
	if (minute < 1) then
		minute = "00"
	elseif (minute < 10) then
		minute = "0" .. minute
	end
	if (second < 10) then
		second = "0" .. second
	end
	return "[" .. minute .. ":" .. second .. "]"
end

local updateTimerInTheTitleBarText = function(instance, timer)
	local originalText = instance.menu_attribute_string.originalText
	if (originalText) then
		local formattedTime = formatTime(timer)
		instance:SetTitleBarText(formattedTime .. " " .. originalText)

	else
		local titleBarTitleText = instance:GetTitleBarText()
		if (titleBarTitleText) then
			if (not titleBarTitleText:find("%[.*%]")) then
				instance:SetTitleBarText("[00:01] " .. titleBarTitleText)
			else
				local formattedTime = formatTime(timer)
				titleBarTitleText = titleBarTitleText:gsub("%[.*%]", formattedTime)
				instance:SetTitleBarText(titleBarTitleText)
			end
		end
	end
end

--self is Details
--this is a ticker callback, it is called on each 1 second
function Details:TitleTextTickTimer(instance)
	--hold the time value to show in the title bar
	local timer

	if (instance.attribute_text.enabled) then
		local zoneType = Details:GetZoneType()

		if (zoneType == "arena") then
			if (instance.attribute_text.show_timer_arena) then
				timer = GetTime() - Details:GetArenaStartTime()
			end

		elseif (zoneType == "pvp") then
			if (instance.attribute_text.show_timer_bg) then
				timer = GetTime() - Details:GetBattlegroundStartTime()
			end

		elseif (zoneType == "raid" or zoneType == "party") then
			--always attempt to show the time during a boss encounter
			if (IsEncounterInProgress) then
				if (IsEncounterInProgress()) then
					timer = Details:GetCurrentCombat():GetCombatTime()
				end
			else
				if (Details.tabela_vigente.is_boss) then
					timer = Details:GetCurrentCombat():GetCombatTime()
				end
			end
		end

		if (not timer) then
			if (instance.attribute_text.show_timer_always) then
				timer = Details:GetCurrentCombat():GetCombatTime()
			end
		end

		if (timer) then
			local combatObject = instance:GetShowingCombat()
			combatObject.hasTimer = timer
			updateTimerInTheTitleBarText(instance, timer)
		end
	end
end

function Details:RefreshTitleBarText()
	local titleBarText = self.menu_attribute_string

	if (titleBarText and self == titleBarText.owner_instance) then
		local sName = self:GetInstanceAttributeText()
		local instanceMode = self:GetMode()

		if (instanceMode == DETAILS_MODE_GROUP or instanceMode == DETAILS_MODE_ALL) then
			local segment = self:GetSegment()
			if (segment == DETAILS_SEGMENTID_OVERALL) then
				local dynamicOverallDataCustomID = Details222.GetCustomDisplayIDByName(Loc["STRING_CUSTOM_DYNAMICOVERAL"])
				if ((dynamicOverallDataCustomID ~= self.sub_atributo) and self.atributo ~= 5) then
					sName = sName .. " " .. Loc["STRING_OVERALL"]
				end

			elseif (segment >= 2) then
				sName = sName .. " [" .. segment .. "]"
			end
		end

		if (not Details.in_combat) then
			local timer = false --self:GetShowingCombat().hasTimer
			if (timer) then
				local timeFormatted = formatTime(timer)
				titleBarText.originalText = sName
				sName = timeFormatted .. " " .. sName
				titleBarText:SetText(sName)
			else
				titleBarText:SetText(sName)
				titleBarText.originalText = sName
			end
		else
			titleBarText:SetText(sName)
			titleBarText.originalText = sName
		end
	end
end

function Details:SetTitleBarText(text)
	if (self.menu_attribute_string) then
		self.menu_attribute_string:SetText(text)
	end
end

function Details:GetTitleBarText()
	if (self.menu_attribute_string) then
		return self.menu_attribute_string:GetText()
	end
end

--~titletext
--@timer_bg: battleground elapsed time
--@timer_arena: arena match elapsed time
function Details:AttributeMenu(enabled, pos_x, pos_y, font, size, color, side, shadow, timer_encounter, timer_bg, timer_arena)
	if (type(enabled) ~= "boolean") then
		enabled = self.attribute_text.enabled
	end

	if (not pos_x) then
		pos_x = self.attribute_text.anchor [1]
	end
	if (not pos_y) then
		pos_y = self.attribute_text.anchor [2]
	end

	if (not font) then
		font = self.attribute_text.text_face
	end

	if (not size) then
		size = self.attribute_text.text_size
	end

	if (not color) then
		color = self.attribute_text.text_color
	end

	if (not side) then
		side = self.attribute_text.side
	end

	if (type(shadow) ~= "boolean") then
		shadow = self.attribute_text.shadow
	end

	if (type(self.attribute_text.show_timer) ~= "boolean") then
		self.attribute_text.show_timer = true
	end
	if (type(timer_encounter) ~= "boolean") then
		timer_encounter = self.attribute_text.show_timer
	end

	if (type(timer_bg) ~= "boolean") then
		timer_bg = self.attribute_text.show_timer_bg
	end
	if (type(timer_arena) ~= "boolean") then
		timer_arena = self.attribute_text.show_timer_arena
	end

	self.attribute_text.enabled = enabled
	self.attribute_text.anchor[1] = pos_x
	self.attribute_text.anchor[2] = pos_y
	self.attribute_text.text_face = font
	self.attribute_text.text_size = size
	self.attribute_text.text_color = color
	self.attribute_text.side = side
	self.attribute_text.shadow = shadow
	self.attribute_text.show_timer = timer_encounter
	self.attribute_text.show_timer_bg = timer_bg
	self.attribute_text.show_timer_arena = timer_arena

	--enabled
	if (not enabled and self.menu_attribute_string) then
		return self.menu_attribute_string:Hide()
	elseif (not enabled) then
		return
	end

	--protection against failed clean up framework table
	if (self.menu_attribute_string and not getmetatable(self.menu_attribute_string)) then
		self.menu_attribute_string = nil
	end

	if (not self.menu_attribute_string) then
		--local label = gump:NewLabel(self.floatingframe, nil, "DetailsAttributeStringInstance" .. self.meu_id, nil, "", "GameFontHighlightSmall")
		local label = gump:NewLabel(self.baseframe, nil, "DetailsAttributeStringInstance" .. self.meu_id, nil, "", "GameFontHighlightSmall")
		self.baseframe.titleText = label
		self.menu_attribute_string = label
		self.menu_attribute_string.owner_instance = self
		self.menu_attribute_string.Enabled = true
		self.menu_attribute_string.__enabled = true

		function self.menu_attribute_string:OnEvent(instance, attribute, subAttribute)
			instance:RefreshTitleBarText()
		end

		Details:RegisterEvent(self.menu_attribute_string, "DETAILS_INSTANCE_CHANGEATTRIBUTE", self.menu_attribute_string.OnEvent)
		Details:RegisterEvent(self.menu_attribute_string, "DETAILS_INSTANCE_CHANGEMODE", self.menu_attribute_string.OnEvent)
		Details:RegisterEvent(self.menu_attribute_string, "DETAILS_INSTANCE_CHANGESEGMENT", self.menu_attribute_string.OnEvent)

		self:RefreshTitleBarText()
	end

	self.menu_attribute_string:Show()

	--anchor
	if (side == 1) then --a string esta no lado de cima
		if (self.toolbar_side == 1) then -- a toolbar esta em cima
			self.menu_attribute_string:ClearAllPoints()
			self.menu_attribute_string:SetPoint("bottomleft", self.baseframe.cabecalho.ball, "bottomright", self.attribute_text.anchor [1], self.attribute_text.anchor [2])

		elseif (self.toolbar_side == 2) then --a toolbar esta em baixo
			self.menu_attribute_string:ClearAllPoints()
			self.menu_attribute_string:SetPoint("bottomleft", self.baseframe, "topleft", self.attribute_text.anchor [1] + 21, self.attribute_text.anchor [2])

		end

	elseif (side == 2) then --a string esta no lado de baixo
		if (self.toolbar_side == 1) then --toolbar esta em cima
			self.menu_attribute_string:ClearAllPoints()
			self.menu_attribute_string:SetPoint("left", self.baseframe.rodape.StatusBarLeftAnchor, "left", self.attribute_text.anchor [1] + 16, self.attribute_text.anchor [2] - 6)

		elseif (self.toolbar_side == 2) then --toolbar esta em baixo
			self.menu_attribute_string:SetPoint("bottomleft", self.baseframe.cabecalho.ball, "topright", self.attribute_text.anchor [1], self.attribute_text.anchor [2] - 19)

		end
	end

	--font face
	local fontPath = SharedMedia:Fetch("font", font)
	Details:SetFontFace(self.menu_attribute_string, fontPath)

	--font size
	Details:SetFontSize(self.menu_attribute_string, size)

	--color
	Details:SetFontColor(self.menu_attribute_string, color)
	C_Timer.After(1, function()
		Details:SetFontColor(self.menu_attribute_string, color)
	end)

	--shadow
	Details:SetFontOutline(self.menu_attribute_string, shadow)

	--refresh size
	self:RefreshAttributeTextSize()
end

-- ~backdrop
function Details:SetBackdropTexture(texturename)
	if (not texturename) then
		texturename = self.backdrop_texture
	end

	self.backdrop_texture = texturename

	local texture_path = SharedMedia:Fetch("background", texturename)

	self.baseframe:SetBackdrop({
		bgFile = texture_path, tile = true, tileSize = 128,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
	)
	self.bgdisplay:SetBackdrop({
		bgFile = texture_path, tile = true, tileSize = 128,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
	)

	self:SetBackgroundAlpha(self.bg_alpha)
end

-- ~alpha (transparency of buttons on the toolbar) ~autohide �utohide ~menuauto
function Details:SetAutoHideMenu(left, right, interacting)
	--30/07/2018: the separation by left and right menu icons doesn't exists for years, but it was still active in the code making
	--the toolbar icons show on initialization even when the options to auto hide them enabled.
	--the code to set the alpha was already updated to only one anhor (left) but this function was still calling to update the right anchor (deprecated)

	if (interacting) then
		if (self.is_interacting) then
			if (self.auto_hide_menu.left) then
				local r, g, b = unpack(self.color_buttons)
				self:InstanceButtonsColors (r, g, b, self.menu_icons_alpha, true, true) --no save, only left

				if (self.baseframe.cabecalho.PluginIconsSeparator) then
					self.baseframe.cabecalho.PluginIconsSeparator:Show()
				end
			end
		else
			if (self.auto_hide_menu.left) then
				local r, g, b = unpack(self.color_buttons)
				self:InstanceButtonsColors (r, g, b, 0, true, true) --no save, only left

				if (self.baseframe.cabecalho.PluginIconsSeparator) then
					self.baseframe.cabecalho.PluginIconsSeparator:Hide()
				end
			end
		end
		return
	end

	if (left == nil) then
		left = self.auto_hide_menu.left
	end
	if (right == nil) then
		right = self.auto_hide_menu.right
	end

	self.auto_hide_menu.left = left
	self.auto_hide_menu.right = right

	local r, g, b = unpack(self.color_buttons)

	if (not left) then
		--auto hide is off
		self:InstanceButtonsColors (r, g, b, self.menu_icons_alpha, true, true) --no save, only left

		if (self.baseframe.cabecalho.PluginIconsSeparator) then
			self.baseframe.cabecalho.PluginIconsSeparator:Show()
		end
	else
		if (self.is_interacting) then
			self:InstanceButtonsColors (r, g, b, self.menu_icons_alpha, true, true) --no save, only left

			if (self.baseframe.cabecalho.PluginIconsSeparator) then
				self.baseframe.cabecalho.PluginIconsSeparator:Show()
			end
		else
			self:InstanceButtonsColors (0, 0, 0, 0, true, true) --no save, only left

			if (self.baseframe.cabecalho.PluginIconsSeparator) then
				self.baseframe.cabecalho.PluginIconsSeparator:Hide()
			end
		end
	end

	self:RefreshAttributeTextSize()
end

-- transparency for toolbar, borders and statusbar
function Details:SetMenuAlpha(enabled, onenter, onleave, ignorebars, interacting)
	if (interacting) then --called from a onenter or onleave script
		if (self.menu_alpha.enabled) then
			if (self.is_interacting) then
				return self:SetWindowAlphaForInteract(self.menu_alpha.onenter)
			else
				return self:SetWindowAlphaForInteract(self.menu_alpha.onleave)
			end
		end
		return
	end

	--ignorebars

	if (enabled == nil) then
		enabled = self.menu_alpha.enabled
	end
	if (not onenter) then
		onenter = self.menu_alpha.onenter
	end
	if (not onleave) then
		onleave = self.menu_alpha.onleave
	end
	if (ignorebars == nil) then
		ignorebars = self.menu_alpha.ignorebars
	end

	self.menu_alpha.enabled = enabled
	self.menu_alpha.onenter = onenter
	self.menu_alpha.onleave = onleave
	self.menu_alpha.ignorebars = ignorebars

	if (not enabled) then
		self.baseframe:SetAlpha(maxAlpha)
		self.rowframe:SetFrameAlpha(maxAlpha)
		self:InstanceAlpha(self.color[4])
		self:SetIconAlpha(1, nil, true)
		return self:InstanceColor(unpack(self.color))
		--return self:SetWindowAlphaForInteract (self.color [4])
	else
		local r, g, b = unpack(self.color)
		self:InstanceColor (r, g, b, 1)
		r, g, b = unpack(self.statusbar_info.overlay)
		self:StatusBarColor(r, g, b, 1)
	end

	if (self.is_interacting) then
		return self:SetWindowAlphaForInteract(onenter) --set alpha
	else
		return self:SetWindowAlphaForInteract(onleave) --set alpha
	end
end

function Details:GetInstanceCurrentAlpha()
	if (self.menu_alpha.enabled) then
		if (self:IsInteracting()) then
			return self.menu_alpha.onenter
		else
			return self.menu_alpha.onleave
		end
	else
		return self.color[4]
	end
end

function Details:GetInstanceIconsCurrentAlpha()
	if (self.menu_alpha.enabled and self.menu_alpha.iconstoo) then
		if (self:IsInteracting()) then
			return self.menu_alpha.onenter
		else
			return self.menu_alpha.onleave
		end
	else
		return 1
	end
end

function Details:MicroDisplaysLock(lockstate)
	if (lockstate == nil) then
		lockstate = self.micro_displays_locked
	end
	self.micro_displays_locked = lockstate

	if (lockstate) then --is locked
		Details.StatusBar:LockDisplays(self, true)
	else
		Details.StatusBar:LockDisplays(self, false)
	end
end

function Details:MicroDisplaysSide(side, fromuser)
	if (not side) then
		side = self.micro_displays_side
	end

	self.micro_displays_side = side

	Details.StatusBar:ReloadAnchors(self)

	if (self.micro_displays_side == 2 and not self.show_statusbar) then --bottom side
		Details.StatusBar:Hide(self)
		if (fromuser) then
			Details:Msg(Loc["STRING_OPTIONS_MICRODISPLAYWARNING"])
		end
	elseif (self.micro_displays_side == 2) then
		Details.StatusBar:Show(self)
	elseif (self.micro_displays_side == 1) then
		Details.StatusBar:Show(self)
	end
end

function Details:IsGroupedWith(instance)
	local id = instance:GetId()
	for side, instanceId in pairs(self.snap) do
		if (instanceId == id) then
			return true
		end
	end
	return false
end

function Details:GetInstanceGroup(instance_id)
	local instance = self

	if (instance_id) then
		instance = Details:GetInstance(instance_id)
		if (not instance or not instance:IsEnabled()) then
			return
		end
	end

	local current_group = {instance}

	for side, insId in pairs(instance.snap) do
		if (insId < instance:GetId()) then
			local last_id = instance:GetId()
			for i = insId, 1, -1 do
				local this_instance = Details:GetInstance(i)
				local got = false
				if (this_instance and this_instance:IsEnabled()) then
					for side, id in pairs(this_instance.snap) do
						if (id == last_id) then
							table.insert(current_group, this_instance)
							got = true
							last_id = i
						end
					end
				end
				if (not got) then
					break
				end
			end
		else
			local last_id = instance:GetId()
			for i = insId, Details.instances_amount do
				local this_instance = Details:GetInstance(i)
				local got = false
				if (this_instance and this_instance:IsEnabled()) then
					for side, id in pairs(this_instance.snap) do
						if (id == last_id) then
							table.insert(current_group, this_instance)
							got = true
							last_id = i
						end
					end
				end
				if (not got) then
					break
				end
			end
		end
	end

	return current_group
end

function Details:SetWindowScale(scale, fromOptions)
	if (not scale) then
		scale = self.window_scale
	end

	if (fromOptions) then
		local group = self:GetInstanceGroup()
		for _, instance in ipairs(group) do
			instance.baseframe:SetScale(scale)
			instance.rowframe:SetScale(scale)
			instance.windowSwitchButton:SetScale(scale)
			instance.windowBackgroundDisplay:SetScale(scale)
			instance.window_scale = scale
		end
	else
		self.window_scale = scale
		self.baseframe:SetScale(scale)
		self.rowframe:SetScale(scale)
		self.windowSwitchButton:SetScale(scale)
		self.windowBackgroundDisplay:SetScale(scale)
	end
end

function Details:ToolbarSide(side, only_update_anchors)
	if (not side) then
		side = self.toolbar_side
	end

	self.toolbar_side = side

	local skin = Details.skins [self.skin]

	if (side == 1) then --top
		local anchor_mod = not self.show_sidebars and skin.instance_cprops.show_sidebars_need_resize_by or 0

		--icon (ball) point
		self.baseframe.cabecalho.ball_point:ClearAllPoints()

		local x, y = unpack(skin.icon_point_anchor)
		x = x + (anchor_mod)
		self.baseframe.cabecalho.ball_point:SetPoint("bottomleft", self.baseframe, "topleft", x, y)

		--ball
		if (self.hide_icon) then
			self.baseframe.cabecalho.ball:SetTexCoord(unpack(COORDS_LEFT_BALL_NO_ICON))
			self.baseframe.cabecalho.emenda:SetTexCoord(unpack(COORDS_LEFT_CONNECTOR_NO_ICON))
		else
			self.baseframe.cabecalho.ball:SetTexCoord(unpack(COORDS_LEFT_BALL))
			self.baseframe.cabecalho.emenda:SetTexCoord(unpack(COORDS_LEFT_CONNECTOR))
		end

		self.baseframe.cabecalho.ball:ClearAllPoints()

		local x, y = unpack(skin.left_corner_anchor)
		x = x + (anchor_mod)
		self.baseframe.cabecalho.ball:SetPoint("bottomleft", self.baseframe, "topleft", x, y)

		--ball r
		self.baseframe.cabecalho.ball_r:SetTexCoord(unpack(COORDS_RIGHT_BALL))
		self.baseframe.cabecalho.ball_r:ClearAllPoints()

		local x, y = unpack(skin.right_corner_anchor)
		x = x + ((anchor_mod) * -1)
		self.baseframe.cabecalho.ball_r:SetPoint("bottomright", self.baseframe, "topright", x, y)

		--tex coords
		self.baseframe.cabecalho.top_bg:SetTexCoord(unpack(COORDS_TOP_BACKGROUND))

		--up frames
		self.baseframe.UPFrame:SetPoint("left", self.baseframe.cabecalho.ball, "right", 0, -53)
		self.baseframe.UPFrame:SetPoint("right", self.baseframe.cabecalho.ball_r, "left", 0, -53)

		self.baseframe.UPFrameConnect:ClearAllPoints()
		self.baseframe.UPFrameConnect:SetPoint("bottomleft", self.baseframe, "topleft", 0, -1)
		self.baseframe.UPFrameConnect:SetPoint("bottomright", self.baseframe, "topright", 0, -1)

		self.baseframe.UPFrameLeftPart:ClearAllPoints()
		self.baseframe.UPFrameLeftPart:SetPoint("bottomleft", self.baseframe, "topleft", 0, 0)

	else --bottom
		local y = 0
		if (self.show_statusbar) then
			y = -14
		end

		local anchor_mod = not self.show_sidebars and skin.instance_cprops.show_sidebars_need_resize_by or 0

		--ball point
		self.baseframe.cabecalho.ball_point:ClearAllPoints()

		local _x, _y = unpack(skin.icon_point_anchor_bottom)
		_x = _x + (anchor_mod)
		self.baseframe.cabecalho.ball_point:SetPoint("topleft", self.baseframe, "bottomleft", _x, _y + y)

		--ball
		self.baseframe.cabecalho.ball:ClearAllPoints()

		local _x, _y = unpack(skin.left_corner_anchor_bottom)
		_x = _x + (anchor_mod)
		self.baseframe.cabecalho.ball:SetPoint("topleft", self.baseframe, "bottomleft", _x, _y + y)
		local l, r, t, b = unpack(COORDS_LEFT_BALL)
		self.baseframe.cabecalho.ball:SetTexCoord(l, r, b, t)

		--ball r
		self.baseframe.cabecalho.ball_r:ClearAllPoints()

		local _x, _y = unpack(skin.right_corner_anchor_bottom)
		_x = _x + ((anchor_mod) * -1)
		self.baseframe.cabecalho.ball_r:SetPoint("topright", self.baseframe, "bottomright", _x, _y + y)
		local l, r, t, b = unpack(COORDS_RIGHT_BALL)
		self.baseframe.cabecalho.ball_r:SetTexCoord(l, r, b, t)

		--tex coords
		local l, r, t, b = unpack(COORDS_LEFT_CONNECTOR)
		self.baseframe.cabecalho.emenda:SetTexCoord(l, r, b, t)
		local l, r, t, b = unpack(COORDS_TOP_BACKGROUND)
		self.baseframe.cabecalho.top_bg:SetTexCoord(l, r, b, t)

		--up frames
		self.baseframe.UPFrame:SetPoint("left", self.baseframe.cabecalho.ball, "right", 0, 53)
		self.baseframe.UPFrame:SetPoint("right", self.baseframe.cabecalho.ball_r, "left", 0, 53)

		self.baseframe.UPFrameConnect:ClearAllPoints()
		self.baseframe.UPFrameConnect:SetPoint("topleft", self.baseframe, "bottomleft", 0, 1)
		self.baseframe.UPFrameConnect:SetPoint("topright", self.baseframe, "bottomright", 0, 1)

		self.baseframe.UPFrameLeftPart:ClearAllPoints()
		self.baseframe.UPFrameLeftPart:SetPoint("topleft", self.baseframe, "bottomleft", 0, 0)

	end

	if (only_update_anchors) then
		--ShowSideBars depends on this and creates a infinite loop
		return
	end

	--update top menus
	self:LeftMenuAnchorSide()

	self:StretchButtonAnchor()

	self:HideMainIcon() --attribute menu reseting value

	if (self.show_sidebars) then
		self:ShowSideBars()
	end

	self:AttributeMenu()

	--update the grow direction to update the gap between the titlebar and the baseframe
	self:SetBarGrowDirection()
end

function Details:StretchButtonAlwaysOnTop (on_top)
	if (type(on_top) ~= "boolean") then
		on_top = self.grab_on_top
	end

	self.grab_on_top = on_top

	if (self.grab_on_top) then
		self.baseframe.button_stretch:SetFrameStrata("FULLSCREEN")
	else
		self.baseframe.button_stretch:SetFrameStrata(self.strata)
	end
end

function Details:StretchButtonAnchor (side)
	if (not side) then
		side = self.stretch_button_side
	end

	if (side == 1 or string.lower(side) == "top") then
		self.baseframe.button_stretch:ClearAllPoints()

		local y = 0
		if (self.toolbar_side == 2) then --bottom
			y = -20
		end

		self.baseframe.button_stretch:SetPoint("bottom", self.baseframe, "top", 0, 20 + y)
		self.baseframe.button_stretch:SetPoint("right", self.baseframe, "right", -27, 0)
		self.baseframe.button_stretch.texture:SetTexCoord(unpack(COORDS_STRETCH))
		self.stretch_button_side = 1

	elseif (side == 2 or string.lower(side) == "bottom") then
		self.baseframe.button_stretch:ClearAllPoints()

		local y = 0
		if (self.toolbar_side == 2) then --bottom
			y = y -20
		end
		if (self.show_statusbar) then
			y = y -14
		end

		self.baseframe.button_stretch:SetPoint("center", self.baseframe, "center")
		self.baseframe.button_stretch:SetPoint("top", self.baseframe, "bottom", 0, y)

		local l, r, t, b = unpack(COORDS_STRETCH)
		self.baseframe.button_stretch.texture:SetTexCoord(r, l, b, t)

		self.stretch_button_side = 2
	end
end

function Details:MenuAnchor (x, y)
	if (self.toolbar_side == 1) then --top
		if (not x) then
			x = self.menu_anchor [1]
		end
		if (not y) then
			y = self.menu_anchor [2]
		end
		self.menu_anchor [1] = x
		self.menu_anchor [2] = y

	elseif (self.toolbar_side == 2) then --bottom
		if (not x) then
			x = self.menu_anchor_down [1]
		end
		if (not y) then
			y = self.menu_anchor_down [2]
		end
		self.menu_anchor_down [1] = x
		self.menu_anchor_down [2] = y
	end

	local menu_points = self.menu_points -- = {MenuAnchorLeft, MenuAnchorRight}

	if (self.menu_anchor.side == 1) then --left

		menu_points [1]:ClearAllPoints()

		if (self.toolbar_side == 1) then --top
			menu_points [1]:SetPoint("bottomleft", self.baseframe.cabecalho.ball, "bottomright", x, y) -- y+2

		else --bottom
			menu_points [1]:SetPoint("topleft", self.baseframe.cabecalho.ball, "topright", x, (y*-1) - 4)
		end

	elseif (self.menu_anchor.side == 2) then --right

		menu_points [2]:ClearAllPoints()

		if (self.toolbar_side == 1) then --top
			menu_points [2]:SetPoint("topleft", self.baseframe.cabecalho.ball_r, "bottomleft", x, y+16)

		else --bottom
			menu_points [2]:SetPoint("topleft", self.baseframe.cabecalho.ball_r, "topleft", x, (y*-1) - 4)
		end
	end

	self:ToolbarMenuButtons()
end

function Details:HideMainIcon (value)
	if (type(value) ~= "boolean") then
		value = self.hide_icon
	end

	if (value) then
		self.hide_icon = true
		Details.FadeHandler.Fader(self.baseframe.cabecalho.atributo_icon, 1)

		if (self.toolbar_side == 1) then
			self.baseframe.cabecalho.ball:SetTexCoord(unpack(COORDS_LEFT_BALL_NO_ICON))
			self.baseframe.cabecalho.emenda:SetTexCoord(unpack(COORDS_LEFT_CONNECTOR_NO_ICON))

		elseif (self.toolbar_side == 2) then
			local l, r, t, b = unpack(COORDS_LEFT_BALL_NO_ICON)
			self.baseframe.cabecalho.ball:SetTexCoord(l, r, b, t)
			local l, r, t, b = unpack(COORDS_LEFT_CONNECTOR_NO_ICON)
			self.baseframe.cabecalho.emenda:SetTexCoord(l, r, b, t)
		end

		local skin = Details.skins [self.skin]

		if (skin.icon_on_top) then
			self.baseframe.cabecalho.atributo_icon:SetParent(self.floatingframe)
		else
			self.baseframe.cabecalho.atributo_icon:SetParent(self.baseframe)
		end

	else
		self.hide_icon = false
		Details.FadeHandler.Fader(self.baseframe.cabecalho.atributo_icon, 0)

		if (self.toolbar_side == 1) then

			self.baseframe.cabecalho.ball:SetTexCoord(unpack(COORDS_LEFT_BALL))
			self.baseframe.cabecalho.emenda:SetTexCoord(unpack(COORDS_LEFT_CONNECTOR))

		elseif (self.toolbar_side == 2) then
			local l, r, t, b = unpack(COORDS_LEFT_BALL)
			self.baseframe.cabecalho.ball:SetTexCoord(l, r, b, t)
			local l, r, t, b = unpack(COORDS_LEFT_CONNECTOR)
			self.baseframe.cabecalho.emenda:SetTexCoord(l, r, b, t)
		end
	end
end

--search key: ~desaturate
function Details:DesaturateMenu (value)
	if (value == nil) then
		value = self.desaturated_menu
	end

	if (value) then
		self.desaturated_menu = true
		self.baseframe.cabecalho.modo_selecao:GetNormalTexture():SetDesaturated(true)
		self.baseframe.cabecalho.segmento:GetNormalTexture():SetDesaturated(true)
		self.baseframe.cabecalho.atributo:GetNormalTexture():SetDesaturated(true)
		self.baseframe.cabecalho.report:GetNormalTexture():SetDesaturated(true)
		self.baseframe.cabecalho.reset:GetNormalTexture():SetDesaturated(true)
		self.baseframe.cabecalho.fechar:GetNormalTexture():SetDesaturated(true)

		if (self.meu_id == Details:GetLowerInstanceNumber()) then
			for _, button in ipairs(Details.ToolBar.AllButtons) do
				button:GetNormalTexture():SetDesaturated(true)
			end
		end

	else
		self.desaturated_menu = false
		self.baseframe.cabecalho.modo_selecao:GetNormalTexture():SetDesaturated(false)
		self.baseframe.cabecalho.segmento:GetNormalTexture():SetDesaturated(false)
		self.baseframe.cabecalho.atributo:GetNormalTexture():SetDesaturated(false)
		self.baseframe.cabecalho.report:GetNormalTexture():SetDesaturated(false)
		self.baseframe.cabecalho.reset:GetNormalTexture():SetDesaturated(false)
		self.baseframe.cabecalho.fechar:GetNormalTexture():SetDesaturated(false)

		if (self.meu_id == Details:GetLowerInstanceNumber()) then
			for _, button in ipairs(Details.ToolBar.AllButtons) do
				button:GetNormalTexture():SetDesaturated(false)
			end
		end
	end
end

function Details:ShowSideBars (instancia)
	if (instancia) then
		self = instancia
	end

	self.show_sidebars = true

	self.baseframe.barra_esquerda:Show()
	self.baseframe.barra_direita:Show()

	--set default spacings
	local this_skin = Details.skins [self.skin]
	if (this_skin.instance_cprops and this_skin.instance_cprops.row_info and this_skin.instance_cprops.row_info.space) then
		self.row_info.space.left = this_skin.instance_cprops.row_info.space.left
		self.row_info.space.right = this_skin.instance_cprops.row_info.space.right
	else
		self.row_info.space.left = 3
		self.row_info.space.right = -5
	end

	if (self.show_statusbar) then
		self.baseframe.barra_esquerda:SetPoint("bottomleft", self.baseframe, "bottomleft", -56, -14)
		self.baseframe.barra_direita:SetPoint("bottomright", self.baseframe, "bottomright", 56, -14)

		if (self.toolbar_side == 2) then
			self.baseframe.barra_fundo:Show()
			local l, r, t, b = unpack(COORDS_BOTTOM_SIDE_BAR)
			self.baseframe.barra_fundo:SetTexCoord(l, r, b, t)
			self.baseframe.barra_fundo:ClearAllPoints()
			self.baseframe.barra_fundo:SetPoint("bottomleft", self.baseframe, "topleft", 0, -6)
			self.baseframe.barra_fundo:SetPoint("bottomright", self.baseframe, "topright", -1, -6)
		else
			self.baseframe.barra_fundo:Hide()
		end
	else
		self.baseframe.barra_esquerda:SetPoint("bottomleft", self.baseframe, "bottomleft", -56, 0)
		self.baseframe.barra_direita:SetPoint("bottomright", self.baseframe, "bottomright", 56, 0)

		self.baseframe.barra_fundo:Show()

		if (self.toolbar_side == 2) then --tooltbar on bottom
			local l, r, t, b = unpack(COORDS_BOTTOM_SIDE_BAR)
			self.baseframe.barra_fundo:SetTexCoord(l, r, b, t)
			self.baseframe.barra_fundo:ClearAllPoints()
			self.baseframe.barra_fundo:SetPoint("bottomleft", self.baseframe, "topleft", 0, -6)
			self.baseframe.barra_fundo:SetPoint("bottomright", self.baseframe, "topright", -1, -6)
		else --tooltbar on top
			self.baseframe.barra_fundo:SetTexCoord(unpack(COORDS_BOTTOM_SIDE_BAR))
			self.baseframe.barra_fundo:ClearAllPoints()
			self.baseframe.barra_fundo:SetPoint("bottomleft", self.baseframe, "bottomleft", 0, -56)
			self.baseframe.barra_fundo:SetPoint("bottomright", self.baseframe, "bottomright", -1, -56)
		end
	end

	--self:SetBarGrowDirection()
	--passando true - apenas atulizar as anchors
	self:ToolbarSide (nil, true)
end

function Details:HideSideBars (instancia)
	if (instancia) then
		self = instancia
	end

	self.show_sidebars = false

	local this_skin = Details.skins [self.skin]
	local space_config = this_skin.instance_cprops and this_skin.instance_cprops.row_info and this_skin.instance_cprops.row_info.space
	if (space_config) then
		if (space_config.left_noborder) then
			self.row_info.space.left = space_config.left_noborder
		else
			self.row_info.space.left = 0
		end

		if (space_config.right_noborder) then
			self.row_info.space.right = space_config.right_noborder
		else
			self.row_info.space.right = 0
		end
	else
		self.row_info.space.left = 0
		self.row_info.space.right = 0
	end

	self.baseframe.barra_esquerda:Hide()
	self.baseframe.barra_direita:Hide()
	self.baseframe.barra_fundo:Hide()

	--self:SetBarGrowDirection() --j� � chamado no toolbarside
	--passando true - apenas atulizar as anchors
	self:ToolbarSide (nil, true)
end

function Details:HideStatusBar (instancia)
	if (instancia) then
		self = instancia
	end

	self.show_statusbar = false

	self.baseframe.rodape.esquerdo:Hide()
	self.baseframe.rodape.direita:Hide()
	self.baseframe.rodape.top_bg:Hide()
	self.baseframe.rodape.StatusBarLeftAnchor:Hide()
	self.baseframe.rodape.StatusBarCenterAnchor:Hide()
	self.baseframe.DOWNFrame:Hide()

	--debug
	self.baseframe.rodape.direita_nostatusbar:Show()
	self.baseframe.rodape.esquerdo_nostatusbar:Show()
	--

	if (self.toolbar_side == 2) then
		self:ToolbarSide()
	end

	if (self.show_sidebars) then
		self:ShowSideBars()
	end

	self:StretchButtonAnchor()

	if (self.micro_displays_side == 2) then --bottom side
		Details.StatusBar:Hide (self) --mini displays widgets
	end
end

function Details:StatusBarColor(r, g, b, a, no_save)
	if (not r) then
		r, g, b = unpack(self.statusbar_info.overlay)
		a = a or self.statusbar_info.alpha
	end

	if (not no_save) then
		self.statusbar_info.overlay [1] = r
		self.statusbar_info.overlay [2] = g
		self.statusbar_info.overlay [3] = b
		self.statusbar_info.alpha = a
	end

	self.baseframe.rodape.esquerdo:SetVertexColor(r, g, b)
	self.baseframe.rodape.esquerdo:SetAlpha(a)
	self.baseframe.rodape.direita:SetVertexColor(r, g, b)
	self.baseframe.rodape.direita:SetAlpha(a)
	self.baseframe.rodape.direita_nostatusbar:SetVertexColor(r, g, b)
	self.baseframe.rodape.esquerdo_nostatusbar:SetVertexColor(r, g, b)
	self.baseframe.rodape.direita_nostatusbar:SetAlpha(a)
	self.baseframe.rodape.esquerdo_nostatusbar:SetAlpha(a)
	self.baseframe.rodape.top_bg:SetVertexColor(r, g, b)
	self.baseframe.rodape.top_bg:SetAlpha(a)
end

function Details:ShowStatusBar(instancia)
	if (instancia) then
		self = instancia
	end

	self.show_statusbar = true

	self.baseframe.rodape.esquerdo:Show()
	self.baseframe.rodape.direita:Show()
	self.baseframe.rodape.top_bg:Show()
	self.baseframe.rodape.StatusBarLeftAnchor:Show()
	self.baseframe.rodape.StatusBarCenterAnchor:Show()
	self.baseframe.DOWNFrame:Show()

	--debug
	--self.baseframe.rodape.direita_nostatusbar:Hide()
	--self.baseframe.rodape.esquerdo_nostatusbar:Hide()
	--

	self:ToolbarSide()
	self:StretchButtonAnchor()

	if (self.micro_displays_side == 2) then --bottom side
		Details.StatusBar:Show(self) --mini displays widgets
	end
end

function Details:SetTooltipBackdrop(border_texture, border_size, border_color)
	if (not border_texture) then
		border_texture = Details.tooltip.border_texture
	end
	if (not border_size) then
		border_size = Details.tooltip.border_size
	end
	if (not border_color) then
		border_color = Details.tooltip.border_color
	end

	Details.tooltip.border_texture = border_texture
	Details.tooltip.border_size = border_size

	local c = Details.tooltip.border_color
	local cc = Details.tooltip_border_color
	c[1], c[2], c[3], c[4] = border_color[1], border_color[2], border_color[3], border_color[4] or 1
	cc[1], cc[2], cc[3], cc[4] = border_color[1], border_color[2], border_color[3], border_color[4] or 1

	Details.tooltip_backdrop.edgeFile = SharedMedia:Fetch("border", border_texture)
	Details.tooltip_backdrop.edgeSize = border_size
end

--reset button functions
	local resetButton_OnEnter = function(self, _, bForceOpen)
		local gameCooltip = GameCooltip

		OnEnterMainWindow(self.instance, self)
		gameCooltip.buttonOver = true
		self.instance.baseframe.cabecalho.button_mouse_over = true

		if (self.instance.desaturated_menu) then
			self:GetNormalTexture():SetDesaturated(false)
		end

		if (Details.instances_menu_click_to_open and not bForceOpen) then
			return
		end

		--prepare the reset button menu
		gameCooltip:Reset()
		gameCooltip:SetType("menu")

		gameCooltip:SetOption("ButtonsYMod", -6)
		gameCooltip:SetOption("HeighMod", 6)
		gameCooltip:SetOption("YSpacingMod", -3)
		gameCooltip:SetOption("TextHeightMod", 0)
		gameCooltip:SetOption("IgnoreButtonAutoHeight", false)

		Details:SetTooltipMinWidth()

		gameCooltip:AddLine("Reset, but keep Mythic+ Overall Segments", nil, 1, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		gameCooltip:AddIcon([[Interface\Buttons\UI-StopButton]], 1, 1, 14, 14, 0, 1, 0, 1, "orange")
		gameCooltip:AddMenu(1, function() Details.tabela_historico:ResetDataByCombatType("m+overall"); GameCooltip:Hide() end)

		gameCooltip:AddLine("$div", nil, 1, nil, -5, -11)

		gameCooltip:AddLine("Remove Common Segments", nil, 1, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		gameCooltip:AddIcon([[Interface\Buttons\UI-StopButton]], 1, 1, 14, 14, 0, 1, 0, 1, "orange")
		gameCooltip:AddMenu(1, function() Details.tabela_historico:ResetDataByCombatType("generic"); GameCooltip:Hide() end)

		gameCooltip:AddLine("Remove Battleground Segments", nil, 1, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		gameCooltip:AddIcon([[Interface\Buttons\UI-StopButton]], 1, 1, 14, 14, 0, 1, 0, 1, "orange")
		gameCooltip:AddMenu(1, function() Details.tabela_historico:ResetDataByCombatType("battleground"); GameCooltip:Hide() end)

		gameCooltip:AddLine("$div", nil, 1, nil, -5, -11)

		gameCooltip:AddLine(Loc["STRING_ERASE_DATA_OVERALL"], nil, 1, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		gameCooltip:AddIcon([[Interface\Buttons\UI-StopButton]], 1, 1, 14, 14, 0, 1, 0, 1, "orange")
		gameCooltip:AddMenu(1, Details.tabela_historico.ResetOverallData)

		gameCooltip:AddLine(Loc["STRING_ERASE_DATA"], nil, 1, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		gameCooltip:AddIcon([[Interface\Buttons\UI-StopButton]], 1, 1, 14, 14, 0, 1, 0, 1, "red")
		gameCooltip:AddMenu(1, Details.tabela_historico.ResetAllCombatData)

		show_anti_overlap(self.instance, self, "top")

		Details:SetMenuOwner(self, self.instance)

		Details:AddRoundedCornerToTooltip()

		gameCooltip:ShowCooltip()
	end

	local resetButton_OnLeave = function(self)
		OnLeaveMainWindow(self.instance, self)

		if (self.instance.desaturated_menu) then
			self:GetNormalTexture():SetDesaturated(true)
		end

		hide_anti_overlap(self.instance.baseframe.anti_menu_overlap)

		GameCooltip.buttonOver = false
		self.instance.baseframe.cabecalho.button_mouse_over = false

		if (GameCooltip.active) then
			parameters_table [2] = 0
			self:SetScript("OnUpdate", onLeaveMenuFunc)
		else
			self:SetScript("OnUpdate", nil)
		end
	end

--close button functions

	local closeButton_OnClick = function(self, button_type, button)
		if (self and not self.instancia and button and button.instancia) then
			self = button
		end

		self = self or button

		self:Disable()
		self.instancia:DesativarInstancia()

		--check if there's no more windows opened
		if (Details.opened_windows == 0) then
			Details:Msg(Loc["STRING_CLOSEALL"])
		end

		if (not Details:GetTutorialCVar("FULL_DELETE_WINDOW")) then
			Details:SetTutorialCVar("FULL_DELETE_WINDOW", true)

			local panel = gump:Create1PxPanel(UIParent, 600, 100, "|cFFFFFFFFDetails!, the window hit the ground, bang bang...|r", nil, nil, nil, nil)
			panel:SetBackdropColor(0, 0, 0, 0.9)
			panel:SetPoint("center", UIParent, "center")

			local s = panel:CreateFontString(nil, "overlay", "GameFontNormal")
			s:SetPoint("center", panel, "center")
			s:SetText(Loc["STRING_TUTORIAL_FULLY_DELETE_WINDOW"])

			panel:Show()
		end

		GameCooltip:Hide()
	end
	Details.close_instancia_func = closeButton_OnClick

	local closeButton_OnEnter = function(self)
		OnEnterMainWindow(self.instance, self)

		if (self.instance.desaturated_menu) then
			self:GetNormalTexture():SetDesaturated(false)
		end

		local GameCooltip = GameCooltip

		GameCooltip.buttonOver = true
		self.instance.baseframe.cabecalho.button_mouse_over = true

		GameCooltip:Reset()
		GameCooltip:SetType("menu")
		GameCooltip:SetOption("ButtonsYMod", -7)
		GameCooltip:SetOption("ButtonsYModSub", -2)
		GameCooltip:SetOption("YSpacingMod", 0)
		GameCooltip:SetOption("YSpacingModSub", -3)
		GameCooltip:SetOption("TextHeightMod", 0)
		GameCooltip:SetOption("TextHeightModSub", 0)
		GameCooltip:SetOption("IgnoreButtonAutoHeight", false)
		GameCooltip:SetOption("IgnoreButtonAutoHeightSub", false)
		GameCooltip:SetOption("SubMenuIsTooltip", true)
		GameCooltip:SetOption("FixedWidthSub", 180)

		GameCooltip:SetOption("HeighMod", 9)

		GameCooltip:AddLine(Loc["STRING_MENU_CLOSE_INSTANCE"], nil, 1, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		GameCooltip:AddIcon([[Interface\Buttons\UI-Panel-MinimizeButton-Up]], 1, 1, 14, 14, 0.2, 0.8, 0.2, 0.8)
		GameCooltip:AddMenu(1, closeButton_OnClick, self)

		GameCooltip:AddLine(Loc["STRING_MENU_CLOSE_INSTANCE_DESC"], nil, 2, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		GameCooltip:AddIcon([[Interface\CHATFRAME\UI-ChatIcon-Minimize-Up]], 2, 1, 18, 18)

		GameCooltip:AddLine(Loc["STRING_MENU_CLOSE_INSTANCE_DESC2"], nil, 2, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
		GameCooltip:AddIcon([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]], 2, 1, 18, 18)

		GameCooltip:SetWallpaper(1, Details.tooltip.menus_bg_texture, Details.tooltip.menus_bg_coords, Details.tooltip.menus_bg_color, true)
		GameCooltip:SetWallpaper(2, Details.tooltip.menus_bg_texture, Details.tooltip.menus_bg_coords, Details.tooltip.menus_bg_color, true)
		GameCooltip:SetBackdrop(1, menus_backdrop, nil, menus_bordercolor)
		GameCooltip:SetBackdrop(2, menus_backdrop, nil, menus_bordercolor)

		show_anti_overlap(self.instance, self, "top")
		Details:SetMenuOwner(self, self.instance)
		GameCooltip:ShowCooltip()
	end

	local closeButton_OnLeave = function(self)
		OnLeaveMainWindow(self.instance, self, 3)

		if (self.instance.desaturated_menu) then
			self:GetNormalTexture():SetDesaturated(true)
		end

		hide_anti_overlap (self.instance.baseframe.anti_menu_overlap)

		GameCooltip.buttonOver = false
		self.instance.baseframe.cabecalho.button_mouse_over = false

		if (GameCooltip.active) then
			parameters_table [2] = 0
			self:SetScript("OnUpdate", onLeaveMenuFunc)
		else
			self:SetScript("OnUpdate", nil)
		end
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------
--build upper menu bar

local reportButton_OnEnter = function(self, motion, forced)
	local instancia = self._instance or self.widget._instance
	local baseframe = instancia.baseframe

	OnEnterMainWindow(instancia, self)
	if (instancia.desaturated_menu) then
		self:GetNormalTexture():SetDesaturated(false)
	end

	GameCooltip.buttonOver = true
	baseframe.cabecalho.button_mouse_over = true

	if (Details.instances_menu_click_to_open and not forced) then
		return
	end

	GameCooltip:Reset()

	GameCooltip:SetType("menu")
	GameCooltip:SetOption("ButtonsYMod", -6)
	GameCooltip:SetOption("HeighMod", 6)
	GameCooltip:SetOption("YSpacingMod", -1)
	GameCooltip:SetOption("TextHeightMod", 0)
	GameCooltip:SetOption("IgnoreButtonAutoHeight", false)

	Details:SetTooltipMinWidth()

	Details:AddRoundedCornerToTooltip()

	Details:CheckLastReportsIntegrity()

	local lastPeports = Details.latest_report_table
	if (#lastPeports > 0) then
		local amountReports = #lastPeports
		amountReports = math.min(amountReports, 10)

		for index = amountReports, 1, -1 do
			local report = lastPeports[index]
			local instanceId, attribute, subattribute, amt, report_where, custom_name = unpack(report)

			local subAttributeName = Details:GetSubAttributeName(attribute, subattribute, custom_name)
			local artwork =  Details.GetReportIconAndColor(report_where)

			GameCooltip:AddLine(subAttributeName .. " (#" .. amt .. ")", nil, 1, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
			if (artwork) then
				GameCooltip:AddIcon(artwork.icon, 1, 1, 14, 14, artwork.coords[1], artwork.coords[2], artwork.coords[3], artwork.coords[4], artwork.color, nil, false)
			end
			GameCooltip:AddMenu(1, Details.ReportFromLatest, index)
		end

		GameCooltip:AddLine("$div", nil, nil, -4)
	end

	GameCooltip:AddLine(Loc["STRING_REPORT_TOOLTIP"], nil, 1, "white", nil, Details.font_sizes.menus, Details.font_faces.menus)
	GameCooltip:AddIcon([[Interface\Addons\Details\Images\report_button]], 1, 1, 12, 19)
	GameCooltip:AddMenu(1, function() instancia:Reportar("INSTANCE" .. instancia.meu_id) end)

	show_anti_overlap(instancia, self, "top")
	Details:SetMenuOwner(self, instancia)

	GameCooltip:ShowCooltip()
end

local reportButton_OnLeave = function(self, motion, forced, from_click)
	local instancia = self._instance or self.widget._instance
	local baseframe = instancia.baseframe

	OnLeaveMainWindow(instancia, self)

	hide_anti_overlap(instancia.baseframe.anti_menu_overlap)

	GameCooltip.buttonOver = false
	baseframe.cabecalho.button_mouse_over = false

	if (instancia.desaturated_menu) then
		self:GetNormalTexture():SetDesaturated(true)
	end

	if (GameCooltip.active) then
		parameters_table[2] = from_click and 1 or 0
		self:SetScript("OnUpdate", onLeaveMenuFunc)
	else
		self:SetScript("OnUpdate", nil)
	end
end

local attributeButton_OnEnter = function(self, motion, forced, from_click)
	local instancia = self._instance or self.widget._instance
	local baseframe = instancia.baseframe

	OnEnterMainWindow(instancia, self)

	if (instancia.desaturated_menu) then
		self:GetNormalTexture():SetDesaturated(false)
	end

	GameCooltip.buttonOver = true
	baseframe.cabecalho.button_mouse_over = true

	show_anti_overlap(instancia, self, "top")

	if (Details.instances_menu_click_to_open and not forced) then
		return
	end

	GameCooltip:Reset()
	GameCooltip:SetType(3)
	GameCooltip:SetFixedParameter(instancia)

	if (Details.solo and Details.solo == instancia.meu_id) then
		Details:MontaSoloOption(instancia)

	elseif (instancia:IsRaidMode()) then
		local hasRaidPlugins = Details:MontaRaidOption(instancia)
		if (not hasRaidPlugins) then
			GameCooltip:SetType ("tooltip")
			GameCooltip:SetOption("ButtonsYMod", 0)

			GameCooltip:SetOption("TextHeightMod", 0)
			GameCooltip:SetOption("IgnoreButtonAutoHeight", false)
			GameCooltip:AddLine("All raid plugins already\nin use or disabled.", nil, 1, "white", nil, 10, SharedMedia:Fetch("font", "Friz Quadrata TT"))
			GameCooltip:AddIcon([[Interface\GROUPFRAME\UI-GROUP-ASSISTANTICON]], 1, 1)
			GameCooltip:SetWallpaper(1, Details.tooltip.menus_bg_texture, Details.tooltip.menus_bg_coords, Details.tooltip.menus_bg_color, true)
		end
	else
		Details:MontaAtributosOption(instancia)
		GameCooltip:SetOption("YSpacingMod", -1)
		GameCooltip:SetOption("YSpacingModSub", -2)
	end

	GameCooltip:SetOption("TextSize", Details.font_sizes.menus)
	Details:SetMenuOwner(self, instancia)

	Details:AddRoundedCornerToTooltip()

	GameCooltip:ShowCooltip()
end

local attributeButton_OnLeave = function(self, motion, forced, from_click)
	local instancia = self._instance or self.widget._instance
	local baseframe = instancia.baseframe

	OnLeaveMainWindow(instancia, self)
	hide_anti_overlap(instancia.baseframe.anti_menu_overlap)

	if (instancia.desaturated_menu) then
		self:GetNormalTexture():SetDesaturated(true)
	end

	GameCooltip.buttonOver = false
	baseframe.cabecalho.button_mouse_over = false

	if (GameCooltip.active) then
		parameters_table[2] = 0
		self:SetScript("OnUpdate", onLeaveMenuFunc)
	else
		self:SetScript("OnUpdate", nil)
	end
end

local segmentButton_OnEnter = function(self, motion, forced, fromClick)
	local instance = self._instance or self.widget._instance
	local baseframe = instance.baseframe

	OnEnterMainWindow(instance, self)

	if (instance.desaturated_menu) then
		self:GetNormalTexture():SetDesaturated(false)
	end

	GameCooltip.buttonOver = true
	baseframe.cabecalho.button_mouse_over = true

	if (Details.instances_menu_click_to_open and not forced) then
		return
	end

	local timeToOpen = 0
	if (_G.GameCooltip.active) then
		timeToOpen = 0.15
	end

	parameters_table[1] = instance
	parameters_table[2] = fromClick and 1 or timeToOpen
	self:SetScript("OnUpdate", buildSegmentTooltip)
end

local segmentButton_OnLeave = function(self, motion, forced, fromClick)
	local instance = self._instance or self.widget._instance
	local baseframe = instance.baseframe

	OnLeaveMainWindow(instance, self)
	hide_anti_overlap(instance.baseframe.anti_menu_overlap)

	if (instance.desaturated_menu) then
		self:GetNormalTexture():SetDesaturated(true)
	end

	GameCooltip.buttonOver = false
	baseframe.cabecalho.button_mouse_over = false

	if (GameCooltip.active) then
		parameters_table[2] = 0
		self:SetScript("OnUpdate", onLeaveMenuFunc)
	else
		self:SetScript("OnUpdate", nil)
	end
end

local modeSelector_OnEnter = function(self, motion, forced, from_click)
	local instancia = self._instance or self.widget._instance
	local baseframe = instancia.baseframe

	OnEnterMainWindow(instancia, self)

	if (instancia.desaturated_menu) then
		self:GetNormalTexture():SetDesaturated(false)
	end

	GameCooltip.buttonOver = true
	baseframe.cabecalho.button_mouse_over = true

	if (Details.instances_menu_click_to_open and not forced) then
		return
	end

	local elapsedTime = 0
	if (_G.GameCooltip.active) then
		elapsedTime = 0.15
	end

	local checked
	if (instancia.modo == 1) then
		checked = 4
	elseif (instancia.modo == 2) then
		checked = 1
	elseif (instancia.modo == 3) then
		checked = 2
	elseif (instancia.modo == 4) then
		checked = 3
	end

	parameters_table[1] = instancia
	parameters_table[2] = from_click and 1 or elapsedTime
	parameters_table[3] = checked

	self:SetScript("OnUpdate", build_mode_list)
end

local modeSelector_OnLeave = function(self)
	local instancia = self._instance or self.widget._instance
	local baseframe = instancia.baseframe

	OnLeaveMainWindow(instancia, self)
	hide_anti_overlap(instancia.baseframe.anti_menu_overlap)

	if (instancia.desaturated_menu) then
		self:GetNormalTexture():SetDesaturated(true)
	end

	GameCooltip.buttonOver = false
	baseframe.cabecalho.button_mouse_over = false

	if (GameCooltip.active) then
		parameters_table[2] = 0
		self:SetScript("OnUpdate", onLeaveMenuFunc)
	else
		self:SetScript("OnUpdate", nil)
	end
end

local changeSegmentOnClick = function(instancia, buttontype)
	if (buttontype == "LeftButton") then
		--previous segment as the pointer move upwards getting older segments
		local previousSegment = instancia.segmento + 1
		if (previousSegment > segmentsUsed) then
			previousSegment = -1
		elseif (previousSegment > Details.segments_amount) then
			previousSegment = -1
		end

		--cooltip menu update
		local maxSegments = segmentsFilled + 2
		local targetSegment = previousSegment + 1
		local segmentIndex = math.abs(targetSegment - maxSegments)
		GameCooltip:Select(1, segmentIndex)

		--change the segment
		instancia:SetSegment(previousSegment) --todo: use new api
		segmentButton_OnEnter(instancia.baseframe.cabecalho.segmento.widget, _, true, true)

	elseif (buttontype == "RightButton") then
		--next segment as the pointer move downwards getting newer segments
		local nextSegment = instancia.segmento - 1
		if (nextSegment < -1) then
			nextSegment = segmentsUsed
		end

		--cooltip menu update
		local maxSegments = segmentsFilled + 2
		local targetSegment = nextSegment + 1
		local segmentIndex = math.abs(targetSegment - maxSegments)
		GameCooltip:Select(1, segmentIndex)

		instancia:SetSegment(nextSegment)
		segmentButton_OnEnter(instancia.baseframe.cabecalho.segmento.widget, _, true, true)

	elseif (buttontype == "MiddleButton") then
		local segmento_goal = 0

		local total_shown = segmentsFilled+2
		local goal = segmento_goal+1

		local select_ = math.abs(goal - total_shown)
		GameCooltip:Select(1, select_)

		instancia:SetSegment(segmento_goal)
		segmentButton_OnEnter (instancia.baseframe.cabecalho.segmento.widget, _, true, true)

	end
end

function gump:CriaCabecalho (baseframe, instancia)

	baseframe.cabecalho = {}

	--FECHAR INSTANCIA ----------------------------------------------------------------------------------------------------------------------------------------------------
	baseframe.cabecalho.fechar = CreateFrame("button", "DetailsCloseInstanceButton" .. instancia.meu_id, baseframe) --, "UIPanelCloseButton"
	baseframe.cabecalho.fechar:SetWidth(18)
	baseframe.cabecalho.fechar:SetHeight(18)
	baseframe.cabecalho.fechar:SetFrameLevel(5) --altura mais alta que os demais frames
	baseframe.cabecalho.fechar:SetPoint("bottomright", baseframe, "topright", 5, -6) --seta o ponto dele fixando no base frame

	baseframe.cabecalho.fechar:SetNormalTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	baseframe.cabecalho.fechar:GetNormalTexture():SetTexCoord(160/256, 192/256, 0, 1)
	baseframe.cabecalho.fechar:SetHighlightTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	baseframe.cabecalho.fechar:GetHighlightTexture():SetTexCoord(160/256, 192/256, 0, 1)
	baseframe.cabecalho.fechar:SetPushedTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	baseframe.cabecalho.fechar:GetPushedTexture():SetTexCoord(160/256, 192/256, 0, 1)

	--baseframe.cabecalho.fechar:SetNormalTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Up]])
	--baseframe.cabecalho.fechar:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight]])
	--baseframe.cabecalho.fechar:SetPushedTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Down]])

	baseframe.cabecalho.fechar.instancia = instancia
	baseframe.cabecalho.fechar.instance = instancia

	baseframe.cabecalho.fechar:SetScript("OnEnter", closeButton_OnEnter)
	baseframe.cabecalho.fechar:SetScript("OnLeave", closeButton_OnLeave)

	baseframe.cabecalho.fechar:SetScript("OnClick", closeButton_OnClick)

	--bola do canto esquedo superior --primeiro criar a arma��o para apoiar as texturas
	baseframe.cabecalho.ball_point = instancia.floatingframe:CreateTexture(nil, "overlay")
	baseframe.cabecalho.ball_point:SetPoint("bottomleft", baseframe, "topleft", -37, 0)
	baseframe.cabecalho.ball_point:SetWidth(64)
	baseframe.cabecalho.ball_point:SetHeight(32)

	--icone do atributo
	--baseframe.cabecalho.atributo_icon = _detalhes.listener:CreateTexture(nil, "artwork")
	baseframe.cabecalho.atributo_icon = baseframe:CreateTexture("DetailsAttributeIcon" .. instancia.meu_id, "background")
	local icon_anchor = Details.skins ["WoW Interface"].icon_anchor_main
	baseframe.cabecalho.atributo_icon:SetPoint("topright", baseframe.cabecalho.ball_point, "topright", icon_anchor[1], icon_anchor[2])
	baseframe.cabecalho.atributo_icon:SetTexture(DEFAULT_SKIN)
	baseframe.cabecalho.atributo_icon:SetWidth(32)
	baseframe.cabecalho.atributo_icon:SetHeight(32)

	--bola overlay
	--baseframe.cabecalho.ball = _detalhes.listener:CreateTexture(nil, "overlay")
	baseframe.cabecalho.ball = baseframe:CreateTexture(nil, "overlay")
	baseframe.cabecalho.ball:SetPoint("bottomleft", baseframe, "topleft", -107, 0)
	baseframe.cabecalho.ball:SetWidth(128)
	baseframe.cabecalho.ball:SetHeight(128)

	baseframe.cabecalho.ball:SetTexture(DEFAULT_SKIN)
	baseframe.cabecalho.ball:SetTexCoord(unpack(COORDS_LEFT_BALL))

	--emenda
	baseframe.cabecalho.emenda = baseframe:CreateTexture(nil, "background")
	baseframe.cabecalho.emenda:SetPoint("bottomleft", baseframe.cabecalho.ball, "bottomright")
	baseframe.cabecalho.emenda:SetWidth(8)
	baseframe.cabecalho.emenda:SetHeight(128)
	baseframe.cabecalho.emenda:SetTexture(DEFAULT_SKIN)
	baseframe.cabecalho.emenda:SetTexCoord(unpack(COORDS_LEFT_CONNECTOR))

	baseframe.cabecalho.atributo_icon:Hide()
	baseframe.cabecalho.ball:Hide()

	--bola do canto direito superior
	baseframe.cabecalho.ball_r = baseframe:CreateTexture(nil, "background")
	baseframe.cabecalho.ball_r:SetPoint("bottomright", baseframe, "topright", 96, 0)
	baseframe.cabecalho.ball_r:SetWidth(128)
	baseframe.cabecalho.ball_r:SetHeight(128)
	baseframe.cabecalho.ball_r:SetTexture(DEFAULT_SKIN)
	baseframe.cabecalho.ball_r:SetTexCoord(unpack(COORDS_RIGHT_BALL))

	--barra centro
	baseframe.cabecalho.top_bg = baseframe:CreateTexture(nil, "background")
	baseframe.cabecalho.top_bg:SetPoint("left", baseframe.cabecalho.emenda, "right", 0, 0)
	baseframe.cabecalho.top_bg:SetPoint("right", baseframe.cabecalho.ball_r, "left")
	baseframe.cabecalho.top_bg:SetTexture(DEFAULT_SKIN)
	baseframe.cabecalho.top_bg:SetTexCoord(unpack(COORDS_TOP_BACKGROUND))
	baseframe.cabecalho.top_bg:SetWidth(512)
	baseframe.cabecalho.top_bg:SetHeight(128)

	--frame invis�vel
	baseframe.UPFrame = CreateFrame("frame", "DetailsUpFrameInstance"..instancia.meu_id, baseframe)
	baseframe.UPFrame:SetPoint("left", baseframe.cabecalho.ball, "right", 0, -53)
	baseframe.UPFrame:SetPoint("right", baseframe.cabecalho.ball_r, "left", 0, -53)
	baseframe.UPFrame:SetHeight(20)
	baseframe.UPFrame.is_toolbar = true

	baseframe.UPFrame:Show()
	baseframe.UPFrame:EnableMouse(true)
	baseframe.UPFrame:SetMovable(true)
	baseframe.UPFrame:SetResizable(true)

	BGFrame_scripts(baseframe.UPFrame, baseframe, instancia)

	--corrige o v�o entre o baseframe e o upframe
	baseframe.UPFrameConnect = CreateFrame("frame", "DetailsAntiGap"..instancia.meu_id, baseframe)
	baseframe.UPFrameConnect:SetPoint("bottomleft", baseframe, "topleft", 0, -1)
	baseframe.UPFrameConnect:SetPoint("bottomright", baseframe, "topright", 0, -1)
	baseframe.UPFrameConnect:SetHeight(2)
	baseframe.UPFrameConnect:EnableMouse(true)
	baseframe.UPFrameConnect:SetMovable(true)
	baseframe.UPFrameConnect:SetResizable(true)
	baseframe.UPFrameConnect.is_toolbar = true

	BGFrame_scripts(baseframe.UPFrameConnect, baseframe, instancia)

	baseframe.UPFrameLeftPart = CreateFrame("frame", "DetailsUpFrameLeftPart"..instancia.meu_id, baseframe)
	baseframe.UPFrameLeftPart:SetPoint("bottomleft", baseframe, "topleft", 0, 0)
	baseframe.UPFrameLeftPart:SetSize(22, 20)
	baseframe.UPFrameLeftPart:EnableMouse(true)
	baseframe.UPFrameLeftPart:SetMovable(true)
	baseframe.UPFrameLeftPart:SetResizable(true)
	baseframe.UPFrameLeftPart.is_toolbar = true

	BGFrame_scripts(baseframe.UPFrameLeftPart, baseframe, instancia)

	--anchors para os micro displays no lado de cima da janela
	local StatusBarLeftAnchor = CreateFrame("frame", "DetailsStatusBarLeftAnchor" .. instancia.meu_id, baseframe)
	StatusBarLeftAnchor:SetPoint("bottomleft", baseframe, "topleft", 0, 9)
	StatusBarLeftAnchor:SetWidth(1)
	StatusBarLeftAnchor:SetHeight(1)
	baseframe.cabecalho.StatusBarLeftAnchor = StatusBarLeftAnchor

	local StatusBarCenterAnchor = CreateFrame("frame", "DetailsStatusBarCenterAnchor" .. instancia.meu_id, baseframe)
	StatusBarCenterAnchor:SetPoint("center", baseframe, "center")
	StatusBarCenterAnchor:SetPoint("bottom", baseframe, "top", 0, 9)
	StatusBarCenterAnchor:SetWidth(1)
	StatusBarCenterAnchor:SetHeight(1)
	baseframe.cabecalho.StatusBarCenterAnchor = StatusBarCenterAnchor

	local StatusBarRightAnchor = CreateFrame("frame", "DetailsStatusBarRightAnchor" .. instancia.meu_id, baseframe)
	StatusBarRightAnchor:SetPoint("bottomright", baseframe, "topright", 0, 9)
	StatusBarRightAnchor:SetWidth(1)
	StatusBarRightAnchor:SetHeight(1)
	baseframe.cabecalho.StatusBarRightAnchor = StatusBarRightAnchor

	local MenuAnchorLeft = CreateFrame("frame", "DetailsMenuAnchorLeft"..instancia.meu_id, baseframe)
	MenuAnchorLeft:SetSize(1, 1)

	local MenuAnchorRight = CreateFrame("frame", "DetailsMenuAnchorRight"..instancia.meu_id, baseframe)
	MenuAnchorRight:SetSize(1, 1)

	local Menu2AnchorRight = CreateFrame("frame", "DetailsMenu2AnchorRight"..instancia.meu_id, baseframe)
	Menu2AnchorRight:SetSize(1, 1)

	instancia.menu_points = {MenuAnchorLeft, MenuAnchorRight}
	instancia.menu2_points = {Menu2AnchorRight}

-------------------------------------------------------------------------------------------------------------------------------------------------
--title bar buttons

	--mode selection
	local modeSelector_OnClick = function()
		if (Details.instances_menu_click_to_open) then
			if (instancia.LastMenuOpened == "mode" and GameCooltipFrame1:IsShown()) then
				GameCooltip:ShowMe(false)
				instancia.LastMenuOpened = nil
			else
				modeSelector_OnEnter(instancia.baseframe.cabecalho.modo_selecao.widget, _, true, true)
				instancia.LastMenuOpened = "mode"
			end
		else
			Details:OpenOptionsWindow(instancia)
		end
	end

	baseframe.cabecalho.modo_selecao = gump:NewButton(baseframe, nil, "DetailsModeButton"..instancia.meu_id, nil, 16, 16, modeSelector_OnClick, nil, nil, [[Interface\AddOns\Details\images\modo_icone]])
	baseframe.cabecalho.modo_selecao:SetPoint("bottomleft", baseframe.cabecalho.ball, "bottomright", instancia.menu_anchor [1], instancia.menu_anchor [2])
	baseframe.cabecalho.modo_selecao:SetFrameLevel(baseframe:GetFrameLevel()+5)
	baseframe.cabecalho.modo_selecao.widget._instance = instancia

	baseframe.cabecalho.modo_selecao:SetScript("OnEnter", modeSelector_OnEnter)
	baseframe.cabecalho.modo_selecao:SetScript("OnLeave", modeSelector_OnLeave)

	local b = baseframe.cabecalho.modo_selecao.widget
	b:SetNormalTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetNormalTexture():SetTexCoord(0/256, 32/256, 0, 1)
	b:SetHighlightTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetHighlightTexture():SetTexCoord(0/256, 32/256, 0, 1)
	b:SetPushedTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetPushedTexture():SetTexCoord(0/256, 32/256, 0, 1)


	--segment selection
	local segmentSelector_OnClick = function(self, button, param1)
		if (Details.instances_menu_click_to_open) then
			if (instancia.LastMenuOpened == "segments" and GameCooltipFrame1:IsShown()) then
				GameCooltip:ShowMe(false)
				instancia.LastMenuOpened = nil
			else
				segmentButton_OnEnter(instancia.baseframe.cabecalho.segmento.widget, _, true, true)
				instancia.LastMenuOpened = "segments"
			end
		else
			changeSegmentOnClick(instancia, button)
		end
	end

	baseframe.cabecalho.segmento = gump:NewButton(baseframe, nil, "DetailsSegmentButton"..instancia.meu_id, nil, 16, 16, segmentSelector_OnClick, nil, nil, [[Interface\AddOns\Details\images\segmentos_icone]])
	baseframe.cabecalho.segmento:SetFrameLevel(baseframe.UPFrame:GetFrameLevel()+1)
	baseframe.cabecalho.segmento.widget._instance = instancia
	baseframe.cabecalho.segmento:SetPoint("left", baseframe.cabecalho.modo_selecao, "right", 0, 0)

	--ativa bot�o do meio e direito
	baseframe.cabecalho.segmento:SetClickFunction(segmentSelector_OnClick, nil, nil, "rightclick")

	baseframe.cabecalho.segmento:SetScript("OnEnter", segmentButton_OnEnter)
	baseframe.cabecalho.segmento:SetScript("OnLeave", segmentButton_OnLeave)

	local b = baseframe.cabecalho.segmento.widget
	b:SetNormalTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetNormalTexture():SetTexCoord(32/256, 64/256, 0, 1)
	b:SetHighlightTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetHighlightTexture():SetTexCoord(32/256, 64/256, 0, 1)
	b:SetPushedTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetPushedTexture():SetTexCoord(32/256, 64/256, 0, 1)

	--SELECIONAR O ATRIBUTO  ----------------------------------------------------------------------------------------------------------------------------------------------------
	local atributo_button_click = function()
		if (Details.instances_menu_click_to_open) then
			if (instancia.LastMenuOpened == "attributes" and GameCooltipFrame1:IsShown()) then
				GameCooltip:ShowMe(false)
				instancia.LastMenuOpened = nil
			else
				attributeButton_OnEnter (instancia.baseframe.cabecalho.atributo.widget, _, true, true)
				instancia.LastMenuOpened = "attributes"
			end
		end
	end

	baseframe.cabecalho.atributo = gump:NewButton(baseframe, nil, "DetailsAttributeButton"..instancia.meu_id, nil, 16, 16, atributo_button_click)
	baseframe.cabecalho.atributo:SetFrameLevel(baseframe.UPFrame:GetFrameLevel()+1)
	baseframe.cabecalho.atributo.widget._instance = instancia
	baseframe.cabecalho.atributo:SetPoint("left", baseframe.cabecalho.segmento.widget, "right", 0, 0)

	baseframe.cabecalho.atributo:SetScript("OnEnter", attributeButton_OnEnter)
	baseframe.cabecalho.atributo:SetScript("OnLeave", attributeButton_OnLeave)

	local b = baseframe.cabecalho.atributo.widget
	b:SetNormalTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetNormalTexture():SetTexCoord(66/256, 93/256, 0, 1)
	b:SetHighlightTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetHighlightTexture():SetTexCoord(68/256, 93/256, 0, 1)
	b:SetPushedTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	b:GetPushedTexture():SetTexCoord(68/256, 93/256, 0, 1)

	--report button ~report
	local reportButtton_OnClick = function()
		instancia:Reportar("INSTANCE" .. instancia.meu_id)
		GameCooltip2:Hide()
	end

	baseframe.cabecalho.report = gump:NewButton(baseframe, nil, "DetailsReportButton"..instancia.meu_id, nil, 8, 16, reportButtton_OnClick)
	baseframe.cabecalho.report:SetFrameLevel(baseframe.UPFrame:GetFrameLevel()+1)
	baseframe.cabecalho.report.widget._instance = instancia
	baseframe.cabecalho.report:SetPoint("left", baseframe.cabecalho.atributo, "right", -6, 0)

	baseframe.cabecalho.report:SetScript("OnEnter", reportButton_OnEnter)
	baseframe.cabecalho.report:SetScript("OnLeave", reportButton_OnLeave)

	local reportButton = baseframe.cabecalho.report.widget
	reportButton:SetNormalTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	reportButton:GetNormalTexture():SetTexCoord(96/256, 128/256, 0, 1)
	reportButton:SetHighlightTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	reportButton:GetHighlightTexture():SetTexCoord(96/256, 128/256, 0, 1)
	reportButton:SetPushedTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	reportButton:GetPushedTexture():SetTexCoord(96/256, 128/256, 0, 1)

	--reset button ~delete ~erase ~reset
	local resetButton_OnClick = function()
		if (Details.instances_menu_click_to_open) then
			if (instancia.LastMenuOpened == "reset" and GameCooltipFrame1:IsShown()) then
				GameCooltip:ShowMe(false)
				instancia.LastMenuOpened = nil
			else
				resetButton_OnEnter(instancia.baseframe.cabecalho.reset, _, true, true)
				instancia.LastMenuOpened = "reset"
			end
		else
			if (not Details.disable_reset_button) then
				Details.tabela_historico:ResetAllCombatData()
			else
				Details:Msg(Loc["STRING_OPTIONS_DISABLED_RESET"])
			end
		end
	end

	baseframe.cabecalho.reset = CreateFrame("button", "DetailsClearSegmentsButton" .. instancia.meu_id, baseframe)
	baseframe.cabecalho.reset:SetFrameLevel(baseframe.UPFrame:GetFrameLevel()+1)
	baseframe.cabecalho.reset:SetSize(10, 16)
	baseframe.cabecalho.reset:SetPoint("right", baseframe.cabecalho.novo, "left")
	baseframe.cabecalho.reset.instance = instancia
	baseframe.cabecalho.reset._instance = instancia

	baseframe.cabecalho.reset:SetScript("OnClick", resetButton_OnClick)
	baseframe.cabecalho.reset:SetScript("OnEnter", resetButton_OnEnter)
	baseframe.cabecalho.reset:SetScript("OnLeave", resetButton_OnLeave)

	local resetButton = baseframe.cabecalho.reset
	resetButton:SetNormalTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	resetButton:GetNormalTexture():SetTexCoord(128/256, 160/256, 0, 1)

	resetButton:SetHighlightTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	resetButton:GetHighlightTexture():SetTexCoord(128/256, 160/256, 0, 1)

	resetButton:SetPushedTexture([[Interface\AddOns\Details\images\toolbar_icons]])
	resetButton:GetPushedTexture():SetTexCoord(128/256, 160/256, 0, 1)
end
