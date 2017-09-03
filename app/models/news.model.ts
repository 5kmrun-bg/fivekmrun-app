import { Md5 } from "ts-md5/dist/md5";

export class News {
    id: string;

    constructor(
        public title:string,
        public url: string
    ) {
        this.id = Md5.hashStr(title + "#" + url).toString();
    }
}