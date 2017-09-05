import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-telerik-ui/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-telerik-ui/sidedrawer/angular";
import { UserService, RunService } from "../services";
import { User, Run } from "../models";
import { Observable } from "rxjs/Observable";

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
    private currentUser$: Observable<User>;
    private lastRun$: Observable<Run>;
    private bestRun$: Observable<Run>;
    private runs$: Observable<Run[]>;
    constructor(private userService: UserService, private runService: RunService) { }

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
        this._sideDrawerTransition = new SlideInOnTopTransition();
        this.currentUser$ = this.userService.getCurrentUser();
        const that = this;
        this.lastRun$ = this.runService.getByCurrentUser().map(runs => runs.sort((a, b) => { return 0 - that.getTime(a.date) - that.getTime(b.date);})[0]);
        this.bestRun$ = this.runService.getByCurrentUser().map(runs => runs.sort((a, b) => { return a.time.localeCompare(b.time);})[0]);
        this.runs$ = this.runService.getByCurrentUser().map(runs => runs.reverse());
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
}