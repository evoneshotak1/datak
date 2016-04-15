local function run(msg, matches)
  return [[*datak*
  
  *open sourced*
  
  *https://github.com/DATAKTM/datak*
  
  *Bot-Version : 2*
  
  *channel = @datak_team * ]]
end

return {
  description = "Shows bot info", 
  usage = "info: Shows bot info",
  patterns = {
    "^داتک$",
  }, 
  run = run 
}
end
