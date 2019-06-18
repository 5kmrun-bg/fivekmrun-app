import { Md5 } from "ts-md5/dist/md5";
import { RunDetails } from "./run-details.model";

export class Run {
    public id: string;
    public timeInSeconds: number;
    public runDetails: RunDetails;
    constructor(
        public date: Date,
        public time: string,
        public place: string,
        public differenceFromPrevious: string,
        public differenceFromBest: string,
        public position: number,
        public speed: string,
        public notes: string,
        public pace: string
    ) {
        this.id = Md5.hashStr(date + "#" + time + "#" + place + "#").toString();
        const timeParts = time.split(':');
        this.timeInSeconds = (Number(timeParts[0]) * 60 + Number(timeParts[1]))/60;
    }
}