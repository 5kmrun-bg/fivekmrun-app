import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { BarcodeRoutingModule } from "./barcode-routing.module";
import { BarcodeComponent } from "./barcode.component";

import { IdFormatModule } from "../pipes/id-format.module";

if (module['hot']) {
    module['hot'].accept();
}

@NgModule({
    imports: [
        BarcodeRoutingModule,
        IdFormatModule,
        CommonModule,
        NativeScriptCommonModule
    ],
    declarations: [
        BarcodeComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class BarcodeModule { }
