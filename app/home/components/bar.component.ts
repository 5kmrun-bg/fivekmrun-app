import { Component, Input } from "@angular/core";

@Component({
    selector: "bar-component",
    moduleId: module.id,
    templateUrl: "./bar.component.html"
})
export class BarComponent {
    @Input() barTitle: string;
    @Input() barValue: number;
    @Input() barMaximumValue: number;

    get emptyBarWidth(): number {
        if (isNaN(this.barMaximumValue) || isNaN(this.barValue)) {
            return 50;
        }

        return (this.barMaximumValue - this.barValue) * (100 / this.barMaximumValue);
    }
    
    get fullBarWidth(): number {
        if (isNaN(this.barMaximumValue) || isNaN(this.barValue)) {
            return 50;
        }

        return this.barValue * (100 / this.barMaximumValue);
    }
}
