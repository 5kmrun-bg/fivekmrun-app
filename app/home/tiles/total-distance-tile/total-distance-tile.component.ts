import { Component, OnInit, Input } from "@angular/core";

@Component({ 
    selector: "total-distance-tile",
    moduleId: module.id,
    templateUrl: "./total-distance-tile.component.html"
})
export class TotalDistanceTileComponent implements OnInit {
    @Input() distance: string;
    
    ngOnInit(): void {
        console.log('test')
    }
}