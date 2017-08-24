import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";
import { User } from "../models";

import * as cheerio from "cheerio";
import 'rxjs/Rx';

@Injectable()
export class UserService {
    private currentUser: User;

    constructor(private http: Http) { }

    getCurrentUser(): Observable<User> {
        const that = this;
        return this.http.get("http://5kmrun.bg/usr.php?id=13731").map(response => {
                const content = response.text();

                const options = {
                    normalizeWhitespace: true,
                    xmlMode: true
                };

                const webPage = cheerio.load(content, options);

                const avatarUrl = this.parseAvatarUrl(webPage);
                const userPoints = this.parseUserPoints(webPage);
                const name = this.parseName(webPage);

                that.currentUser = new User(name, avatarUrl, userPoints);

                return that.currentUser;
        });
    }

    private parseAvatarUrl(webPage: any) : string {
        return "http://5kmrun.bg/" + webPage("div.row div figure img").attr("src");
    }

    private parseUserPoints(webPage: any) : number {
        return webPage("div.container div.col-sm-9.col-md-9 table tbody").find("td").last().text();
    }

    private parseName(webPage: any) : string {
        const title = webPage("h2.article-title").first().text();
        return title.substr(title.indexOf("-") + 2);
    }

}
