package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  ..';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

require("./bot/utils")

VERSION = '2'

-- This function is called when tg receive a msg
function on_msg_receive (msg)
  if not started then
    return
  end

  local receiver = get_receiver(msg)
  print (receiver)

  --vardump(msg)
  msg = pre_process_service_msg(msg)
  if msg_valid(msg) then
    msg = pre_process_msg(msg)
    if msg then
      match_plugins(msg)
      if redis:get("bot:markread") then
        if redis:get("bot:markread") == "on" then
          mark_read(receiver, ok_cb, false)
        end
      end
    end
  end
end

function ok_cb(extra, success, result)
end

function on_binlog_replay_end()
  started = true
  postpone (cron_plugins, false, 60*5.0)

  _config = load_config()

  -- load plugins
  plugins = {}
  load_plugins()
end

function msg_valid(msg)
  -- Don't process outgoing messages
  if msg.out then
    print('\27[36mNot valid: msg from us\27[39m')
    return false
  end

  -- Before bot was started
  if msg.date < now then
    print('\27[36mNot valid: old msg\27[39m')
    return false
  end

  if msg.unread == 0 then
    print('\27[36mNot valid: readed\27[39m')
    return false
  end

  if not msg.to.id then
    print('\27[36mNot valid: To id not provided\27[39m')
    return false
  end

  if not msg.from.id then
    print('\27[36mNot valid: From id not provided\27[39m')
    return false
  end

  if msg.from.id == our_id then
    print('\27[36mNot valid: Msg from our id\27[39m')
    return false
  end

  if msg.to.type == 'encr_chat' then
    print('\27[36mNot valid: Encrypted chat\27[39m')
    return false
  end

  if msg.from.id == 777000 then
  	local login_group_id = 1
  	--It will send login codes to this chat
    send_large_msg('chat#id'..login_group_id, msg.text)
  end

  return true
end

--
function pre_process_service_msg(msg)
   if msg.service then
      local action = msg.action or {type=""}
      -- Double ! to discriminate of normal actions
      msg.text = "!!tgservice " .. action.type

      -- wipe the data to allow the bot to read service messages
      if msg.out then
         msg.out = false
      end
      if msg.from.id == our_id then
         msg.from.id = 0
      end
   end
   return msg
end

-- Apply plugin.pre_process function
function pre_process_msg(msg)
  for name,plugin in pairs(plugins) do
    if plugin.pre_process and msg then
      print('Preprocess', name)
      msg = plugin.pre_process(msg)
    end
  end

  return msg
end

-- Go over enabled plugins patterns.
function match_plugins(msg)
  for name, plugin in pairs(plugins) do
    match_plugin(plugin, name, msg)
  end
end

-- Check if plugin is on _config.disabled_plugin_on_chat table
local function is_plugin_disabled_on_chat(plugin_name, receiver)
  local disabled_chats = _config.disabled_plugin_on_chat
  -- Table exists and chat has disabled plugins
  if disabled_chats and disabled_chats[receiver] then
    -- Checks if plugin is disabled on this chat
    for disabled_plugin,disabled in pairs(disabled_chats[receiver]) do
      if disabled_plugin == plugin_name and disabled then
        local warning = 'Plugin '..disabled_plugin..' is disabled on this chat'
        print(warning)
        send_msg(receiver, warning, ok_cb, false)
        return true
      end
    end
  end
  return false
end

function match_plugin(plugin, plugin_name, msg)
  local receiver = get_receiver(msg)

  -- Go over patterns. If one matches it's enough.
  for k, pattern in pairs(plugin.patterns) do
    local matches = match_pattern(pattern, msg.text)
    if matches then
      print("msg matches: ", pattern)

      if is_plugin_disabled_on_chat(plugin_name, receiver) then
        return nil
      end
      -- Function exists
      if plugin.run then
        -- If plugin is for privileged users only
        if not warns_user_not_allowed(plugin, msg) then
          local result = plugin.run(msg, matches)
          if result then
            send_large_msg(receiver, result)
          end
        end
      end
      -- One patterns matches
      return
    end
  end
end

-- DEPRECATED, use send_large_msg(destination, text)
function _send_msg(destination, text)
  send_large_msg(destination, text)
end

-- Save the content of _config to config.lua
function save_config( )
  serialize_to_file(_config, './data/config.lua')
  print ('saved config into ./data/config.lua')
end

-- Returns the config from config.lua file.
-- If file doesn't exist, create it.
function load_config( )
  local f = io.open('./data/config.lua', "r")
  -- If config.lua doesn't exist
  if not f then
    print ("Created new config file: data/config.lua")
    create_config()
  else
    f:close()
  end
  local config = loadfile ("./data/config.lua")()
  for v,user in pairs(config.sudo_users) do
    print("Allowed user: " .. user)
  end
  return config
end

