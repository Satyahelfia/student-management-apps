export class Project {
    id?: number
    name: string
    pdfName?: string
    imageName?: string
    constructor(name: string, id?: number) {
        this.id = id
        this.name = name
    }
}

