import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";
import { User } from "../models";

import * as cheerio from "cheerio";
import 'rxjs/Rx';

@Injectable()
export class UserService {
    private currentUser: User;
    private webPage: any;
    private name: string;
    private avatarUrl: string;
    private userPoints: number;

    constructor(private http: Http) { }

    getCurrentUser(): Observable<User> {
        const that = this;
        return this.http.get("http://5kmrun.bg/usr.php?id=13731").map(response => {
                const content = response.text();

                const options = {
                    normalizeWhitespace: true,
                    xmlMode: true
                };

                this.webPage = cheerio.load(content, options);


                that.avatarUrl = "http://5kmrun.bg/" + this.webPage("div.row div figure img").attr("src");
                that.userPoints = this.webPage("div.container div.col-sm-9.col-md-9 table tbody").find("td").last().text();
                const title = this.webPage("h2.article-title").first().text();
                that.name = title.substr(title.indexOf("-") + 2);

                that.currentUser = new User(this.name, this.avatarUrl, this.userPoints);

                return that.currentUser;
        });
    }
}
