import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptUIGaugeModule } from "nativescript-ui-gauge/angular";
import { SharedModule } from "../../shared/shared.modules";
import { RunDetailsRoutingModule } from "./run-details-routing.module";
import { RunDetailsComponent } from "./run-details.component";

@NgModule({
    imports: [
        SharedModule,
        RunDetailsRoutingModule,
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
