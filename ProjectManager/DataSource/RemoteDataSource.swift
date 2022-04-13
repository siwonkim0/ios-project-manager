import Foundation
import RxSwift
import FirebaseFirestore

class RemoteDataSource {
    let dataBase = Firestore.firestore()
    
    func fetch() -> Single<[Project]> {
        return Single.create { single in
            self.dataBase
                .collection("users")
                .getDocuments { snapshot, error in
                if let snapshot = snapshot, error == nil {
                    let projects = snapshot.documents.compactMap { document in
                        Project(document: document.data())
                    }
                    single(.success(projects))
                }
            }
            return Disposables.create()
        }
    }
    
    func append(_ project: Project) {
        dataBase
            .collection("users")
            .document(project.id.description)
            .setData(project.convertToDT())
    }
    
    func update(_ project: Project) {
        dataBase
            .collection("users")
            .document(project.id.description)
            .updateData(project.convertToDT())
    }
    
    func delete(_ project: Project) {
        dataBase
            .collection("users")
            .document(project.id.description)
            .delete()
    }
}
