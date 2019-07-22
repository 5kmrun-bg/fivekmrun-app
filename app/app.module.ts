import { CommonModule } from "@angular/common";
import { ErrorHandler, NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { NativeScriptModule } from "nativescript-angular/nativescript.module";
import { NativeScriptHttpClientModule } from "nativescript-angular/http-client";

import { AppRoutingModule } from "./app-routing.module";
import { AppComponent } from "./app.component";

import { NativeScriptAnimationsModule } from "nativescript-angular/animations";
import { AuthenticationGuard, ConnectivityGuard } from "./guards";
import { EventService, NewsService, RunService, StatisticsService, UserService, HttpInterceptorService } from "./services";
import { HTTP_INTERCEPTORS } from "@angular/common/http";

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
        ConnectivityGuard,
        {
            provide: HTTP_INTERCEPTORS,
            useClass: HttpInterceptorService,
            multi: true
        }
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class AppModule { }
