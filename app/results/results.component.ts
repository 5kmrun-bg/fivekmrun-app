import { Component, OnInit, ViewChild } from "@angular/core";
import { EventService } from "../services";
import { Event } from "../models";
import { Observable } from "rxjs/Observable";
import * as app from "application";
import { RadSideDrawer } from "nativescript-ui-sidedrawer";

@Component({
    selector: "Results",
    moduleId: module.id,
    templateUrl: "./results.component.html"
})
export class ResultsComponent implements OnInit {

    events: Observable<Event[]>;

    constructor(private eventService: EventService) {}

    ngOnInit(): void {
        this.events = this.eventService.getAllPastEvents();
    }

    onDrawerButtonTap(): void {
        const sideDrawer = <RadSideDrawer>app.getRootView();
        sideDrawer.showDrawer();
    }
}
