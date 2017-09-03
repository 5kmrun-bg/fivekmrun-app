import { Component, OnInit, ViewChild } from "@angular/core";
import { DrawerTransitionBase, SlideInOnTopTransition } from "nativescript-telerik-ui/sidedrawer";
import { RadSideDrawerComponent } from "nativescript-telerik-ui/sidedrawer/angular";
import { PageRoute } from "nativescript-angular/router";
import { NewsService } from "../../services";
import { News } from "../../models";
import { Observable } from "rxjs/Observable";
import { WebView } from "ui/web-view";
import { StackLayout } from "ui/layouts/stack-layout";

@Component({
    selector: "NewsDetails",
    moduleId: module.id,
    templateUrl: "./news-details.component.html"
})
export class NewsDetailsComponent implements OnInit {

    private _sideDrawerTransition: DrawerTransitionBase;
    private id: string;
    private news$: Observable<News>;
    private webViewSrc: Observable<string>;

    constructor(private newsService: NewsService, private pageRoute: PageRoute) {
        this.pageRoute.activatedRoute
                .switchMap(activatedRoute => activatedRoute.params)
                .forEach((params) => { this.id = params["id"]; });;

        this.webViewSrc = Observable.from("http://5kmrun.bg");
    }

    ngOnInit(): void {
        const that = this;

        this.webViewSrc = this.newsService.getAll().map(newsList => {
            const news =  newsList.filter(n => n.id == that.id)[0];

            return news.url;
        });
    }
}
