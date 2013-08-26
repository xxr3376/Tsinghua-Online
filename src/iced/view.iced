$ () ->
	status = 
		keepConnect: false
	flowDOM = ($ '#flow')
	cNumberDOM = ($ '#connect-number')
	keepConnect_btn = ($ '#keep-connect')
	flow_btn = ($ '#real-flow')
	setFlow = (flowString) ->
		flowDOM.text ('' + flowString).substr(0, 6)
	window.setConnectNumber = (number) ->
		cNumberDOM.text number

	updateFlow = () ->
		($ '#real-flow i').show(100)
		chrome.extension.sendMessage(
			op: CONST.op.updateFlow
			(response) ->
				setFlow response.data
				($ '#real-flow i').hide(1000)
		)
	init = () ->
		keepConnect_btn.on 'click', () ->
			status.keepConnect = !status.keepConnect
			updateGUI()
			window.close()
		flow_btn.on 'click', () ->
			updateFlow()
		($ '#real-flow i').hide()
		updateGUI()
	updateGUI = () ->
		if status.keepConnect
			keepConnect_btn.addClass 'active'
		else
			keepConnect_btn.removeClass 'active'
	init()
