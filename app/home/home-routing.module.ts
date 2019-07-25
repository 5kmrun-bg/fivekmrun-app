import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { HomeComponent } from "./home.component";
import { BarcodeComponent } from "../barcode/barcode.component";

const routes: Routes = [
    { path: "", redirectTo: "default", pathMatch: "full"},
    { path: "default", component: HomeComponent },
    { path: "barcode", component: BarcodeComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class HomeRoutingModule { }
