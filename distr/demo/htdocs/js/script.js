function wpopup(url,h,w,features,center,n)
{
	if (center==1)
	{
		ytop=Math.floor((screen.height-h)/2);
		ftop = "top="+ytop;
		left=Math.floor((screen.width-w)/2);
		fleft = "left="+left;
	}
	feat="";
	if (ftop || fleft)
	{
		feat=ftop+","+fleft+",";
	}
	feat+="height="+h+",width="+w;
	feat+=(features!="")?(","+features):"";
	window.open(url,(!n)?"newwin":n,feat);
}

function checkform(f)
{
	var errMSG = "";
		// цикл ниже перебирает все элементы в объекте f, переданном в качестве параметра функции, в данном случае - наша форма.
	for (var i = 0; i<f.elements.length; i++)
	{
		if (null!=f.elements[i].getAttribute("required"))			// если текущий элемент имеет атрибут required т.е. обязательный для заполнения
		{
			if (isEmpty(f.elements[i].value)) // проверяем, заполнен ли он в форме и если он пустой
			{
				errMSG += "  " + f.elements[i].id + "\n";			// формируем сообщение об ошибке, перечисляя  незаполненные поля
				if ("" != errMSG)		//если сообщение об ошибке не пусто, выводим его, и возвращаем false
				{
					alert("Не заполнены обязательные поля:\n" + errMSG);
					return false;
				}
			}
		}
	}
}

function isEmpty(str)
{
	for (var i = 0; i < str.length; i++)
	if (" " != str.charAt(i))
	{
		return false;
	}
	else
	{
		return true;
	}
}

function show(id)
{
	if (document.getElementById('block_'+id).style.display=="")
	{
		document.getElementById('block_'+id).style.display="none";
		document.getElementById('img_'+id).src="img/btn_down.gif";
		setCookie('block_'+id,'close');
	} else {
		document.getElementById('block_'+id).style.display="";
		document.getElementById('img_'+id).src="img/btn_up.gif";
		setCookie('block_'+id,'open');
	}
}

function checkBlock(id)
{
	var open=getCookie('block_'+id);
	if (!open) {
		return;
	}
	if (open=='open') {
		document.getElementById('block_'+id).style.display="";
		document.getElementById('img_'+id).src="img/btn_up.gif";
	} else {
		document.getElementById('block_'+id).style.display="none";
		document.getElementById('img_'+id).src="img/btn_down.gif";
	}
}

function toggle_prop(id) {
	var dd = document.getElementById(id);
	var di = document.getElementById('i'+id)
	if (dd.style.display=='') {
		dd.style.display = 'none';
		if (/select_/.test(di.src)) {
			di.src = '/img/portf/select_off.gif'
		} else {
			di.src = '/img/portf/off.gif'
		}
	} else {
		dd.style.display = ''
		if (/select_/.test(di.src)) {
			di.src = '/img/portf/select_on.gif'
		} else {
			di.src = '/img/portf/on.gif'
		}
	}
}

function select(obj,on) {
	if (on) {
		if (/on\./.test(obj.src)) {
			obj.src = "/img/portf/select_on.gif"
		} else {
			obj.src = "/img/portf/select_off.gif"
		}
	} else {
		if (/on\./.test(obj.src)) {
			obj.src = "/img/portf/on.gif"
		} else {
			obj.src = "/img/portf/off.gif"
		}
	}
}

function CtrlEnter(e) {
	if (!isMozilla) e = event;
	if ((e.ctrlKey) && ((e.keyCode==10)||(e.keyCode==13))) {
		txt = getSel()
		new Ajax.Updater('_ajax',
						 '/pcgi/send_mistype.pl?text='+encodeURIComponent(txt)+'&page='+location.href,
						 {method: 'get', onSuccess: info})
		//this.form.submit();
	}
}

function info() {
	alert('Опечатка отправлена!')
}

document.onkeypress=CtrlEnter;

function getSel() {
	var txt = '';
	var foundIn = '';
	if (window.getSelection) {
		txt = window.getSelection();
	} else if (document.getSelection) {
		txt = document.getSelection();
	} else if (document.selection) {
		txt = document.selection.createRange().text;
	} else return;
	return txt;
}