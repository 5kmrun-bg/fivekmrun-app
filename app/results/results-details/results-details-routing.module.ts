import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { ResultsDetailsComponent } from "./results-details.component";

const routes: Routes = [
    { path: "", component: ResultsDetailsComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class ResultsDetailsRoutingModule { }
