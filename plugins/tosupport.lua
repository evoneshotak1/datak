do

function run(msg, matches)
  return " لینک ساپورت بات : \n https://telegram.me/joinchat/ClGL-QOZQ4Tb6gz1-VJ7dA"
  end
return {
  description = "shows support link", 
  usage = "لینک ساپورت : Return supports link",
  patterns = {
    "^لینک ساپورت$",
  },
  run = run
}
end
