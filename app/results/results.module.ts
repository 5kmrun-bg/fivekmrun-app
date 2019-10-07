import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { SharedModule } from "../shared/shared.modules";
import { ResultsDetailsModule } from "./results-details/results-details.module";
import { ResultsRoutingModule } from "./results-routing.module";
import { ResultsComponent } from "./results.component";

@NgModule({
    imports: [
        SharedModule,
        ResultsRoutingModule,
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
