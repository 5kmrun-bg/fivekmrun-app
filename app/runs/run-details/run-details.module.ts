import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";
import { RunDetailsRoutingModule } from "./run-details-routing.module";
import { RunDetailsComponent } from "./run-details.component";

@NgModule({
    imports: [
        NativeScriptModule,
        RunDetailsRoutingModule
    ],
    declarations: [
        RunDetailsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class RunDetailsModule { }