--Импорт библиотек
local GUI = require("GUI")
local image = require("Image")
local system = require("System")
local component = require("component")
local fs = require("Filesystem")
local event = require("Event")
local number = require("Number")
local internet = require("Internet")
local text = require("Text")
local screen = require("Screen")
--
local reactor
local turbine

local loc = system.getCurrentScriptLocalization()
local scriptPath = fs.path(system.getCurrentScript())

local function stopSricpt(message)
	GUI.alert(message)
	window:remove()
    menu:remove()
end

local workspace, window = system.addWindow(GUI.filledWindow(1, 1, 118, 31, 0xFAFAFA))
local menu = workspace:addChild(GUI.menu(1, 1, workspace.width, 0xEEEEEE, 0x666666, 0xCC2222, 0xFFFFFF))

if component.isAvailable("br_reactor") then
    reactor = component.get("br_reactor")
	else
    stopScript(loc.noReactor)
end
if not reactor.getConnected() then
	stopScript(loc.reactorInvalid)
end
if reactor.isActivelyCooled() and component.isAvailable("br_turbine") then
    turbine = component.get("br_turbine")
	else
    stopScript(loc.noTurbine)
end
if reactor.isActivelyCooled() and not turbine.getConnected() then
	stopScript(loc.turbineInvalid)
end

local FileMenu = menu:addContextMenuItem(loc.menuProgram)
FileMenu:addItem(loc.menuProgramClose).onTouch = function()
    window:remove()
    menu:remove()
end
local controlMenu = menu:addContextMenuItem(loc.menuControl)
controlMenu:addItem(loc.controlEjectFuel).onTouch = function()
    reactor.doEjectFuel()
    GUI.alert(loc.controlEjectFuelMessage)
end
controlMenu:addItem(loc.controlEjectWaste).onTouch = function()
    reactor.doEjectWaste()
    GUI.alert(loc.controlEjectWasteMessage)
end
controlMenu:addSeparator()
controlMenu:addItem(loc.menuReactorActive).onTouch = function()
    if reactor.getActive() == true then
		reactor.setActive(false)
		else
		reactor.setActive(true)
	end
end
controlMenu:addItem(loc.menuTurbineActive).onTouch = function()
    if turbine.getActive() == true then
		turbine.setActive(false)
		else
		turbine.setActive(true)
	end
end
controlMenu:addItem(loc.menuTurbineInductive).onTouch = function()
    if turbine.getInductorEngaged() == true then
		turbine.setInductorEngaged(false)
		else
		turbine.setInductorEngaged(true)
	end
end

window.showDesktopOnMaximize = true
window.actionButtons.close.onTouch = function()
    window:remove()
    menu:remove()
end

local list = window:addChild(GUI.list(1, 4, 22, 1, 3, 0, 0x4B4B4B, 0xE1E1E1, 0x4B4B4B, 0xE1E1E1, 0xB00000, 0x4FFFFFF))
local listCover = window:addChild(GUI.panel(1, 1, list.width, 3, 0x4B4B4B))
local layout = window:addChild(GUI.layout(list.width + 1, 1, 1, 1, 1, 1))

window.backgroundPanel.localX = layout.localX

local function infoCeil(num)
	return tostring(math.ceil(num))
end

local function addTab(text, func)
    list:addItem(text).onTouch = function()
		layout:removeChildren()
		func()
		workspace:draw()
	end
end
local function addText(text)
    newText = layout:addChild(GUI.text(workspace.width, workspace.height, 0x3C3C3C, text))
    return newText
end
local function addButton(text, func)
    newButton = layout:addChild(GUI.button(1, 1, 24, 1, 0x3C3C3C, 0xE1E1E1, 0xFFFFFF, 0x2D2D2D, text))
    newButton.onTouch = function()
		func()
	end
    return newButton
end
local function addSwitchReactor(func)
    newSwitch = layout:addChild(GUI.switch(3, 2, 8, 0xB00000, 0x1D1D1D, 0xC9C9C9, reactor.getActive()))
    newSwitch.onStateChanged = function(state)
		func()
	end
    return newSwitch
