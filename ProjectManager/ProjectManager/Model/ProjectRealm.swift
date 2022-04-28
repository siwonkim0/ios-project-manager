import Foundation
import RealmSwift

class ProjectRealm: Object {
    @objc dynamic var id: UUID = UUID()
    @objc dynamic var state: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var deletedAt: Date?
    @objc dynamic var updatedAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension ProjectRealm {
    convenience init?(_ project: Project) {
        self.init()
        self.id = project.id
        self.state = project.state.string
        self.title = project.title
        self.body = project.body
        self.date = project.date
        self.updatedAt = project.updatedAt
    }
}
