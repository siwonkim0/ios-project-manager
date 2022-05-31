import Foundation
import FirebaseFirestore

struct Project {
    let id: UUID
    let state: ProjectState
    let title: String
    let body: String
    let date: Date
    var deletedAt: Date? = nil
    var updatedAt: Date = Date()
}

extension Project: Equatable {
    static func ==(lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.body == rhs.body && lhs.date == rhs.date && lhs.state == rhs.state && lhs.deletedAt == rhs.deletedAt && lhs.updatedAt == rhs.updatedAt
    }
}

extension Project {
    func convertToDTO() -> [String: Any] {
        return ["id": self.id.uuidString,
                "title": self.title,
                "body": self.body,
                "date": self.date,
                "state": self.state.string,
                "updatedAt": self.updatedAt,
                "deletedAt": self.deletedAt
        ]
    }
    
    init?(document: [String: Any]) {
        guard let idString = document["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = document["title"] as? String,
              let body = document["body"] as? String,
              let date = document["date"] as? Timestamp,
              let stateString = document["state"] as? String,
              let state = ProjectState(rawValue: stateString),
              let updatedAt = document["updatedAt"] as? Timestamp
        else {
            return nil
        }
        
        self.id = id
        self.state = state
        self.title = title
        self.body = body
        self.date = date.dateValue()
        self.updatedAt = updatedAt.dateValue()
    }
}

extension Project {
    init(projectRealm: ProjectRealm) {
        self.id = projectRealm.id
        self.state = ProjectState(rawValue: projectRealm.state)!
        self.title = projectRealm.title
        self.body = projectRealm.body
        self.date = projectRealm.date
        self.deletedAt = projectRealm.deletedAt
        self.updatedAt = projectRealm.updatedAt
    }
}
