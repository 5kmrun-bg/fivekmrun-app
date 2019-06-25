import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";
import { Event, Result } from "../models";

import * as cheerio from "cheerio";

@Injectable()
export class EventService {

    constructor(private http: Http) { }

    getAllPastEvents(): Observable<Event[]> {
        return this.http.get("http://5km.5kmrun.bg/calendar-a.php")
            .map(response => {
                return this.parseEventsResponse(response, 4);
            });
    }

    getResultsDetailsById(eventId: string): Observable<Result[]> {
        return this.getResultsDetails("http://5km.5kmrun.bg/results.php?event=" + eventId + "&type=1");
    }

    getAllFutureEvents(): Observable<Event[]> {
        return this.http.get("http://5km.5kmrun.bg/calendar.php")
            .map(response => {
                return this.parseEventsResponse(response);
            });
    }

    getResultsDetails(eventDetailUrl: string) : Observable<Result[]> {
        return this.http.get(eventDetailUrl)
            .map(response => {
                return this.parseResultsDetails(response);
            });
    }

    private parseResultsDetails(response: any) : Result[] {
        const results = Array<Result>();
        const content = response.text();

        const options = {
            normalizeWhitespace: true,
            xmlMode: true
        };

        const webPage = cheerio.load(content, options);
        const rows = webPage("div.table-responsive1 table tbody tr")

        rows.each((index, row) => {
            let name: string;
            if (!row.children[5].children[0].data) {
                name = row.children[5].children[0].children[0].data;
            } else {
                name = row.children[5].children[0].data
            }
            const time = row.children[7].children[0].data;
            const position = row.children[1].children[0].data;

            results.push(new Result(name, time, position));
        })

        return results;
    }

    private parseEventsResponse(response: any, topNWeeks: number = 0) : Event[] {
        const events = Array<Event>();
        const content = response.text();

        const options = {
            normalizeWhitespace: true,
            xmlMode: true
        };

        const webPage = cheerio.load(content, options);
        const rows = webPage("div.table-responsive table tr");

        if (topNWeeks > 0) {
            rows.splice(topNWeeks, rows.length-topNWeeks);
        } else {
            rows.splice(-1, 1);
        }

        rows.each((index, row) => {
            const cells = row.children.filter(c => c.type == "tag" && c.name=="td");
            let date: Date;
            for (let i = 0; i < cells.length; ++i) {
                if (i == 0) {
                    if (cells[0].children[1] != undefined) {
                        let parts = cells[0].children[1].children[0].data.match(/(\d+)/g)
                        date = new Date(parts[2], parts[1] - 1, parts[0]);
                    } else {
                        break;
                    }
                } else {
                    this.parseCell(cells[i].children[1], date, events);
                    this.parseCell(cells[i].children[3], date, events);
                }
            }
        });

        return events;
    }

    private parseCell(cell: any, date: Date, events: Array<Event>) {
        if (cell && cell.type == "tag" && cell.name == "a") {
            const title = this.parseTitle(cell);
            const imageUrl = this.parseImageUrl(cell);
            const link = this.parseLink(cell);
            const location = this.parseLocation(cell);

            events.push(new Event(title, date, imageUrl, location, link));
        }
    }

    private parseLink(cell: any) : string {
        let url = cell.attribs["href"];
        if (!url.startsWith("http")) {
            url = "http://5km.5kmrun.bg/" + url;
        }

        return url;
    }

    private parseLocation(cell: any) : string {
        return cell.children[3].children[1].children[0].data;
    }

    private parseImageUrl(cell: any) : string {
        let imageUrl = cell.children[3].attribs.src;
        if (!imageUrl.startsWith("http")) {
            imageUrl = "http://5km.5kmrun.bg/" + imageUrl;
        }

        return imageUrl;
    }

    private parseTitle(cell: any) : string {
        if (cell.children[1].children[0]) {
            return cell.children[1].children[0].data;
        } else {
            return "";
        }
    }
}