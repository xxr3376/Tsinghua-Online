window.CONST =
	url:
		login_net: "http://net.tsinghua.edu.cn/cgi-bin/do_login"
		logout_net: "http://net.tsinghua.edu.cn/cgi-bin/do_logout"
		login_suc: "http://net.tsinghua.edu.cn/succeed.html?"
		login: "http://usereg.tsinghua.edu.cn/do.php",
		online: "http://usereg.tsinghua.edu.cn/online_user_ipv4.php",
		stats: "http://usereg.tsinghua.edu.cn/user_detail_statistics.php"
		check: "http://net.tsinghua.edu.cn/cgi-bin/do_login"
	flag:
		login_ok: 'ok'
	op:
		updateFlow: 'updateFlow'
		updateConnectNumber: 'updateCN'
		dropAllConnect: 'dropAll'
		connectNow: 'CN'
		disconnect: 'disconnect'
	unitConvert:
		'B' : 1
		'K' : Math.pow(2, 10)
		'M' : Math.pow(2, 20)
		'G' : Math.pow(2, 30)
		'T' : Math.pow(2, 40)
	status:
		logged_in: 1
		not_logged_in: 2
		cant_reach_net: 3
		keep_online:1
		manual_connect:0
	timeout:
		IP_EXIST: 25000
		NORMAL: 10000
	code_list:
		username_error: "ÓÃ»§Ãû´íÎó"	
