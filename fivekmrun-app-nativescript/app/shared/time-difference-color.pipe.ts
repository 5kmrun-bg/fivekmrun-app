import { Pipe, PipeTransform } from "@angular/core";

@Pipe({ name: "timeDifferenceColor" })
export class TimeDifferenceColorPipe implements PipeTransform {
    transform(value: string, args: string[]): any {
        let returnClass = "";

        if (!value || value == null || value === undefined) {
            return returnClass;
        }

        if (value.indexOf("-") > -1) {
            returnClass = "color-green";
        }

        if (value.indexOf("+") > -1) {
            returnClass = "color-red";
        }

        return returnClass;
    }
}
