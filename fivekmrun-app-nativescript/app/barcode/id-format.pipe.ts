import { Pipe, PipeTransform } from "@angular/core";

@Pipe({ name: "idFormat" })
export class IdFormatPipe implements PipeTransform {
    transform(value: number, args: string[]): any {
        if (!value) { return value; }

        return "*" + this.pad(value, 10) + "*";
    }

    private pad(num: number, size: number): string {
        let s = num + "";
        while (s.length < size) { s = "0" + s; }
        return s;
    }
}