end
local function addSwitchTurbine(func)
    newSwitch = layout:addChild(GUI.switch(3, 2, 8, 0xB00000, 0x1D1D1D, 0xC9C9C9, turbine.getActive()))
    newSwitch.onStateChanged = function(state)
		func()
	end
    return newSwitch
end
local function addSwitchInductor(func)
    newSwitch = layout:addChild(GUI.switch(3, 2, 8, 0xB00000, 0x1D1D1D, 0xC9C9C9, turbine.getInductorEngaged()))
    newSwitch.onStateChanged = function(state)
		func()
	end
    return newSwitch
end
local function addSliderFluidMax()
	newSlider = layout:addChild(GUI.slider(3, 2, layout.width - 20, 0xB00000, 0x1D1D1D, 0xC9C9C9, 0x3C3C3C, 0, turbine.getFluidFlowRateMaxMax(), turbine.getFluidFlowRateMax(), true, loc.controlCurrentValue, 'mB'))
	newSlider.roundValues = true
	newSlider.onValueChanged = function()
		turbine.setFluidFlowRateMax(newSlider.value)
	end
	return newSlider
end
local function drawIcon(pic)
    return layout:addChild(GUI.image(2, 2, image.load(pic)))
end

--Вкладки
addTab(loc.tabMain, function() --Главная
    drawIcon(scriptPath .. "Icon.pic")
    addText(loc.greetingUser .. system.getUser() .. "!")
	addText(loc.greeting)
end)

addTab(loc.tabReactorInfo, function() -- Датчики реактора
    infoFuelTemp = addText(loc.infoFuelTemp)
    infoCasingTemp = addText(loc.infoCasingTemp)
    infoFuel = addText(loc.infoFuel)
    infoWaste = addText(loc.infoWaste)
    infoFuelMax = addText(loc.infoFuelMax)
    infoReactivity = addText(loc.infoReactivity)
    infoFuelCons = addText(loc.infoFuelCons)
    infoReactorEnergyProd = addText(loc.infoReactorEnergyProd)
    infoReactorEenergyStore = addText(loc.infoReactorEenergyStore)
    infoReactorState = addText(loc.infoReactorState)
    mainhandler=event.addHandler(function()
		infoFuelTemp.text = loc.infoFuelTemp .. infoCeil(reactor.getFuelTemperature())
		infoCasingTemp.text = loc.infoCasingTemp .. infoCeil(reactor.getCasingTemperature())
		infoFuel.text = loc.infoFuel .. infoCeil(reactor.getFuelAmount())
		infoWaste.text = loc.infoWaste .. infoCeil(reactor.getWasteAmount())
		infoFuelMax.text = loc.infoFuelMax .. infoCeil(reactor.getFuelAmountMax())
		infoReactivity.text = loc.infoReactivity .. infoCeil(reactor.getFuelReactivity())
		infoFuelCons.text = loc.infoFuelCons .. infoCeil(reactor.getFuelConsumedLastTick())
		infoReactorEnergyProd.text = loc.infoReactorEnergyProd .. infoCeil(reactor.getEnergyProducedLastTick())
		infoReactorEenergyStore.text = loc.infoReactorEenergyStore .. infoCeil(reactor.getEnergyStored())
		if reactor.getActive() == true then
			infoReactorState.text = loc.infoReactorState .. loc.infoReactorActive
			else
			infoReactorState.text = loc.infoReactorState .. loc.infoReactorInactive
		end
	end, 0.15)
end)
if reactor.isActivelyCooled() then
	addTab(loc.tabTurbineInfo, function() -- Индикаторы турбины
		infoRotorSpeed = addText(loc.infoRotorSpeed)
		infoInput = addText(loc.infoInput)
		infoOutput = addText(loc.infoOutput)
		infoFluidMax = addText(loc.infoFluidMax)
		infoFluidFlow = addText(loc.infoFluidFlow)
		infoTurbineEnergyProd = addText(loc.infoTurbineEnergyProd)
		infoTurbineEnergyStore = addText(loc.infoTurbineEnergyStore)
		infoInductorState = addText(loc.infoInductorState)
		infoTurbineState = addText(loc.infoTurbineState)
		mainhandler=event.addHandler(function()
			infoRotorSpeed.text = loc.infoRotorSpeed .. infoCeil(turbine.getRotorSpeed())
			infoInput.text = loc.infoInput .. infoCeil(turbine.getInputAmount())
			infoOutput.text = loc.infoOutput .. infoCeil(turbine.getOutputAmount())
			infoFluidMax.text = loc.infoFluidMax .. infoCeil(turbine.getFluidAmountMax())
			infoFluidFlow.text = loc.infoFluidFlow .. infoCeil(turbine.getFluidFlowRate())
			infoTurbineEnergyProd.text = loc.infoTurbineEnergyProd .. infoCeil(turbine.getEnergyProducedLastTick())
			infoTurbineEnergyStore.text = loc.infoTurbineEnergyStore .. infoCeil(turbine.getEnergyStored())
			if turbine.getInductorEngaged() == true then
				infoInductorState.text = loc.infoInductorState .. loc.infoInductorActive
				else
				infoInductorState.text = loc.infoInductorState .. loc.infoInductorInactive
			end
			if turbine.getActive() == true then
				infoTurbineState.text = loc.infoTurbineState .. loc.infoTurbineActive
				else
				infoTurbineState.text = loc.infoTurbineState .. loc.infoTurbineInactive
			end
		end, 0.15)
	end)
