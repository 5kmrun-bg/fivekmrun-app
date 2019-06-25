import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { RunDetailsRoutingModule } from "./run-details-routing.module";
import { RunDetailsComponent } from "./run-details.component";
import { TimeDifferenceColorModule } from "../../pipes/time-difference-color.module";
import { NativeScriptUIGaugeModule } from "nativescript-ui-gauge/angular";

@NgModule({
    imports: [
        RunDetailsRoutingModule,
        CommonModule,
        NativeScriptCommonModule,
        TimeDifferenceColorModule,
        NativeScriptUIGaugeModule
    ],
    declarations: [
        RunDetailsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class RunDetailsModule { }