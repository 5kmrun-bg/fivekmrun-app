import { Component, OnInit, Input } from "@angular/core";

@Component({ 
    selector: "bar-component",
    moduleId: module.id,
    templateUrl: "./bar.component.html"
})
export class BarComponent implements OnInit {
    @Input() barTitle: string;
    @Input() barValue: number;
    @Input() barMaximumValue: number;

    emptyBarWidth: number;
    fullBarWidth: number;

    ngOnInit(): void {
        this.fullBarWidth = this.barValue * (100 / this.barMaximumValue);
        this.emptyBarWidth = (this.barMaximumValue - this.barValue) * (100 / this.barMaximumValue);
    }
}