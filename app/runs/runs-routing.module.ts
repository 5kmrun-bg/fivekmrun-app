import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { RunsComponent } from "./runs.component";
import { RunDetailsComponent } from "./run-details/run-details.component";

const routes: Routes = [
    { path: "", redirectTo: "default", pathMatch: "full"},
    { path: "default", component: RunsComponent },
    { path: ":id", component: RunDetailsComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class RunsRoutingModule { }
