import { Component, OnInit, ViewChild } from "@angular/core";
import { RunService } from "../services";
import { Run } from "../models";
import { Observable } from "rxjs/Observable";
import * as app from "application";
import { RadSideDrawer } from "nativescript-ui-sidedrawer";

@Component({
    selector: "Runs",
    moduleId: module.id,
    templateUrl: "./runs.component.html"
})
export class RunsComponent implements OnInit {

    runs: Observable<Run[]>;

    constructor(private runService: RunService) {}

    ngOnInit(): void {
        this.runs = this.runService.getByCurrentUser();
    }

    onDrawerButtonTap(): void {
        const sideDrawer = <RadSideDrawer>app.getRootView();
        sideDrawer.showDrawer();
    }
}
