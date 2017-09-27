import { Component, OnInit, ViewChild } from "@angular/core";
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
    
    constructor(private _page: Page, private router: Router, private userService: UserService) {
        this._page.actionBarHidden = true;
        this.userService.currentUserId = undefined;
     }

    ngOnInit(): void {
        const userIdTextField:TextField = <TextField> this._page.getViewById("userId");
        userIdTextField.focus();
    }

    onTap(): void {
        const numUserId = Number(this.userId);

        if (numUserId != NaN) {
            this.userService.currentUserId = numUserId;
            console.log(this.userService.currentUserId);
            this.router.navigate(["/home"]);
        } else {
            // handle error
        }
    }
}