import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptRouterModule, NSEmptyOutletComponent } from "nativescript-angular/router";
import { NativeScriptCommonModule } from "nativescript-angular/common";

import { TabsComponent } from "./tabs.component";
import { ConnectivityGuard } from "~/guards";

@NgModule({
    imports: [            
        NativeScriptCommonModule,
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