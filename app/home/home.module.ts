import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { HomeRoutingModule } from "./home-routing.module";
import { HomeComponent } from "./home.component";
import { NativeScriptUIGaugesModule } from "nativescript-telerik-ui-pro/gauges/angular";
import { NativeScriptUIChartModule } from "nativescript-telerik-ui-pro/chart/angular";
import { RunDetailsTileComponent, NextMilestoneTileComponent } from "./tiles";

@NgModule({
    imports: [
        NativeScriptModule,
        HomeRoutingModule,
        SharedModule,
        NativeScriptUIGaugesModule,
        NativeScriptUIChartModule
    ],
    declarations: [
        HomeComponent,
        RunDetailsTileComponent,
        NextMilestoneTileComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class HomeModule { }
