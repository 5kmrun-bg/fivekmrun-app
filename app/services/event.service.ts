import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";
import { Event } from "../models";

import * as cheerio from "cheerio";
import 'rxjs/Rx';

@Injectable()
export class EventService {

    constructor(private http: Http) { }

    getAllPastEvents(): Observable<Event[]> {
        return this.http.get("http://5km.5kmrun.bg/calendar-a.php")
            .map(response => {
                return this.parseEventsResponse(response, 4);
            });
    }

    getAllFutureEvents(): Observable<Event[]> {
        return this.http.get("http://5km.5kmrun.bg/calendar.php")
            .map(response => {
                return this.parseEventsResponse(response);
            });
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
                    let parts = cells[0].children[1].children[0].data.match(/(\d+)/g)
                    date = new Date(parts[2], parts[1] - 1, parts[0]);
                } else {

                    const cell = cells[i].children[1];

                    if (cell && cell.type == "tag" && cell.name == "a") {
                        const title = this.parseTitle(cell);
                        const imageUrl = this.parseImageUrl(cell);
                        const link = cell.attribs["href"];
                        const location = this.parseLocation(cell);

                        events.push(new Event(title, title, date, imageUrl, location));
                    }
                }
            }
        });

        return events;
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