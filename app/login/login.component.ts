import { Component, OnInit, ViewChild, ElementRef} from "@angular/core";
import { trigger, state, style, transition, animate } from "@angular/animations";
import { UserService } from "../services";
import { User } from "../models";
import { Observable } from "rxjs/Observable";
import { EventData } from "data/observable";
import { Router } from "@angular/router";
import { Page } from "ui/page";
import { TextField } from "ui/text-field";
import * as firebase from "nativescript-plugin-firebase";

@Component({
    selector: "Login",
    moduleId: module.id,
    templateUrl: "./login.component.html",
    animations: [
        trigger('login', [
            state('hidden', style({
                transform: 'translateX(-800)'
            })),
            state('shown', style({
                transform: 'translateX(0)'
            })),
            transition('hidden => shown', animate('400ms ease-in')),
            transition('shown => hidden', animate('400ms ease-out'))
        ]),
        trigger('confirm', [
            state('hidden', style({
                transform: 'translateX(800)'
            })),
            state('shown', style({
                transform: 'translateX(0)'
            })),
            transition('hidden => shown', animate('400ms ease-in')),
            transition('shown => hidden', animate('400ms ease-out'))
        ])
    ]
})
export class LoginComponent implements OnInit {
    public userId = "";
    public user$: Observable<User>;
    public isProfileLoaded = false;

    @ViewChild("txtUserId") txtUserId: ElementRef;

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

            this.txtUserId.nativeElement.dismissSoftInput();
        } else {
            // handle error
        }
    }

    ngAfterViewInit(): void {
        setTimeout(() => this.txtUserId.nativeElement.focus(), 600);
    }

    goBack(): void {
        this.isProfileLoaded = false;
        this.user$ = null;
        this.userService.currentUserId = undefined;
    }

    next(): void {
        firebase.analytics.logEvent({ key: "login"});
        this.router.navigate([ "/" ]);
    }
}