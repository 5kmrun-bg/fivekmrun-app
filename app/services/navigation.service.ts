import { TabView } from "tns-core-modules/ui/tab-view";
import { Injectable } from "@angular/core";
import { RouterExtensions } from "nativescript-angular/router";
import { ActivatedRoute } from "@angular/router";

@Injectable({
    providedIn: "root"
})
export class NavigationService {
    private tabView: TabView;

    constructor(private routerEx: RouterExtensions) {

    }

    initTabView(tabView: TabView) {
        this.tabView = tabView;
    }

    selectRunsTab() {
        if (this.tabView) {
            this.tabView.selectedIndex = 1;
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
