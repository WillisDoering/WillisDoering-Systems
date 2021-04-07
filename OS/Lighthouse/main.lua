----------------------------------------
-- Load GUI and set kill
----------------------------------------
os.loadAPI("CORE/interface.lua")
os.loadAPI("config.lua")
modem = peripheral.wrap("top")
rednet.open("top")
local int = interface
local live = true
local per_list = {}

----------------------------------------
-- Home Page
----------------------------------------

function main()
  display_home()
  
  while live do
    live = int.wait(0)
  end
end


--Display Home Page
function display_home()
  --set section and page
  int.new_section("home")
  int.new_page()
  
  --setup main page
  int.set_header("Main Menu")
  
  --show all peripherals
  int.new_text(1, "List of Control Systems", 3, 3)
  
  int.new_button("mod_list", "Modify List", mod_item, "", 29,3,13, 1)
  if fs.exists("components.cfg") then
    get_list()
  end
  
  --print home page
  int.print_screen()
end

function flip_status(item)
  rednet.broadcast("flip", item)
end


function mod_item()
  local item_modded = false
  function accept(mod)
    item_modded = not item_modded
    if mod == "add" then
      table.insert(per_list, int.get_input("item_input", "data"))
    end
    if mod == "del" then
      for i=1, #per_list do
        if per_list[i] == int.get_input("item_input", "data") then
          table.remove(per_list, i)
        end
      end
    end
  end
  
  int.new_section("mod_item")
  int.new_page()
  
  int.set_header("Modify Item")
  
  int.new_text("item_prompt", "Input Item to Modify", 3, 3)
  int.new_input("item_input", "", "_", "", 3, 5, 15)
  int.new_button("add", "Add", accept, "add", 3, 7, 8, 1)
  int.new_button("del", "Delete", accept, "del", 12, 7, 8, 1)
  int.new_button("can", "Cancel", accept, "can", 21, 7, 8, 1)
  
  int.print_screen()
  while item_modded == false and live == true do
    live = int.wait(0)
  end
  
  config.write(per_list)
  display_home()
end

function get_list()
  store_pos = {int.get_section(), int.get_page()}
  int.set_section("home")
  
  per_list = config.read()
  
  for i=1, #per_list do
    int.new_button(per_list[i], per_list[i], flip_status, per_list[i], 3, 3+(i*2), 15, 1)
  end
  
  int.set_section(store_pos[1])
  int.set_page(store_pos[2])
end

main();
