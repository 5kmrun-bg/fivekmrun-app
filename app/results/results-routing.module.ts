import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { ResultsComponent } from "./results.component";
import { ResultsDetailsComponent } from "./results-details/results-details.component";

const routes: Routes = [
    { path: "", redirectTo: "default"},
    { path: "default", component: ResultsComponent },
    { path: ":id", component: ResultsDetailsComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class ResultsRoutingModule { }
