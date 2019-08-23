import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { NativeScriptFormsModule } from "nativescript-angular/forms"
import { DonationComponent } from "./donation.component";
import { DonationRoutingModule } from "./donation-routing.module";

@NgModule({
    imports: [
        NativeScriptFormsModule,
        CommonModule,
        NativeScriptCommonModule,
        DonationRoutingModule
    ],
    declarations: [
        DonationComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class DonationModule { }
