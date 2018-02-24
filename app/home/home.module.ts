import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { HomeRoutingModule } from "./home-routing.module";
import { HomeComponent } from "./home.component";
import { NativeScriptUIGaugeModule } from "nativescript-ui-gauge/angular";
import { NativeScriptUIChartModule } from "nativescript-ui-chart/angular";
import { RunDetailsTileComponent, NextMilestoneTileComponent, TotalDistanceTileComponent, RunStatsTileComponent } from "./tiles";

@NgModule({
    imports: [
        NativeScriptModule,
        HomeRoutingModule,
        SharedModule,
        NativeScriptUIGaugeModule,
        NativeScriptUIChartModule
    ],
    declarations: [
        HomeComponent,
        RunDetailsTileComponent,
        NextMilestoneTileComponent,
        TotalDistanceTileComponent,
        RunStatsTileComponent

    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class HomeModule { }
