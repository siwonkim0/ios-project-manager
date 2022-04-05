import Foundation
import RxSwift
import FirebaseFirestore

final class RemoteDataSource: DataSourceProtocol {
    private let db = Firestore.firestore()
    
    func append(_ project: Project) -> Completable {
        return Completable.create { [weak self] completable in
            self?.db.collection("project").document(project.id.uuidString).setData(project.makeEntity()) { err in
                if let err = err {
                    completable(.error(err))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    func delete(_ project: Project) -> Completable {
        return Completable.create { [weak self] completable in
            self?.db.collection("project").document(project.id.uuidString)
                .delete(completion: { err in
                    if let err = err {
                        completable(.error(err))
                    } else {
                        completable(.completed)
                    }
                })
            return Disposables.create()
        }
    }
    
    func update(_ project: Project) -> Completable {
        return Completable.create { [weak self] completable in
            self?.db.collection("project").document(project.id.uuidString).setData(project.makeEntity()) { err in
                if let err = err {
                    completable(.error(err))
                } else {
                    completable(.completed)
                }
            }
            return Disposables.create()
        }
    }
    
    
    func fetch() -> Single<[Project]> {
        return Single.create { single in
            self.db.collection("project").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    single(.failure(err))
                } else {
                    guard let querySnapshot = querySnapshot else {
                        single(.success([]))
                        return
                    }
                    
                    let projects = querySnapshot.documents
                        .compactMap { Project(document: $0.data()) }
                    
                    single(.success(projects))
                }
            }
            return Disposables.create()
        }
    }
}

private extension Project {
    func makeEntity() -> [String: Any] {
        return [
            "id": self.id.uuidString,
            "title": self.title,
            "body": self.body,
            "state": self.state.rawValue,
            "date": self.date
        ]
    }
    
    init?(document: [String: Any]) {
        guard let idString = document["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = document["title"] as? String,
              let body = document["body"] as? String,
              let date = document["date"] as? Timestamp,
              let stateString = document["state"] as? String,
              let state = ProjectState(rawValue: stateString) else {
            return nil
        }
        self.id = id
        self.title = title
        self.body = body
        self.date = date.dateValue()
        self.state = state
    }
}




