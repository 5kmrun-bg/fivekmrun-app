import { Component } from "@angular/core";
import { Http } from "@angular/http";
import { UserService } from "./services";

@Component({
    selector: "ns-app",
    templateUrl: "app.component.html",
    providers: [UserService]
})
export class AppComponent {
    constructor(userService: UserService) {
        console.debug("test");
        userService.getCurrentUser();
    }
}
