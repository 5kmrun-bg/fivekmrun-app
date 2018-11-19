import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { StatisticsRoutingModule } from "./statistics-routing.module";
import { StatisticsComponent } from "./statistics.component";

import { NativeScriptUIChartModule } from "nativescript-ui-chart/angular";

if (module['hot']) {
    module['hot'].accept();
}

@NgModule({
    imports: [
        StatisticsRoutingModule,
        NativeScriptUIChartModule,
        CommonModule,
        NativeScriptCommonModule
    ],
    declarations: [
        StatisticsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class StatisticsModule { }
