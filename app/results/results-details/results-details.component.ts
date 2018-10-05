import { Component, OnInit } from "@angular/core";
import { EventService } from "../../services";
import { Event, Result } from "../../models";
import { PageRoute } from "nativescript-angular/router";
import "rxjs/add/operator/switchMap";
import { RouterExtensions } from "nativescript-angular/router";

@Component({
    selector: "ResultsDetails",
    moduleId: module.id,
    templateUrl: "./results-details.component.html"
})
export class ResultsDetailsComponent implements OnInit {
    private id: string;
    event$: Event;
    unfilteredResults: Result[];
    results: Result[];

    constructor(
        private eventService: EventService,
        private pageRoute: PageRoute, 
        private routerExtensions: RouterExtensions) {
        this.pageRoute.activatedRoute
                .switchMap(activatedRoute => activatedRoute.params)
                .forEach((params) => { this.id = params["id"]; });
      
    }

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
        this.eventService.getAllPastEvents()
                .map(events => events.filter(e => e.id == this.id)[0])
                .do(event => this.event$ = event)
                .do(event => this.eventService.getResultsDetails(event.eventDetailsUrl)
                                                .do(r => this.results = this.unfilteredResults = r)
                                                .subscribe())
                .subscribe();
    }

    onNavBtnTap(): void {
        this.routerExtensions.back();
    }

    reFilter(args): void {
        const filterString = args.value.toLowerCase().trim();

        if (filterString.length > 0) {
            this.results = this.unfilteredResults.filter(r => r.name.toLowerCase().includes(filterString));
        }
        else {
            this.results = this.unfilteredResults;
        }
    }
}
