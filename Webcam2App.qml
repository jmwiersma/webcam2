import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import FileIO 1.0

App {
	id: webcam2App

	property url 	tileUrl : "Webcam2Tile.qml"
	property url 	thumbnailIcon: "qrc:/tsc/webcam2.png"
	property 		Webcam2FullScreen webcamFullScreen
	property 		Webcam2ConfigScreen webcamConfigScreen
	property 		Webcam2Tile webcamTile

	property string 	webcamImage1Source
	property string 	webcamImage2Source
	property bool 	webcamImage1Ready: false
	property bool 	webcamImage2Ready: false
	property int 	webcamImage1Z: 100
	property int 	webcamImage2Z: 0
	property int 	pictureCycleCounter: 0
	property int 	pictureCountdownCounterStart: 50
	property int 	pictureCountdownCounter: 100
	property int 	webcamTimer1Interval: 1000
	property bool 	webcamTimer1Running: false
	property variant settings: { 
		"webcamImageURL1" : "http://admin:XXXX@192.168.X.XXX/ISAPI/Streaming/channels/201/picture"
	}

	FileIO {
		id: webcamSettingsFile
		source: "file:///mnt/data/tsc/webcam2.userSettings.json"
 	}

	QtObject {
		id: p
		property url webcamFullScreenUrl : "Webcam2FullScreen.qml"
		property url webcamConfigScreenUrl : "Webcam2ConfigScreen.qml"
	}

	function init() {
		registry.registerWidget("tile", tileUrl, this, "webcamTile", {thumbLabel: qsTr("Webcam2"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", p.webcamFullScreenUrl, this, "webcamFullScreen");
		registry.registerWidget("screen", p.webcamConfigScreenUrl, this, "webcamConfigScreen");
		webcamImage1Source = settings["webcamImageURL1"];
		webcamImage2Source = settings["webcamImageURL1"];
		webcamImage1Z = 0;
		webcamImage2Z = 100;
	}

	function listProperty(item){
    		for (var p in item)
    			console.log(p + ": " + item[p]);
	}

	Component.onCompleted: {

		// read user settings
		try {
			settings = JSON.parse(webcamSettingsFile.read());
		} catch(e) {
		}
		console.log("webcam: listProperty(screenStateController)")
		listProperty(screenStateController)
	}

	function updateWebcamImage1() {
		if (webcamFullScreen.visible && !dimState){
			console.log("webcam: updateWebcamImage1() called")
			switch(pictureCycleCounter) {
			case 0:
				webcamImage2Source = ""
				webcamImage2Source = settings["webcamImageURL1"]
				pictureCycleCounter = pictureCycleCounter + 1
				break
			case 1:
				if (webcamImage2Ready) {
					webcamImage2Z = 100
					webcamImage1Z = 0
					pictureCycleCounter = pictureCycleCounter + 1
					pictureCountdownCounter = pictureCountdownCounter - 1
				}
				break
			case 2:
				webcamImage1Source = ""
				webcamImage1Source = settings["webcamImageURL1"]
				pictureCycleCounter = pictureCycleCounter + 1
				break
			case 3:
				if (webcamImage1Ready) {
					webcamImage1Z = 100
					webcamImage2Z = 0
					pictureCycleCounter = 0
					pictureCountdownCounter = pictureCountdownCounter - 1
				}
				break
			}
		}
	}

	Timer {
		id: webcamTimer1
		interval: webcamTimer1Interval
		triggeredOnStart: true
		running: webcamTimer1Running
		repeat: true
		onTriggered: updateWebcamImage1()
	}
}
