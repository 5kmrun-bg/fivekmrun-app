import { NgModule } from "@angular/core";
import { Routes } from "@angular/router";
import { NativeScriptRouterModule, NSEmptyOutletComponent } from "nativescript-angular/router";
import { AuthenticationGuard, ConnectivityGuard } from "./guards";

// const routes: Routes = [
//     {
//         path: "", canActivate: [AuthenticationGuard], children: [
//             { path: "", redirectTo: "/home", pathMatch: "full" },
//             { path: "home/default", loadChildren: "./home/home.module#HomeModule", outlet: "homeTab", component: NSEmptyOutletComponent, canActivate: [ConnectivityGuard] },
//             { path: "runs", loadChildren: "./runs/runs.module#RunsModule", outlet: "runsTab", component: NSEmptyOutletComponent },
//             { path: "future-events", loadChildren: "./future-events/future-events.module#FutureEventsModule", canActivate: [ConnectivityGuard], outlet: "eventsTab", component: NSEmptyOutletComponent},
//             { path: "results", loadChildren: "./results/results.module#ResultsModule", canActivate: [ConnectivityGuard], outlet: "resultsTab", component: NSEmptyOutletComponent},
//         ]
//     },
//     {
//         path: "login", loadChildren: "./login/login.module#LoginModule", canActivate: [ConnectivityGuard]
//     },
//     {
//         path: "errors/no-internet", loadChildren: "./errors/no-internet.module#NoInternetModule"
//     }
// ];

const routes: Routes = [
    { path: "", redirectTo: "/tabs/default", pathMatch: "full" },
    {
        path: "login", 
        loadChildren: "./login/login.module#LoginModule",
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


// const routes: Routes = [
//     {
//         path: "",
//         redirectTo: "/(homeTab:home/default//resultsTab:results/default//runsTab:runs/default//eventsTab:future-events/default)",
//         pathMatch: "full",
//     },
//     {
//         path: "home",
//         component: NSEmptyOutletComponent,
//         loadChildren: "./home/home.module#HomeModule",
//         outlet: "homeTab"
//     },
//     {
//         path: "results",
//         component: NSEmptyOutletComponent,
//         loadChildren: "./results/results.module#ResultsModule",
//         outlet: "resultsTab"
//     },
//     {
//         path: "future-events",
//         component: NSEmptyOutletComponent,
//         loadChildren: "./future-events/future-events.module#FutureEventsModule",
//         outlet: "eventsTab"
//     },
//     {
//         path: "runs",
//         component: NSEmptyOutletComponent,
//         loadChildren: "./runs/runs.module#RunsModule",
//         outlet: "runsTab"
//     }
// ];


@NgModule({
    imports: [NativeScriptRouterModule.forRoot(routes)],
    exports: [NativeScriptRouterModule]
})
export class AppRoutingModule { }
