import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { NoInternetComponent } from "./no-internet.component";

const routes: Routes = [
    { path: "", component: NoInternetComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class NoInternetRoutingModule { }
