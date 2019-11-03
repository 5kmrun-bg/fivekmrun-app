import { Component, OnInit } from "@angular/core";
import { NavigationEnd, Router } from "@angular/router";
import * as firebase from "nativescript-plugin-firebase";
import { Observable } from "rxjs";
import { filter } from "rxjs/operators";
import { User } from "./models";
import { UserService } from "./services";
import { HttpLoaderService } from "./services/http-loader.service";

@Component({
    selector: "ns-app",
    templateUrl: "app.component.html"
})
export class AppComponent implements OnInit {
    currentUser$: Observable<User>;

    private _activatedUrl: string;

    constructor(
        private router: Router,
        private userService: UserService,
        public loaderService: HttpLoaderService) {
    }

    ngOnInit(): void {
        this._activatedUrl = "/home";

        this.currentUser$ = this.userService.getCurrentUser();

        this.router.events
        .pipe(filter((event: any) => event instanceof NavigationEnd))
        .subscribe((event: NavigationEnd) => {
            this._activatedUrl = event.urlAfterRedirects;
            firebase.analytics.logEvent({
                key: "page_view",
                parameters: [
                    {
                        key: "page_id",
                        value: this._activatedUrl
                    }
                ]
            });
        });

        this.userService.userChanged.subscribe(() => {
            this.currentUser$ = this.userService.getCurrentUser();
        });

        firebase.init({
            showNotifications: true,
            showNotificationsWhenInForeground: true,
            onPushTokenReceivedCallback: function(token) {
              console.log("[Firebase] onPushTokenReceivedCallback: " + token);
            },
            onMessageReceivedCallback: function(message) {
                console.log("Title: " + message.title);
                console.log("Body: " + message.body);
                // if your server passed a custom property called 'foo', then do this:
                console.log("Value of 'foo': " + message.data.foo);
              }
          }).then(
            (instance) => {
              console.log("firebase.init done");
            }).catch(
            (error) => {
              console.log(`firebase.init error: ${error}`);
            }
          );
        
          firebase.subscribeToTopic("news").then(() => console.log("Subscribed to topic"));
    }
}
