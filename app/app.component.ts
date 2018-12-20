import { Component, OnInit, ViewChild } from "@angular/core";
import { NavigationEnd, Router } from "@angular/router";
import * as app from "application";
import { RouterExtensions } from "nativescript-angular/router";
import * as firebase from "nativescript-plugin-firebase";
import { DrawerTransitionBase, RadSideDrawer, SlideInOnTopTransition } from "nativescript-ui-sidedrawer";
import { Observable } from "rxjs/Observable";
import { filter } from "rxjs/operators";
import { User } from "./models";
import { UserService } from "./services";
import { isAndroid } from "tns-core-modules/platform/platform";

@Component({
    selector: "ns-app",
    templateUrl: "app.component.html"
})
export class AppComponent implements OnInit {
    currentUser$: Observable<User>;

    private _activatedUrl: string;
    private _sideDrawerTransition: DrawerTransitionBase;
    private _navigationItems: Array<any>;

    constructor(
        private router: Router,
        private routerExtensions: RouterExtensions,
        private userService: UserService) {
    }

    ngOnInit(): void {
        firebase.init({
          }).then(
            (instance) => {
              console.log("firebase.init done");
            },
            (error) => {
              console.log(`firebase.init error: ${error}`);
            }
          );

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

        this.userService.userChanged.subscribe(value => {
            this.currentUser$ = this.userService.getCurrentUser();
        });
    }
}
