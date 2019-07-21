import { CommonModule } from "@angular/common";
import { ErrorHandler, NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";
import { NativeScriptHttpClientModule } from "nativescript-angular/http-client";

import { AppRoutingModule } from "./app-routing.module";
import { AppComponent } from "./app.component";

import { NativeScriptAnimationsModule } from "nativescript-angular/animations";
import { AuthenticationGuard, ConnectivityGuard } from "./guards";
import { EventService, NewsService, RunService, StatisticsService, UserService } from "./services";

export class LoggerErrorHandler implements ErrorHandler {
    handleError(error) {
        console.log("### ErrorHandler Error: " + error.toString());
        console.log("### ErrorHandler Stack: " + error.stack);
    }
}

@NgModule({
    bootstrap: [
        AppComponent
    ],
    imports: [
        NativeScriptModule,
        NativeScriptHttpClientModule,
        AppRoutingModule,
        NativeScriptAnimationsModule,
        CommonModule
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
        { provide: ErrorHandler, useClass: LoggerErrorHandler },
        ConnectivityGuard
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class AppModule { }
