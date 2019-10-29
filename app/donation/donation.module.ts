import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { SharedModule } from "../shared/shared.modules";
import { DonationRoutingModule } from "./donation-routing.module";
import { DonationComponent } from "./donation.component";

@NgModule({
    imports: [
        SharedModule,
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
