export class Event {
    constructor(
        public id: string,
        public title: string,
        public date: Date,
        public imageUrl: string,
        public location: string
    )
    {}
}