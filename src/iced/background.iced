parser = new DOMParser()

auto_online_interval = CONST.auto_online_intervals.NORMAL
auto_online_event = CONST.status.auto_online_event_end

timeout_function_id = 0
# will convert unit to Byte
unit_convert = (input) ->
	matches = ($.trim input).match /(\d+(.\d+)?)([GMKB])/
	number = parseFloat matches[1]
	unit = matches[3]
	if unit of CONST.unitConvert
		return number * CONST.unitConvert[unit]
	else
		return number

get_err_code = (res) ->
	code = CONST.err_code_list[res]
	return code if code
	return res

auto_online_handle_error = (errMsg) ->
	clearTimeout auto_online_event if auto_online_event
	auto_online_event = CONST.status.auto_online_event_end
	console.log errMsg

auto_online_set_event = () ->
	if auto_online_event == CONST.status.auto_online_event_end
		auto_online_event = setTimeout( () ->
				login_check auto_online_handle_login_status
			auto_online_interval)

auto_online_login_fail = (res) ->
	switch res
		when "ip_exist_error"
			auto_online_interval = CONST.auto_online_intervals.IP_EXIST
			auto_online_set_event()
			break
		else
			auto_online_handle_error get_err_code res

auto_online_login_succ = (res) ->
	console.log res
	auto_online_interval = CONST.auto_online_intervals.NORMAL
	auto_online_set_event()

auto_online_handle_login_status = (data) ->
	auto_online_event = CONST.status.auto_online_event_end
	if data.status == CONST.status.not_logged_in
		login_net_post username,password,auto_online_login_succ,auto_online_login_fail
	else if data.status == CONST.status.logged_in
		auto_online_interval = CONST.auto_online_intervals.NORMAL
		auto_online_set_event()
	else if data.status == CONST.status.cant_reach_net
		auto_online_handle_error "无法连接到校园网"

auto_online_clear = () ->
	clearTimeout auto_online_event if auto_online_event
	console.log auto_online_event
	auto_online_event = CONST.status.auto_online_event_end

process_online_setting_change = (nowStatus) ->
	if nowStatus is CONST.status.auto_online_on
		auto_online_set_event()
	else if nowStatus is CONST.status.auto_online_off and timeout_function_id
		auto_online_clear()

######
# check current login status
# @output: {status: CONST.status.?, username: current_username}
login_check = (callback) ->
	$.post(CONST.url.check, "action=check_online", (response) ->
		console.log response
		matches = response.match /\d+,([^,]+),\d+,\d+,\d+/
		if matches
			callback(
				status: CONST.status.logged_in
				username: matches[1]
			)
		else
			callback(
				status: CONST.status.not_logged_in
			)
	).fail ->
		callback(
			status: CONST.status.cant_reach_net
		)
login_net_post = (username, md5_password, successCallback, failCallback) ->
	$.post(
		CONST.url.login_net
		{
			username: username
			password: md5_password
			drop: 0
			type: 1
			n: 100
		}
		(result) ->
			if /^\d+,/.test result
				successCallback && successCallback result
			else
				failCallback && failCallback result
	)

login_net = (callback) ->
	username = localStorage.getItem 'username', ''
	password = localStorage.getItem 'password', ''
	if not username or not password
		console.log "haven't set token, use setToken first"
	login_net_post username,password,callback,(result) ->
		console.log "failReason " + result

logout_net = (callback) ->
	$.post(
		CONST.url.logout_net
		(res) ->
			callback && callback res
	)

login_usereg = (username, md5_password, successCallback, failCallback) ->
	$.post(
		CONST.url.login
		{
			action: "login"
			user_login_name: username
			user_password: md5_password
		}
		(result) ->
			if result == CONST.flag.login_ok
				successCallback && successCallback()
			else
				failCallback && failCallback result
	)
login_guarantee = (callback) ->
	username = localStorage.getItem 'username', ''
	password = localStorage.getItem 'password', ''
	if not username or not password
		console.log "haven't set token, use setToken first"
	login_usereg username, password, callback, (failReason) ->
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
##########
# do when background.js start
auto_online_switch = localStorage.getItem CONST.storageKey.auto_online
if auto_online is CONST.status.auto_online_on
	auto_online_set_event()
