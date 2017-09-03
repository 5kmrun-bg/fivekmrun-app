import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";
import { News } from "../models";

import * as cheerio from "cheerio";
import 'rxjs/Rx';

@Injectable()
export class NewsService {

    constructor(private http: Http) { }

    getAll(): Observable<News[]> {
        return this.http.get("http://info-5kmrun.bg/feed/")
            .map(response => {
                const news = new Array<News>();

                const content = response.text();

                const options = {
                    normalizeWhitespace: true,
                    xmlMode: true
                };

                const rssFeed = cheerio.load(content, options);
                const feedItems = rssFeed("rss channel item");

                feedItems.each((index, elem) => {
                    news.push(this.extractRssItem(elem));
                });

                return news;
            });
    }

    private extractRssItem(elem: any): News {
        const title = elem.children.filter(c => c.name == "title" && c.type == "tag")[0].children[0].data;
        const url = elem.children.filter(c => c.name == "guid" && c.type == "tag")[0].children[0].data;

        return new News(title, url);
    }
}
