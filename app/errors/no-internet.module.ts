import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { NoInternetRoutingModule } from "./no-internet-routing.module";
import { NoInternetComponent } from "./no-internet.component";

@NgModule({
    imports: [
        NoInternetRoutingModule,
        NativeScriptCommonModule
    ],
    declarations: [
        NoInternetComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class NoInternetModule { }
