var DLEVELS = { 
    DETAILS:{ value: 0},
    DEBUG: { value: 1 },
    INFO: { value: 2},
    NONE: { value: 3}
};

var DLEVEL="DETAILS";

function debugout( level, str ) {
  if( true ) {
      if( DLEVELS[DLEVEL].value<=DLEVELS[level].value )
	console.debug( str )
  }
}

// While a build is in progress the status is reported with a question mark
var OKCodes = ["stable", "back to normal", "?"];

var STATES = {
	  INVALID: { id: -1, name: "", icon: ""},
	  BUILDING: { id: 1, name: "building", icon: "emblem-rabbitvcs-locked"},
	  OK: { id: 2, name: "ok", icon: "weather-clear"},
	  FAIL: { id: 3, name: "failed", icon: "weather-storm"}
	}
	
function getListModelIndexByTitle( title ) {
	for (var i=0; i < dialogModel.count; i++) {
	  if( title.localeCompare(dialogModel.get(i).title)==0 )
	    return i;
	}
	return -1;
}
	
function handleItems(items) {
	var jenkinsTitleStateRE = /(.*) #[0-9]+ \((.*)\)/;
	var jenkinsTitleNumberRE = /#([0-9]+)/;
	
	var state = "OK";		
	var building = false;
	var allunseen=0;
	//dialogModel.clear()
	
	for (var i in items) {
		debugout("INFO", "handleItems: " + items[i].title)
		
		var thisstate= "OK";
		var thisbuild = false;
		var result = jenkinsTitleStateRE.exec(items[i].title);
		var number = 0
		var name = ""
		
		// parse status
		if (result) {
			debugout("DEBUG", " " + result)
			if (OKCodes.indexOf(result[2]) == -1) {
				state = "FAIL";
				thisstate = state;
			}
			if ( result[2].localeCompare("?")==0 ) {
				building = true;
				thisbuild=building;
			}
			name = result[1]
			debugout("DETAILS", " " + name)
		}
		
		// parse buildnumber
		var result = items[i].title.match(jenkinsTitleNumberRE);		
		if (result) {
			debugout("DETAILS", " " + result[1])
			number = parseInt( result[1],10 )	
		}
		
		s = thisbuild ? "BUILDING" : thisstate 
		
		index = getListModelIndexByTitle( name )
		debugout("DETAILS", "   index:" + index)
		olditem = dialogModel.get(index)
		
		myunseen = 0
		if( index >=0 ) {
		  myunseen += number-olditem.number;
		  myunseen += olditem.unseen
		  debugout("DETAILS", "   oldnumber"+olditem.number)
		  debugout("DETAILS", "   newnumber"+number)
		}
		debugout("INFO"," =" + myunseen)
		
		newitem = {"title":name, "link":items[i].link, "state": STATES[s].name, "number": number, "unseen": myunseen}		
		
		if( index >= 0) {
		  dialogModel.set(index,newitem)
		}
		else {
		  dialogModel.append( newitem )
		}
		allunseen +=  myunseen
	}

	root.state=building ? "BUILDING" : state
	root.unseen = parseInt(root.unseen)+allunseen
}

function setName(source) {
	var s = source.split("/");
	var t = "";
	for (var i in s) {		
	  //debugout("s: " + s[i])
	  t = decodeURI(s[i])
	}
	root.name=t;	
}
