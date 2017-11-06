import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";
import { ResultsDetailsRoutingModule } from "./results-details-routing.module";
import { ResultsDetailsComponent } from "./results-details.component";

@NgModule({
    imports: [
        NativeScriptModule,
        ResultsDetailsRoutingModule
    ],
    declarations: [
        ResultsDetailsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class ResultsDetailsModule { }