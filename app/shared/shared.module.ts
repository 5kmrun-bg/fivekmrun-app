import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { NativeScriptUISideDrawerModule } from "nativescript-ui-sidedrawer/angular";

import { MyDrawerComponent } from "./my-drawer/my-drawer.component";

@NgModule({
    imports: [
        NativeScriptUISideDrawerModule,
        CommonModule,
        NativeScriptCommonModule
    ],
    declarations: [
        MyDrawerComponent
    ],
    exports: [
        MyDrawerComponent,
        NativeScriptUISideDrawerModule
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class SharedModule { }
