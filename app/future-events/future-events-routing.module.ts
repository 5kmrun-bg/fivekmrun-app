import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

import { FutureEventsComponent } from "./future-events.component";

const routes: Routes = [
    { path: "", redirectTo: "default"},
    { path: "default", component: FutureEventsComponent }
];

@NgModule({
    imports: [NativeScriptRouterModule.forChild(routes)],
    exports: [NativeScriptRouterModule]
})
export class FutureEventsRoutingModule { }
