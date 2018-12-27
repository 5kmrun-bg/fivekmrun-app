import { Component, OnInit, ViewChild } from "@angular/core";
import { EventService } from "../services";
import { Event } from "../models";
import { Observable } from "rxjs/Observable";

@Component({
    selector: "FutureEvents",
    moduleId: module.id,
    templateUrl: "./future-events.component.html"
})
export class FutureEventsComponent implements OnInit {

    events$: Observable<Event[]>;

    constructor(private eventService: EventService) {}

    ngOnInit(): void {
        this.events$ = this.eventService.getAllFutureEvents();
    }
}
