import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";
import { AuthenticationGuard } from "./guards";

const routes: Routes = [
    {
        path: "", canActivate: [AuthenticationGuard], children: [
            { path: "", redirectTo: "/home", pathMatch: "full" },
            { path: "home", loadChildren: "./home/home.module#HomeModule" },
            { path: "runs", loadChildren: "./runs/runs.module#RunsModule" },
            { path: "runs/:id", loadChildren: "./runs/run-details/run-details.module#RunDetailsModule" },
            { path: "barcode", loadChildren: "./barcode/barcode.module#BarcodeModule" },
            { path: "settings", loadChildren: "./settings/settings.module#SettingsModule" },
            { path: "news", loadChildren: "./news/news-list/news-list.module#NewsListModule" },
        ]
    },
    {
        path: "login", loadChildren: "./login/login.module#LoginModule"
    }
];

@NgModule({
    imports: [NativeScriptRouterModule.forRoot(routes)],
    exports: [NativeScriptRouterModule]
})
export class AppRoutingModule { }
