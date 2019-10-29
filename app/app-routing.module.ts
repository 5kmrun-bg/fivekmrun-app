import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule } from "nativescript-angular/router";
import { AuthenticationGuard, ConnectivityGuard } from "./guards";

const routes: Routes = [
    { path: "", redirectTo: "/tabs/default", pathMatch: "full" },
    {
        path: "login", 
        loadChildren: "./login/login.module#LoginModule",
        canActivate: [ConnectivityGuard]
    },
    {
        path: "barcode",
        loadChildren: "./barcode/barcode.module#BarcodeModule",
        canActivate: [ConnectivityGuard]
    },
    {
        path: "tabs",
        loadChildren: "./tabs/tabs.module#TabsModule",
        canActivate: [AuthenticationGuard, ConnectivityGuard]
    },
    {
        path: "errors/no-internet", 
        loadChildren: "./errors/no-internet.module#NoInternetModule"
    }    
];

@NgModule({
    imports: [NativeScriptRouterModule.forRoot(routes)],
    exports: [NativeScriptRouterModule]
})
export class AppRoutingModule { }
