import { Injectable } from "@angular/core";
import { List } from "linqts";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";

import { RunService } from "./run.service";


@Injectable()
export class StatisticsService {

    constructor(private runService: RunService) {
    }

    getRunsByCity(): Observable<{ City: string, RunsCount: number }[]> {
        return this.runService.getByCurrentUser().pipe(
            map(runs => {
                const cityRuns = (new List(runs)).GroupBy(r => r.place, r => 1);
                const result = Object.keys(cityRuns).map(k => ({ City: this.trimCityName(k), RunsCount: cityRuns[k].length }));
                return result;
            })
        );
    }

    getBestTimesByCity(): Observable<{ City: string, BestTime: number }[]> {
        return this.runService.getByCurrentUser().pipe(
            map(runs => {
                const cityRuns = (new List(runs)).GroupBy(r => r.place, r => r.timeInSeconds);
                const result = Object.keys(cityRuns)
                    .map(k => ({ City: this.trimCityName(k), BestTime: Math.min.apply(null, cityRuns[k]) }));

                return result;
            })
        );
    }

    getRunsTimes(): Observable<{ Date: Date, Time: number }[]> {
        return this.runService.getByCurrentUser().pipe(
            map(runs => {
                // v Items are sorted because of a bug in the Chart component
                return runs.map(r => ({ Date: r.date, Time: r.timeInSeconds }))
                    .sort((i1, i2) => (i1.Date < i2.Date) ? -1 : (i1.Date > i2.Date) ? 1 : 0);
            })
        );
    }

    getRunsByMonth(): Observable<{ Date: Date, RunsCount: number }[]> {
        return this.runService.getByCurrentUser().pipe(
            map(runs => {
                const groupedRuns = (new List(runs))
                    .GroupBy(r => new Date(r.date.getFullYear(), r.date.getMonth(), 1, 0, 0, 0).toString(), r => 1);

                const runsByMonth = Object.keys(groupedRuns)
                    .map(k => ({ Date: new Date(k), RunsCount: groupedRuns[k].length }));
                // v Items are sorted because of a bug in the Chart component
                return runsByMonth.sort((i1, i2) => (i1.Date < i2.Date) ? -1 : (i1.Date > i2.Date) ? 1 : 0);
            })
        );
    }

    private trimCityName(fullName: string): string {
        if (fullName.includes("Бургас")) {
            return "Бургас";
        } else if (fullName.includes("Варна")) {
            return "Варна";
        } else if (fullName.includes("Гребен канал 2")) {
            return "Гребен канал 2";
        } else if (fullName.includes("Гребен канал")) {
            return "Гребен канал";
        } else if (fullName.includes("Борисова градина")) {
            return "Борисова градина";
        } else {
            return fullName;
        }
    }
}
