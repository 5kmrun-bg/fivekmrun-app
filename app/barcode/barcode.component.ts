import { Component, OnInit } from "@angular/core";
import { Observable } from "rxjs";
import { UserService } from "../services/user.service";
import { User } from "../models/user.model";
import { Brightness } from "nativescript-brightness";
import { Page } from "tns-core-modules/ui/page/page";
import { RouterExtensions } from "nativescript-angular/router";

@Component({
    selector: "Barcode",
    moduleId: module.id,
    templateUrl: "./barcode.component.html",
})
export class BarcodeComponent implements OnInit {
    private brightness: Brightness;
    oldBrightness: number;
    currentUser$: Observable<User>;
 
    constructor(userService: UserService, private page: Page, private routerExtensions: RouterExtensions) {
        this.brightness = new Brightness();
        this.currentUser$ = userService.getCurrentUser();

        this.oldBrightness = this.brightness.get();
        this.brightness.set({
            intensity: 100
        });
        this.page.on("navigatingFrom", (data) => {
            this.brightness.set({
                intensity: this.oldBrightness
            });
        })
    }

    ngOnInit(): void {   
    }

    onNavBtnTap(): void {
        this.routerExtensions.back();
    }
}
