--------------------------------------------
--Наименование: Программа управляющего устройства
--Разработал: Баранников Максим Юрьевич
--Группа: П-477
--Дата: 22.05.2020
--------------------------------------------

--------------------------------------------
--init.lua
--------------------------------------------
-- Файл для последующего запуска
local runfile = "setglobals.lua"
-- Если файла нет - переименовываем init.lua
-- чтобы не войти в бесконечный цикл перезагрузки
tmr.create():alarm(5000, 0, function()
  if file.exists(runfile) then
      dofile(runfile)
  else
      print("No ".. runfile..", Rename init.lua!")
      if file.exists("init.lua") then
          file.rename("init.lua","_init.lua")
          node.restart()
      end
  end
end)

