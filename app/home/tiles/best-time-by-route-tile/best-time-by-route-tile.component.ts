import { Component, OnInit } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { StatisticsService } from "../../../services";

@Component({ 
    selector: "best-time-by-route-tile",
    moduleId: module.id,
    templateUrl: "./best-time-by-route-tile.component.html"
})
export class BestTimeByRouteComponent implements OnInit {

    citiesBestTimesSource$: Observable<{City, BestTime}[]>;

    constructor(private statisticsService: StatisticsService) {
    }

    ngOnInit(): void {
        this.citiesBestTimesSource$ = this.statisticsService.getBestTimesByCity();
    }
}