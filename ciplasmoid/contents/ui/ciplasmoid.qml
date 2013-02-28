import Qt 4.7
import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
//import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import "citools.js" as CITools

Item {
	id: root
	property bool allOK: true
	property bool building: true
	
	property int minimumWidth: childrenRect.width
	property int minimumHeight: childrenRect.height
	
	PlasmaWidgets.IconWidget {
		id: icon
		onClicked: Qt.openUrlExternally( plasmoid.readConfig("ciServerUrl") ) 
		minimumIconSize: "16x16"
		maximumIconSize: "128x128"
		preferredIconSize: "32x32"
		Component.onCompleted: setIcon("face-smile")
		text: "foobar"
		//infoText: root.allOK ? "good1" : "fail"
		anchors.centerIn: parent
	 }
	
	
	Component.onCompleted: {
		plasmoid.addEventListener('ConfigChanged', configChanged)

		root.allOK = false
		root.allOK = true
	}
	
	onAllOKChanged: {
		var iconName = root.building ? "weather-windy" : (root.allOK ? "weather-clear" : "weather-storm")
		plasmoid.setPopupIconByName(iconName)
		icon.setIcon(iconName)
		//icon.infoText= root.building ? "building" : (root.allOK ? "good" : "fail")
		console.debug("onAllOKChanged: " + iconName)
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
