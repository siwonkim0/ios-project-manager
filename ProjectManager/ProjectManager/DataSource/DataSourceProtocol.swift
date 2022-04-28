import RxSwift

protocol DataSourceProtocol {
    func fetch() -> Single<[Project]>
    func append(_ project: Project) -> Completable
    func update(_ project: Project) -> Completable
    func delete(_ project: Project) -> Completable
}
