do

function run(msg, matches)
  return "سلام, " .. matches[1]
end

return {
  description = "Says Hello to Someone", 
  usage = "Say Hello to (name)",
  patterns = {
    "^سلام بده به (.*)$",
    "^Say hello to (.*)$"
  }, 
  run = run 
}

end