end
addTab(loc.tabReactorControl, function() -- Управление реактором
    addButton(loc.controlEjectFuel, function()
		reactor.doEjectFuel()
		GUI.alert(loc.controlEjectFuelMessage)
	end)
    addButton(loc.controlEjectWaste, function()
		reactor.doEjectWaste()
		GUI.alert(loc.controlEjectWasteMessage)
	end)
    addText(loc.controlReactorState)
    r_as = addSwitchReactor(function()
		reactor.setActive(r_as.state)
	end)
end)
if reactor.isActivelyCooled() then
	addTab(loc.tabTurbineControl, function() -- Управление турбиной
		addText(loc.controlVentType)
		addButton(loc.controlVentOff, function()
			turbine.setVentNone()
			GUI.alert(loc.controlVentTypeMessage .. loc.controlVentOff)
		end)
		addButton(loc.controlVentOverflow, function()
			turbine.setVentOverflow()
			GUI.alert(loc.controlVentTypeMessage .. loc.controlVentOverflow)
		end)
		addButton(loc.controlVentAll, function()
			turbine.setVentAll()
			GUI.alert(loc.controlVentTypeMessage .. loc.controlVentAll)
		end)
		addText(loc.controlInductorState)
		ie_as = addSwitchInductor(function()
			turbine.setInductorEngaged(ie_as.state)
		end)
		addText(loc.controlTurbineState)
		t_as = addSwitchTurbine(function()
			turbine.setActive(t_as.state)
		end)
		addText(loc.controlFluidMax)
		addSliderFluidMax()
	end)
end
addTab(loc.tabAbout, function() -- О программе
    addText(loc.aboutAuthor)
	addText("GitHub: ")
	addText(loc.aboutVersion .. "1.0.1")
	addText(loc.aboutFounded)
end)
--
list.eventHandler = function(workspace, list, e1, e2, e3, e4, e5)
    if e1 == "scroll" then
		local horizontalMargin, verticalMargin = list:getMargin()
		list:setMargin(horizontalMargin, math.max(-list.itemSize * (#list.children - 1), math.min(0, verticalMargin + e5)))
		
		workspace:draw()
	end
end

local function calculateSizes()
    list.height = window.height
	
    window.backgroundPanel.width = window.width - list.width
    window.backgroundPanel.height = window.height
	
    layout.width = window.backgroundPanel.width
    layout.height = window.height
end

window.onResize = function()
    calculateSizes()
end

calculateSizes()
window.actionButtons:moveToFront()
list:getItem(1).onTouch()