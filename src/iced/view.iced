$ () ->
	#####
	# util
	#####
	
	# convert unit from Byte to most readable one
	unit2readable = (input) ->
		result = input + 'Byte'
		for unit of CONST.unitConvert
			converted = input / CONST.unitConvert[unit]
			if converted > 1 and converted < 512
				result = ('' + converted).substr(0, 5) + unit
		return result

	status =
		keepConnect: false
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
		chrome.extension.sendMessage(
			op: CONST.op.updateFlow
			(response) ->
				setFlow response.data
				($ '#real-flow-btn i').hide(1000)
		)
	updateConnectNumber = () ->
		($ '#connect-number-btn i').show(100)
		chrome.extension.sendMessage(
			op: CONST.op.updateConnectNumber
			(response) ->
				setConnectNumber response.data
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
		keepConnect_btn.on 'click', () ->
			status.keepConnect = !status.keepConnect
			updateGUI()
			window.close()
		flow_btn.on 'click', () ->
			updateFlow()
		connectNumber_btn.on 'click', () ->
			updateConnectNumber()
		($ '#drop-all-btn').on 'click', () ->
			dropAll()
		($ '#options-btn').on 'click', () ->
			window.open 'options.html#0'
		($ '#about-btn').on 'click', () ->
			window.open 'options.html#1'
		($ 'i.icon-refresh.icon-spin').hide()
		updateGUI()
		# now refresh data
		updateFlow()
		updateConnectNumber()
	updateGUI = () ->
		if status.keepConnect
			keepConnect_btn.addClass 'active'
		else
			keepConnect_btn.removeClass 'active'
	init()
