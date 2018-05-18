import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { SharedModule } from "../shared/shared.module";
import { RunsRoutingModule } from "./runs-routing.module";
import { RunsComponent } from "./runs.component";

@NgModule({
    imports: [
        RunsRoutingModule,
        SharedModule,
        CommonModule,
        NativeScriptCommonModule
    ],
    declarations: [
        RunsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class RunsModule { }
