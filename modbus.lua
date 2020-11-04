--------------------------------------------
--Наименование: Программа управляющего устройства
--Разработал: Баранников Максим Юрьевич
--Группа: П-477
--Дата: 22.05.2020
--------------------------------------------


--------------------------------------------
-- modbus.lua
--------------------------------------------
--Конфигурируем modbus rtu slave устройство
local M = {}
M.setup = function()
	if not M.set then 
		M.set = true
		uart.setup(2, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, {tx = 16, rx = 17})
		uart.start(2)
	end
end
local startUART = false
local gotuartt = {}
local startsg = 1
local lengthans = 100
local gotuartt = {}
local killtimer
local setuart
killtimer = tmr.create()
-- Проверка/расчет контрольной суммы:
local function crchex(dt, ok)
	local res = ''
	local crc = 0xFFFF
	local lowb, hihb
	if ok then
		if type(dt) ~= 'table' then
			return false
		end
		lowb = table.remove(dt)
		hihb = table.remove(dt)
	end	

	for i = 1, #dt do
		crc = bit.bxor(crc, dt[i])
		for j = 0, 7 do
			if bit.band(crc, 1) > 0 then
				crc = bit.rshift(crc, 1)
				crc = bit.bxor(crc, 0xA001)
			else
				crc = bit.rshift(crc, 1)
			end
		end
	end
	dt[#dt+1] = bit.band(crc, 0xFF)
	dt[#dt+1] = bit.rshift(crc, 8)
	
	if lowb then 
		if dt[#dt-1] == hihb  and dt[#dt] == lowb then
			print('good crc')
			return true
		else
			print('bad crc')
			return false
		end	
	end

	for i = 1, #dt do
		res = res..string.char(dt[i])
	end
	return res
end
-- Функция приема данных от UART
local function parcecom (t, gotuartt) 
	setuart()
	t:stop()
	local ok = crchex(gotuartt, true)
	if not ok then 
		print('Lost Modbus Unit')
		return 
	end
	if M.call then
		M.call(ok, gotuartt, t) 
	end
end
killtimer:register(500, tmr.ALARM_SEMI, parcecom)
-- Устанавливаем или отменяем callback на UART
setuart = function(com)
	if com then 
	startUART = false
	gotuartt = {}
	lengthans = 100
	uart.on(2,"data",1,
		function(data)
			if startUART == false and string.byte(data) ~= startsg then return
			elseif startUART == false then startUART = true end
			gotuartt[#gotuartt+1] = string.byte(data)
			if #gotuartt == 3 then 
				lengthans = gotuartt[3] + 5
			end
			if #gotuartt == lengthans then 
				startUART = false
				lengthans = 100
				startsg = 1
				return parcecom(killtimer, gotuartt)
			end
	end, 0)
	else
		uart.on(2,"data")
	end
end
-- Опрос устройства, принимаем таблицу для чтения и callback
M.askpzem = function(modtb, call)
	if not M.set then M.setup()
	end
	if call then M.call = call
	end
	if type(modtb) ~= 'table' then modtb = {1,4,0,0,0,10}
	end 
	startsg = modtb[1]
	setuart('on')
	local ask = crchex(modtb)
	local u = ''
	for i = 1, #ask do
		u = u ..string.byte(ask, i, i)..', ' 
	end
	print('Ask: '..u)
	uart.write(2, ask)
	killtimer:start()
end
return M

