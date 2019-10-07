import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptRouterModule, NSEmptyOutletComponent } from "nativescript-angular/router";

import { ConnectivityGuard } from "../guards";
import { SharedModule } from "../shared/shared.modules";
import { TabsComponent } from "./tabs.component";

@NgModule({
    imports: [
        SharedModule,
        NativeScriptRouterModule,
        NativeScriptRouterModule.forChild([
            {
                path: "default", component: TabsComponent, children: [

                    {
                        path: "home",
                        outlet: "homeTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../home/home.module#HomeModule",
                        canActivate: [ConnectivityGuard]
                    },
                    {
                        path: "results",
                        outlet: "resultsTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../results/results.module#ResultsModule",
                        canActivate: [ConnectivityGuard]
                    },
                    {
                        path: "runs",
                        outlet: "runsTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../runs/runs.module#RunsModule",
                        canActivate: [ConnectivityGuard]
                    },
                    {
                        path: "future-events",
                        outlet: "eventsTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../future-events/future-events.module#FutureEventsModule",
                        canActivate: [ConnectivityGuard]
                    },
                    {
                        path: "donation",
                        outlet: "donationTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../donation/donation.module#DonationModule",
                        canActivate: [ConnectivityGuard]
                    }
                ]
            }
        ])
    ],
    declarations: [
        TabsComponent
    ],
    providers: [
    ],
    schemas: [NO_ERRORS_SCHEMA]
})
export class TabsModule { }
