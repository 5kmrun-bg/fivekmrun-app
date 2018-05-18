import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { NewsListRoutingModule } from "./news-list-routing.module";
import { NewsListComponent } from "./news-list.component";

@NgModule({
    imports: [
        NewsListRoutingModule,
        CommonModule,
        NativeScriptCommonModule
    ],
    declarations: [
        NewsListComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class NewsListModule { }
