import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { RunsRoutingModule } from "./runs-routing.module";
import { RunsComponent } from "./runs.component";

@NgModule({
    imports: [
        NativeScriptModule,
        RunsRoutingModule,
        SharedModule
    ],
    declarations: [
        RunsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class RunsModule { }
