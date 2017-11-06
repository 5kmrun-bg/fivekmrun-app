import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { ResultsRoutingModule } from "./results-routing.module";
import { ResultsComponent } from "./results.component";

@NgModule({
    imports: [
        NativeScriptModule,
        ResultsRoutingModule,
        SharedModule
    ],
    declarations: [
        ResultsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class ResultsModule { }
