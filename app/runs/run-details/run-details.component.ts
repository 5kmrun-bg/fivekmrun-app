import { Component, OnInit } from "@angular/core";
import { RunService, EventService } from "../../services";
import { Run, Result, RunDetails } from "../../models";
import { PageRoute } from "nativescript-angular/router";
import "rxjs/add/operator/switchMap";
import {RouterExtensions} from "nativescript-angular/router";
import { Observable } from "rxjs/Observable";

@Component({
    selector: "RunsDetails",
    moduleId: module.id,
    templateUrl: "./run-details.component.html"
})
export class RunDetailsComponent implements OnInit {
    id: string;
    run: Run;
    runDetails$: Observable<RunDetails>;
    results$: Observable<Result[]>;

    constructor(
        private runService: RunService, 
        private eventService: EventService,
        private pageRoute: PageRoute, 
        private routerExtensions: RouterExtensions) {
        this.pageRoute.activatedRoute
                .switchMap(activatedRoute => activatedRoute.params)
                .forEach((params) => { this.id = params["id"]; });

        this.runService.getByCurrentUser()
                        .map(runs => runs.filter(r => r.id == this.id)[0])
                        .do(run$ => {
                            this.run = run$;                        
                        })
                        .subscribe();
        
        this.runService.getRunDetails(this.id)
                        .do(rDetails => this.results$ = this.eventService.getResultsDetailsById(rDetails.eventId)).subscribe();
    }

    /* ***********************************************************
    * Use the sideDrawerTransition property to change the open/close animation of the drawer.
    *************************************************************/
    ngOnInit(): void {
    }

    onNavBtnTap(): void {
        this.routerExtensions.back();
    }
}
