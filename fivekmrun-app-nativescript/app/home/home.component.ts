import { Component, OnInit } from "@angular/core";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";

import { Ratings } from "nativescript-ratings";
import { Page } from "tns-core-modules/ui/page/page";

import { Run, User } from "../models";
import { RunService, UserService } from "../services";

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
        this.runs$ = this.runService.getByCurrentUser();
        this.lastRun$ = this.runs$.pipe(map(runs => runs.reduce((a, b) => a.date > b.date ? a : b)));
        this.bestRun$ = this.runs$.pipe(map(runs => runs.reduce((a, b) => a.timeInSeconds < b.timeInSeconds ? a : b)));

        this.initializeRatingPlugin();
    }

    private initializeRatingPlugin() {
        const ratings = new Ratings({
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
