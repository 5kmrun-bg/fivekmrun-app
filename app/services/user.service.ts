import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { User } from "../models";

const http = require("http");
const cheerio = require("cheerio");

@Injectable()
export class UserService {
    private currentUser: User;
    constructor() {
        http.request({ url: "http://5kmrun.bg/usr.php?id=13731", method: "GET"}).then(
            (res) => {
                 // const webPage = cheerio.load(res);
                 // console.log(webPage("h2.article-title"));
            }
        );
    }

    getCurrentUser(): User {
        this.currentUser = new User("Test name", "", 123);

        return this.currentUser;
    }
}
