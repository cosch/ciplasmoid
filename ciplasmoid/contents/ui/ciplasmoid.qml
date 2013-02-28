import Qt 4.7
import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
//import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import "citools.js" as CITools

Item {
	id: root
	
	property string state: "INVALID"

	property string name: "name	"
	
	property int minimumWidth: childrenRect.width
	property int minimumHeight: childrenRect.height
	
	PlasmaWidgets.IconWidget {
		id: icon
		onClicked: Qt.openUrlExternally( plasmoid.readConfig("ciServerUrl") ) 
		minimumIconSize: "16x16"
		maximumIconSize: "128x128"
		preferredIconSize: "32x32"
		Component.onCompleted: setIcon("face-smile")
		anchors.centerIn: parent
	 }
	
	
	Component.onCompleted: {
		plasmoid.addEventListener('ConfigChanged', configChanged)
		root.state=CITools.STATES.BUILDING.id
	}
	
	function updateToolTip() {
		var data = new Object
		data["image"] = getIconName()
		data["mainText"] = root.name+": "+getStateText();
		data["subText"] = plasmoid.readConfig("ciServerUrl")
		plasmoid.popupIconToolTip = data	  
	}
	
	function getIconName() {		
		return CITools.STATES[root.state].icon
	}
	
	function getStateText() {		
		return CITools.STATES[root.state].name
	}
	
	onStateChanged: {
		var iconName =  getIconName()
                plasmoid.setPopupIconByName(iconName)
                icon.setIcon(iconName)
                console.debug("onStateChanged: " + iconName)
		updateToolTip();	
	}
	
	onNameChanged: {
		updateToolTip()
	}	
	
	function configChanged() {
		var source = plasmoid.readConfig("ciServerUrl")
		dataSource.connectedSources = [source + "/rssLatest"]
		CITools.setIconName(source+"")
		console.debug("Source: " + source)
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
