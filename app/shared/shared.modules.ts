import { NgModule } from "@angular/core";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { NativeScriptFormsModule } from "nativescript-angular/forms";
import { TimeDifferenceColorPipe } from "./time-difference-color.pipe";

@NgModule({
    imports: [
        NativeScriptCommonModule,
        NativeScriptFormsModule,
    ],
    declarations: [
        TimeDifferenceColorPipe,
    ],
    exports: [
        TimeDifferenceColorPipe,
        NativeScriptCommonModule,
        NativeScriptFormsModule,
    ]
})
export class SharedModule { }
