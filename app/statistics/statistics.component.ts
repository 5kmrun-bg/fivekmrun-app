import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-telerik-ui-pro/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-telerik-ui-pro/sidedrawer/angular";
import { StatisticsService } from "../services";
import { Observable } from "rxjs/Observable";

@Component({
    selector: "Statistics",
    moduleId: module.id,
    templateUrl: "./statistics.component.html"
})
export class StatisticsComponent implements OnInit {
    /* ***********************************************************
    * Use the @ViewChild decorator to get a reference to the drawer component.
    * It is used in the "onDrawerButtonTap" function below to manipulate the drawer.
    *************************************************************/
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

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
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

    /* ***********************************************************
    * According to guidelines, if you have a drawer on your page, you should always
    * have a button that opens it. Use the showDrawer() function to open the app drawer section.
    *************************************************************/
    onDrawerButtonTap(): void {
        this.drawerComponent.sideDrawer.showDrawer();
    }
}
