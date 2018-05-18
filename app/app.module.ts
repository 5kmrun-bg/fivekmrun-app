import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";
import { NativeScriptHttpModule } from "nativescript-angular/http";

import { AppRoutingModule } from "./app-routing.module";
import { AppComponent } from "./app.component";

import { UserService, RunService, NewsService, EventService, StatisticsService } from "./services";
import { AuthenticationGuard, ConnectivityGuard } from "./guards";
import { FabricModule } from 'nativescript-fabric/angular';
import { NativeScriptAnimationsModule } from "nativescript-angular/animations";

@NgModule({
    bootstrap: [
        AppComponent
    ],
    imports: [
        NativeScriptModule,
        NativeScriptHttpModule,
        AppRoutingModule,
        NativeScriptAnimationsModule,
        FabricModule.forRoot()
    ],
    declarations: [
        AppComponent
    ],
    providers: [
        UserService,
        RunService,
        NewsService,
        EventService,
        StatisticsService,
        AuthenticationGuard,
        ConnectivityGuard
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class AppModule { }
