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
	
	for (var i in items) {
		var result = jenkinsTitleRE.exec(items[i].title);
		//console.debug("handleItems: " + items[i].title)
		if (result) {
			if (OKCodes.indexOf(result[2]) == -1) {
				state = "FAIL";
			}
			if ( result[2].localeCompare("?")==0 ) {
				building = true;
				console.debug("handleItems: building")
			}
		}
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
