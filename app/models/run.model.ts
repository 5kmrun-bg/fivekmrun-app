import { Md5 } from "ts-md5/dist/md5";

export class Run {
    public id: string;

    constructor(
        public date: Date,
        public time: string,
        public place: string,
        public differenceFromPrevious: number,
        public differenceFromBest: number
    ) {
        this.id = Md5.hashStr(date + "#" + time + "#" + place + "#").toString();
    }
}