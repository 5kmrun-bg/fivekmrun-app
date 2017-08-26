import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";

import { SharedModule } from "../shared/shared.module";
import { BarcodeRoutingModule } from "./barcode-routing.module";
import { BarcodeComponent } from "./barcode.component";

import { IdFormatModule } from "../pipes/id-format.module";

@NgModule({
    imports: [
        NativeScriptModule,
        BarcodeRoutingModule,
        SharedModule,
        IdFormatModule
    ],
    declarations: [
        BarcodeComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class BarcodeModule { }
