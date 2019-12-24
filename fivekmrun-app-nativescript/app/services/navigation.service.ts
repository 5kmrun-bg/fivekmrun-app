import { Injectable } from "@angular/core";
import { RouterExtensions } from "nativescript-angular/router";
import { BottomNavigation } from "tns-core-modules/ui/bottom-navigation/bottom-navigation";

@Injectable({
    providedIn: "root"
})
export class NavigationService {
    private bottomNavigation: BottomNavigation;

    constructor(private routerEx: RouterExtensions) {

    }

    initTabView(bottomNavigation: BottomNavigation) {
        this.bottomNavigation = bottomNavigation;
    }

    selectRunsTab() {
        if (this.bottomNavigation) {
            this.bottomNavigation.selectedIndex = 1;
        }
    }

    navigateToRun(id: string) {
        this.routerEx.navigate(
            ["/tabs/default", { outlets: { runsTab: ["runs", id] } }],
            { animated: true }
        );

        this.selectRunsTab();
    }
}
