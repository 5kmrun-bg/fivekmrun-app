import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { SharedModule } from "../shared/shared.modules";
import { FutureEventsRoutingModule } from "./future-events-routing.module";
import { FutureEventsComponent } from "./future-events.component";

@NgModule({
    imports: [
        SharedModule,
        FutureEventsRoutingModule,
    ],
    declarations: [
        FutureEventsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class FutureEventsModule { }
