import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { StatisticsRoutingModule } from "./statistics-routing.module";
import { StatisticsComponent } from "./statistics.component";

import { NativeScriptUIChartModule } from "nativescript-ui-chart/angular";

@NgModule({
    imports: [
        NativeScriptModule,
        StatisticsRoutingModule,
        SharedModule,
        NativeScriptUIChartModule
    ],
    declarations: [
        StatisticsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class StatisticsModule { }
