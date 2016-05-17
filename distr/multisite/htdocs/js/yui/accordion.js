function Accordion(id) {
  // Speicher das Element der ?bergebenen ID als Akkordion Container
  this.accContainer = document.getElementById(id);
	
  // Alle Elemente mit der CSS-Klasse 'accordionItem' holen
  this.accItems = YAHOO.util.Dom.getElementsByClassName("accordionItem", "div", this.accContainer);
  
  // default Akkordion body H?he definieren
  this.accItemBodyHeight = 0;
  
  // ?ber alle Akkordion Elemente iterieren und jedes einzelne in einem Array speichern
  for (var i=0; i<this.accItems.length; i++) {
    // Aktuelles Akkordion Element als Eltern-Element f?r dazugeh?rigen Header und Body speichern
    this.accItems[i].parent = this;
    // Akkordion Header und Body des aktuellen Akkordion Elements holen und speichern
    this.accItems[i].header = 
      YAHOO.util.Dom.getElementsByClassName("accordionHeader", "div", this.accItems[i])[0];
    this.accItems[i].body = 
      YAHOO.util.Dom.getElementsByClassName("accordionBody", "div", this.accItems[i])[0];
    
    // Pr?fen ob das aktuelle Akkordion Element das aktive Element ist (also eine gr??ere
    // H?he f?r den accordion body gesetzt hat). Normalerweise sollte nur ein Element eine
    // H?he gr??er 0 definiert haben. Wenn die H?he gr??er 0 ist wird das aktuelle Element
    // als aktives Element gespeichert
    if (this.accItems[i].body.offsetHeight > this.accItemBodyHeight) {
      this.accItemBodyHeight = this.accItems[i].body.offsetHeight;
      this.activeItem = this.accItems[i];
      this.activeItem.body.style.height = this.accItemBodyHeight + "px";
    }
    
    // Einen Click Event Listener f?r jeden accordion header registrieren
    YAHOO.util.Event.addListener(this.accItems[i].header, "click", function(){
      // Wenn auf das aktive Element geklickt wurde - nichts machen
      if(this.parent.activeItem == this){
        return;
      }

      // F?r das aktive Element eine "Schrumpf" Animation definieren
      var shrinkLastAccAnim = new YAHOO.util.Anim(this.parent.activeItem.body, {
        height:{from:this.parent.accItemBodyHeight, to:0}}, 0.5);
	    
      // F?r das angeklickte Elment eine "Ausdehnen" Animation definieren
      var expandNewActiveAccAnim = new YAHOO.util.Anim(this.body, {
        height:{from:0, to:this.parent.accItemBodyHeight}}, 0.5);
	    	
      // Selektiertes Element als aktives Element setzen
      expandNewActiveAccAnim.onStart.subscribe(function() {
        this.parent.activeItem = this;
      }, this, true);
	
      // Animation starten
      shrinkLastAccAnim.animate();
      expandNewActiveAccAnim.animate();
    }, this.accItems[i], true);
  }
  
  // Letzte Pr?fung, falls mehrere Elemente eine H?he angegeben haben. Es wird nur das 
  //aktive Element offen gelassen. Alle anderen Akkordion Elemente erhalten die H?he 0px.
  for(var i=0; i<this.accItems.length; i++){
    if(this.activeItem != this.accItems[i]){
      this.accItems[i].body.style.height = 0 + "px";
    }
  }
};