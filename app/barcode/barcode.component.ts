import { Component, OnInit, ViewChild } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { UserService } from "../services/user.service";
import { User } from "../models/user.model";
import { Brightness } from "nativescript-brightness";
import { Page } from "tns-core-modules/ui/page/page";

@Component({
    selector: "Barcode",
    moduleId: module.id,
    templateUrl: "./barcode.component.html",
})
export class BarcodeComponent implements OnInit {
    private brightness: Brightness;
    oldBrightness: number;
    currentUser$: Observable<User>;
 
    constructor(userService: UserService, private page: Page) {
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
}
