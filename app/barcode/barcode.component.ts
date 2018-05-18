import { Component, OnInit, ViewChild } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { UserService } from "../services/user.service";
import { User } from "../models/user.model";
import * as app from "application";
import { RadSideDrawer } from "nativescript-ui-sidedrawer";

@Component({
    selector: "Barcode",
    moduleId: module.id,
    templateUrl: "./barcode.component.html",
})
export class BarcodeComponent implements OnInit {

    currentUser$: Observable<User>;

    constructor(userService: UserService) {
        this.currentUser$ = userService.getCurrentUser();
    }

    ngOnInit(): void {
    }

    onDrawerButtonTap(): void {
        const sideDrawer = <RadSideDrawer>app.getRootView();
        sideDrawer.showDrawer();
    }
}
