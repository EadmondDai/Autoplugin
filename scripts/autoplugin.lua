--Init load configs
tai.load()

if not files.exists(tai_ux0_path) and not files.exists(tai_ur0_path) then--Copy defect for config.txt
	files.copy("resources/config/config.txt", "ur0:tai/")
	tai.load()
end

--Backups
tai.sync(__UX0, "ux0:tai/config_backup.txt")
tai.sync(__UR0, "ur0:tai/config_backup.txt")

if back then back:blit(0,0) end
	message_wait(STRING_BACKUP_CONFIGS)
os.delay(1500)

files.mkdir("ux0:CustomBootsplash/")

function img2splashbin(path2img)
	local img = image.load(path2img)
	if img then
		if img:getw() != 960 and img:geth() != 544 then img = img_fixed(img) end
			local data_img = image.data(img)
			if data_img then
				local fp = io.open("ur0:tai/boot_splash.bin","w+")
				if fp then
					fp:write(data_img)
					fp:close()
					os.message(INSTALLP_DESC_BOOTSPLASHDONE)
					return 1
				end
			end
		--else
		--	os.message(INSTALLP_DESC_SPLASHGH)
		--end
	end
	return 0
end

function plugins_installation(sel)

         if plugins[sel].path == "custom_warning.suprx" and ( version == "3.67" or version == "3.68") then os.message(INSTALLP_CWARNING_360_365)
	else

		if files.exists(tai[loc].path) then

			local install = true

			--Checking plugin Batt (only 1 of them)
			if plugins[sel].path == "shellbat.suprx" then
				local idx = tai.find(loc, "main", "shellsecbat.suprx")
				if idx then
					if os.message(INSTALLP_QUESTION_SHELLSECBAT,1) == 1 then
						tai.del(loc, "main", "shellsecbat.suprx")
					else
						install = false
					end
				end
			elseif plugins[sel].path == "shellsecbat.suprx" then
				local idx = tai.find(loc, "main", "shellbat.suprx")
				if idx then
					if os.message(INSTALLP_QUESTION_SHELLBAT,1) == 1 then
						tai.del(loc, "main", "shellbat.suprx")
					else
						install = false
					end
				end
			end

			if install then

				--Install plugin to tai folder
				files.copy(path_plugins..plugins[sel].path, path_tai)

				--Install Extra Plugin
				if plugins[sel].path2 then files.copy(path_plugins..plugins[sel].path2, path_tai) end

				--Install Especial Config for the plugin
				if plugins[sel].config then
					if plugins[sel].config == "custom_warning.txt" then
						local text = osk.init(INSTALLP_OSK_TITLE, INSTALLP_OSK_TEXT)
						if not text or (string.len(text)<=0) then text = "" end--os.nick() end

						files.copy(path_plugins..plugins[sel].config, locations[loc].."tai/")

						local fp = io.open(locations[loc].."tai/"..plugins[sel].config, "wb")
						if fp then
							fp:write(string.char(0xFF)..string.char(0xFE))
							fp:write(os.toucs2(text))
							fp:close()
						end
					else
						if plugins[sel].configpath then
							files.copy(path_plugins..plugins[sel].config, plugins[sel].configpath)
						else
							files.copy(path_plugins..plugins[sel].config, locations[loc].."tai/")
						end
					end
				end

				--Insert plugin to Config
				local pathline_in_config = path_tai..plugins[sel].path

				if plugins[sel].path == "adrenaline_kernel.skprx" then pathline_in_config = "ux0:app/PSPEMUCFW/sce_module/adrenaline_kernel.skprx" end

				local idx = nil

				if plugins[sel].section2 then
					idx = tai.find(loc, plugins[sel].section2, path_tai..plugins[sel].path2)
					if idx then tai.del(loc, plugins[sel].section2, path_tai..plugins[sel].path2) end
					tai.put(loc, plugins[sel].section2, path_tai..plugins[sel].path2)
				end

				idx = tai.find(loc, plugins[sel].section, pathline_in_config)
				if idx then tai.del(loc, plugins[sel].section,  pathline_in_config) end

				tai.put(loc, plugins[sel].section,  pathline_in_config)

				--Write
				tai.sync(loc)

				--Extra
				if plugins[sel].path == "vsh.suprx" then files.delete("ur0:/data:/vsh/")
				elseif plugins[sel].path == "custom_boot_splash.skprx" and not files.exists("ur0:tai/boot_splash.bin") then--Custom Boot Splash
					img2splashbin("resources/boot_splash.png")
				elseif plugins[sel].path == "vitacheat.skprx" and not files.exists("ux0:vitacheat/db/") then--Vitacheat
					files.extract("resources/plugins/vitacheat.zip","ux0:")
                           elseif plugins[sel].path == "AutoBoot.suprx" and not files.exists("ux0:data/AutoBoot/") then--AutoBoot
					files.extract("resources/plugins/AutoBoot.zip","ux0:")
				end

				if back then back:blit(0,0) end
				message_wait(plugins[sel].name.."\n\n"..STRING_INSTALLED)
				os.delay(1500)

				change = true
				buttons.homepopup(0)

			end

		else
			os.message(STRING_MISSING_CONFIG)
		end
	end

