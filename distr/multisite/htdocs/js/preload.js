var img = new Array();
function preloadImages() {
	var al = arguments.length
	for(var i=0; i<al; i++) {
		img[i] = new Image;
		img[i].src = arguments[i]
	}
}

