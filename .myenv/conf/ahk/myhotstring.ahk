; tag	C	case-sensitive
; tag	*	ending char (e.g. space/period/enter) is not required to trigger the hotstring. 
; tag	?	triggered even when it is inside another word
; From Help FIle:"Hotstrings can never be triggered by keystrokes produced by any AutoHotkey script. This avoids the possibility of an infinite loop where hotstrings trigger each other over and over."
; !!!	ff	all use prefix "ff", reason 1) already used for ffdate, which could used by one hand

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; misc
:*:ffbrstico::BR//Stico
:*:ffip::
(
/sbin/ifconfig | sed -n -e '/inet addr/s/.*inet addr:\([.0-9]*\).*/\1/p'
)
; /sbin/ifconfig | grep -B1 "inet addr" | awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' | awk -F: '{ print $1 ": " $3 }'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; html
:*:ffhtmltpl::
(
<html>
	<head>
		<script type="text/javascript">
			var date = new Date(1330653007092);
			alert(date.getDate());
		</script>
	</head>
	<body>
	</body>
</html>
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; jquery
:*:ffjqptn::
(
$("selector").method(function(){
    
});
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Functional replacement
:*?:ffdate:: 
FormatTime, CurrentDateTime,, yyyy-MM-dd
SendInput %CurrentDateTime%
return
:*?:fftime::
FormatTime, CurrentDateTime,, HH:mm:ss
SendInput %CurrentDateTime%
return
:*?:ffmin::
FormatTime, CurrentDateTime,, HH:mm
SendInput %CurrentDateTime%
return
:*?:fgdate::
FormatTime, CurrentDateTime,, yyyy-MM-dd
SendInput _%CurrentDateTime%
return
:*?:ffdati::
FormatTime, CurrentDateTime,, yyyy-MM-dd_HH-mm-ss
SendInput %CurrentDateTime%
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; mail 
;:*:ffmlrecharge::jiangnan@yy.com; longchao@yy.com; gongzichao@yy.com; yangpeng@yy.com
;:*:ffmlrecharge::jiangnan@yy.com; longchao@yy.com; gongzichao@yy.com; panleiming@yy.com; wangqitao@yy.com; wuhaoqing@yy.com; duanyunfeng@yy.com
:*:ffmlpay::jiangnan@yy.com; duanyunfeng@yy.com; wujiabao@yy.com; wangfei1@yy.com; wuhaoqing@yy.com; xieyuanxi@yy.com; xiaoweiteng@yy.com; wenziheng@yy.com; yinhongliang1@yy.com; wangke@yy.com
:*:ffmlintern::xiaoweiteng@yy.com; wenziheng@yy.com; yinhongliang1@yy.com; wangke@yy.com
:*:ffmyenvinit::curl https://raw.github.com/stico/myenv/master/.myenv/init/myenv.ro.LU.sh | bash

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Deprecated
;::jws::JAX-WS
;::tof::Throttle on Farm
;:C:ws::web service
;::ldaplogin::cn=manager,o=Ericsson,c=de

