import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-telerik-ui/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-telerik-ui/sidedrawer/angular";
import { RunService } from "../../services";
import { Run } from "../../models";
import { Observable } from "rxjs/Observable";

@Component({
    selector: "RunsDetails",
    moduleId: module.id,
    templateUrl: "./run-details.component.html"
})
export class RunDetailsComponent implements OnInit {
    constructor(private runService: RunService) {}

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
    }
}
