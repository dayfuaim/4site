//if (typeof document.defaultView == 'undefined') document.defaultView = {};
//if (typeof document.defaultView.getComputedStyle == 'undefined') {
//	document.defaultView.getComputedStyle = function(element, pseudoElement) {
//	  return element.currentStyle;
//	}
//}

function wpopup(url,w,h,features,center,n) {
	if (center==1) {
		ytop=Math.floor((getWindowHeight(window)-h)/2);
		ftop = "top="+ytop;
		left=Math.floor((getWindowWidth(window)-w)/2);
		fleft = "left="+left;
	}
	feat="";
	if (ftop || fleft) {
		feat=ftop+","+fleft+",";
	}
	feat+="height="+h+",width="+w;
	feat+=(features!="")?(","+features):"";
	var win = window.open(url,(!n)?"newwin":n,feat);
	return win
}

function showCal(frmName,fldName) {
	wpopup(CGI_REF+'/setdate.pl?elnum='+fldName+'&formname='+frmName,
			300,250,
			'scrollbars=no,resizable=yes',
			1,
			'cal')
}

function showFS() {
	wpopup('',
			300,250,
			'scrollbars=no,resizable=yes',
			1,
			'fs')
}

function checkform(f){
	var errMSG = "";
		// цикл ниже перебирает все элементы в объекте f, переданном в качестве параметра функции, в данном случае - наша форма.
	for (var i = 0; i<f.elements.length; i++) {
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

function isEmpty(str) {
	for (var i = 0; i < str.length; i++) {
		if (" " != str.charAt(i)) {
			return false;
		} else {
			return true;
		}
	}
}

function show(id) {
	if ($('block_'+id).style.display=="") {
		$('block_'+id).style.display="none";
		$('img_'+id).src="img/btn_down.gif";
		setCookie('block_'+id,'close');
	} else {
		$('block_'+id).style.display="";
		$('img_'+id).src="img/btn_up.gif";
		setCookie('block_'+id,'open');
	}
}

function checkBlock(id) {
	var open=getCookie('block_'+id);
	if (!open) {
		return;
	}
	if (open=='open') {
		$('block_'+id).style.display="";
		$('img_'+id).src="img/btn_up.gif";
	} else {
		$('block_'+id).style.display="none";
		$('img_'+id).src="img/btn_down.gif";
	}
}

function layerClose(oid) {
	var l = layer(oid)
	l.disappear()
}

function hiliteTop(obj) {
	if (obj.className=='tmenu') { return }
	obj.className = 'cpic'
	obj.previousSibling.className = 'lpic'
	obj.nextSibling.className = 'rpic'
}

function unliteTop(obj) {
	if (obj.className=='tmenu') { return }
	obj.className = ''
	obj.previousSibling.className = ''
	obj.nextSibling.className = ''
}

function clickTop(obj) {
	if (obj.className=='tmenu') {
		obj.className = 'cpic'
		obj.previousSibling.className = 'lpic'
		obj.nextSibling.className = 'rpic'
	} else {
		obj.className = 'tmenu'
		obj.previousSibling.className = ''
		obj.nextSibling.className = ''
	}
}

function showHideFAV(obj) {
	var d = document;
	var fav = $('_fav')
	if (fav.style.visibility=='visible') {
		fav.style.visibility = 'hidden'
		fav.style.zIndex = -999;
	} else {
		fav.style.visibility = 'visible';
		fav.style.zIndex = 999;
	}
}

function showHideHelp(oid) {
	var d = document;
	var help = $('_help')
	var par = layer('_help');
	var r = par.getAbsoluteLeft();
	var ww = getDocumentWidth();
	var wown = 400;
	var hown = 300;
	par.setLeft(ww - wown);
	par.setWidth(wown)
	par.setHeight(hown)
	if (par.isVisible()) {
		par.hide()
	} else {
		par.show()
	}
}

function b_hilite(obj) {
	if (obj.disabled==true) { return }
	obj.src = obj.src.replace(/1\.gif$/,"2.gif")
}
function b_unlite(obj) {
	if (obj.disabled==true) { return }
	obj.src = obj.src.replace(/2\.gif$/,"1.gif")
}

var toggled = 0;
function toggleSection(id) {
	var d = document;
	var o = $('m'+id);
	var im = $('im'+id);
	var s = im.src
	if (o.style.display=='none') {
		o.style.display = ''
		im.src = s.replace(/close/,'open')
	} else {
		o.style.display = 'none'
		im.src = s.replace(/open/,'close')
	}
}

function addEvent(obj,evt,func) {
	Event.observe(obj,evt,func,false)
/*   if (isIE) {
      obj.attachEvent('on'+evt, func);
   } else {
      obj.addEventListener(evt,func, false);
   }*/
}

function doSubmit(f,w,h) {
	var frm = document.forms[f];
	if (!w) { w = 800 }
	if (!h) { h = 600 }
	var wfb = wpopup('',w,h,'scrollbars=1',1,'wfb');
	wfb.focus();
	frm.submit();
}

function addOption(selObj, sText, sValue) {
	var opt = document.createElement('option');
	var txt = document.createTextNode(sText);
	opt.setAttribute('value', sValue);
	opt.appendChild(txt);
	selObj.appendChild(opt);
	return false;
}

function removeOption(selObj) {
	var opt = selObj.options[selObj.selectedIndex];
	selObj.removeChild(opt);
	return false;
}

function emptySelect(obj) {
	while (obj.lastChild) {
		obj.removeChild(obj.lastChild);
	}
}

function buildSelect(obj,arr) {
	for (var i=0; i<arr.length; i++) {
		addOption(obj,arr[i][0],arr[i][1]);
	}
}

function _showPar(o) {
	var str = '';
	for (var i in o) {
		str += i +": "
		if (typeof o[i] == 'function') {
			if (/^(?:get|is)/.test(i)) {
				str += "'" + o[i]() + "'"
			} else {
				str += "[Method]"
			}
		} else {
			str += o[i]
		}
		str += "\n"
	}
	alert(str)
}

function charCount(x,y,z) {
	var text = x.value;
	var left = (z - text.length);
	if(left < '1') { x.value = text.slice(0, (z - 1)); }
	$(y).innerHTML = left + ' characters';
}
