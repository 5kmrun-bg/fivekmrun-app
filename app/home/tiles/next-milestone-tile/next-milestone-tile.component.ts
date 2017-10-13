import { Component, OnInit, Input } from "@angular/core";
import { Run } from "../../../models";
import { Observable } from "rxjs/Observable";

@Component({ 
    selector: "next-milestone-tile",
    moduleId: module.id,
    templateUrl: "./next-milestone-tile.component.html"
})
export class NextMilestoneTileComponent implements OnInit {
    @Input() runs$: Observable<Run[]>;
    nextMilestone: number = 0;
    currentRuns: number = 0;

    ngOnInit(): void {
        this.runs$.do(runs => {
            if (runs.length < 50) {
                this.nextMilestone = 50;
            } else if (runs.length < 100) {
                this.nextMilestone = 100;
            } else if (runs.length < 250) {
                this.nextMilestone = 250;
            } else {
                this.nextMilestone = 500;
            }

            this.currentRuns = runs.length;
        }).subscribe();
    }
}