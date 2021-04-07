----------------------------------------
-- Default Declarations
----------------------------------------
local pm_status = true --power menu displayed
local bm_status = false --bar menu displayed
local version = "0.0.3" --software version

--table starters
local page = {}
local max_page = {}
local header = {}
local text = {}
local link = {}
local input = {}
local button = {}

--colors
local p_color --primary color
local s_color --secondary color
local b_color --background color

--get screen dimensions
local x_size, y_size = term.getSize()


----------------------------------------
-- Config
----------------------------------------

--Sets the config file, adding a new line after
--each setting. Descriptions of settings are listed
--below.
function set_config()
  f_config = io.open("WDS/CORE/config", "w")
  
  --Line 2: Primary Color
  f_config:write("Line 2: Primary Color\n")
  f_config:write(p_color)
  f_config:write("\n")
  
  --Line 4: Secondary Color
  f_config:write("Line 4: Secondary Color\n")
  f_config:write(s_color)
  f_config:write("\n")
  
  --Line 6: Background Color
  f_config:write("Line 6: Background Color\n")
  f_config:write(b_color)
  f_config:write("\n")
  
  --Line 8: Warning Color
  f_config:write("Line 8: Warning Color\n")
  f_config:write(w_color)
  f_config:write("\n")
  
  --eof
  f_config:close()
end

--Reads setting from config file.
function get_config()
  f_config = io.open("WDS/CORE/config", "r")
  
  --read in config
  local file_in = {}
  local line = f_config:read()
  repeat
  table.insert(file_in, line)
  line = f_config:read()
  until line == nil
  
  --Line 2: Primary Color
  p_color = math.floor(file_in[2])
  
  --Line 4: Secondary Color
  s_color = math.floor(file_in[4])
  
  --Line 6: Background Color
  b_color = math.floor(file_in[6])
  
  --Line 8: Warning Color
  w_color = math.floor(file_in[8])
  
  --eof
  f_config:close()
end

--Creates the default config file
function create_config()

  --Line 2: Primary Color
  p_color = colors.blue
  
  --Line 4: Secondary Color
  s_color = colors.white
  
  --Line 6: Background Color
  b_color = colors.black
  
  --Line 8: Warning Color
  w_color = colors.red
  
  --Set config settings
  set_config()
end

--Checks for config file and creates new one if
--missing, else loads config settings.
function check_config()
  if fs.exists("WDS/CORE/config") then
    get_config()
  else
    create_config()
  end
end


----------------------------------------
-- Sections
----------------------------------------

--Create new section
function new_section(name)
  section = name
  max_page[section] = 0
  header[section] = {}
  text[section] = {}
  link[section] = {}
  input[section] = {}
  button[section] = {}
end
  
--Switch to different section
function set_section(name)
  section = name
end

--Get current section
function get_section()
  return section
end


----------------------------------------
-- Page
----------------------------------------

--Create new page
function new_page()
  max_page[section] = max_page[section] + 1
  page[section] =  max_page[section]
  text[section][page] = {}
  link[section][page] = {}
  input[section][page] = {}
  button[section][page] = {}
end  
  
--Switch to specific page
function set_page(number)
  page[section] = number
end

--Get current page
function get_page()
  return page
end

--Move to next page
function next_page()
  page = page + 1
end

--Move to previous page
function prev_page()
  page = page - 1
end


----------------------------------------
-- Header
----------------------------------------

--Set header text
function set_header(name)
  header[section] = name
end

--Get header text
function get_header()
  return header[section]
end

--Display header
function print_header()  
  --set starting point
  h_size = string.len(header[section])
  x_pos = math.floor(x_size/2) - math.ceil(h_size/2)
  
  --set correct colors
  term.setTextColor(p_color)
  term.setBackgroundColor(b_color)
  
  --print header
  term.setCursorPos(1,1)   --put cursor at top of screen
  if h_size < (x_size - 6) then --check overflow
    for v = 1, x_pos do --space in front of header to center
      term.write(" ")
    end
    term.write(header[section])
    for v = 2, x_pos + 1 do
      term.write(" ")
    end
  else
    term.write("   ")        --space in front of header
    term.write(header[section])
    term.setCursorPos(x_size-5,1) --cut off header
    term.write("...   ")
  end
  
  --power menu
  if pm_status then
    term.setCursorPos(x_size-2, 1)
    term.write(" []")
  end
end
  

----------------------------------------
-- Text Display
----------------------------------------

--Create text box
function new_text(name, data, x, y)
  text[section][page][name] = {}
  text[section][page][name]["data"] = data --text displayed
  text[section][page][name]["x"] = x --starting x coordinate
  text[section][page][name]["y"] = y --starting y coordinate
  text[section][page][name]["display"] = true --whether text is displayed
end

--Set text box display
function set_text(name, object, data)
  text[section][page][name][object] = data
end

--Gets objects from text box
function get_text(name, object)
  return text[section][page][name][object]
end

