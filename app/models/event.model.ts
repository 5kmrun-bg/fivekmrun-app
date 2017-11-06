import { Md5 } from "ts-md5/dist/md5";

export class Event {
    public id: string;

    constructor(
        public title: string,
        public date: Date,
        public imageUrl: string,
        public location: string,
        public eventDetailsUrl: string
    ) {
        this.id = Md5.hashStr(date + "#" + location + "#" + title + "#").toString();
    }
}