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
}
	
function handleItems(items) {
	var jenkinsTitleStateRE = /(.*) #[0-9]+ \((.*)\)/;
	var jenkinsTitleNumberRE = /#([0-9]+)/;
	
	var state = "OK";		
	var building = false;
	
	//dialogModel.clear()
	
	for (var i in items) {
		console.debug("handleItems: " + items[i].title)
		
		var thisstate= "OK";
		var thisbuild = false;
		var result = jenkinsTitleStateRE.exec(items[i].title);
		var number = "0"
		var name = ""
		
		// parse status
		if (result) {
			console.debug(" " + result)
			if (OKCodes.indexOf(result[2]) == -1) {
				state = "FAIL";
				thisstate = state;
			}
			if ( result[2].localeCompare("?")==0 ) {
				building = true;
				thisbuild=building;
				//console.debug("building...")
			}
			name = result[1]
			console.debug(" " + name)
		}
		
		// parse buildnumber
		var result = items[i].title.match(jenkinsTitleNumberRE);		
		if (result) {
			console.debug(" " + result[1])
			number = parseInt( result[1] )	
		}
		
		s = thisbuild ? "BUILDING" : thisstate 
		
		index = getListModelIndexByTitle( items[i].title )
		olditem = dialogModel.get(index)
		
		unseen = 0
		if( index >=0 ) {
		  unseen += number-olditem.number;
		  unseen += olditem.unseen
		}
		console.debug(" =" + unseen)
		
		newitem = {"title":name, "link":items[i].link, "state": STATES[s].name, "number": number, "unseen": unseen}		
		
		if( index >= 0) {
		  dialogModel.set(index,newitem)
		}
		else {
		  dialogModel.append( newitem )
		}
	}

	root.state=building ? "BUILDING" : state
}

function setName(source) {
	var s = source.split("/");
	var t = "";
	for (var i in s) {		
	  //console.debug("s: " + s[i])
	  t = decodeURI(s[i])
	}
	root.name=t;	
}
