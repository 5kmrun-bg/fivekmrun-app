import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-telerik-ui-pro/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-telerik-ui-pro/sidedrawer/angular";
import { RunService, UserService } from "../../services";
import { Run } from "../../models";
import { Observable } from "rxjs/Observable";
import { PageRoute } from "nativescript-angular/router";
import "rxjs/add/operator/switchMap";

@Component({
    selector: "RunsDetails",
    moduleId: module.id,
    templateUrl: "./run-details.component.html"
})
export class RunDetailsComponent implements OnInit {
    id: string;
    private run: Observable<Run>;

    constructor(private userService: UserService, private runService: RunService, private pageRoute: PageRoute) {
        this.pageRoute.activatedRoute
                .switchMap(activatedRoute => activatedRoute.params)
                .forEach((params) => { this.id = params["id"]; });
        
        this.run = this.runService.getByCurrentUser()
                            .map(runs => runs.filter(r => r.id == this.id)[0]);        
    }

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
    }
}
