import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";

const routes: Routes = [
    { path: "", redirectTo: "/home", pathMatch: "full" },
    { path: "home", loadChildren: "./home/home.module#HomeModule" },
    { path: "runs", loadChildren: "./runs/runs.module#RunsModule" },
    { path: "runs/:id", loadChildren: "./runs/run-details/run-details.module#RunDetailsModule"},
    { path: "barcode", loadChildren: "./barcode/barcode.module#BarcodeModule" },
    { path: "settings", loadChildren: "./settings/settings.module#SettingsModule" },
    { path: "news", loadChildren: "./news/news-list/news-list.module#NewsListModule"},
];

@NgModule({
    imports: [NativeScriptRouterModule.forRoot(routes)],
    exports: [NativeScriptRouterModule]
})
export class AppRoutingModule { }
