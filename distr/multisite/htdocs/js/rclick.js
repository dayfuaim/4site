<script language=JavaScript>
<!--
var message="����������� ���������!";//protect from right-click
function click(mouse) {
	if (document.all) {
		if (event.button==2||event.button==3) {
			alert(message);
			return false;
		}
	}
	if (document.layers) {
		if (mouse.which == 3) {
			alert(message);
			return false;
		}
	}
}
//if (document.layers) {
//	document.captureEvents(Event.MouseDown);//protect from keyboard keypress
//	function keypressed() {
//		alert("�� �� ������ ����������!");
//	}
//}
document.onmousedown=click;
//document.onkeydown=keypressed;// -->
</script>
