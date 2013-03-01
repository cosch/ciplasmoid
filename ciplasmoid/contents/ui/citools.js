// While a build is in progress the status is reported with a question mark
var OKCodes = ["stable", "back to normal", "?"];

var STATES = {
	  INVALID: { id: -1, name: "", icon: ""},
	  BUILDING: { id: 1, name: "building", icon: "emblem-rabbitvcs-locked"},
	  OK: { id: 2, name: "ok", icon: "weather-clear"},
	  FAIL: { id: 3, name: "failed", icon: "weather-storm"}
	}
	
function handleItems(items) {
	var jenkinsTitleRE = /(.*) #[0-9]+ \((.*)\)/;
	
	var state = "OK";		
	var building = false;
	dialogModel.clear()
	
	for (var i in items) {
		var thisstate= "OK";
		var thisbuild = false;
		var result = jenkinsTitleRE.exec(items[i].title);
		
		console.debug("handleItems: " + items[i].title+":"+items[i].link+":")
		if (result) {
			if (OKCodes.indexOf(result[2]) == -1) {
				state = "FAIL";
				thisstate = state;
			}
			if ( result[2].localeCompare("?")==0 ) {
				building = true;
				thisbuild=building;
			}
		}
		
		s = thisbuild ? "BUILDING" : thisstate 
		console.debug("handleItems: state:"+STATES[s].name)
		dialogModel.append( {"title":items[i].title, "link":items[i].link, "state":STATES[s].name} )
	}
	
	root.state=building ? "BUILDING" : state
}

function setIconName(source) {
	var s = source.split("/");
	var t = "";
	for (var i in s) {		
	  console.debug("s: " + s[i])
	  t = decodeURI(s[i])
	}
	root.name=t;	
}
