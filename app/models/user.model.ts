export class User {
    constructor(
        public id: number,
        public name: string,
        public avatarUrl: string,
        public suuntoPoints: number,
        public runsCount: number,
        public totalKmRan: number
    ) { }
}
