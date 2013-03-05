import Qt 4.7
import QtQuick 1.0
import org.kde.plasma.graphicswidgets 0.1 as PlasmaWidgets
import org.kde.plasma.components 0.1 as PlasmaComponents
import org.kde.plasma.core 0.1 as PlasmaCore
import org.kde.plasma.extras 0.1 as PlasmaExtras
import "citools.js" as CITools

Item {
	id: root
	
	property string state: "FAIL"
	property string name: "name"
	property string source: "source"
	property string unseen: "0"
	
	property int minimumWidth: 46//childrenRect.width
	property int minimumHeight: 46// childrenRect.height
	
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
		 h = 400		 
		 if( dialogModel.count <= 10 )
		   h = dialogModel.count*40
		 scrollArea.height = h
		 
		 point = dialog.popupPosition(root)
		 dialog.x= point.x
		 dialog.y= point.y
		 dialog.visible=!dialog.visible
	}
	
	ListModel {
	    id: dialogModel
	    ListElement { title: "title"; link: "link"; jobstate: "state"; number: 23; unseen: 42 }
	}
	
	 // The delegate for each section header
	Component {
	    id: listHeading
	    Rectangle {
	    	width: 0
	    	height: 0
	    }    
	//    Rectangle {
	//	width: dialog.width
	//	height: childrenRect.height
	//	color: "lightgray"
	//	Text {
	//	    text: section
	//	    font.bold: true
	//	    color: "white"
	//	}
	//    }
	}
	
	Component {
             id: listDelegate

             Item {
                 width: parent.width; height: 40

                 Row {
                    Column {
			Item  {
			    width: 32
			    height: 32
		    
			    Image {
				height: 32
				width: 32
			      
				id: itemBtn                          
				source: CITools.STATES[jobstate].file
				MouseArea {
				    anchors.fill: parent;                             

				    onClicked:{
					CITools.debugout("DETAILS"," dialog item clicked:"+ index);
					listView.currentIndex = index;
					root.unseen = (parseInt(root.unseen)-dialogModel.get(index).unseen)
					dialogModel.get(index).unseen=0 
				    }
				}
			    }
			    Text {
				anchors.fill: parent; 
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				text: unseen
				color: "black"
				//visible: (unseen>0)
			    }
			}
                    }
                    Column {
			 id: detailColumn
                         width: listDelegate.width-40; height: 32;
			 Text { text: title; color: "white"; font.pixelSize: detailColumn.height / 3}
                         Row {
			    Column {
			      width: listDelegate.width-80; 
			      Text { text:  number; color: "white"; font.pixelSize: detailColumn.height / 4; horizontalAlignment: Text.AlignHLeft}
			    }
			    Column {
			      width: listDelegate.width-200; 
			      Text { text:  jobstate; color: "white"; font.pixelSize: detailColumn.height / 4; horizontalAlignment: Text.AlignHRight }
			    }
			 }
                    }
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
	    
	    mainItem: PlasmaExtras.ScrollArea {
		id: scrollArea
		width: 250
		height: 250
		ListView {
		    width: parent.width
		    height: parent.height
		    id: listView
		      
		    //anchors.fill: parent
		    //highlightMoveDuration: 300		

		    model: dialogModel
		    //highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
		    focus: true
		    clip: true
		    
		    delegate: listDelegate
		    //Text {
		    //    text: title
		    //    color: "white"
		    //}

		    section.property: "jobstate"
		    section.criteria: ViewSection.FullString
		    section.delegate: listHeading
		    
		}
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
	
	 Item  {
		width: root.width > 64 ? 32 : 24
		height: root.width > 64 ? 32 : 24
		
		Image {        
			id: unseenStar  
			source: "../images/draw-star.png"
			width: root.width > 64 ? 32 : 24
			height: root.width > 64 ? 32 : 24
			visible: false
			MouseArea {
			    anchors.fill: parent;                             

			    onClicked:{
				root.unseen=0
				for (var i=0; i < dialogModel.count; i++) {
				    dialogModel.get(i).unseen=0 
				    return i;
				}
			    }
			}
			Text {
			    anchors.fill: parent; 
			    horizontalAlignment: Text.AlignHCenter
			    verticalAlignment: 	Text.AlignVCenter
			    text: root.unseen
			    color: "red"
			}
		}
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
		dialogModel.clear()
	}
	
	onStateChanged: {
		var iconName =  getIconName()
                plasmoid.setPopupIconByName(iconName)
                icon.setIcon(iconName)
                
		updateToolTip();		
	}
	
	onNameChanged: {
		updateToolTip()
	}	
	
	onUnseenChanged: {
		CITools.debugout("INFO","global Unseen: " + root.unseen)
		unseenStar.visible= ( parseInt(root.unseen,10)>0 )  
	}
	
	onSourceChanged: {
		dataSource.connectedSources = [root.source + "/rssLatest"]
		CITools.setName(root.source+"")
		CITools.debugout("INFO","Source: " + root.source)
	}
	
	function configChanged() {
		root.source = plasmoid.readConfig("ciServerUrl")
		
		if( !CITools.isRelease() ) {
		  root.source = "http://ci:8080/jenkins/view/WIN8_APPS"
		  //root.source = "https://ci.jenkins-ci.org/view/All"
		}
		
		CITools.debugout("DEBUG","configChanged: " + root.source)
	}
	
	function action_contextOpen() {
		Qt.openUrlExternally( root.source ) 
	}
	
	PlasmaCore.DataSource {
		id: dataSource
		engine: "rss"
		interval: 60 * 1000
		
		onNewData: {
			CITools.debugout("INFO","have new data..")
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


