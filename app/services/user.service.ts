import { Injectable } from "@angular/core";
import { Http } from "@angular/http";
import { User } from "../models";
@Injectable()
export class UserService {
    private currentUser: User;
    getCurrentUser(): User {
        this.currentUser = new User("Test name", "", 123);

        return this.currentUser;
    }
}
