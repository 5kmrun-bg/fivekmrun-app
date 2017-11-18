import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { StatisticsRoutingModule } from "./statistics-routing.module";
import { StatisticsComponent } from "./statistics.component";

@NgModule({
    imports: [
        NativeScriptModule,
        StatisticsRoutingModule,
        SharedModule
    ],
    declarations: [
        StatisticsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class StatisticsModule { }
