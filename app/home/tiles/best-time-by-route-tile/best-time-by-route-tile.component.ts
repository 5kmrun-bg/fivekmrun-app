import { Component, OnInit } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { StatisticsService } from "../../../services";
import { List } from "linqts";

@Component({
    selector: "best-time-by-route-tile",
    moduleId: module.id,
    templateUrl: "./best-time-by-route-tile.component.html"
})
export class BestTimeByRouteComponent implements OnInit {

    citiesBestTimesSource$: Observable<{ City, BestTime }[]>;
    maxBarValue: number;

    constructor(private statisticsService: StatisticsService) {
    }

    ngOnInit(): void {
        this.citiesBestTimesSource$ = this.statisticsService.getBestTimesByCity();
        this.citiesBestTimesSource$.subscribe((bestTimeEntries) => {
            this.maxBarValue = (new List(bestTimeEntries)).Select(e => e.BestTime).Max() * 1.4;
        });
    }
}