end

limit,xscr1,toinstall = 13,5,0
scroll = newScroll(plugins,limit)
function autoplugin()

	--Init load configs
	loc = 1
	tai.load()
	if tai[__UR0].exist then loc = 2 end
	path_tai = locations[loc].."tai/"

	buttons.interval(10,10)
	while true do
		buttons.read()
		if back then back:blit(0,0) end

		screen.print(10,10,INSTALLP_LIST_PLUGINS.."  "..toinstall.."/"..#plugins,1,color.white)

		--Partitions
		local xRoot = 750
		local w = (955-xRoot)/#locations
		for i=1, #locations do
			if loc == i then
				draw.fillrect(xRoot,0,w,30, color.green:a(90))
			end
			screen.print(xRoot+(w/2), 7, locations[i], 1, color.white, color.blue, __ACENTER)
			xRoot += w
		end

		draw.fillrect(0,40,960,350,color.shine:a(25))

		--List of Plugins
		local y = 50
		for i=scroll.ini,scroll.lim do

			if i == scroll.sel then	draw.fillrect(0,y-3,945,24,color.green:a(90)) end

			screen.print(35,y, plugins[i].name, 1.0,color.white,color.blue,__ALEFT)

			if plugins[i].inst then
				screen.print(3,y,"-->",1,color.white,color.green)
			end

			y+=26
		end

		---- Draw Scroll Bar
		local ybar,hbar = 50, (limit*26)-2
		draw.fillrect(950,ybar-2,8,hbar,color.shine)
		if scroll.maxim >= limit then
			local pos_height = math.max(hbar/scroll.maxim, limit)
			--Bar Scroll
			draw.fillrect(950, ybar-2 + ((hbar-pos_height)/(scroll.maxim-1))*(scroll.sel-1), 8, pos_height, color.new(0,255,0))
		end

		if screen.textwidth(plugins[scroll.sel].desc) > 935 then
			xscr1 = screen.print(xscr1, 405, plugins[scroll.sel].desc,1,color.white,color.orange,__SLEFT,935)
		else
			screen.print(480, 405, plugins[scroll.sel].desc,1,color.white,color.orange,__ACENTER)
		end

		screen.print(10,445,STRING_CONFIRM_PLUGIN,1,color.white,color.black,__ALEFT)
		screen.print(10,470,INSTALLP_LR_SWAP,1,color.white,color.black,__ALEFT)
		screen.print(10,495,INSTALLP_CUSTOM_PATH..": "..path_tai,1,color.white,color.black,__ALEFT)

		screen.print(955,445,INSTALLP_SQUARE_MARK,1,color.white,color.black, __ARIGHT)
		screen.print(955,470,INSTALLP_SELECT_CLEAN,1,color.white,color.black, __ARIGHT)

		screen.print(10,522,STRING_BACK,1,color.white,color.black, __ALEFT)
		screen.print(955,522,STRING_START_CLOSE,1,color.white,color.red, __ARIGHT)

		screen.flip()

		--------------------------	Controls	--------------------------
		if buttons.up or buttons.analogly < -60 then scroll:up() xscr1 = 5 end
		if buttons.down or buttons.analogly > 60 then scroll:down() xscr1 = 5 end

		if buttons[cancel] then break end

		--Exit
		if buttons.start then
			if change then
				os.message(STRING_PSVITA_RESTART)
				os.delay(250)
				buttons.homepopup(1)
				power.restart()
			end
			os.exit()
		end

		if buttons.released.l or buttons.released.r then
			if tai[__UX0].exist and tai[__UR0].exist then
				if loc == __UX0 then loc = __UR0 else loc = __UX0 end
			end
		end

		--Install selected plugins
		if buttons[accept] then

			if back then back:blit(0,0) end
				message_wait(STRING_PLEASE_WAIT)
			os.delay(1000)

			if toinstall <= 1 then
				plugins_installation(scroll.sel)
			else
				for i=1, scroll.maxim do
					if plugins[i].inst then
						plugins_installation(i)
					end
				end
				os.delay(50)
			end

			for i=1,scroll.maxim do
				plugins[i].inst = false
				if toinstall >= 1 then toinstall-=1 end
			end

		end

		--Mark/Unmark
		if buttons.square then
			plugins[scroll.sel].inst = not plugins[scroll.sel].inst
			if plugins[scroll.sel].inst then toinstall+=1 else toinstall-=1 end
		end

		--Clean selected
		if buttons.select then
			for i=1,scroll.maxim do
				plugins[i].inst = false
				if toinstall >= 1 then toinstall-=1 end
			end
		end

		--Customize install path for plugins
		if buttons.triangle then
			if folder_tai then
				folder_tai = false
				path_tai = locations[loc].."tai/"
			else
				folder_tai = true
				path_tai = locations[loc].."tai/plugins/"
			end
		end

	end

end
