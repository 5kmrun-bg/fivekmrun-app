import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";

import { Run, RunDetails } from "../models";
import * as cheerio from "cheerio";

import { UserService } from "../services";

@Injectable()
export class RunService {
    private lastUserId: number;
    private lastRuns: Observable < Run[] > ;

    constructor(private http: Http, private userService: UserService) {}

    getByCurrentUser(): Observable < Run[] > {
        if (this.lastRuns != null && this.lastUserId == this.userService.currentUserId) {
            return this.lastRuns;
        } else {
            console.log("Getting runs ...");
            const that = this;
            this.lastUserId = this.userService.currentUserId;
            return this.lastRuns = this.http.get("http://5km.5kmrun.bg/stat.php?id=" + this.userService.currentUserId).map(response => {
                const runs: Array < Run > = new Array < Run > ();

                const content = response.text();

                const options = {
                    normalizeWhitespace: true,
                    xmlMode: true
                };

                const webPage = cheerio.load(content, options);
                const rows = webPage("table tbody tr");

                rows.each((index, elem) => {
                    const cells = elem.children.filter(c => c.type == "tag" && c.name == "td");
                    if (cells.length == 9) {
                        runs.push(this.extractRun(cells));
                    }
                });

                return runs.sort((a, b) => (a.date < b.date) ? 1 : (a.date > b.date) ? -1 : 0);
            });
        }
    }

    public getRunDetails(runId: string): Observable < RunDetails > {
        return this.http.get("http://5km.5kmrun.bg/user.php?id=" + this.userService.currentUserId)
            .map(response => {

                console.log("get details ...");
                const content = response.text();

                const options = {
                    normalizeWhitespace: true,
                    xmlMode: true
                };

                const webPage = cheerio.load(content, options);
                const rows = webPage(".accordion table tbody tr");

                var result = null

                rows.each((index, elem) => {
                    const cells = elem.children.filter(c => c.type == "tag" && c.name == "td");
                    var rDetails = this.extractRunDetails(cells);

                    if (rDetails != null && rDetails.id == runId && result == null) {
                        result = rDetails.runDetails;
                    }
                });

                return result;
            });
    }

    private extractRunDetails(cells: any): Run {
        const run = new Run(
            this.extractDate(cells[2]),
            this.extractTime(cells[4]),
            this.extractPlace(cells[0]),
            "", "", 0, "", "", ""
        );

        const runDetails = new RunDetails();
        runDetails.eventId = this.extractEventId(cells[1]);
        run.runDetails = runDetails;
        return run;
    }

    private extractEventId(cell: any): string {
        const strMatch = cell.children[0].attribs.href.match(/^results\.php\?event=([0-9]*)$/);
        return strMatch[1];
    }

    private extractRun(cells: any): Run {
        return new Run(
            this.extractDate(cells[1]),
            this.extractTime(cells[3]),
            this.extractPlace(cells[0]),
            this.extractDifferenceToLast(cells[4]),
            this.extractDifferenceToBest(cells[5]),
            this.extractPosition(cells[2]),
            this.extractSpeed(cells[6]),
            this.extractNotes(cells[8]),
            this.extractPage(cells[7])
        );
    }

    private extractDate(cell: any): Date {
        const strMatch = cell.children[0].data.match(/^(\d{1,2})\.(\d{1,2})\.(\d{4})$/);
        return new Date(strMatch[3], strMatch[2] - 1, strMatch[1]);
    }

    private extractPlace(cell: any): string {
        return cell.children[0].data;
    }

    private extractTime(cell: any): string {
        return cell.children[0].data;
    }

    private extractDifferenceToLast(cell: any): string {
        if (cell.children[0].data == null || cell.children[0].data == undefined) {
            return cell.children[0].children[0].data;
        } else {
            return cell.children[0].data;
        }
    }

    private extractPosition(cell: any): number {
        return +cell.children[0].data;
    }

    private extractDifferenceToBest(cell: any): string {
        if (cell.children[0].data == null || cell.children[0].data == undefined) {
            return cell.children[0].children[0].data;
        } else {
            return cell.children[0].data;
        }
    }

    private extractSpeed(cell: any): string {
        var untrimmedSpeed = cell.children[0].data;
        return untrimmedSpeed.substring(0, untrimmedSpeed.length - 5);
    }

    private extractNotes(cell: any): string {
        if (cell.children[0].children[0].data == undefined) {
            return cell.children[0].children[0].children[0].data;
        } else {
            return cell.children[0].children[0].data;
        }
    }

    private extractPage(cell: any): string {
        return cell.children[0].data;
    }
}