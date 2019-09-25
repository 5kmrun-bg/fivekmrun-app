import { NgModule } from "@angular/core";
import { NativeScriptCommonModule } from "nativescript-angular/common";
import { NativeScriptFormsModule } from "nativescript-angular/forms";
import { TimeDifferenceColorPipe } from "./time-difference-color.pipe";
import { TimeMinutesPipe } from "./time-minutes.pipe";

@NgModule({
    imports: [
        NativeScriptCommonModule,
        NativeScriptFormsModule,
    ],
    declarations: [
        TimeDifferenceColorPipe,
        TimeMinutesPipe,
    ],
    exports: [
        TimeDifferenceColorPipe,
        TimeMinutesPipe,
        NativeScriptCommonModule,
        NativeScriptFormsModule,
    ]
})
export class SharedModule { }
