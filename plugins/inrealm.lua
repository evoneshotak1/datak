-- data saved to moderation.json
-- check moderation plugin
do

local function create_group(msg)
        -- superuser and admins only (because sudo are always has privilege)
        if is_sudo(msg) or is_realm(msg) and is_admin(msg) then
                local group_creator = msg.from.print_name
                create_group_chat (group_creator, group_name, ok_cb, false)
                return 'گروه [ '..string.gsub(group_name, '_', ' ')..' ] ساخته شد.'
        end
end

local function create_realm(msg)
        -- superuser and admins only (because sudo are always has privilege)
        if is_sudo(msg) or is_realm(msg) and is_admin(msg) then
                local group_creator = msg.from.print_name
                create_group_chat (group_creator, group_name, ok_cb, false)
                return 'ریلم [ '..string.gsub(group_name, '_', ' ')..' ] ساخته شد.'
        end
end


local function killchat(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user_any(v.id, result.id)     
  end
end

local function killrealm(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local chat_id = "chat#id"..result.id
  local chatname = result.print_name
  for k,v in pairs(result.members) do
    kick_user_any(v.id, result.id)     
  end
end

local function get_group_type(msg)
  local data = load_data(_config.moderation.data)
  if data[tostring(msg.to.id)] then
    if not data[tostring(msg.to.id)]['group_type'] then
     return 'اینجا هیچی نیست.'
    end
     local group_type = data[tostring(msg.to.id)]['group_type']
     return group_type
  else 
     return 'اینجا هیچی نیست.'
  end 
end

local function callbackres(extra, success, result)
--vardump(result)
  local user = result.id
  local name = string.gsub(result.print_name, "_", " ")
  local chat = 'chat#id'..extra.chatid
  send_large_msg(chat, user..'\n'..name)
  return user
end

local function set_description(msg, data, target, about)
    if not is_admin(msg) then
        return "شما توانایی استفاده از این دستور را ندارید!"
    end
    local data_cat = 'description'
        data[tostring(target)][data_cat] = about
        save_data(_config.moderation.data, data)
        return 'توضیحات جدید to:\n'..about
end
 
local function set_rules(msg, data, target)
    if not is_admin(msg) then
        return "شما توانایی استفاده از این دستور را ندارید!"
    end
    local data_cat = 'قوانین'
        data[tostring(target)][data_cat] = rules
        save_data(_config.moderation.data, data)
        return ' قانون جدید:\n'..rules
end
-- lock/unlock group name. bot automatically change group name when locked
local function lock_group_name(msg, data, target)
    if not is_admin(msg) then
        return "شما توانایی استفاده از این دستور را ندارید!"
    end
    local group_name_set = data[tostring(target)]['settings']['set_name']
    local group_name_lock = data[tostring(target)]['settings']['lock_name']
        if group_name_lock == 'yes' then
            return 'قفل اسم گروه دوباره بسته شد'
        else
            data[tostring(target)]['settings']['lock_name'] = 'yes'
                save_data(_config.moderation.data, data)
                rename_chat('chat#id'..target, group_name_set, ok_cb, false)
        return 'قفل اسم گروه بسته شد'
        end
end
 
local function unlock_group_name(msg, data, target)
    if not is_admin(msg) then
        return "شما توانایی این دستور را ندارید!"
    end
    local group_name_set = data[tostring(target)]['settings']['set_name']
    local group_name_lock = data[tostring(target)]['settings']['lock_name']
        if group_name_lock == 'no' then
            return 'قفل اسم گروه دوباره باز شد'
        else
            data[tostring(target)]['settings']['lock_name'] = 'no'
            save_data(_config.moderation.data, data)
        return 'قفل اسم گروه باز شد'
        end
end
--lock/unlock group member. bot automatically kick new added user when locked
local function lock_group_member(msg, data, target)
    if not is_admin(msg) then
        return "شما توانایی استفاده از این دستور را ندارید!"
    end
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
        if group_member_lock == 'yes' then
            return 'قفل اعضا دوباره بسته شد'
        else
            data[tostring(target)]['settings']['lock_member'] = 'yes'
            save_data(_config.moderation.data, data)
        end
        return 'قفل اعضا بسته شد'
end
 
local function unlock_group_member(msg, data, target)
    if not is_admin(msg) then
        return "شما توانایی استفاده از این دستور را ندارید!"
    end
    local group_member_lock = data[tostring(target)]['settings']['lock_member']
        if group_member_lock == 'no' then
            return 'قفل اعضا از قبل باز بوده'
        else
            data[tostring(target)]['settings']['lock_member'] = 'no'
            save_data(_config.moderation.data, data)
        return 'باز شد قفل اعضا'
        end
end
 
--lock/unlock group photo. bot automatically keep group photo when locked
local function lock_group_photo(msg, data, target)
    if not is_admin(msg) then
        return "شما توانایی استفاده از این دستور را ندارید!"
    end
    local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
        if group_photo_lock == 'yes' then
            return 'قفل عکس دوباره فعال شد'
        else
            data[tostring(target)]['settings']['set_photo'] = 'waiting'
            save_data(_config.moderation.data, data)
        end
        return 'عکس جدید رو بفرس'
end
 
local function unlock_group_photo(msg, data, target)
    if not is_admin(msg) then
        return "شما توانایی استفاده از این دستور را ندارید!"
    end
    local group_photo_lock = data[tostring(target)]['settings']['lock_photo']
        if group_photo_lock == 'no' then
            return 'عکس گروه باز بوده است'
        else
            data[tostring(target)]['settings']['lock_photo'] = 'no'
            save_data(_config.moderation.data, data)
        return 'عکس گروه باز شد'
        end
end
 
local function lock_group_flood(msg, data, target)
    if not is_admin(msg) then
        return " شما توانایی این دستور را ندارید!"
    end
    local group_flood_lock = data[tostring(target)]['settings']['flood']
        if group_flood_lock == 'yes' then
            return 'حساسیت گروه دوباره بسته شد'
        else
            data[tostring(target)]['settings']['flood'] = 'yes'
            save_data(_config.moderation.data, data)
        return 'حساسیت گروه بسته شد'
        end
end
 
local function unlock_group_flood(msg, data, target)
    if not is_admin(msg) then
        return "شما توانایی این دستور را ندارید!"
    end
    local group_flood_lock = data[tostring(target)]['settings']['flood']
        if group_flood_lock == 'no' then
            return 'حساسیت گروه دوباره باز شد'
        else
            data[tostring(target)]['settings']['flood'] = 'no'
            save_data(_config.moderation.data, data)
        return 'حساسیت گروه باز شد'
        end
end
-- show group settings
local function show_group_settings(msg, data, target)
    local data = load_data(_config.moderation.data, data)
    if not is_admin(msg) then
        return " شما توانایی این دستور را ندارید!"
    end
    local settings = data[tostring(target)]['settings']
    local text = "تنظیمات گروه:\n قفل گروه اسم : "..settings.lock_name.."\n قفل گروه عکس : "..settings.lock_photo.."\nقفل گروه اعضا : "..settings.lock_member
    return text
end

local function returnids(cb_extra, success, result)
 
        local receiver = cb_extra.receiver
    local chat_id = "chat#id"..result.id
    local chatname = result.print_name
    local text = 'Users in '..string.gsub(chatname,"_"," ")..' ('..result.id..'):'..'\n'..''
    for k,v in pairs(result.members) do
        local username = ""
        text = text .. "- " .. string.gsub(v.print_name,"_"," ") .. "  (" .. v.id .. ") \n"
    end
    send_large_msg(receiver, text)
        local file = io.open("./groups/lists/"..result.id.."memberlist.txt", "w")
        file:write(text)
        file:flush()
        file:close()
end
 
local function returnidsfile(cb_extra, success, result)
    local receiver = cb_extra.receiver
    local chat_id = "chat#id"..result.id
    local chatname = result.print_name
    local text = 'Users in '..string.gsub(chatname,"_"," ")..' ('..result.id..'):'..'\n'..''
    for k,v in pairs(result.members) do
        local username = ""
        text = text .. "- " .. string.gsub(v.print_name,"_"," ") .. "  (" .. v.id .. ") \n"
    end
        local file = io.open("./groups/lists/"..result.id.."memberlist.txt", "w")
        file:write(text)
        file:flush()
        file:close()
        send_document("chat#id"..result.id,"./groups/lists/"..result.id.."memberlist.txt", ok_cb, false)
end
 
local function admin_promote(msg, admin_id)
        if not is_sudo(msg) then
        return "Access denied!"
    end
        local admins = 'ادمین'
        if not data[tostring(admins)] then
                data[tostring(admins)] = {}
                save_data(_config.moderation.data, data)
        end
        if data[tostring(admins)][tostring(admin_id)] then
                return admin_name..' دوباره ادمین شد.'
        end
        data[tostring(admins)][tostring(admin_id)] = admin_id
        save_data(_config.moderation.data, data)
        return admin_id..' ادمین شد.'
end

local function admin_demote(msg, admin_id)
    if not is_sudo(msg) then
        return "Access denied!"
    end
    local data = load_data(_config.moderation.data)
        local admins = 'ادمین'
        if not data[tostring(admins)] then
                data[tostring(admins)] = {}
                save_data(_config.moderation.data, data)
        end
        if not data[tostring(admins)][tostring(admin_id)] then
                return admin_id..' ادمین نبوده.'
        end
        data[tostring(admins)][tostring(admin_id)] = nil
        save_data(_config.moderation.data, data)
        return admin_id..' از ادمینی برکنار شد.'
end
 
local function admin_list(msg)
    local data = load_data(_config.moderation.data)
        local admins = 'ادمین'
        if not data[tostring(admins)] then
        data[tostring(admins)] = {}
        save_data(_config.moderation.data, data)
        end
        local message = 'لیست ادمین:\n'
        for k,v in pairs(data[tostring(admins)]) do
                message = message .. '- (at)' .. v .. ' [' .. k .. '] ' ..'\n'
        end
        return message
end
 
local function groups_list(msg)
    local data = load_data(_config.moderation.data)
        local groups = 'گروه'
        if not data[tostring(groups)] then
                return 'گروه وجود نداره'
        end
        local message = 'لیست گروه:\n'
        for k,v in pairs(data[tostring(groups)]) do
                local settings = data[tostring(v)]['settings']
                for m,n in pairs(settings) do
                        if m == 'set_name' then
                                name = n
                        end
                end
                local group_owner = "No owner"
                if data[tostring(v)]['set_owner'] then
                        group_owner = tostring(data[tostring(v)]['set_owner'])
                end
                local group_link = "No link"
                if data[tostring(v)]['settings']['set_link'] then
			group_link = data[tostring(v)]['settings']['set_link']
		end

                message = message .. '- '.. name .. ' (' .. v .. ') ['..group_owner..'] \n {'..group_link.."}\n"
             
               
        end
        local file = io.open("./groups/lists/groups.txt", "w")
        file:write(message)
        file:flush()
        file:close()
        return message
       
end
local function realms_list(msg)
    local data = load_data(_config.moderation.data)
        local realms = 'ریلم'
        if not data[tostring(realms)] then
                return 'ریلم وجود نداره'
        end
        local message = 'لیست ریلم:\n'
        for k,v in pairs(data[tostring(realms)]) do
                local settings = data[tostring(v)]['settings']
                for m,n in pairs(settings) do
                        if m == 'set_name' then
                                name = n
                        end
                end
                local group_owner = "No owner"
                if data[tostring(v)]['admins_in'] then
                        group_owner = tostring(data[tostring(v)]['admins_in'])
		end
                local group_link = "No link"
                if data[tostring(v)]['settings']['set_link'] then
			group_link = data[tostring(v)]['settings']['set_link']
		end
                message = message .. '- '.. name .. ' (' .. v .. ') ['..group_owner..'] \n {'..group_link.."}\n"
        end
        local file = io.open("./groups/lists/realms.txt", "w")
        file:write(message)
        file:flush()
        file:close()
        return message
end
local function admin_user_promote(receiver, member_username, member_id)
        local data = load_data(_config.moderation.data)
        if not data['admins'] then
                data['admins'] = {}
                save_data(_config.moderation.data, data)
        end
        if data['admins'][tostring(member_id)] then
                return send_large_msg(receiver, member_username..' دوباره ادمین شد.')
        end
        data['admins'][tostring(member_id)] = member_username
        save_data(_config.moderation.data, data)
        return send_large_msg(receiver, '@'..member_username..' ادمین شد.')
end
 
local function admin_user_demote(receiver, member_username, member_id)
    local data = load_data(_config.moderation.data)
        if not data['admins'] then
                data['admins'] = {}
                save_data(_config.moderation.data, data)
        end
        if not data['admins'][tostring(member_id)] then
                return send_large_msg(receiver, member_username..' ادمین نیست.')
        end
        data['admins'][tostring(member_id)] = nil
        save_data(_config.moderation.data, data)
        return send_large_msg(receiver, 'ادمین '..member_username..' برکنار شد.')
end

 
local function username_id(cb_extra, success, result)
   local mod_cmd = cb_extra.mod_cmd
   local receiver = cb_extra.receiver
   local member = cb_extra.member
   local text = 'همچین ایدی @'..member..' تو این گروه نیست.'
   for k,v in pairs(result.members) do
      vusername = v.username
      if vusername == member then
        member_username = member
        member_id = v.id
        if mod_cmd == 'ادد ادمین' then
            return admin_user_promote(receiver, member_username, member_id)
        elseif mod_cmd == 'حذف ادمین' then
            return admin_user_demote(receiver, member_username, member_id)
        end
      end
   end
   send_large_msg(receiver, text)
end

local function set_log_group(msg)
  if not is_admin(msg) then
    return 
  end
  local log_group = data[tostring(groups)][tostring(msg.to.id)]['log_group']
  if log_group == 'yes' then
    return 'لاگ گروه دوباره ساخته شد'
  else
    data[tostring(groups)][tostring(msg.to.id)]['log_group'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'لاگ گروه ساخته شد'
  end
end

local function unset_log_group(msg)
  if not is_admin(msg) then
    return 
  end
  local log_group = data[tostring(groups)][tostring(msg.to.id)]['log_group']
  if log_group == 'no' then
    return 'لاگ گروه دوباره اف شد'
  else
    data[tostring(groups)][tostring(msg.to.id)]['log_group'] = 'no'
    save_data(_config.moderation.data, data)
    return 'لاگ گروه اف شد'
  end
end

local function help()
  local help_text = tostring(_config.help_text_realm)
  return help_text
end

function run(msg, matches)
    --vardump(msg)
   	local name_log = user_print_name(msg.from)
       if matches[1] == 'لاگ' and is_owner(msg) then
		savelog(msg.to.id, " لاگ گروه ساخته شد توسط دارنده")
		send_document("chat#id"..msg.to.id,"./groups/"..msg.to.id.."log.txt", ok_cb, false)
        end

	if matches[1] == 'اعضا' and is_momod(msg) then
		local name = user_print_name(msg.from)
		savelog(msg.to.id, name.." ["..msg.from.id.."] requested member list ")
		local receiver = get_receiver(msg)
		chat_info(receiver, returnidsfile, {receiver=receiver})
	end
	if matches[1] == 'لیست اعضا' and is_momod(msg) then
		local name = user_print_name(msg.from)
		savelog(msg.to.id, name.." ["..msg.from.id.."] requested member list in a file")
		local receiver = get_receiver(msg)
		chat_info(receiver, returnids, {receiver=receiver})
	end

    if matches[1] == 'ساخت گروه' and matches[2] then
        group_name = matches[2]
        group_type = 'گروه'
        return create_group(msg)
    end
    
    if not is_sudo(msg) or not is_admin(msg) and not is_realm(msg) then
		return  --Do nothing
	end

    if matches[1] == 'ساخت ریلم' and matches[2] then
        group_name = matches[2]
        group_type = 'ریلم'
        return create_realm(msg)
    end

    local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
	if matches[2] then if data[tostring(matches[2])] then
		local settings = data[tostring(matches[2])]['settings']
		if matches[1] == 'توضیحات جدید' and matches[2] then
			local target = matches[2]
		    local about = matches[3]
		    return set_description(msg, data, target, about)
		end
		if matches[1] == 'قوانین جدید' then
		    rules = matches[3]
			local target = matches[2]
		    return set_rules(msg, data, target)
		end
		if matches[1] == 'قفل' then --group lock *
			local target = matches[2]
		    if matches[3] == 'نام' then
		        return lock_group_name(msg, data, target)
		    end
		    if matches[3] == 'اعضا' then
		        return lock_group_member(msg, data, target)
		    end
		    if matches[3] == 'عکس' then
		        return lock_group_photo(msg, data, target)
		    end
		    if matches[3] == 'حساسیت' then
		        return lock_group_flood(msg, data, target)
		    end
		end
		if matches[1] == 'باز کردن' then --group unlock *
			local target = matches[2]
		    if matches[3] == 'نام' then
		        return unlock_group_name(msg, data, target)
		    end
		    if matches[3] == 'اعضا' then
		        return unlock_group_member(msg, data, target)
		    end
		    if matches[3] == 'عکس' then
		    	return unlock_group_photo(msg, data, target)
		    end
		    if matches[3] == 'حساسیت' then
		        return unlock_group_flood(msg, data, target)
		    end
		end
		if matches[1] == 'تنظیمات' and data[tostring(matches[2])]['settings'] then
			local target = matches[2]
		    return show_group_settings(msg, data, target)
		end

                if matches[1] == 'نام جدید' and is_realm(msg) then
                    local new_name = string.gsub(matches[2], '_', ' ')
                    data[tostring(msg.to.id)]['settings']['set_name'] = new_name
                    save_data(_config.moderation.data, data)
                    local group_name_set = data[tostring(msg.to.id)]['settings']['set_name']
                    local to_rename = 'chat#id'..msg.to.id
                    rename_chat(to_rename, group_name_set, ok_cb, false)
                    savelog(msg.to.id, " ریلم { "..msg.to.print_name.." }   اسم عوض شد  [ "..new_name.." ] توسط "..name_log.." ["..msg.from.id.."]")
                end
		if matches[1] == 'setgpname' and is_admin(msg) then
		    local new_name = string.gsub(matches[3], '_', ' ')
		    data[tostring(matches[2])]['settings']['set_name'] = new_name
		    save_data(_config.moderation.data, data)
		    local group_name_set = data[tostring(matches[2])]['settings']['set_name']
		    local to_rename = 'chat#id'..matches[2]
		    rename_chat(to_rename, group_name_set, ok_cb, false)
                    savelog(msg.to.id, "گروه { "..msg.to.print_name.." }  اسم عوض شد [ "..new_name.." ] توسط "..name_log.." ["..msg.from.id.."]")
		end

	    end 
        end
    	if matches[1] == 'راهنما' and is_realm(msg) then
      		savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /help")
     		return help()
    	end
              if matches[1] == 'set' then
                if matches[2] == 'loggroup' then
                   savelog(msg.to.id, name_log.." ["..msg.from.id.."] set as log group")
                  return set_log_group(msg)
                end
              end
                if matches[1] == 'گروه' and matches[2] == 'حذف' then
                  if not is_admin(msg) then
                     return nil
                  end
                  if is_realm(msg) then
                     local receiver = 'chat#id'..matches[3]
                     return modrem(msg),
                     print("Closing Group: "..receiver),
                     chat_info(receiver, killchat, {receiver=receiver})
                  else
                     return 'Error: Group '..matches[3]..' not found' 
                    end
                 end
                if matches[1] == 'ریلم' and matches[2] == 'حذف' then
                  if not is_admin(msg) then
                     return nil
                  end
                  if is_realm(msg) then
                     local receiver = 'chat#id'..matches[3]
                     return realmrem(msg),
                     print("Closing realm: "..receiver),
                     chat_info(receiver, killrealm, {receiver=receiver})
                  else
                     return 'Error: Realm '..matches[3]..' not found' 
                    end
                 end
		if matches[1] == 'chat_add_user' then
		    if not msg.service then
		        return "داری با من شوخی میکنی?"
		    end
		    local user = 'user#id'..msg.action.user.id
		    local chat = 'chat#id'..msg.to.id
		    if not is_admin(msg) then
				chat_del_user(chat, user, ok_cb, true)
			end
		end
		if matches[1] == 'ادد ادمین' then
			if string.match(matches[2], '^%d+$') then
				local admin_id = matches[2]
				print("user "..admin_id.."  به جمع ادمینا اضافه شد")
				return admin_promote(msg, admin_id)
			else
			local member = string.gsub(matches[2], "@", "")
				local mod_cmd = "ادد ادمین"
				chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
			end
		end
		if matches[1] == 'حذف ادمین' then
			if string.match(matches[2], '^%d+$') then
				local admin_id = matches[2]
				print("user "..admin_id.." از ادمینی برکنار شد")
				return admin_demote(msg, admin_id)
			else
			local member = string.gsub(matches[2], "@", "")
				local mod_cmd = "حذف ادمین"
				chat_info(receiver, username_id, {mod_cmd= mod_cmd, receiver=receiver, member=member})
			end
		end
		if matches[1] == 'مدل'then
                        local group_type = get_group_type(msg)
			return group_type
		end
		if matches[1] == 'لیست' and matches[2] == 'ادمین' then
			return admin_list(msg)
		end
		if matches[1] == 'لیست' and matches[2] == 'گروه' then
                  if msg.to.type == 'chat' then
			groups_list(msg)
		        send_document("chat#id"..msg.to.id, "./groups/lists/groups.txt", ok_cb, true)	
			return "لیست گروه ساخته شد" --group_list(msg)
                   elseif msg.to.type == 'user' then 
                        groups_list(msg)
		        send_document("user#id"..msg.from.id, "./groups/lists/groups.txt", ok_cb, true)	
			return "لیست گروه ساخته شد" --group_list(msg)
                  end
		end
		if matches[1] == 'لیست' and matches[2] == 'ریلم' then
                  if msg.to.type == 'chat' then
			realms_list(msg)
		        send_document("chat#id"..msg.to.id, "./groups/lists/realms.txt", ok_cb, true)	
			return "لیست ریلم ساخته شد" --realms_list(msg)
                   elseif msg.to.type == 'user' then 
                        realms_list(msg)
		        send_document("user#id"..msg.from.id, "./groups/lists/realms.txt", ok_cb, true)	
			return "لیست ریلم ساخته شد" --realms_list(msg)
                  end
		end
   		 if matches[1] == 'res' and is_momod(msg) then 
      			local cbres_extra = {
        			chatid = msg.to.id
     			}
      			local username = matches[2]
      			local username = username:gsub("@","")
      			savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /res "..username)
      			return res_user(username,  callbackres, cbres_extra)
    end
end



return {
  patterns = {
    "^(ساخت گروه) (.*)$",
    "^(ساخت رلم) (.*)$",
    "^(توضیحات جدید) (%d+) (.*)$",
    "^(قوانین جدید) (%d+) (.*)$",
    "^(نام جدید) (.*)$",
    "^(setgpname) (%d+) (.*)$",
    "^(نام جدید) (%d+) (.*)$",
        "^(قفل) (%d+) (.*)$",
    "^(باز کردن) (%d+) (.*)$",
    "^(تنظیمات) (%d+)$",
        "^(لیست اعضا)$",
        "^(اعضا)$",
        "^(مدل)$",
    "^(گروه) (حذف) (%d+)$",
    "^(رلم) (حذف) (%d+)$",
    "^(ادد ادمین) (.*)$", -- sudoers only
    "^(حذف ادمین) (.*)$", -- sudoers only
    "^(لیست) (.*)$",
        "^(لاگ)$",
        "^(راهنما)$",
        "^!!tgservice (.+)$",
  },
  run = run
}
end


