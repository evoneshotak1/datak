do

function run(msg, matches)
send_contact(get_receiver(msg), "+62 889 72891157", "بابا", "جون", ok_cb, true)
end

return {
patterns = {
"^بابا$"

},
run = run
}

end
