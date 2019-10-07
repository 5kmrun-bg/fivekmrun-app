import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { SharedModule } from "../../shared/shared.modules";
import { ResultsDetailsRoutingModule } from "./results-details-routing.module";
import { ResultsDetailsComponent } from "./results-details.component";

@NgModule({
    imports: [
        SharedModule,
        ResultsDetailsRoutingModule,
    ],
    declarations: [
        ResultsDetailsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class ResultsDetailsModule { }
