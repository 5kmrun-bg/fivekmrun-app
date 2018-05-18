import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { SharedModule } from "../shared/shared.module";
import { FutureEventsRoutingModule } from "./future-events-routing.module";
import { FutureEventsComponent } from "./future-events.component";

@NgModule({
    imports: [
        FutureEventsRoutingModule,
        SharedModule,
        CommonModule,
        NativeScriptCommonModule
    ],
    declarations: [
        FutureEventsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class FutureEventsModule { }
