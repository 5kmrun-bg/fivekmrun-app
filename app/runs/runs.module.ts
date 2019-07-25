import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { RunsRoutingModule } from "./runs-routing.module";
import { RunsComponent } from "./runs.component";
import { RunDetailsModule } from "./run-details/run-details.module";

@NgModule({
    imports: [
        RunsRoutingModule,
        CommonModule,
        NativeScriptCommonModule,
        RunDetailsModule
    ],
    declarations: [
        RunsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class RunsModule { }
