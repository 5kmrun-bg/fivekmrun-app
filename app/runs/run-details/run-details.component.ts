import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-telerik-ui-pro/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-telerik-ui-pro/sidedrawer/angular";
import { RunService, UserService } from "../../services";
import { Run } from "../../models";
import { Observable } from "rxjs/Observable";
import { PageRoute } from "nativescript-angular/router";
import "rxjs/add/operator/switchMap";
import {RouterExtensions} from "nativescript-angular/router";

@Component({
    selector: "RunsDetails",
    moduleId: module.id,
    templateUrl: "./run-details.component.html"
})
export class RunDetailsComponent implements OnInit {
    id: string;
    private run: Run;

    constructor(
        private userService: UserService, 
        private runService: RunService, 
        private pageRoute: PageRoute, 
        private routerExtensions: RouterExtensions) {
        this.pageRoute.activatedRoute
                .switchMap(activatedRoute => activatedRoute.params)
                .forEach((params) => { this.id = params["id"]; });

        this.runService.getByCurrentUser()
                        .map(runs => runs.filter(r => r.id == this.id)[0])
                        .do(run$ => this.run = run$)
                        .subscribe();        
    }

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
    }

    onNavBtnTap(): void {
        this.routerExtensions.back();
    }
}
