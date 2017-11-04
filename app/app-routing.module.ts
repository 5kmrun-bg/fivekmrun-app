import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";
import { AuthenticationGuard, ConnectivityGuard } from "./guards";

const routes: Routes = [
    {
        path: "", canActivate: [AuthenticationGuard], children: [
            { path: "", redirectTo: "/home", pathMatch: "full" },
            { path: "home", loadChildren: "./home/home.module#HomeModule", canActivate: [ConnectivityGuard] },
            { path: "runs", loadChildren: "./runs/runs.module#RunsModule" },
            { path: "runs/:id", loadChildren: "./runs/run-details/run-details.module#RunDetailsModule" },
            { path: "barcode", loadChildren: "./barcode/barcode.module#BarcodeModule" },
            { path: "news", loadChildren: "./news/news-list/news-list.module#NewsListModule", canActivate: [ConnectivityGuard] },
            { path: "future-events", loadChildren: "./future-events/future-events.module#FutureEventsModule", canActivate: [ConnectivityGuard] }
        ]
    },
    {
        path: "login", loadChildren: "./login/login.module#LoginModule", canActivate: [ConnectivityGuard]
    },
    {
        path: "errors/no-internet", loadChildren: "./errors/no-internet.module#NoInternetModule"
    }
];

@NgModule({
    imports: [NativeScriptRouterModule.forRoot(routes)],
    exports: [NativeScriptRouterModule]
})
export class AppRoutingModule { }
