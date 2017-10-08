import { Component, OnInit, ViewChild, ElementRef } from "@angular/core";
import { UserService } from "../services";
import { User } from "../models";
import { Observable } from "rxjs/Observable";
import { EventData } from "data/observable";
import { Router } from "@angular/router";
import { Page } from "ui/page";
import { TextField } from "ui/text-field";

@Component({
    selector: "Login",
    moduleId: module.id,
    templateUrl: "./login.component.html"
})
export class LoginComponent implements OnInit {
    public userId = "";
    public user$: Observable<User>;
    public isProfileLoaded = false;

    constructor(private _page: Page, private router: Router, private userService: UserService) {
        this._page.actionBarHidden = true;
        this.userService.currentUserId = undefined;
     }

    ngOnInit(): void {
    }

    loadProfile(): void {
        const numUserId = Number(this.userId);

        if (numUserId != NaN) {
            this.userService.currentUserId = numUserId;
            this.user$ = this.userService.getCurrentUser();
            this.isProfileLoaded = true;
        } else {
            // handle error
        }
    }

    goBack(): void {
        this.isProfileLoaded = false;
        this.user$ = null;
        this.userService.currentUserId = undefined;
    }

    next(): void {
        this.router.navigate(["/"]);
    }
}