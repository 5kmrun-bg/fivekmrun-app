import { Injectable } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs/Observable";
import { News } from "../models";

import * as cheerio from "cheerio";

@Injectable()
export class NewsService {
    private lastNews: Observable<News[]>;

    constructor(private http: HttpClient) { }

    getAll(): Observable<News[]> {
        if (this.lastNews != null) {
            return this.lastNews;
        } else {
            return this.lastNews = this.http.get("http://info-5kmrun.bg/feed/", { responseType: "text" })
                .map(response => {
                    const news = new Array<News>();

                    const content = response;

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
    }

    private extractRssItem(elem: any): News {
        const title = elem.children.filter(c => c.name == "title" && c.type == "tag")[0].children[0].data;
        const url = elem.children.filter(c => c.name == "guid" && c.type == "tag")[0].children[0].data;
        const description = this.sanitizeDescription(elem.children.filter(c => c.name == "description" && c.type == "tag")[0].children[0].children[0].data);

        return new News(title, url, description);
    }

    private sanitizeDescription(description: string): string {
        return description.substring(0, description.lastIndexOf("[...]") + 5);
    }
}
