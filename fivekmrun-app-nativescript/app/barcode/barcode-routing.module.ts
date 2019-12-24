import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { BarcodeComponent } from "./barcode.component";

const routes: Routes = [
    { path: "", component: BarcodeComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class BarcodeRoutingModule { }