--Display all text boxes
function print_text()
  --set colors
  term.setTextColor(p_color)
  term.setBackgroundColor(b_color)
  
  --prints each active text box
  for name, data in pairs(text[section][page]) do
    if data["display"] then
	  term.setCursorPos(data["x"],data["y"])
	  term.write(data["data"])
	end
  end
end


----------------------------------------
-- Text Link
----------------------------------------
function new_link(name, data, func, param, x, y)
  link[section][page][name] = {}
  link[section][page][name]["data"] = data --text displayed
  link[section][page][name]["func"] = func --function executed when clicked ("" is none)
  link[section][page][name]["param"] = param --parameter used in function ("" is none)
  link[section][page][name]["x"] = x --x coordinate of left edge of link
  link[section][page][name]["y"] = y --y coordinate of right edge of link
  link[section][page][name]["display"] = true --whether link is displayed
  link[section][page][name]["active"] = false --state of link (color scheme)
end

--Set link object
function set_link(name, object, data)
  link[section][page][name][object] = data
end

--Gets objects from input box
function get_link(name, object)
  return link[section][page][name][object]
end

function print_link()
  --set colors
  term.setBackgroundColor(b_color)
  
  --prints each active link box
  for name, data in pairs(link[section][page]) do
    if data["display"] then
	
      --set link color	
	  if data["active"] then
	    term.setTextColor(s_color)
	  else
	    term.setTextColor(p_color)
	  end
	  
	  --print link
	  term.setCursorPos(data["x"],data["y"])
	  term.write(data["data"])
	end
  end
end

function action_link(name)
  if link[section][page][name]["func"] ~= "" then
    link[section][page][name]["func"](link[section][page][name]["param"])
  end
  print_screen()
end


----------------------------------------
-- Text Input Box
----------------------------------------

--Create input box.
function new_input(name, data, space, func, x, y, width)
  input[section][page][name] = {}
  input[section][page][name]["data"] = data --text displayed
  input[section][page][name]["space"] = space --space applied after text 
  input[section][page][name]["func"] = func --function executed after text input ("" is none)
  input[section][page][name]["x"] = x --starting x coordinate
  input[section][page][name]["y"] = y --starting y coordinate
  input[section][page][name]["width"] = width  --width of input box
  input[section][page][name]["display"] = true --whether input box is displayed
end

--Set input box display
function set_input(name, object, data)
  input[section][page][name][object] = data
end

--Gets objects from input box
function get_input(name, object)
  return input[section][page][name][object]
end

--Display all input boxes
function print_input()
  --set colors
  term.setTextColor(p_color)
  term.setBackgroundColor(b_color)
  
  --prints each active text box
  for name, data in pairs(input[section][page]) do
    if data["display"] then
	  term.setCursorPos(data["x"],data["y"])
	  
	  --check for size
	  if string.len(data["data"]) > data["width"] then
	    term.write(string.sub(data["data"], 1, 12))
		term.write("...")
      else
		term.write(data["data"])
	    for v = 1, data["width"] - string.len(data["data"]) do
	      term.write(data["space"])
        end
	  end
	end
  end
end

--Input box action
function action_input(name)
  --set colors
  term.setTextColor(s_color)
  term.setBackgroundColor(b_color)
  --clear text box
  term.setCursorPos(input[section][page][name]["x"], input[section][page][name]["y"])
  for v = 1, input[section][page][name]["width"] do
    term.write(input[section][page][name]["space"])
  end
  
  --get user input
  term.setCursorPos(input[section][page][name]["x"], input[section][page][name]["y"])
  local user_in = read()
  
  --analize input
  if user_in ~= "" then
    --call function if available
	if input[section][page][name]["func"] ~= "" then
	  input[section][page][name]["func"](user_in)
	end
    
	--set input box
	input[section][page][name]["data"] = user_in
  end
  print_screen()
end


----------------------------------------
-- Button
----------------------------------------

--Create button
function new_button(name, data, func, param, x, y, width, height)
  button[section][page][name] = {}
  button[section][page][name]["data"] = data --text displayed
  button[section][page][name]["func"] = func --function executed when clicked ("" is none)
  button[section][page][name]["param"] = param --parameter used in function ("" is none)
  button[section][page][name]["x"] = x --x coordinate of left edge of button
  button[section][page][name]["y"] = y --y coordinate of right edge of button
  button[section][page][name]["width"] = width --width of button
  button[section][page][name]["height"] = height --height of button
  button[section][page][name]["display"] = true --whether button is displayed
  button[section][page][name]["active"] = false --state of button (color scheme)
end

--Set button object
function set_button(name, object, data)
  button[section][page][name][object] = data
end

--Gets objects from input box
function get_button(name, object)
  return button[section][page][name][object]
end

--Display all buttons
function print_button()
  for name, data in pairs(button[section][page]) do
    if data["display"] then
	
	  --set colors
	  if data["active"] then
	    term.setTextColor(p_color)
		term.setBackgroundColor(s_color)
	  else
	    term.setTextColor(s_color)
		term.setBackgroundColor(p_color)
	  end
	  
	  --print button shape
	  for v = 1, data["height"] do
	    term.setCursorPos(data["x"], data["y"] + v - 1)
	    for v = 1, data["width"] do
		  term.write(" ")
		end
      end
	  
	  --y position of text in button
	  y_pos = math.ceil(data["height"] / 2) + data["y"] - 1
	  
	  --x position of text in button
	  x_pos = math.ceil(data["width"] / 2) - math.ceil(string.len(data["data"]) / 2) + data["x"]
	  
	  --write text in button
	  term.setCursorPos(x_pos, y_pos)
	  term.write(data["data"])
	  
    end	 
  end
