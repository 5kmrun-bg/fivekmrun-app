import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { BarcodeRoutingModule } from "./barcode-routing.module";
import { BarcodeComponent } from "./barcode.component";

import { SharedModule } from "../shared/shared.modules";
import { IdFormatPipe } from "./id-format.pipe";

@NgModule({
    imports: [
        SharedModule,
        BarcodeRoutingModule,
    ],
    declarations: [
        BarcodeComponent,
        IdFormatPipe
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class BarcodeModule { }
