import Qt 4.7
import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import "citools.js" as CITools

Item {
	id: root
	
	property string state: "INVALID"
	property string name: "name"
	property string source: "source"
	
	property int minimumWidth: 32//childrenRect.width
	property int minimumHeight: 32// childrenRect.height
	
	function updateToolTip() {
		var data = new Object
		data["image"] = getIconName()
		data["mainText"] = root.name+": "+getStateText();
		data["subText"] = root.source
		plasmoid.popupIconToolTip = data	  
	}
	
	function getIconName() {		
		return CITools.STATES[root.state].icon
	}
	
	function getStateText() {		
		return CITools.STATES[root.state].name
	}
	
	function toggleDialog() {
		 point = dialog.popupPosition(root)
		 dialog.x= point.x
		 dialog.y= point.y
		 dialog.visible=!dialog.visible
	}
	
	ListModel {
	    id: dialogModel
	    ListElement { title: "title"; link: "link"; state: "state" }
	}
	
	 // The delegate for each section header
	Component {
	    id: dialogHeading
	    
	    Rectangle {
		width: dialog.width
		height: childrenRect.height
		color: "lightsteelblue"
		Text {
		    text: section
		    font.bold: true
		    color: "white"
		}
	    }
	}
	
        PlasmaCore.Dialog {
            id: dialog
            //Set as a Tool window to bypass the taskbar
            windowFlags: Qt.WindowStaysOnTopHint|Qt.Tool
            visible: false
            onVisibleChanged: {
                if(visible) {
		 
		}
	    }
	    
	    mainItem:  ListView {
		width: 250
		height: 250
		id: entryList
		
		//anchors.fill: parent
		//highlightMoveDuration: 300		

		model: dialogModel
		//highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
		focus: true
		clip: true
		
		delegate: Text {
		    text: title
		    color: "white"
		}

		section.property: "state"
		section.criteria: ViewSection.FullString
		section.delegate: dialogHeading
	    }
         }

         PlasmaWidgets.IconWidget {
		id: icon
		onClicked: toggleDialog()//Qt.openUrlExternally( plasmoid.readConfig("ciServerUrl") ) 
		minimumIconSize: "16x16"
		//maximumIconSize: "128x128"
		preferredIconSize: "32x32"
		Component.onCompleted: setIcon("face-smile")
		//anchors.centerIn: parent		
		
	 }
	
	
	Component.onCompleted: {
		plasmoid.addEventListener('ConfigChanged', configChanged)
		root.state=CITools.STATES.BUILDING.id
		plasmoid.setAction("contextOpen", "Open", "internet-web-browser");
		icon.anchors.left = root.left
		icon.anchors.right= root.right
		icon.anchors.top= root.top
		icon.anchors.bottom= root.bottom
		//icon.anchors.centerIn= root
	}
	
	onStateChanged: {
		var iconName =  getIconName()
                plasmoid.setPopupIconByName(iconName)
                icon.setIcon(iconName)
                console.debug("onStateChanged: " + iconName)
		updateToolTip();
		if( root.state== CITool.STATES["BUILDING"]) {
		    dataSource.interval=30*1000
		} else {
		    dataSource.interval=60*1000
		} 
	}
	
	onNameChanged: {
		updateToolTip()
	}	
	
	onSourceChanged: {
		dataSource.connectedSources = [root.source + "/rssLatest"]
		CITools.setIconName(root.source+"")
		console.debug("Source: " + root.source)
	}
	
	function configChanged() {
		root.source = plasmoid.readConfig("ciServerUrl")		
		//root.source = "http://ci:8080/jenkins/view/PC_APPS_3M"
		console.debug("configChanged: " + root.source)
	}
	
	function action_contextOpen() {
		Qt.openUrlExternally( root.source ) 
	}
	
	PlasmaCore.DataSource {
		id: dataSource
		engine: "rss"
		interval: 60 * 1000
		
		onNewData: {
			CITools.handleItems(data["items"])
		}
	}
	
	Timer {
		interval: 1000
		running: true
		repeat: false
		onTriggered: root.configChanged()
	}
}