end

--Button action
function action_button(name)
  if button[section][page][name]["func"] ~= "" then
    button[section][page][name]["func"](button[section][page][name]["param"])
  end
  print_screen()
end


----------------------------------------
-- Power Menu
----------------------------------------

--Open power menu
function open_pm()
  --display icon
  term.setCursorPos(x_size-1, 1)
  term.setBackgroundColor(b_color)
  term.setTextColor(s_color)
  term.write("[]")
  
  --display menu
  term.setTextColor(s_color)
  term.setBackgroundColor(p_color)
  term.setCursorPos(x_size - 9, 2)
  term.write(" Shutdown ")
  term.setCursorPos(x_size - 9, 3)
  term.write(" Reboot   ")
  term.setCursorPos(x_size - 9, 4)
  term.write(" Shell    ")
  
  --menu options
  event, p1, x, y = os.pullEvent("mouse_click")
  if x >= (x_size - 1) and y == 1 then
    print_screen()
    safe_pm()
  elseif x >= (x_size - 9) then
    if y == 2 then
	  os.shutdown()
	elseif y == 3 then
	  os.reboot()
	elseif y == 4 then
	  kill = true
	  term.setTextColor(colors.white)
	  term.setBackgroundColor(colors.black)
	  term.clear()
	  term.setCursorPos(1,1)
	  print("Type 'exit' to return")
	else
	  print_screen()
	end
  else
     print_screen()	 
  end	
end

--Safety mode
function safe_pm()
  term.setCursorPos(x_size-1, 1)
  term.setBackgroundColor(b_color)
  term.setTextColor(w_color)
  term.write("[]")
  
  --wait third safety click
  event, p1, x, y = os.pullEvent("mouse_click")
  if x >= (x_size - 1) and y == 1 then
    swindow_pm()
  else
    print_screen()
  end
end

--Safety window
function swindow_pm()
  --set colors and clear screen
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.clear()
  local await = true
  
  --display safety options
  term.setCursorPos(2,2)
  term.write("Shutdown")
  term.setCursorPos(2,4)
  term.write("Restore Defaults")
  term.setCursorPos(2,6)
  term.write("Return")
  
  --await decision
  while await do
    event, p1, x, y = os.pullEventRaw("mouse_click")
	if x >= 2 and x <= 9 and y == 2 then
	  await = false
	  os.shutdown()
	elseif x >= 2 and x <= 17 and y == 4 then
	  await = false
	  create_config()
	  print_screen()
	elseif x >= 2 and x <= 7 and y == 6 then
	  await = false
      print_screen()
	end
  end
end

----------------------------------------
-- Interface
----------------------------------------

--Get event
function event()
  --Get event
  event, p1, p2, p3 = os.pullEventRaw()
end

function timeout()
  os.sleep(tout)
  event = "timeout"
end
  
--Look for user input
function wait(tout)
  --Reset kill
  local kill = false
  
  if tout == 0 then
    event()
  else
    parallel.waitForAny(timeout, event)
  end
  
  --Sort event
  if event == "mouse_click" then
    if pm_status and p3 == 1 and p2 >= (x_size - 1) then
	  open_pm()
    elseif bm_status and p3 == 2 then
	  --[bar menu]
	else
	  check(p2, p3)
	end
  else
    return event
  end
  
  if kill == true then
    return "kill"
  end
end

--Check links, input boxes and buttons
function check(x, y)
  local test = false --used to skip if a match is found

  --check links
  for name, data in pairs(link[section][page]) do
    if data["display"] then
	  if p3 == data["y"] then
	    if p2 >= data["x"] and p2 <= data["x"] + (string.len(data["data"]) - 1) then
	      action_link(name)
	      test = true
		end
	  end
	end
  end

  --check input boxes
  for name, data in pairs(input[section][page]) do
    if data["display"] then
	  if p3 == data["y"] then
	    if p2 >= data["x"] and p2 <= data["x"] + (data["width"] - 1) then
	      action_input(name)
	      test = true
		end
	  end
	end
  end
  
  --check button
  if not test then
    for name, data in pairs(button[section][page]) do
	  if data ["display"] then
	    if p3 >= data["y"] and p3 <= data["y"] + (data["height"] - 1) then
		  if p2 >= data["x"] and p2 <= data["x"] + (data["width"] - 1) then
		  action_button(name)
		  test = true
		  end
		end
      end
	end
  end
end

--Print screen
function print_screen()
  term.setBackgroundColor(b_color)
  term.clear()
  print_text()
  print_link()
  print_button()
  print_input()
  print_header()
end


----------------------------------------
-- Initialize GUI
----------------------------------------
check_config()




