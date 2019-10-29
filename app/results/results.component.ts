import { Component, OnInit } from "@angular/core";
import { EventService } from "../services";
import { Event } from "../models";
import { Observable } from "rxjs";

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
}