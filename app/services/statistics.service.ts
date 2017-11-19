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
}