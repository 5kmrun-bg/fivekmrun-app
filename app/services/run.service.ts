import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";

import { Run } from "../models";
import * as cheerio from "cheerio";

import { UserService } from "../services";

@Injectable()
export class RunService {
    private lastUserId: number;
    private lastRuns: Observable<Run[]>;

    constructor(private http: Http, private userService: UserService) {
    }

    getByCurrentUser(): Observable<Run[]> {
        if (this.lastRuns != null && this.lastUserId == this.userService.currentUserId) {
            return this.lastRuns;
        } else {
            console.log("Getting runs ...");
            const that = this;
            this.lastUserId = this.userService.currentUserId;
            return this.lastRuns = this.http.get("http://5km.5kmrun.bg/stat.php?id=" + this.userService.currentUserId).map(response => {
                const runs: Array<Run> = new Array<Run>();

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

    private extractRun(cells: any): Run {
        return new Run(
            this.extractDate(cells),
            this.extractTime(cells),
            this.extractPlace(cells),
            this.extractDifferenceToLast(cells),
            this.extractDifferenceToBest(cells),
            this.extractPosition(cells),
            this.extractSpeed(cells),
            this.extractNotes(cells),
            this.extractPage(cells)
        );
    }

    private extractDate(cells: any): Date {
        const strMatch = cells[1].children[0].data.match(/^(\d{1,2})\.(\d{1,2})\.(\d{4})$/);
        return new Date(strMatch[3], strMatch[2] - 1, strMatch[1]);
    }

    private extractPlace(cells: any): string {
        return cells[0].children[0].data;
    }

    private extractTime(cells: any): string {
        return cells[3].children[0].data;
    }

    private extractDifferenceToLast(cells: any): string {
        if (cells[4].children[0].data == null || cells[4].children[0].data == undefined) {
            return cells[4].children[0].children[0].data;
        } else {
            return cells[4].children[0].data;
        }
    }

    private extractPosition(cells: any): number {
        return +cells[2].children[0].data;
    }

    private extractDifferenceToBest(cells: any): string {
        if (cells[5].children[0].data == null || cells[5].children[0].data == undefined) {
            return cells[5].children[0].children[0].data;
        } else {
            return cells[5].children[0].data;
        }
    }

    private extractSpeed(cells: any): string {
        return cells[6].children[0].data;
    }

    private extractNotes(cells: any): string {
        if (cells[8].children[0].children[0].data == undefined) {
            return cells[8].children[0].children[0].children[0].data;
        } else {
            return cells[8].children[0].children[0].data;
        }
    }

    private extractPage(cells: any): string {
        return cells[7].children[0].data;
    }
}