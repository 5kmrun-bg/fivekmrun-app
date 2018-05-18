import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { ResultsDetailsRoutingModule } from "./results-details-routing.module";
import { ResultsDetailsComponent } from "./results-details.component";

@NgModule({
    imports: [
        ResultsDetailsRoutingModule,
        CommonModule,
        NativeScriptCommonModule
    ],
    declarations: [
        ResultsDetailsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class ResultsDetailsModule { }