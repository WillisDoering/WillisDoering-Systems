function read()
  local file_in = {}
  local f_config = io.open("components.cfg", "r")
  
  local line = f_config:read()
  repeat
    table.insert(file_in, line)
    line = f_config:read()
  until line == nil
  
  f_config:close()
  return file_in
end

function write(data)
  local f_config = io.open("components.cfg", "w")

  for i=1, #data do
    f_config:write(data[i])
    f_config:write("\n")
  end
  
  f_config:close()
end
