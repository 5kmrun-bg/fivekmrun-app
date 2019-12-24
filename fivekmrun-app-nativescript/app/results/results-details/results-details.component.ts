import { Component, OnInit } from "@angular/core";
import { ActivatedRoute } from "@angular/router";
import { RouterExtensions } from "nativescript-angular/router";
import * as firebase from "nativescript-plugin-firebase";
import { map, switchMap, tap } from "rxjs/operators";
import { isIOS } from "tns-core-modules/platform";
import { ItemEventData } from "tns-core-modules/ui/list-view";
import { Event, Result } from "../../models";
import { EventService } from "../../services";

declare var UITableViewCellSelectionStyle;

@Component({
    selector: "ResultsDetails",
    moduleId: module.id,
    templateUrl: "./results-details.component.html"
})
export class ResultsDetailsComponent implements OnInit {
    event$: Event;
    unfilteredResults: Result[];
    results: Result[];
    private id: string;
    private isSearchTracked: boolean = false;

    constructor(
        private eventService: EventService,
        private route: ActivatedRoute,
        private routerExtensions: RouterExtensions) {
        this.route.params.pipe(
            tap((params) => { this.id = params["id"]; })
        ).subscribe();
    }

    ngOnInit(): void {
        // TODO: needs refactoring
        this.eventService.getAllPastEvents().pipe(
            map(events => events.filter(e => e.id == this.id)[0]),
            tap((event: Event) => this.event$ = event),
            tap((event: Event) => this.eventService.getResultsDetails(event.eventDetailsUrl).pipe(
                tap(r => this.results = this.unfilteredResults = r)
            ).subscribe())
        ).subscribe();
    }

    onNavBtnTap(): void {
        this.routerExtensions.back();
    }

    reFilter(args): void {
        if (!this.isSearchTracked) {
            this.isSearchTracked = true;
            firebase.analytics.logEvent({ key: "results_filtered" });
        }

        const filterString = args.value.toLowerCase().trim();

        if (filterString.length > 0) {
            this.results = this.unfilteredResults.filter(r => r.name.toLowerCase().includes(filterString));
        }
        else {
            this.results = this.unfilteredResults;
        }
    }

    onItemLoading(args: ItemEventData) {
        if (isIOS) {
            const iosCell = args.ios;
            iosCell.selectionStyle = UITableViewCellSelectionStyle.None;
        }
    }
}
