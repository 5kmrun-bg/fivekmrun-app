import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-ui-sidedrawer";
import { RadSideDrawerComponent } from "nativescript-ui-sidedrawer/angular";
import { UserService, RunService } from "../services";
import { User, Run } from "../models";
import { Observable } from "rxjs/Observable";
import { Ratings } from "nativescript-ratings";

@Component({
    selector: "Home",
    moduleId: module.id,
    templateUrl: "./home.component.html"
})
export class HomeComponent implements OnInit {
    /* ***********************************************************
    * Use the @ViewChild decorator to get a reference to the drawer component.
    * It is used in the "onDrawerButtonTap" function below to manipulate the drawer.
    *************************************************************/
    @ViewChild("drawer") drawerComponent: RadSideDrawerComponent;

    private _sideDrawerTransition: DrawerTransitionBase;
    currentUser$: Observable<User>;
    lastRun$: Observable<Run>;
    bestRun$: Observable<Run>;
    runs$: Observable<Run[]>;
    constructor(private userService: UserService, private runService: RunService) { }

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
        this._sideDrawerTransition = new SlideInOnTopTransition();
        this.currentUser$ = this.userService.getCurrentUser();

        const that = this;
        this.lastRun$ = this.runService.getByCurrentUser().map(runs => runs.sort((a, b) => { return 0 - (that.getTime(a.date) - that.getTime(b.date));})[0]);
        this.bestRun$ = this.runService.getByCurrentUser().map(runs => runs.sort((a, b) => { return a.time.localeCompare(b.time);})[0]);
        this.runs$ = this.runService.getByCurrentUser().map(runs => runs.reverse());

        this.initializeRatingPlugin();
    }

    get sideDrawerTransition(): DrawerTransitionBase {
        return this._sideDrawerTransition;
    }

    /* ***********************************************************
    * According to guidelines, if you have a drawer on your page, you should always
    * have a button that opens it. Use the showDrawer() function to open the app drawer section.
    *************************************************************/
    onDrawerButtonTap(): void {
        this.drawerComponent.sideDrawer.showDrawer();
    }

    private getTime(date?: Date) {
        return date != null ? date.getTime() : 0;
    }

    private initializeRatingPlugin() {
        let ratings = new Ratings({
            id: "bg.5kmpark.5kmrun",
            showOnCount: 5,
            title: "Харесвате ли приложението?",
            text: "Помогнете ни да го направим още по-добро, като оставите вашето мнение",
            agreeButtonText: "Да, разбира се",
            remindButtonText: "Напомни ми по-късно",
            declineButtonText: "Не, благодаря",
            iTunesAppId: "1299888204"
        });

        ratings.init();
        ratings.prompt();
    }
}