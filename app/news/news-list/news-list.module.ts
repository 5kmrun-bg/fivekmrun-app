import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../../shared/shared.module";
import { NewsListRoutingModule } from "./news-list-routing.module";
import { NewsListComponent } from "./news-list.component";

@NgModule({
    imports: [
        NativeScriptModule,
        NewsListRoutingModule,
        SharedModule
    ],
    declarations: [
        NewsListComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class NewsListModule { }
