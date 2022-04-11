import Foundation
import FirebaseFirestore

struct Project {
    let id: UUID
    let state: ProjectState
    let title: String
    let body: String
    let date: Date
}

extension Project: Equatable {
    static func ==(lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.body == rhs.body && lhs.date == rhs.date && lhs.state == rhs.state
    }
}

extension Project {
    func convertToDT() -> [String: Any] {
        return ["id": self.id.uuidString,
                "title": self.title,
                "body": self.body,
                "date": self.date,
                "state": self.state.string]
    }
    
    init?(document: [String: Any]) {
        guard let idString = document["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = document["title"] as? String,
              let body = document["body"] as? String,
              let date = document["date"] as? Timestamp,
              let stateString = document["state"] as? String,
              let state = ProjectState(rawValue: stateString)
        else {
            return nil
        }
        
        self.id = id
        self.state = state
        self.title = title
        self.body = body
        self.date = date.dateValue()
    }
}
