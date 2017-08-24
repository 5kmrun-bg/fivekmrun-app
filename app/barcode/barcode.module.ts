import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { BarcodeRoutingModule } from "./barcode-routing.module";
import { BarcodeComponent } from "./barcode.component";

@NgModule({
    imports: [
        NativeScriptModule,
        BarcodeRoutingModule,
        SharedModule
    ],
    declarations: [
        BarcodeComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class BarcodeModule { }
