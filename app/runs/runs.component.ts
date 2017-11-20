import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-pro-ui/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-pro-ui/sidedrawer/angular";
import { RunService } from "../services";
import { Run } from "../models";
import { Observable } from "rxjs/Observable";

@Component({
    selector: "Runs",
    moduleId: module.id,
    templateUrl: "./runs.component.html"
})
export class RunsComponent implements OnInit {

    @ViewChild("drawer") drawerComponent: RadSideDrawerComponent;

    private _sideDrawerTransition: DrawerTransitionBase;
    runs: Observable<Run[]>;

    constructor(private runService: RunService) {}

    ngOnInit(): void {
        this._sideDrawerTransition = new SlideInOnTopTransition();
        this.runs = this.runService.getByCurrentUser();
    }

    get sideDrawerTransition(): DrawerTransitionBase {
        return this._sideDrawerTransition;
    }

    onDrawerButtonTap(): void {
        this.drawerComponent.sideDrawer.showDrawer();
    }
}
