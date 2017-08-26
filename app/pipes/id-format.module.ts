import { IdFormatPipe } from "./id-format.pipe";
import { NgModule } from "@angular/core";

@NgModule({
    declarations: [IdFormatPipe],
    exports: [IdFormatPipe]
})
export class IdFormatModule { }