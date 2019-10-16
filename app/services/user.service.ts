import { HttpClient } from "@angular/common/http";
import { EventEmitter, Injectable } from "@angular/core";
import { Observable, ReplaySubject } from "rxjs";
import { User } from "../models";

import * as appSettings from "application-settings";
import * as cheerio from "cheerio";
import { map } from "rxjs/operators";
import { ConstantsService } from "../services";

@Injectable()
export class UserService {
    userChanged: EventEmitter<void> = new EventEmitter();

    private _currentUserId?: number;
    private lastLoadedUser$: ReplaySubject<User> = new ReplaySubject(1);
    private lastLoadedUserId: number;

    constructor(private http: HttpClient, private constantsService: ConstantsService) {
        if (appSettings.getNumber("currentUserId")) {
            this._currentUserId = appSettings.getNumber("currentUserId");
        }
    }

    getCurrentUser(): Observable<User> {
        if (this.lastLoadedUserId !== this.currentUserId) {
            console.log("Getting user ...");
            this.lastLoadedUserId = this.currentUserId;
            this.http.get(
                this.constantsService.userUrl + this._currentUserId,
                { responseType: "text" })
                .pipe(
                    map(response => {
                        const content = response;

                        const options = {
                            normalizeWhitespace: true,
                            xmlMode: true
                        };

                        const webPage = cheerio.load(content, options);

                        const avatarUrl = this.parseAvatarUrl(webPage).replace("http://5kmrun.bg/", "http://old.5kmrun.bg/");
                        console.log("AVATAR URL: " + avatarUrl);
                        const userPoints = this.parseUserPoints(webPage);
                        const name = this.parseName(webPage);
                        const runsCount = this.parseRunsCount(webPage);
                        const totalKmRan = this.parseTotalKmRan(webPage);
                        const age = this.parseAge(webPage);
                        return new User(this._currentUserId, name, avatarUrl, userPoints, runsCount, totalKmRan, age);
                    })
                ).subscribe((user: User) => {
                    this.lastLoadedUser$.next(user);
                    this.userChanged.next();
                });
        }

        return this.lastLoadedUser$;
    }

    get currentUserId(): number {
        this._currentUserId = appSettings.getNumber("currentUserId");
        return this._currentUserId ? this._currentUserId : 0;
    }

    set currentUserId(value: number) {
        this._currentUserId = value;

        if (this._currentUserId) {
            appSettings.setNumber("currentUserId", this._currentUserId);
        } else {
            appSettings.remove("currentUserId");
        }
    }

    isCurrentUserSet(): boolean {
        return !!this._currentUserId;
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
