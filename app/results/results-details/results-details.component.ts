import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-telerik-ui-pro/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-telerik-ui-pro/sidedrawer/angular";
import { EventService } from "../../services";
import { Event } from "../../models";
import { Observable } from "rxjs/Observable";
import { PageRoute } from "nativescript-angular/router";
import "rxjs/add/operator/switchMap";
import { RouterExtensions } from "nativescript-angular/router";

@Component({
    selector: "ResultsDetails",
    moduleId: module.id,
    templateUrl: "./results-details.component.html"
})
export class ResultsDetailsComponent implements OnInit {
    private id: string;
    private event$: Event;

    constructor(
        private eventService: EventService,
        private pageRoute: PageRoute, 
        private routerExtensions: RouterExtensions) {
        this.pageRoute.activatedRoute
                .switchMap(activatedRoute => activatedRoute.params)
                .forEach((params) => { this.id = params["id"]; });
      
    }

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
        console.log('id: ' + this.id);
        this.eventService.getAllPastEvents()
                .map(events => events.filter(e => e.id == this.id)[0])
                .do(event => this.event$ = event)
                .subscribe();
    }

    onNavBtnTap(): void {
        this.routerExtensions.back();
    }
}
