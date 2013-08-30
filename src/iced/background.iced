parser = new DOMParser()

auto_online_interval = CONST.auto_online_intervals.NORMAL
auto_online_event = CONST.status.auto_online_event_end

# about token

get_token = () ->
	username = localStorage.getItem 'username', null
	password = localStorage.getItem 'password', null
	if not username or not password
		set_error "no_token"
		auto_online_clear()
		throw new Error("no_token")
	return [username, password]

# will convert unit to Byte
unit_convert = (input) ->
	matches = ($.trim input).match /(\d+(.\d+)?)([GMKB])/
	number = parseFloat matches[1]
	unit = matches[3]
	if unit of CONST.unitConvert
		return number * CONST.unitConvert[unit]
	else
		return number
###
# about error
###
lastError = null
set_error = (errorCode) ->
	lastError = null
	chrome.extension.sendMessage(
		op: CONST.op.passErrorCode
		lastError: errorCode
		() ->
			sendError = chrome.runtime.lastError
			# if popup doesn't open
			if sendError
				chrome.browserAction.setBadgeText(
					text: '!'
				)
				lastError = errorCode
	)
clear_error = () ->
	chrome.extension.sendMessage(
		op: CONST.op.removeError
	)
	chrome.browserAction.setBadgeText(
		text: ''
	)
	lastError = null
change_icon = (connectStatus) ->
	file = "/icons/19.png"
	if connectStatus is CONST.status.unconnected
		file = "/icons/disable.png"
	chrome.browserAction.setIcon(
		path: file
	)
###
# error end
###
fatal_error_handler = (err_code) ->
	if err_code in CONST.fatal_error
		auto_online_clear()
		localStorage.setItem CONST.storageKey.auto_online, CONST.status.auto_online_off
	else
		auto_online_set_event CONST.auto_online_intervals.NORMAL


auto_online_set_event = (interval) ->
	if auto_online_event == CONST.status.auto_online_event_end
		auto_online_event = setTimeout( () ->
				login_check auto_online_handle_login_status
			interval)

auto_online_login_fail = (err_code) ->
	set_error(err_code)
	switch err_code
		when "ip_exist_error"
			auto_online_set_event CONST.auto_online_intervals.IP_EXIST
		else
			fatal_error_handler err_code

auto_online_login_succ = (res) ->
	console.log res
	auto_online_set_event CONST.auto_online_intervals.NORMAL

auto_online_handle_login_status = (data) ->
	auto_online_event = CONST.status.auto_online_event_end
	if data.status == CONST.status.not_logged_in
		login_net_post auto_online_login_succ,auto_online_login_fail
	else if data.status == CONST.status.logged_in
		auto_online_set_event CONST.auto_online_intervals.NORMAL
	else if data.status == CONST.status.cant_reach_net
		set_error('no_connection')
		auto_online_set_event CONST.auto_online_intervals.NORMAL

auto_online_clear = () ->
	clearTimeout auto_online_event if auto_online_event
	auto_online_event = CONST.status.auto_online_event_end

process_online_setting_change = (nowStatus) ->
	if nowStatus is CONST.status.auto_online_on
		auto_online_set_event CONST.auto_online_intervals.IMMEDIATELY
	else if nowStatus is CONST.status.auto_online_off
		auto_online_clear()

######
# check current login status
# @output: {status: CONST.status.?, username: current_username}
login_check = (callback) ->
	$.post(CONST.url.check, "action=check_online", (response) ->
		console.log response
		matches = response.match /\d+,([^,]+),\d+,\d+,\d+/
		if matches
			change_icon CONST.status.connected
			clear_error()
			callback && callback(
				status: CONST.status.logged_in
				username: matches[1]
			)
		else
			change_icon CONST.status.unconnected
			callback && callback(
				status: CONST.status.not_logged_in
			)
	).fail ->
		change_icon CONST.status.unconnected
		callback && callback(
			status: CONST.status.cant_reach_net
		)
