import { Component, OnInit } from "@angular/core";
import { UserService, RunService } from "../services";
import { User, Run } from "../models";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";

import { Ratings } from "nativescript-ratings";
import { Page } from "tns-core-modules/ui/page/page";

@Component({
    selector: "Home",
    moduleId: module.id,
    templateUrl: "./home.component.html"
})
export class HomeComponent implements OnInit {

    currentUser$: Observable<User>;
    lastRun$: Observable<Run>;
    bestRun$: Observable<Run>;
    runs$: Observable<Run[]>;
    constructor(private userService: UserService, private runService: RunService, private page: Page) {
        this.page.actionBarHidden = true;
     }

    ngOnInit(): void {
        this.currentUser$ = this.userService.getCurrentUser();

        const that = this;
        this.lastRun$ = this.runService.getByCurrentUser().pipe(map(runs => runs.sort((a, b) => { return 0 - (that.getTime(a.date) - that.getTime(b.date));})[0]));
        this.bestRun$ = this.runService.getByCurrentUser().pipe(map(runs => runs.sort((a, b) => { return a.time.localeCompare(b.time);})[0]));
        this.runs$ = this.runService.getByCurrentUser().pipe(map(runs => runs.reverse()));

        this.initializeRatingPlugin();
    }

    private getTime(date?: Date) {
        return date != null ? date.getTime() : 0;
    }

    private initializeRatingPlugin() {
        let ratings = new Ratings({
            id: "bg.5kmpark.5kmrun",
            showOnCount: 5,
            title: "Харесвате ли приложението?",
            text: "Помогнете ни да го направим още по-добро, като оставите вашето мнение",
            agreeButtonText: "Да, разбира се",
            remindButtonText: "Напомни ми по-късно",
            declineButtonText: "Не, благодаря",
            iTunesAppId: "1299888204"
        });

        ratings.init();
        ratings.prompt();
    }
}