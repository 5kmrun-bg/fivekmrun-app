import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { HomeComponent } from "./home.component";
import { BarcodeComponent } from "../barcode/barcode.component";
import { SettingsComponent } from "../settings/settings.component";

const routes: Routes = [
    { path: "", redirectTo: "default", pathMatch: "full"},
    { path: "default", component: HomeComponent },
    { path: "barcode", component: BarcodeComponent },
    { path: "settings", component: SettingsComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class HomeRoutingModule { }
