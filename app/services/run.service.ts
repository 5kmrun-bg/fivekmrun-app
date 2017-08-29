import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";

import { Run } from "../models";
import * as cheerio from "cheerio";

@Injectable()
export class RunService {
    constructor(private http: Http) { }

    getByUserId(userId: number): Observable<Run[]> {
        const that = this;
        return this.http.get("http://5kmrun.bg/stat.php?id=" + userId).map(response => {
            const runs: Array<Run> = new Array<Run>();

            const content = response.text();

            const options = {
                normalizeWhitespace: true,
                xmlMode: true
            };

            const webPage = cheerio.load(content, options);
            const rows = webPage("table tr");

            rows.each((index, elem) => {
                const cells = elem.children.filter(c => c.type == "tag" && c.name == "td");
                if (cells.length == 8) {
                    runs.push(this.extractRun(cells));
                }
            });

            return runs;
        });
    }

    private extractRun(cells: any): Run {
        return new Run(
            this.extractDate(cells),
            this.extractTime(cells),
            this.extractPlace(cells),
            this.extractDifferenceToLast(cells),
            this.extractDifferenceToBest(cells)
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

    private extractDifferenceToBest(cells: any): string {
        if (cells[5].children[0].data == null || cells[5].children[0].data == undefined) {
            return cells[5].children[0].children[0].data;
        } else {
            return cells[5].children[0].data;
        }
    }
}