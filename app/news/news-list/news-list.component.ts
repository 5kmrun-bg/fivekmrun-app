import { Component, OnInit, ViewChild } from "@angular/core";
import { Observable } from "rxjs/Observable";
import { NewsService } from "../../services";
import { News } from "../../models";
var utilityModule = require("utils/utils");
import * as app from "application";
import { RadSideDrawer } from "nativescript-ui-sidedrawer";

@Component({
    selector: "NewsList",
    moduleId: module.id,
    templateUrl: "./news-list.component.html"
})
export class NewsListComponent implements OnInit {

    news$: Observable<News[]>;

    constructor(private newsService: NewsService) {}

    ngOnInit(): void {
        this.news$ = this.newsService.getAll();
    }

    openUrl(url: string): void {
        utilityModule.openUrl(url);
    }

    onDrawerButtonTap(): void {
        const sideDrawer = <RadSideDrawer>app.getRootView();
        sideDrawer.showDrawer();
    }
}
