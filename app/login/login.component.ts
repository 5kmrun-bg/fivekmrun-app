import { Component, OnInit, ViewChild } from "@angular/core";
import { UserService } from "../services";
import { User } from "../models";
import { Observable } from "rxjs/Observable";
import { EventData } from "data/observable";

@Component({
    selector: "Login",
    moduleId: module.id,
    templateUrl: "./login.component.html"
})
export class LoginComponent implements OnInit {
    public userId = "test";
    
    constructor(private userService: UserService) { }

    ngOnInit(): void {
    }

    onTap(): void {
        console.log(this.userId);
    }
}