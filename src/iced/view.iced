$ () ->
	status = 
		keepConnect: false
	flowDOM = ($ '#flow')
	cNumberDOM = ($ '#connect-number')
	keepConnect_btn = ($ '#keep-connect')
	window.setFlow = (flowString) ->
		flowDom.text flowString
	window.setConnectNumber = (number) ->
		cNumberDOM.text number
	init = () ->
		keepConnect_btn.on 'click',() ->
			status.keepConnect = !status.keepConnect
			updateGUI()
			window.close()
		updateGUI()
	updateGUI = () ->
		if status.keepConnect
			keepConnect_btn.addClass 'active'
		else
			keepConnect_btn.removeClass 'active'
	init()
