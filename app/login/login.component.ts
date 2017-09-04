import { Component, OnInit, ViewChild } from "@angular/core";
import { UserService } from "../services";
import { User } from "../models";
import { Observable } from "rxjs/Observable";

@Component({
    selector: "Login",
    moduleId: module.id,
    templateUrl: "./login.component.html"
})
export class LoginComponent implements OnInit {

    constructor(private userService: UserService) { }

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
    }
}