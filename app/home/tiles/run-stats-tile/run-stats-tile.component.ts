import { Component, OnInit, Input } from "@angular/core";
import { Run } from "../../../models";
import { Observable } from "rxjs/Observable";

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

    ngOnInit(): void {
        this.runs$.do((runs) => {
            const times = runs.map(r => r.timeInSeconds);
            this.max = Math.ceil(Math.max(...times));
            this.min = Math.floor(Math.min(...times));
            this.step = Math.round((this.max - this.min) / 4);
        }).subscribe();
    }
}