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
        this._sideDrawerTransition = new SlideInOnTopTransition();
        this._navigationItems = [
            {
                title: "Начало",
                name: "home",
                route: "/home",
                icon: "\uf015"
            },
            {
                title: "Новини",
                name: "news",
                route: "/news",
                icon: "\uf1ea"
 
            },
            {
                title: "Твоите Бягания",
                name: "runs",
                route: "/runs",
                icon: "\uf11e"
            },
            {
                title: "Предстоящи Събития",
                name: "future-events",
                route: "/future-events",
                icon: "\uf073"
            },
            {
                title: "Резултати",
                name: "results",
                route: "/results",
                icon: "\uf0cb"
            },
            {
                title: "Статистика",
                name: "statistics",
                route: "/statistics",
                icon: "\uf080"
            },
            {
                title: "Баркод",
                name: "barcode",
                route: "/barcode",
                icon: "\uf02a"
            },
            {
                title: "Изход",
                name: "login",
                route: "/login",
                icon: "\uf08b "
            }
        ];

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

    get sideDrawerTransition(): DrawerTransitionBase {
        return this._sideDrawerTransition;
    }

    isComponentSelected(url: string): boolean {
        return this._activatedUrl === url;
    }

    onNavigationItemTap(navItemRoute: string): void {
        this.routerExtensions.navigate([navItemRoute], {
            transition: {
                name: "fade"
            }
        });

        const sideDrawer = <RadSideDrawer>app.getRootView();
        sideDrawer.closeDrawer();
    }

    get navigationItems(): Array<any> {
        return this._navigationItems;
    }

    isPageSelected(pageTitle: string): boolean {
        return false;
    }
}
