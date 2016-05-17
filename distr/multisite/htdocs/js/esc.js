self.focus();
var travel=true
var hotkey=27
if (document.layers)
document.captureEvents(Event.KEYPRESS)

function closeit(e) {
	if (document.layers) {
		if (e.which==hotkey&&travel) window.close();
	} else if (document.all) {
		if (event.keyCode==hotkey) window.close();
	}
}

document.onkeypress=closeit;