import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { SharedModule } from "../shared/shared.modules";
import { NoInternetRoutingModule } from "./no-internet-routing.module";
import { NoInternetComponent } from "./no-internet.component";

@NgModule({
    imports: [
        SharedModule,
        NoInternetRoutingModule,
    ],
    declarations: [
        NoInternetComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class NoInternetModule { }
