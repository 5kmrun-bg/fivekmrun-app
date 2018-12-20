import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { RunsComponent } from "./runs.component";

const routes: Routes = [
    { path: "", redirectTo: "default"},
    { path: "default", component: RunsComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class RunsRoutingModule { }
