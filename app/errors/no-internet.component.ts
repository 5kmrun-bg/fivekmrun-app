import { Component, OnInit, ViewChild } from "@angular/core";
import { Router } from "@angular/router";

@Component({
    selector: "NoInternet",
    moduleId: module.id,
    templateUrl: "./no-internet.component.html",
})
export class NoInternetComponent implements OnInit {
    constructor(private router: Router) {

    }

    ngOnInit(): void {
    }

    attemptConnectivity() {
        this.router.navigate(["/"]);
    }
}