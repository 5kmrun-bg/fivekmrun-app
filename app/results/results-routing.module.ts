import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { ResultsComponent } from "./results.component";

const routes: Routes = [
    { path: "", redirectTo: "default"},
    { path: "default", component: ResultsComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class ResultsRoutingModule { }
