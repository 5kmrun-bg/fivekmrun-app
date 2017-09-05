import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { Observable } from "rxjs/Observable";
import { User } from "../models";

import * as cheerio from "cheerio";
import 'rxjs/Rx';
var appSettings = require("application-settings");

@Injectable()
export class UserService {
    private currentUser: User;
    private _currentUserId?: number;

    constructor(private http: Http) {
        if (appSettings.getNumber("currentUserId") != NaN) {
            this._currentUserId = appSettings.getNumber("currentUserId");
        }
     }

    getCurrentUser(): Observable<User> {
        const that = this;

        return this.http.get("http://5kmrun.bg/usr.php?id=" + this._currentUserId).map(response => {
                const content = response.text();

                const options = {
                    normalizeWhitespace: true,
                    xmlMode: true
                };

                const webPage = cheerio.load(content, options);

                const avatarUrl = this.parseAvatarUrl(webPage);
                const userPoints = this.parseUserPoints(webPage);
                const name = this.parseName(webPage);
                const runsCount = this.parseRunsCount(webPage);
                const totalKmRan = this.parseTotalKmRan(webPage);
                that.currentUser = new User(this._currentUserId, name, avatarUrl, userPoints, runsCount, totalKmRan);

                return that.currentUser;
        });
    }

    get currentUserId(): number {
        this._currentUserId = appSettings.getNumber("currentUserId");
        return this._currentUserId ? this._currentUserId : 0;
    }

    set currentUserId(value: number) {
        this._currentUserId = value;

        if (this._currentUserId != undefined) {
        appSettings.setNumber("currentUserId", this._currentUserId);
        } else {
            appSettings.remove("currentUserId");
        }
    }

    isCurrentUserSet(): boolean {
        return this._currentUserId != undefined;
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

    private parseRunsCount(webPage: any) : number {
        return webPage("div.col-md-12 h2.article-title span").first().text();
    }   

    private parseTotalKmRan(webPage: any) : number {
        return webPage("div.col-md-12 h2.article-title span").last().text();
    }
}
