--------------------------------------------
--Наименование: Программа управляющего устройства
--Разработал: Баранников Максим Юрьевич
--Группа: П-477
--Дата: 22.05.2020
--------------------------------------------


--------------------------------------------
-- wifi.lua
--------------------------------------------
-- Подключаемся к wi-fi точке
	do
wifi.setmode(wifi.STATION)		
wifi.sta.clearconfig()
local scfg = {}
scfg.auto = true
scfg.save = true
scfg.ssid = 'ТочкаДоступа'
scfg.pwd = 'Пароль'
wifi.sta.config(scfg)
wifi.sta.connect()
tmr.create():alarm(15000, tmr.ALARM_SINGLE, function() print('\n', wifi.sta.getip()) end)	
	end

