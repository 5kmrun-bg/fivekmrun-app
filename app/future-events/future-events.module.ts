import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { FutureEventsRoutingModule } from "./future-events-routing.module";
import { FutureEventsComponent } from "./future-events.component";

@NgModule({
    imports: [
        NativeScriptModule,
        FutureEventsRoutingModule,
        SharedModule
    ],
    declarations: [
        FutureEventsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class FutureEventsModule { }
