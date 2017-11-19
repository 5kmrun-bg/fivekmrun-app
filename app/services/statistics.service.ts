import { Injectable } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { RunService } from "./run.service";
import { Run } from "../models";
import { List } from "linqts";

@Injectable()
export class StatisticsService {

    constructor(private runService: RunService) {
    }

    getRunsByCity() : Observable<{City, RunsCount}[]> {
        return this.runService.getByCurrentUser()
                                .map(runs => {
                                    const cityRuns = (new List(runs)).GroupBy(r => r.place, r => 1);
                                    const result = Object.keys(cityRuns).map(k => { return {City: k, RunsCount: cityRuns[k].length}});
                                    return result;
                                });
    }

    getBestTimesByCity() : Observable<{City, BestTime}[]> {
        return this.runService.getByCurrentUser()
                                .map(runs => {
                                    const cityRuns = (new List(runs)).GroupBy(r => r.place, r => r.timeInSeconds);
                                    const result = Object.keys(cityRuns).map(k => {return {City:k, BestTime: Math.round(Math.min.apply(null, cityRuns[k]) * 100)/100}});

                                    return result;
                                })
    }

    getRunsTimes() : Observable<{Date, Time}[]> {
        return this.runService.getByCurrentUser()
                                .map(runs => {
                                    return runs.map(r => {return {Date: r.date, Time: r.timeInSeconds}});
                                });
    }

    getRunsByMonth() : Observable<{Date, RunsCount}[]> {
        return this.runService.getByCurrentUser()
                                .map(runs => {
                                    const groupedRuns = (new List(runs)).GroupBy(r => new Date(r.date.getFullYear(), r.date.getMonth(), 1, 0 ,0 ,0), r => 1);
                                    const runsByMonth = Object.keys(groupedRuns).map(k => {return {Date: k, RunsCount: groupedRuns[k].length}});

                                    return runsByMonth;
                                })
    }
}