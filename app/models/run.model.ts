export class Run {
    constructor(
        public id: number,
        public date: Date,
        public time: string,
        public place: string,
        public differenceFromPrevious: number,
        public differenceFromBest: number
    ) {}
}