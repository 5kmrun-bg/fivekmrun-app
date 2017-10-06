import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";
import { NoInternetRoutingModule } from "./no-internet-routing.module";
import { NoInternetComponent } from "./no-internet.component";

@NgModule({
    imports: [
        NativeScriptModule,
        NoInternetRoutingModule
    ],
    declarations: [
        NoInternetComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class NoInternetModule { }