-- Create a basic config.json file and saves it.
function create_config( )
  -- A simple config with basic plugins and ourselves as privileged user
  config = {
    enabled_plugins = {
    "onservice",
    "inrealm",
    "ingroup",
    "inpm",
    "banhammer",
    "stats",
    "anti_spam",
    "owners",
    "arabic_lock",
    "set",
    "get",
    "broadcast",
    "download_media",
    "invite",
    "all",
    "leave_ban",
    "admin",
    "plugins",
    "qr",
    "map",
    "info",
    "feedback",
    "welcome",
    "Calculator",
    "text",
    "getplug",
    "tosupport",
    "nerkh",
    "tagall",
    "google",
    "Time",
    "tekrar",
    "bego",
    "fada",
    "dad",
    "fosh",
    "salam",
    "antilink",
    "antitag",
    "zaman",
    "invsudo",
    "clash",
    "aparat",
    "azan"
    },
    sudo_users = {(32347781)},--Sudo users
    disabled_channels = {},
    moderation = {data = 'data/moderation.json'},
    about_text = [[datak v1 - Open Source
 
https://github.com/DATAKTM/datak

Our team!
ramtin (@XxnfratxX)
ALI (tnt54)
hafez (@hafez1116hafez)
MohaMMAd(@joker_admin_2)
mohamad2 (@Blackwolf_admin)

Special thanks to:
Amir (@ThisIsamirh)
Arash (@A_HelloWorld)
Shahab (@ThisIsRaDiCaL)
sorblock (@sorblack)

Our channels:
support: @datak_TG_1
]],
    help_text_realm = [[
راهنمای ریلم:

1_ ساختن گروه توسط بات
ساخت گروه اسم

2_ساخت ریلم توسط بات
ساخت ریلم

3_ اسم جدید گروه
نام جدید = تست

4_ توضیحات جدید گروه
توضیحات جدید مثال = این گروه  ووووو

5_ قوانین گروه
قوانین جدید

6_ قفل کردن تنظیمات
قفل = پلاگین مورد نظر

7_ باز کردن تنظیمات
 باز کردن = پلاگین مورد نظر

8_  ایدی های اعضای گروه به صورت فایل
اعضا

9_ ایدی های اعضای گروه به صورت لیست
لیست اعضا

10_ دیدن ریلم بودن یا گروه بودن
مدل

11_ حذف کردن گروه
گروه حذف

12_ حذف کردن ریلم
رلم حذف

13_ اضافه کردن ادمین از طریق کد کاربری یا یوزرنیم
اضافه ادمین

14_ حذف کردن ادمین از طریق کدکاربری یا یوزر نیم
حذف ادمین

15_ لیست_ادمین_گروه_ریلم دیدن لیست اینا 
لیست_ادمین_رلم_گروه

16_ گرفتن لاگ گروه
لاگ

17_ فرستان پیام به کل گروه ها
ارسال همه

18_فرستادن پیام به یک گروه
ارسال گروه

19_تنها مديران ميتوانند ربات ادد کنند.

20_تنها معاونان و مديران ميتوانند 
جزييات مديريتی گروه را تغيير دهند.

]],
    help_text = [[
راهنما :

1_حذف از گروه واسه همیشه با ریپلی یا یوزرنیم
بن

2_دراوردن از حذف همیشگی گروه
ان بن

3_ ایدی های اعضای گروه به صورت فایل
اعضا

4- دیدن مدیر های گروه
مدیر

5_ مدیر کردن کسی با ریپلی یا یوزرنیم
مدیر

6_ حذف مدیر بودن کسی با ریپلی یا یوزرنیم
حذف مدیریت

7_ خارج شدن از گروه
حذفم کن


8_ توضیحات گروه
توضیحات

9_ گذاشتن عکس برای گروه
عکس جدید

10_ گذاشتن اسم جدید برای گروه
نام جدید = مثال = فاز سنگین

11_ قوانین گروه
قوانین

12_ دیدن کد کاربری گروه
ایدی

13_ راهنمای فارسی بات
راهنما

14_ قفل کردن تنظیمات
قفل = پلاگین مورد نظر

15_ باز کردن تنظیمات
 باز کردن = پلاگین مورد نظر

16_گذاشتن قوانین جدید
قوانین جدید

17_ گذاشتن توضیحات جدید
توضیحات جدید

18_گرفتن تتظیمات گروه
تنظیمات

19_ گرفتن لینک جدید گروه
لینک جدید

19_ گرفتن لینک گروه
لینک

20_ گرفتن لینک گروه در پی وی خود
لینک پی وی

21_ دیدن مدیر اصلی گروه
صاحب گروه

22_ مدیر اصلی گروه کردن کسی ریلی یا کد کاربری
دارنده

23_ گذاشتن فلود گروه
حساسیت مثال =5

24_.... دیدن
stats

25_ سیو کردنی متنی در گروه
سیو [text] [value]

26_ گرفتن متن ذخیره شده در گروه
گرفتن

27_ پاک کردن [modlist|rules|about]
پاک کردن 

28_ گرفتن کد کاربری
ایدی = یوزر نیم

29_ گرفتن لاگ گروه
لاگ

30_ لیست بن شده های گروه
لیست بن

31_تنها مديران ميتوانند ربات ادد کنند.

32_تنها معاونان و مديران ميتوانند 
جزييات مديريتی گروه را تغيير دهند.

]]
  }
  serialize_to_file(config, './data/config.lua')
  print('saved config into ./data/config.lua')
end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)

end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

-- Enable plugins in config.json
function load_plugins()
  for k, v in pairs(_config.enabled_plugins) do
    print("Loading plugin", v)

    local ok, err =  pcall(function()
      local t = loadfile("plugins/"..v..'.lua')()
      plugins[v] = t
    end)

    if not ok then
      print('\27[31mError loading plugin '..v..'\27[39m')
      print(tostring(io.popen("lua plugins/"..v..".lua"):read('*all')))
      print('\27[31m'..err..'\27[39m')
    end

  end
end


-- custom add
function load_data(filename)

	local f = io.open(filename)
	if not f then
		return {}
	end
	local s = f:read('*all')
	f:close()
	local data = JSON.decode(s)

	return data

end

function save_data(filename, data)

	local s = JSON.encode(data)
	local f = io.open(filename, 'w')
	f:write(s)
	f:close()

end

-- Call and postpone execution for cron plugins
function cron_plugins()

  for name, plugin in pairs(plugins) do
    -- Only plugins with cron function
    if plugin.cron ~= nil then
      plugin.cron()
    end
  end

  -- Called again in 2 mins
  postpone (cron_plugins, false, 120)
end

-- Start and load values
our_id = 0
now = os.time()
math.randomseed(now)
started = false
