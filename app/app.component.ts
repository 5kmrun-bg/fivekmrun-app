import { Component, OnInit, ViewChild } from "@angular/core";
import { NavigationEnd, Router } from "@angular/router";
import * as firebase from "nativescript-plugin-firebase";
import { Observable } from "rxjs/Observable";
import { filter } from "rxjs/operators";
import { User } from "./models";
import { UserService } from "./services";

@Component({
    selector: "ns-app",
    templateUrl: "app.component.html"
})
export class AppComponent implements OnInit {
    currentUser$: Observable<User>;

    private _activatedUrl: string;

    constructor(
        private router: Router,
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

        this.userService.userChanged.subscribe(() => {
            this.currentUser$ = this.userService.getCurrentUser();
        });
    }
}
