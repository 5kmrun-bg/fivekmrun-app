import { NgModule, NO_ERRORS_SCHEMA } from "@angular/core";
import { CommonModule } from "@angular/common";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { RunsRoutingModule } from "./runs-routing.module";
import { RunsComponent } from "./runs.component";

if (module['hot']) {
    module['hot'].accept();
}

@NgModule({
    imports: [
        RunsRoutingModule,
        CommonModule,
        NativeScriptCommonModule
    ],
    declarations: [
        RunsComponent
    ],
    schemas: [
        NO_ERRORS_SCHEMA
    ]
})
export class RunsModule { }
