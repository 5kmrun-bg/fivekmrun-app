import { Md5 } from "ts-md5/dist/md5";

export class Run {
    public id: string;
    public timeInSeconds: number;
    constructor(
        public date: Date,
        public time: string,
        public place: string,
        public differenceFromPrevious: string,
        public differenceFromBest: string
    ) {
        this.id = Md5.hashStr(date + "#" + time + "#" + place + "#").toString();
        const timeParts = time.split(':');
        this.timeInSeconds = (Number(timeParts[0]) * 60 + Number(timeParts[1]))/60;
    }
}