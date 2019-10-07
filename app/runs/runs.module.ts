import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { SharedModule } from "../shared/shared.modules";
import { RunDetailsModule } from "./run-details/run-details.module";
import { RunsRoutingModule } from "./runs-routing.module";
import { RunsComponent } from "./runs.component";

@NgModule({
    imports: [
        SharedModule,
        RunsRoutingModule,
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
