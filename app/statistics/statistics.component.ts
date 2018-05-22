import { Component, OnInit, ViewChild } from "@angular/core";
import { StatisticsService } from "../services";
import { Observable } from "rxjs/Observable";
import * as app from "application";
import { RadSideDrawer } from "nativescript-ui-sidedrawer";

@Component({
    selector: "Statistics",
    moduleId: module.id,
    templateUrl: "./statistics.component.html"
})
export class StatisticsComponent implements OnInit {

    private citiesParticipationSource$: Observable<{City, RunsCount}[]>;
    private citiesBestTimesSource$: Observable<{City, BestTime}[]>;
    private runsStatistics$: Observable<{Date, Time}[]>;
    private runsStatsMajorStep: string;
    private runsStatsMax: number = 30;
    private runsByMonth$: Observable<{Date, RunsCount}[]>;

    constructor(private statisticsService: StatisticsService) {
    }

    ngOnInit(): void {
        this.citiesParticipationSource$ = this.statisticsService.getRunsByCity();
        this.citiesBestTimesSource$ = this.statisticsService.getBestTimesByCity();
        this.runsStatistics$ = this.statisticsService.getRunsTimes();
        this.runsByMonth$ = this.statisticsService.getRunsByMonth();

        this.runsStatistics$.do(stats => {
            stats = stats.sort(s => s.Date);

            if (stats[0].Date.getFullYear() - stats[stats.length - 1].Date.getFullYear() != 0 ) {
                this.runsStatsMajorStep = "Year";
            } else {
                this.runsStatsMajorStep = "Month";
            }

            this.runsStatsMax = Math.max.apply(null, stats.map(s => s.Time)) + 2;
        }).subscribe();
    }

    onDrawerButtonTap(): void {
        const sideDrawer = <RadSideDrawer>app.getRootView();
        sideDrawer.showDrawer();
    }
}
