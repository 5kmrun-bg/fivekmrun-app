import { HttpClient } from "@angular/common/http";
import { EventEmitter, Injectable } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { User } from "../models";

import * as appSettings from "application-settings";
import * as cheerio from "cheerio";

@Injectable()
export class UserService {
    private currentUser: User;
    private _currentUserId?: number;
    private lastLoadedUser: Observable<User>;
    private lastLoadedUserId: number;

    userChanged: EventEmitter<void> = new EventEmitter();

    constructor(private http: HttpClient) {
        if (appSettings.getNumber("currentUserId") != NaN) {
            this._currentUserId = appSettings.getNumber("currentUserId");
        }
    }

    getCurrentUser(): Observable<User> {
        if (this.lastLoadedUser != null && this.lastLoadedUserId == this.currentUserId) {
            return this.lastLoadedUser;
        } else {
            console.log("Getting user ...");
            this.lastLoadedUserId = this.currentUserId;
            return this.lastLoadedUser = this.http.get(
                "http://5km.5kmrun.bg/usr.php?id=" + this._currentUserId,
                { responseType: "text"}
            ).map(response => {
                const content = response;

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
                const age = this.parseAge(webPage);
                this.currentUser = new User(this._currentUserId, name, avatarUrl, userPoints, runsCount, totalKmRan, age);

                this.userChanged.next();
                return this.currentUser;
            });
        }
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

    private parseAvatarUrl(webPage: any): string {
        return webPage("div.row div figure img").attr("src");
    }

    private parseUserPoints(webPage: any): number {
        return webPage("div.container div.col-sm-9.col-md-9 table tbody").find("td").last().text();
    }

    private parseName(webPage: any): string {
        let title = webPage("h2.article-title").first().text();
        if (title.indexOf("-") > 0) {
            title = title.substr(title.indexOf("-") + 2);
        }
        return title;
    }

    private parseRunsCount(webPage: any): number {
        return webPage("div.col-md-12 h2.article-title span").first().text();
    }

    private parseTotalKmRan(webPage: any): number {
        return webPage("div.col-md-12 h2.article-title span").last().text();
    }

    private parseAge(webPage: any): string {
        return webPage("div.container div.col-sm-9.col-md-9 table tbody").find("td").first().text();
    }
}
