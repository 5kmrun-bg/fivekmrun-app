import { Injectable } from "@angular/core";
import { Router, CanActivate } from "@angular/router";
import { UserService } from "../services";

@Injectable()
export class AuthenticationGuard implements CanActivate {
    constructor(private router: Router, private userService: UserService) {}

    canActivate() {
        console.log("Checking user ...");
        if (this.userService.isCurrentUserSet()) {
            return true;
        } else {
            this.router.navigate(["/login"]);
            return false;
        }
    }
}