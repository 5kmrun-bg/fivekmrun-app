import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptRouterModule, NSEmptyOutletComponent } from "nativescript-angular/router";
import { NativeScriptCommonModule } from "nativescript-angular/common";

import { TabsComponent } from "./tabs.component";

@NgModule({
    imports: [
        NativeScriptCommonModule,
        NativeScriptRouterModule,
        NativeScriptRouterModule.forChild([
            { path: "", redirectTo:"default", pathMatch: "full" },
            {
                path: "default", component: TabsComponent, children: [
                    {
                        path: "home",
                        outlet: "homeTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../home/home.module#HomeModule",
                    },
                    {
                        path: "results",
                        outlet: "resultsTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../results/results.module#ResultsModule"
                    },
                    {
                        path: "runs",
                        outlet: "runsTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../runs/runs.module#RunsModule"
                    },
                    {
                        path: "future-events",
                        outlet: "eventsTab",
                        component: NSEmptyOutletComponent,
                        loadChildren: "../future-events/future-events.module#FutureEventsModule"
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