import { Component, Input } from "@angular/core";
import { Run } from "../../../models";
import { NavigationService } from "../../../services";
import { ActivatedRoute } from "@angular/router";

@Component({
    selector: "run-details-tile",
    moduleId: module.id,
    templateUrl: "./run-details-tile.component.html"
})
export class RunDetailsTileComponent {
    @Input() run: Run;
    @Input() title: string;
    @Input() col: number;
    @Input() row: number;

    constructor(private navService: NavigationService) {
    }

    navigateToRun() {
        if (!this.run) {
            return;
        }

        this.navService.navigateToRun(this.run.id);
    }
}
