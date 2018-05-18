import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { SharedModule } from "../shared/shared.module";
import { HomeRoutingModule } from "./home-routing.module";
import { HomeComponent } from "./home.component";
import { NativeScriptUIGaugeModule } from "nativescript-ui-gauge/angular";
import { NativeScriptUIChartModule } from "nativescript-ui-chart/angular";
import { RunDetailsTileComponent, NextMilestoneTileComponent, TotalDistanceTileComponent, RunStatsTileComponent } from "./tiles";

@NgModule({
    imports: [
        HomeRoutingModule,
        SharedModule,
        NativeScriptUIGaugeModule,
        NativeScriptUIChartModule,
        CommonModule,
        NativeScriptCommonModule
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
