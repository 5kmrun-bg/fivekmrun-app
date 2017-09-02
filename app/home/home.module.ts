import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { HomeRoutingModule } from "./home-routing.module";
import { HomeComponent } from "./home.component";
import { NativeScriptUIGaugesModule } from "nativescript-telerik-ui-pro/gauges/angular";

@NgModule({
    imports: [
        NativeScriptModule,
        HomeRoutingModule,
        SharedModule,
        NativeScriptUIGaugesModule
    ],
    declarations: [
        HomeComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class HomeModule { }
