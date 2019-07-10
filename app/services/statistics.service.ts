import { Injectable } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { RunService } from "./run.service";
import { List } from "linqts";
import 'rxjs/add/operator/map';

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
                                    const result = Object.keys(cityRuns).map(k => {return {City: k, BestTime: Math.round(Math.min.apply(null, cityRuns[k]) * 100)/100}});

                                    return result;
                                })
    }

    getRunsTimes() : Observable<{Date, Time}[]> {
        return this.runService.getByCurrentUser()
                                .map(runs => {                                                          // v Items are sorted because of a bug in the Chart component
                                    return runs.map(r => {return {Date: r.date, Time: r.timeInSeconds}}).sort((i1, i2) => {return (i1.Date < i2.Date) ? -1 : (i1.Date > i2.Date) ? 1 : 0});
                                });
    }

    getRunsByMonth() : Observable<{Date, RunsCount}[]> {
        return this.runService
                    .getByCurrentUser()
                    .map(runs => {
                            const groupedRuns = (new List(runs)).GroupBy(r => new Date(r.date.getFullYear(), r.date.getMonth(), 1, 0 ,0 ,0).toString(), r => 1);
                            
                            const runsByMonth = Object.keys(groupedRuns).map(k => {return {Date:  new Date(k), RunsCount: groupedRuns[k].length}});
                                                // v Items are sorted because of a bug in the Chart component
                            return runsByMonth.sort((i1, i2) => {return (i1.Date < i2.Date) ? -1 : (i1.Date > i2.Date) ? 1 : 0});
                        });
    }

    private trimCityName(fullName: string) : string {
        if (fullName.includes("Бургас")) {
            return "Бургас";
        } else if (fullName.includes("Варна")) {
            return "Варна";
        } else if (fullName.includes("Пловдив")) {
            return "Пловдив";
        } else {
            return fullName;
        }
    }
}