login_net_post = (successCallback, failCallback) ->
	[username, password] = get_token()
	$.post(
		CONST.url.login_net
		{
			username: username
			password: password
			drop: 0
			type: 1
			n: 100
		}
		(result) ->
			if /^\d+,/.test result
				change_icon CONST.status.connected
				clear_error()
				successCallback && successCallback result
			else
				change_icon CONST.status.unconnected
				failCallback && failCallback result
	)

login_net = (successCallback) ->
	login_net_post(
		successCallback
		(result) ->
			set_error result
	)
logout_net = (callback) ->
	$.post(
		CONST.url.logout_net
		(res) ->
			callback && callback res
			change_icon CONST.status.unconnected
	)

login_usereg = (successCallback, failCallback) ->
	[ username, password] = get_token()
	$.post(
		CONST.url.login
		{
			action: "login"
			user_login_name: username
			user_password: password
		}
		(result) ->
			if result == CONST.flag.login_ok
				successCallback && successCallback()
			else
				failCallback && failCallback result
	)
login_guarantee = (successCallback) ->
	login_usereg successCallback, (failReason) ->
		console.log("登录失败：" + failReason)

drop_user = (userIP,chksum,callback) ->
	console.log "IP:"+userIP+" chksum:"+chksum
	$.post(
		CONST.url.online
		{
			action: "drop"
			user_ip: userIP
			checksum: chksum
		}
		(result) ->
			if result == "ok"
				callback && callback 1
			else
				callback && callback 0
	)

dropall_usereg = (callback) ->
	await online_usereg defer online
	while online.length > 0
		await drop_user online[0][0],online[0][2], defer suc
		await online_usereg defer online
	callback && callback 0

drop = (ip,chksum) ->
	console.log(chksum)
	chksum

online_usereg = (callback) ->
	login_guarantee ()->
		$.get(
			CONST.url.online
			(data)->
				elms = (parser.parseFromString data,"text/html").querySelectorAll "td.maintd"
				count = elms.length/12
				rtn = []
				if count > 1
					rtn = (elms[i*12+j].innerText for j in [2,3] for i in [1..count-1])
					for i in [1..count-1]
						elm = elms[12 * i + 11].children.item(0).outerHTML
						rtn[i-1].push elm.match(/drop\('(.+?)','(.+?)'\)/)[2]
				callback(rtn)
		)
stats_usereg = (callback) ->
	await login_guarantee defer foo
	$.get( CONST.url.stats, (data) ->
			doc = parser.parseFromString data,"text/html"
			elms = doc.querySelectorAll "td.maintd"
			wired_in = unit_convert elms[1].innerText
			wireless_in = unit_convert elms[7].innerText
			callback wired_in + wireless_in
		)

real_time_userreg = (callback) ->
	await
		stats_usereg defer old
		online_usereg defer online
	total = old
	total += (unit_convert online[i][1]) for i in [0..online.length - 1] if online.length > 0
	callback(total)


##############
# interface
chrome.runtime.onMessage.addListener (feeds, sender, sendResponse) ->
	if feeds.op is CONST.op.updateFlow
		real_time_userreg (result) ->
			sendResponse(
				data: result
			)
		return true
	else if feeds.op is CONST.op.updateConnectNumber
		online_usereg (result) ->
			sendResponse(
				data: result.length
			)
		return true
	else if feeds.op is CONST.op.dropAll
		dropall_usereg (result) ->
			sendResponse(
				msg: 'ok'
			)
		return true
	else if feeds.op is CONST.op.connectNow
		login_net()
		return false
	else if feeds.op is CONST.op.disconnect
		process_online_setting_change CONST.status.auto_online_off
		logout_net()
		return false
	else if feeds.op is CONST.op.keepOnlineChange
		process_online_setting_change feeds.now
		return false
	else if feeds.op is CONST.op.getLastError
		if lastError
			sendResponse(
				lastError: lastError
			)
			clear_error()
			return true
		else
			return false
##########
# do when background.js start

login_check()

auto_online_switch = localStorage.getItem CONST.storageKey.auto_online
if auto_online_switch is CONST.status.auto_online_on
	auto_online_set_event CONST.auto_online_intervals.IMMEDIATELY
