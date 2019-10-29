import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptUIChartModule } from "nativescript-ui-chart/angular";
import { NativeScriptUIGaugeModule } from "nativescript-ui-gauge/angular";
import { BarcodeModule } from "../barcode/barcode.module";
import { SharedModule } from "../shared/shared.modules";
import { BarComponent } from "./components/bar.component";
import { HomeRoutingModule } from "./home-routing.module";
import { HomeComponent } from "./home.component";
import {
    BestTimeByRouteComponent, NextMilestoneTileComponent,
    RunDetailsTileComponent, RunsByRouteComponent,
    RunStatsTileComponent, TotalDistanceTileComponent
} from "./tiles";

@NgModule({
    imports: [
        SharedModule,
        HomeRoutingModule,
        NativeScriptUIGaugeModule,
        NativeScriptUIChartModule,
        BarcodeModule,
    ],
    declarations: [
        HomeComponent,
        RunDetailsTileComponent,
        NextMilestoneTileComponent,
        TotalDistanceTileComponent,
        RunStatsTileComponent,
        RunsByRouteComponent,
        BestTimeByRouteComponent,
        BarComponent

    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class HomeModule { }
