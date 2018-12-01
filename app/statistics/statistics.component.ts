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

    citiesParticipationSource$: Observable<{City, RunsCount}[]>;
    citiesBestTimesSource$: Observable<{City, BestTime}[]>;
    runsStatistics$: Observable<{Date, Time}[]>;
    runsStatsMajorStep: string;
    runsStatsMax: number = 30;
    runsByMonth$: Observable<{Date, RunsCount}[]>;
    dataLoaded: boolean = false;

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
            this.dataLoaded = true;
        }).subscribe();
    }

    onDrawerButtonTap(): void {
        const sideDrawer = <RadSideDrawer>app.getRootView();
        sideDrawer.showDrawer();
    }
}
