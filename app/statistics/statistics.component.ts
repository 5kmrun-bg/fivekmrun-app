import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-pro-ui/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-pro-ui/sidedrawer/angular";
import { StatisticsService } from "../services";
import { Observable } from "rxjs/Observable";

@Component({
    selector: "Statistics",
    moduleId: module.id,
    templateUrl: "./statistics.component.html"
})
export class StatisticsComponent implements OnInit {

    @ViewChild("drawer") drawerComponent: RadSideDrawerComponent;

    private _sideDrawerTransition: DrawerTransitionBase;
    private citiesParticipationSource$: Observable<{City, RunsCount}[]>;
    private citiesBestTimesSource$: Observable<{City, BestTime}[]>;
    private runsStatistics$: Observable<{Date, Time}[]>;
    private runsStatsMajorStep: string;
    private runsStatsMax: number;
    private runsByMonth$: Observable<{Date, RunsCount}[]>;

    constructor(private statisticsService: StatisticsService) {
    }

    ngOnInit(): void {
        this._sideDrawerTransition = new SlideInOnTopTransition();

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

    get sideDrawerTransition(): DrawerTransitionBase {
        return this._sideDrawerTransition;
    }

    onDrawerButtonTap(): void {
        this.drawerComponent.sideDrawer.showDrawer();
    }
}
