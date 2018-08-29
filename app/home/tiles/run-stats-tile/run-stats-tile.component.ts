import { Component, OnInit, Input } from "@angular/core";
import { Run } from "../../../models";
import { Observable } from "rxjs/Observable";
import 'rxjs/add/operator/do';

@Component({
    selector: "run-stats-tile",
    moduleId: module.id,
    templateUrl: "./run-stats-tile.component.html"
})
export class RunStatsTileComponent implements OnInit {
    @Input() runs$: Observable<Run[]>;

    min: number;
    max: number;
    step: number;
    runs: Run[] = [];

    ngOnInit(): void {
        this.runs$.do((runsResults) => {
            const times = runsResults.map(r => r.timeInSeconds);
            this.max = Math.ceil(Math.max(...times));
            this.min = Math.floor(Math.min(...times));
            this.step = Math.round((this.max - this.min) / 4);
                                    // v Items are sorted because of a bug in the Chart component
            this.runs = runsResults.sort((r1, r2) => {return (r1.date < r2.date) ? -1 : (r1.date > r2.date) ? 1 : 0});
        }).subscribe();

    }
}