import com.streamwork.methods.MethodService;
import com.streamwork.methods.Utilities;

import flash.system.Security;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.events.CloseEvent;
import mx.events.ListEvent;

import mx.collections.ArrayCollection;

private var feedItems:XMLList;
private var items:ArrayCollection;

private var loader:URLLoader;

private var dataObj:Object;
private var _methodService:MethodService;

private var arrayId:String;

private function init():void
{
	var uuid:String = Application.application.parameters.itemUuid;
	
	MethodService.init(APPLICATION_KEY, uuid);
	_methodService = MethodService.getInstance();
	_methodService.registerCallback("initialData", this.handleSetData);
	_methodService.registerCallback("setData", this.handleSetData);
	_methodService.registerErrorCallback(this.processErrors)        
	_methodService.getData("feedURL", "initialData");
	
	validateNow();
	Utilities.adjustSize(String(Application.application.parameters.elementId), "100%", "400");
	Security.allowDomain("*");
}

private function getFeed(inputURL:String): void {
	if (!inputURL) return;
	var rssRequest:URLRequest = new URLRequest(inputURL);
	loader = new URLLoader(rssRequest);
	loader.addEventListener("complete", feedLoaded);
}

private function feedLoaded(evtObj:Event): void {
	hideSettings(null);
		
	var feed:XML = XML(loader.data);
	
	if (feed.namespace("") != undefined) {
		default xml namespace = feed.namespace("");
	}
		
	items = new ArrayCollection();
	
	feedtitle.text = feed.channel.title.toString();
	feeddescr.text = feed.channel.description.toString();
	feeddescr.visible = true;
	
	for each (var item:XML in feed..item) {
		items.addItem({
			pubDate: item.pubDate.toString(),
			title: item.title.toString(),
			description: item.description.toString(),
			link: item.link.toString()
		});
	}
	
	myDataGrid.dataProvider = items;
}

public function processErrors(messageParams:Object) :void {
	showDetails(null);
	descr.text = "An error has occurred: " + messageParams.message;
}

public function handleSetData(messageParams:Object) : void
{
	inputURL.text = messageParams.value;
	
	if (!inputURL.text)
		showSettings(null);
	else 
		getFeed(inputURL.text);
}

private function doSetData():void {
	_methodService.setData("feedURL", inputURL.text, "setData");
	save.enabled = false;
}

protected function openURL(event:ListEvent):void {
	navigateToURL(new URLRequest(items.getItemAt(event.rowIndex).link));
}

protected function showDetails(event:ListEvent):void {
	if (event) {
		detail.title = items.getItemAt(event.rowIndex).title;
		descr.htmlText = items.getItemAt(event.rowIndex).description;
	}
	detail.height = 150;
	detail.visible = true;
}

protected function hideDetails(event:CloseEvent):void {
	detail.height = 0;
	detail.visible = false;
}

protected function showSettings(event:MouseEvent):void {
	feedsettings.visible = true;
	feedsettings.height = 30;
	save.enabled = true;
}

protected function hideSettings(event:MouseEvent):void {
	feedsettings.visible = false;
	feedsettings.height = 0;
}