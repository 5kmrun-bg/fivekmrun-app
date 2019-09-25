import { formatDate } from "@angular/common";
import { Component, Input, OnInit } from "@angular/core";
import { TrackballCustomContentData } from "nativescript-ui-chart";
import { Observable } from "rxjs";
import { tap } from "rxjs/operators";
import { isAndroid } from "tns-core-modules/ui/page/page";
import { Run } from "../../../models";

@Component({
    selector: "run-stats-tile",
    moduleId: module.id,
    templateUrl: "./run-stats-tile.component.html",
})
export class RunStatsTileComponent implements OnInit {
    @Input() runs$: Observable<Run[]>;

    min: number;
    max: number;
    step: number;
    runs: Run[] = [];

    ngOnInit(): void {
        this.runs$.pipe(tap((runsResults) => {
            const times = runsResults.map(r => r.timeInSeconds);
            this.max = Math.ceil(Math.max(...times));
            this.min = Math.floor(Math.min(...times));
            this.step = Math.round((this.max - this.min) / 4);
            // v Items are sorted because of a bug in the Chart component
            this.runs = runsResults.sort((r1, r2) => (r1.date < r2.date) ? -1 : (r1.date > r2.date) ? 1 : 0);
        })).subscribe();

    }

    onTrackBallContentRequested(args: TrackballCustomContentData) {
        const run: Run = args.pointData;
        const date = formatDate(run.date, "dd.MM.yy", "en-US");
        const time = run.time + " мин.";

        if (isAndroid) {
            // Issue with trackball content in Android:
            // https://github.com/NativeScript/nativescript-ui-feedback/issues/1244
            args.content = `${time}`;
        } else {
            args.content = `${date}\n${time}`;
        }
    }
}
