import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";
import { Event } from "../models";

import * as cheerio from "cheerio";
import 'rxjs/Rx';

@Injectable()
export class EventService {

    constructor(private http: Http) { }

    getAllFutureEvents(): Observable<Event[]> {
        return this.http.get("http://5km.5kmrun.bg/calendar.php")
            .map(response => {
                const events = Array<Event>();
                const content = response.text();

                const options = {
                    normalizeWhitespace: true,
                    xmlMode: true
                };

                const webPage = cheerio.load(content, options);
                const rows = webPage("div#5km table tr td.td_20 a.cal_ev");

                rows.each((index, elem) => {
                    const title = elem.children[1].children[0].data;
                    const link = elem.attribs["href"];
                    const imageUrl = elem.children[3].attribs.src;

                    events.push(new Event(title, title, null, imageUrl, null));
                });

                return events;
            });
    }
}