import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../../shared/shared.module";
import { NewsDetailsRoutingModule } from "./news-details-routing.module";
import { NewsDetailsComponent } from "./news-details.component";

@NgModule({
    imports: [
        NativeScriptModule,
        NewsDetailsRoutingModule,
        SharedModule
    ],
    declarations: [
        NewsDetailsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class NewsDetailsModule { }
