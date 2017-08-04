import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
const http = require("http");

@Injectable()
export class UserService {
    private currentUser: any;
    constructor() {
        http.request({ url: "http://5kmrun.bg/usr.php?id=13731", method: "GET"}).then(
            (res) => {
                console.log(res);
            }
        );
    }

    getCurrentUser() {
        return this.currentUser;
    }
}
