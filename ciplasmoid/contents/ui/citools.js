// While a build is in progress the status is reported with a question mark
var OKCodes = ["stable", "back to normal", "?"];

function handleItems(items) {
	var jenkinsTitleRE = /(.*) #[0-9]+ \((.*)\)/;
	var allOK = true;
	var building = false;
	root.building = false;
	for (var i in items) {
		var result = jenkinsTitleRE.exec(items[i].title);
		//console.debug("handleItems: " + items[i].title)
		if (result) {
			if (OKCodes.indexOf(result[2]) == -1) {
				allOK = false;
			}
			if ( result[2].localeCompare("?")==0 ) {
				building = true;
				console.debug("handleItems: building")
			}
		}
	}
	
	root.allOK = !allOK
	root.allOK = allOK
	root.building = !building
	root.building = building
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