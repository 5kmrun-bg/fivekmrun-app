import { Component, OnInit } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { StatisticsService } from "../../../services";

@Component({
    selector: "runs-by-route-tile",
    moduleId: module.id,
    templateUrl: "./runs-by-route.component.html"
})
export class RunsByRouteComponent implements OnInit {
    citiesParticipationSource$: Observable<{City, RunsCount}[]>;

    constructor(private statisticsService: StatisticsService) {
    }
    
    ngOnInit(): void {
        this.citiesParticipationSource$ = this.statisticsService.getRunsByCity();
    }
}