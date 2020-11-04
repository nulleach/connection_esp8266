--------------------------------------------
--Наименование: Программа управляющего устройства
--Разработал: Баранников Максим Юрьевич
--Группа: П-477
--Дата: 22.05.2020
--------------------------------------------


--------------------------------------------
-- instmqtt.lua
--------------------------------------------
-- Устанавливаем соединение с mqtt брокером
print('Set MQTT')
	if not dat then dat = {} 
	end
	if not myClient then myClient = "myClient" 
	end
	if not killtop then killtop = {} 
	end
	if not m then
    m = mqtt.Client( myClient, 60, myClient, 'passfor'..myClient)
    m:lwt(myClient..'/state', "OFF", 0, 0)
    m:on("message", function(conn, topic, dt)
        local top = string.gsub(topic, myClient.."/command/","")
        print(top, ":", dt)
            table.insert(killtop, {top, dt})
            -- отправляем для анализа если такой анализ
            -- еще не производится (разберемся позже)
            if not dat.analiz then
                dofile("analize.lua")
            end
        end
    end)
    m:on ("offline", function(con)
        dat.broker = false
        dofile('setmqtt.lua')
		end)
	end
m:close()
-- Счетчик ожидания wifi, нужен для некоторых случаев
local count = 0
local connecting = function(getmq)
    -- Проверяем wifi
    if wifi.sta.status() == 5 then
        print('Got wifi')
        tmr.stop(getmq)
        tmr.unregister(getmq)
        getmq = nil
        print('iot.eclipse.org ')
        m:connect('iot.eclipse.org', 1883, 0, 0,
        function(con)
            print("Connected to Broker")
            m:subscribe(myClient.."/command/#",0, function(conn)
                print("Subscribed.")
            end)
            m:publish(myClient..'/state',"ON",0,0)
            dat.broker = true
            count = nil
        end,
        function(con, reason)
            print("failed mqtt: " .. reason)
            dofile('setmqtt.lua')
        end)
    else
        print("Wating for WiFi "..count.." times")
        count = count + 1
    end
end
-- Таймер периодически запускает функцию соединения
tmr.create():alarm(5000, 1, function(t)
    connecting(t)
end)
