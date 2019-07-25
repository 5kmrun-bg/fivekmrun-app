import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { ResultsRoutingModule } from "./results-routing.module";
import { ResultsComponent } from "./results.component";
import { ResultsDetailsModule } from "./results-details/results-details.module";

@NgModule({
    imports: [
        ResultsRoutingModule,
        CommonModule,
        NativeScriptCommonModule,
        ResultsDetailsModule
    ],
    declarations: [
        ResultsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class ResultsModule { }
