$ () ->
	no_main_function = false
	###
	# get Error, Do it at first
	###
	chrome.extension.sendMessage(
		op: CONST.op.getLastError
		(response) ->
			errorCode = response.lastError
			show_error errorCode
	)
	chrome.extension.onMessage.addListener (feeds, sender, sendResponse) ->
		if feeds.op is CONST.op.passErrorCode
			errorCode = feeds.lastError
			show_error errorCode
		else if feeds.op is CONST.op.removeError
			($ '#error').hide()
			($ '#main-function').show()
	show_error = (errorCode) ->
		switch errorCode
			when "username_error", "password_error"
				($ '#main-function').hide()
				no_main_function = true
				($ '#wrong-token').show()
			when "no_token"
				($ '#main-function').hide()
				no_main_function = true
				($ '#no-token').show()
			else
				if not no_main_function
					text = (if errorCode of CONST.err_code_list then CONST.err_code_list[errorCode] else errorCode)
					($ '#error-text').text text
					($ '#error').show()
					($ '#main-function').show()

	#####
	# util
	#####
	window.cache =
		prefix: 'cache_'
		assemble: (key, value, vaild, expireTime) ->
			return JSON.stringify(
				key: key
				value: value
				vaild: vaild
				expireTime: expireTime
				lastTime: null
			)
		# expireTime unit is millisecond
		init: (key, expireTime) ->
			localStorage.setItem (this.prefix + key), (assemble key, null, false, expireTime)
		set: (key, value) ->
			old = localStorage.getItem (this.prefix + key), null
			old ?= assemble key, value, true, null
			old.vaild = true
			old.lastTime = (new Date()).getTime()
			localStorage.setItem (this.prefix + key), old
		get: (key, defaultValue) ->
			item = localStorage.getItem (this.prefix + key), null
			if not item or item.vaild isnt true
				return defaultValue
			else
				now = new Date().getTime()
				isExpired = (now - item.lastTime) > expireTime
				if isExpired
					return defaultValue
				return item.value
	# convert unit from Byte to most readable one
	unit2readable = (input) ->
		result = input + 'Byte'
		for unit of CONST.unitConvert
			converted = input / CONST.unitConvert[unit]
			if converted > 1 and converted < 512
				result = ('' + converted).substr(0, 5) + unit
		return result

	switch_auto_connect_setting = () ->
		current = localStorage.getItem CONST.storageKey.auto_online
		next = CONST.status.auto_online_off
		if next is current
			next = CONST.status.auto_online_on
		localStorage.setItem CONST.storageKey.auto_online, next
		chrome.extension.sendMessage(
			op: CONST.op.keepOnlineChange
			now: next
		)

	flowDOM = ($ '#flow')
	cNumberDOM = ($ '#connect-number')

	keepConnect_btn = ($ '#keep-connect-btn')
	flow_btn = ($ '#real-flow-btn')
	connectNumber_btn = ($ '#connect-number-btn')
	setFlow = (flowNumber) ->
		flowDOM.text (unit2readable flowNumber)
	setConnectNumber = (number) ->
		cNumberDOM.text number
	updateFlow = () ->
		($ '#real-flow-btn i').show(100)
		($ '#connect-number-btn i').show(100)
		chrome.extension.sendMessage(
			op: CONST.op.updateFlow
			(response) ->
				setFlow response.data
				setConnectNumber response.online
				($ '#real-flow-btn i').hide(1000)
				($ '#connect-number-btn i').hide(1000)
		)
	dropAll = () ->
		($ '#drop-all-btn i').show(100)
		chrome.extension.sendMessage(
			op: CONST.op.dropAll
			(response) ->
				setConnectNumber 0
				($ '#drop-all-btn i').hide(1000)
		)
	init = () ->
		($ '#no-token, #wrong-token').on 'click', () ->
			window.open 'options.html#0'
		keepConnect_btn.on 'click', () ->
			switch_auto_connect_setting()
			updateGUI()
			window.close()
		flow_btn.on 'click', () ->
			updateFlow()
		connectNumber_btn.on 'click', () ->
			updateFlow()
		($ '#drop-all-btn').on 'click', () ->
			dropAll()
		($ '#options-btn').on 'click', () ->
			window.open 'options.html#0'
		($ '#about-btn').on 'click', () ->
			window.open 'options.html#1'
		($ 'i.icon-refresh.icon-spin').hide()
		($ '#connect-btn').on 'click', () ->
			chrome.extension.sendMessage(
				op:CONST.op.connectNow
			)
		($ '#disconnect-btn').on 'click', () ->
			localStorage.setItem CONST.storageKey.auto_online, CONST.status.auto_online_off
			chrome.extension.sendMessage(
				op:CONST.op.disconnect
			)
			updateGUI()
			window.close()
		updateGUI()
		# now refresh data
		if not no_main_function
			updateFlow()
	updateGUI = () ->
		status = localStorage.getItem CONST.storageKey.auto_online
		if status is CONST.status.auto_online_on
			keepConnect_btn.addClass 'active'
		else if status is CONST.status.auto_online_off
			keepConnect_btn.removeClass 'active'
	init()
