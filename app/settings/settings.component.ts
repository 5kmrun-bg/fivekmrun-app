import { Component, OnInit } from "@angular/core";
import { SettingsService } from "../services";
import { EventData } from "tns-core-modules/data/observable";
import { Switch } from "tns-core-modules/ui/switch/switch";
import * as firebase from "nativescript-plugin-firebase";
import { messaging } from "nativescript-plugin-firebase";

@Component({
    selector: "Settings",
    moduleId: module.id,
    templateUrl: "./settings.component.html"
})
export class SettingsComponent implements OnInit {
    notificationsAllowed: boolean = false;

    constructor(private settingsService: SettingsService) { }

    ngOnInit(): void {
        this.notificationsAllowed = this.settingsService.NotificationsAllowed;
    }

    onCheckedChange(args: EventData) {
        let sw = args.object as Switch;
        this.settingsService.NotificationsAllowed = sw.checked;
        console.log("NOTIFICATIONS ALLOWED: " + this.settingsService.NotificationsAllowed);

        if (this.settingsService.NotificationsAllowed) {
            firebase.registerForPushNotifications({
                showNotifications: true,
                showNotificationsWhenInForeground: true,
                onMessageReceivedCallback: function(message) {
                    console.log("Title: " + message.title);
                    console.log("Body: " + message.body);
                    // if your server passed a custom property called 'foo', then do this:
                    console.log("Value of 'foo': " + message.data.foo);
                  }
                }
            );
            firebase.subscribeToTopic("general").then(() => console.log("Subscribed to topic: general"));
        } else {
            firebase.unsubscribeFromTopic("general").then(() => console.log("Unsubscribe from topic: general"));
            firebase.unregisterForPushNotifications();
        }
     }
}
