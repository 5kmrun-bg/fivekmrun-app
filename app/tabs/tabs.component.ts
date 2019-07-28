import { Component, ViewChild, AfterViewInit, ElementRef, OnInit, NgZone } from "@angular/core";
import { RouterExtensions } from "nativescript-angular/router";
import { ActivatedRoute } from "@angular/router";
import { NavigationService } from "../services/navigation.service";
import { BottomNavigation, SelectedIndexChangedEventData } from "tns-core-modules/ui/bottom-navigation";
import { EventData } from "tns-core-modules/data/observable";
import { Color } from "tns-core-modules/color/color";

@Component({
    moduleId: module.id,
    selector: "tabs-page",
    templateUrl: "./tabs.component.html"
})
export class TabsComponent implements OnInit, AfterViewInit {
    @ViewChild("tabView", { static: true })
    tabElementRef: ElementRef<BottomNavigation>;
    selectedIndex: number = 1;

    constructor(
        private routerExtension: RouterExtensions,
        private activeRoute: ActivatedRoute,
        private navService: NavigationService,
        private _zone: NgZone
    ) {
    }

    ngOnInit() {
        this.routerExtension.navigate([{
            outlets: {
                homeTab: ["home"],
                runsTab: ["runs"],
                eventsTab: ["future-events"],
                resultsTab: ["results"]
            }
        }], { relativeTo: this.activeRoute });
    }

    onBottomNavLoaded(args: EventData) {
        // Using the loaded event to ger a reference to the BottomNavigation
        const bottomNavigation = args.object as BottomNavigation;

        // Using selectedIndexChanged
        bottomNavigation.on(BottomNavigation.selectedIndexChangedEvent, (data: SelectedIndexChangedEventData) => {
            bottomNavigation.tabStrip.items[data.newIndex].color = new Color("#fb5a2e");
            bottomNavigation.tabStrip.items[data.oldIndex].color = new Color("#787878");
        });
    }

    ngAfterViewInit() {
        this.navService.initTabView(this.tabElementRef.nativeElement);
    }
}
